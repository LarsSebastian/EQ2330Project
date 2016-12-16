% Part 1 (Intra Mode) and Part 2 (Conditional Replenishment) of Project 3
% EQ2330 Image and Video Processing
% Fall Term 2016, KTH
% Authors: Jan Zimmermann, Lars Kuger

%%
clear all;
clc;
%% load video

%file_name = 'mother-daughter_qcif.yuv';
file_name = 'foreman_qcif.yuv';
frame_size = [176 144]; %taken from example 

V = yuv_import_y(file_name,frame_size,50);

delta = [2^3, 2^4, 2^5, 2^6]; % quantization steps
%delta = 2^4;


%% start with intra frame coding
%seperate all frames into blocks of 16 then blocks of 8, apply dct2 and quantization

%Initialize all Matrices

Vblk16 = cell(length(V), 1);

blocks = cell(length(delta), length(V));


for quantStep = 1:length(delta)  % loop over step sizes of quantizer
    for nframe = 1:length(V) % loop over all frames
        nframe
        
        %divide each frame into blocks of 16x16
        Vblk16{nframe} = mat2cell(V{nframe}, repmat(16, 1, frame_size(2)/16), ...
            repmat(16, 1, frame_size(1)/16)); 
        
        % how many 16x16 block fit into one frame
        [M,N] = size(Vblk16{nframe}); 
        
        for ii = 1:M
            for jj =1:N
                blocks{quantStep,nframe}{ii,jj}.imgData = Vblk16{nframe}{ii,jj};
                % Apply DCT transform and quantize
                [blocks{quantStep,nframe}{ii,jj}.DCT, blocks{quantStep,nframe}{ii,jj}.quantDCT, ...
                    blocks{quantStep,nframe}{ii,jj}.MSE] = ...
                    encode_intraframe2(blocks{quantStep,nframe}{ii,jj}.imgData, delta(quantStep));
            end
        end

    end
end

%% PSNR and rate calculation

% codebooks for each coefficients for each quantizer step size
codebooks(256,numel(delta)).codewords = [];
codebooks(256,numel(delta)).codelength = [];
codebooks(256,numel(delta)).entropy = [];

coefVec = zeros(256, numel(delta), 50*frame_size(1)*frame_size(2)/16^2 );

% averaged MSE
MSEfinal    = zeros(1,numel(delta));

% For each quantization level, take all coefficients at a certain position
% Then calculate the entropy for this i-th coefficient
for quantStep=1:numel(delta)    % loop through all quantization steps
    idx = 1;
    for nframe = 1:length(V) % loop over all frames
        for nrow = 1:M
            for ncol = 1:N
                % loop through all coefficients of a 16x16
                for coefIdx = 1:16^2          
                    coefVec(coefIdx, quantStep, idx) = ...
                        blocks{quantStep, nframe}{nrow,ncol}.quantDCT(coefIdx);
                end
                idx = idx +1;
            end
        end
        
        b = [blocks{quantStep,nframe}{:,:}];
        MSEfinal(quantStep) = mean([b.MSE]);
    end
end

Ratefinal = zeros(1,numel(delta));

for quantStep = 1:numel(delta)
    for coefIdx = 1:256
         % Generate VLC for a set of i-th coefficients
         [ codebooks(coefIdx, quantStep).codewords, ...
          codebooks(coefIdx, quantStep).codelength, ...
          codebooks(coefIdx, quantStep).entropy] = ...
                                        jzlk_generateCode(coefVec(coefIdx,quantStep,:));
    end
    Ratefinal(quantStep) = mean([codebooks(:,quantStep).entropy]);
end
        
Ratekbps = Ratefinal.*30*frame_size(1)*frame_size(2)/1000;

PSNR = 10*log10(255^2./MSEfinal);


%% Plot PSNR vs Rate in kbits/sec

figure;
plot(Ratekbps, PSNR, 'LineWidth', 2);
grid on;
hold on
xlabel('Rate [kbps]');
ylabel('PSNR [dB]');


%% Start with conditional replenishment



%% Calculation of Lagrangian cost function


for quantStep = 1:length(delta)  % loop over step sizes of quantizer
    
    % lambda for cost function according to instructions
    lambda = 0.2*delta(quantStep)^2;
    
    % send first frame in intra mode 
    nframe = 1
    % loop over all 16x16 blocks
    for ii = 1:M
        for jj =1:N
            % we already calculatd this before
            DCTCoef = blocks{quantStep,nframe}{ii,jj}.quantDCT; 
            Dist_intra = blocks{quantStep,nframe}{ii,jj}.MSE;
            
            % add 1/16^2 to the rate in bits/pixel. This is equivalent to
            % adding 1 bit per block for mode indication
            R_intra = jzlk_getRateStruct(DCTCoef, codebooks, quantStep);
            R_intra = R_intra + 1/16^2;  
             
            % save the sent coefficients
            blocks{quantStep,nframe}{ii,jj}.quantDCT_CR = DCTCoef;
            blocks{quantStep,nframe}{ii,jj}.decision = 1;
            blocks{quantStep,nframe}{ii,jj}.R = R_intra; 
            blocks{quantStep,nframe}{ii,jj}.MSE_CR = Dist_intra;
        end
    end
    
       
    for nframe = 2:length(V) % loop over all frames, comparison between two frames: -1
        nframe
        
        M = size(V{nframe},1)/16;
        N = size(V{nframe},2)/16;
        
        
        % loop over all 16x16 blocks
        for ii = 1:M
            for jj =1:N
                
                % we already calculatd these before
                DCTCoef = blocks{quantStep,nframe}{ii,jj}.quantDCT; 
                Dist_intra = blocks{quantStep,nframe}{ii,jj}.MSE;
                
                R_intra = jzlk_getRateStruct(DCTCoef, codebooks, quantStep);
                R_intra = R_intra + 1/16^2;  % this means 1 bit per block
                
                % Calculate the distortion between the previously sent
                % coefficients and the UNquantized DCT coefficients of the
                % current frame
                framePrevSent = blocks{quantStep,nframe-1}{ii,jj}.quantDCT_CR;
                frameCur = blocks{quantStep,nframe}{ii,jj}.DCT;
                Dist_copy = sum(abs(framePrevSent(:)-frameCur(:)).^2)/16^2;
                
                % rate for copy mode is only 1 bit per block for indication
                R_copy = 1/16^2;
                
                % calculate cost functions
                J_intra = Dist_intra + lambda*R_intra;
                J_copy = Dist_copy + lambda*R_copy;
                
                % compare cost functions and decide on mode
                if J_intra < J_copy
                    blocks{quantStep,nframe}{ii,jj}.quantDCT_CR = DCTCoef;
                    blocks{quantStep,nframe}{ii,jj}.decision = 1;
                    blocks{quantStep,nframe}{ii,jj}.R = R_intra; 
                    blocks{quantStep,nframe}{ii,jj}.MSE_CR = Dist_intra;
                else
                    blocks{quantStep,nframe}{ii,jj}.quantDCT_CR = ...
                        blocks{quantStep,nframe-1}{ii,jj}.quantDCT_CR;
                    blocks{quantStep,nframe}{ii,jj}.decision = 2;
                    blocks{quantStep,nframe}{ii,jj}.R = R_copy; 
                    blocks{quantStep,nframe}{ii,jj}.MSE_CR = Dist_copy;
                end
                
                
            end
        end
        
    end
   
end



% calculate rate and PSNR
Rfinal_CR = zeros(1,numel(delta));
MSEfinal_CR = zeros(1,numel(delta));
for quantStep=1:numel(delta)
    for nframe=1:numel(V)
        curBlock = [blocks{quantStep, nframe}{:,:}];
        Rfinal_CR(quantStep) = Rfinal_CR(quantStep) + ...
            mean([curBlock.R]) / numel(V);
        MSEfinal_CR(quantStep) = MSEfinal_CR(quantStep) + ...
            mean([curBlock.MSE_CR]) / numel(V);
    end
end

R_CRkbps = Rfinal_CR.*30*frame_size(1)*frame_size(2)/1000;
PSNR_CR = 10*log10(255^2./MSEfinal_CR);

%% plot

figure(1);
plot(R_CRkbps, PSNR_CR, 'r', 'LineWidth', 2);
legend('Intra Mode', 'Conditional Replenishment Mode',...
    'Location', 'northwest');
