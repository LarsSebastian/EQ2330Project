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

delta = [2^3, 2^4, 2^5, 2^6]; % quantization steps
%delta = 2^4;

V = yuv_import_y(file_name,frame_size,50);
Vreceived_Intra = cell(numel(delta),50);
Vreceived_CR = cell(numel(delta),50);
Vreceived_Inter = cell(numel(delta),50);
Vrec_Inter_Frame = cell(numel(delta),50);


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
                    blocks{quantStep,nframe}{ii,jj}.MSEIntra] = ...
                    encode_intraframe2(blocks{quantStep,nframe}{ii,jj}.imgData, delta(quantStep));
                
                Vreceived_Intra{quantStep,nframe}{ii,jj} = ...
                    decode_intraframe2(blocks{quantStep,nframe}{ii,jj}.quantDCT);
            end
        end
        Vreceived_Intra{quantStep,nframe} = cell2mat(Vreceived_Intra{quantStep,nframe});
    end
end

%% PSNR and rate calculation for pure Intra Mode


[codebooks, Ratefinal, MSEfinal] = jzlk_getCodebooks(blocks, 'quantDCT', 'MSEIntra');
        
Ratekbps_Intra = Ratefinal.*30*frame_size(1)*frame_size(2)/1000;

PSNR_Intra = 10*log10(255^2./MSEfinal);


% Plot PSNR vs Rate in kbits/sec
figure;
plot(Ratekbps_Intra, PSNR_Intra, 'LineWidth', 2);
grid on;
hold on
xlabel('Rate [kbps]');
ylabel('PSNR [dB]');


%% Start with conditional replenishment
% Calculation of Lagrangian cost function


for quantStep = 1:length(delta)  % loop over step sizes of quantizer
    
    % lambda for cost function according to instructions
    lambda = 0.2*delta(quantStep)^2;
    
    for nframe = 1:length(V) % loop over all frames, comparison between two frames: -1
        nframe
        
        M = size(V{nframe},1)/16;
        N = size(V{nframe},2)/16;
        
        % loop over all 16x16 blocks
        for ii = 1:M
            for jj =1:N
                
                % we already calculatd these before
                DCTCoef = blocks{quantStep,nframe}{ii,jj}.quantDCT; 
                Dist_intra = blocks{quantStep,nframe}{ii,jj}.MSEIntra;
                
                R_intra = jzlk_getRateStruct(DCTCoef, codebooks, quantStep);
                R_intra = R_intra + 1/16^2;  % this means 1 bit per block
                
                if nframe==1
                    % the first frame has to be transmitted in intra mode
                    J_copy = inf;
                else
                    % Calculate the distortion between the previously sent
                    % coefficients and the UNquantized DCT coefficients of the
                    % current frame
                    framePrevSent = blocks{quantStep,nframe-1}{ii,jj}.receivedDCT;
                    frameCur = blocks{quantStep,nframe}{ii,jj}.DCT;
                    Dist_copy = sum(abs(framePrevSent(:)-frameCur(:)).^2)/16^2;
                    
                    % rate for copy mode is only 1 bit per block for indication
                    R_copy = 1/16^2;

                    % calculate cost functions
                    J_copy = Dist_copy + lambda*R_copy;
                    
                end
                
                J_intra = Dist_intra + lambda*R_intra;

                    
                
                % compare cost functions and decide on mode
                if J_intra < J_copy
                    blocks{quantStep,nframe}{ii,jj}.receivedDCT = DCTCoef;
                    blocks{quantStep,nframe}{ii,jj}.decision = 1;
                    blocks{quantStep,nframe}{ii,jj}.R_CR = R_intra; 
                    blocks{quantStep,nframe}{ii,jj}.MSE_CR = Dist_intra;
                else
                    blocks{quantStep,nframe}{ii,jj}.receivedDCT = ...
                        blocks{quantStep,nframe-1}{ii,jj}.receivedDCT;
                    blocks{quantStep,nframe}{ii,jj}.decision = 2;
                    blocks{quantStep,nframe}{ii,jj}.R_CR = R_copy; 
                    blocks{quantStep,nframe}{ii,jj}.MSE_CR = Dist_copy;
                end
                
                %blocks{quantStep,nframe}{ii,jj}.MSECopy = Dist_copy;
                
                % they already contain 1 bit for decision
                blocks{quantStep,nframe}{ii,jj}.RIntra = R_intra;
                
                Vreceived_CR{quantStep,nframe}{ii,jj} = ...
                    decode_intraframe2(blocks{quantStep,nframe}{ii,jj}.receivedDCT);
                
            end
        end
        Vreceived_CR{quantStep,nframe} = cell2mat(Vreceived_CR{quantStep,nframe});
    end
end



% calculate rate and PSNR
Rfinal_CR = zeros(1,numel(delta));
MSEfinal_CR = zeros(1,numel(delta));
for quantStep=1:numel(delta)
    for nframe=1:numel(V)
        curBlock = [blocks{quantStep, nframe}{:,:}];
        Rfinal_CR(quantStep) = Rfinal_CR(quantStep) + ...
            mean([curBlock.R_CR]) / numel(V);
        MSEfinal_CR(quantStep) = MSEfinal_CR(quantStep) + ...
            mean([curBlock.MSE_CR]) / numel(V);
    end
end

R_CRkbps = Rfinal_CR.*30*frame_size(1)*frame_size(2)/1000;
PSNR_CR = 10*log10(255^2./MSEfinal_CR);

figure(1);
plot(R_CRkbps, PSNR_CR, 'r', 'LineWidth', 2);
legend('Intra Mode', 'Conditional Replenishment Mode',...
    'Location', 'northwest');


%% Start calculating residuals for Inter Mode


for quantStep = 1:length(delta)  % loop over step sizes of quantizer
    for nframe = 1:length(V) % loop over all frames
        nframe
         
        % how many 16x16 block fit into one frame
        [M,N] = size(Vblk16{nframe}); 
        
        % calculate motion vector and residual matrix for every block
        for nrow = 1:M
            for ncol =1:N
                
                blocks{quantStep,nframe}{nrow,ncol}.imgData = ...
                    Vblk16{nframe}{nrow,ncol};
                
                blocks{quantStep,nframe}{nrow,ncol}.pos = ...
                     [(nrow-1)*16+1 (ncol-1)*16+1];
                
                if nframe >= 2 % previous frame available
                    [blocks{quantStep,nframe}{nrow,ncol}.motionVec,...
                     blocks{quantStep,nframe}{nrow,ncol}.residual ] = ...
                        jzlk_findMotionVec(Vrec_Inter_Frame{quantStep,nframe-1}, ... 
                        Vblk16{nframe}{nrow,ncol},...
                        blocks{quantStep,nframe}{nrow,ncol}.pos);
                        %2nd argblocks{quantStep,nframe-1}{nrow, ncol}.imgData,...
                else
                    % the first frame has no previous frame
                    [blocks{quantStep,nframe}{nrow,ncol}.motionVec,...
                     blocks{quantStep,nframe}{nrow,ncol}.residual ] = ...
                        jzlk_findMotionVec(V{nframe}, ... 
                        Vblk16{nframe}{nrow,ncol},...
                        blocks{quantStep,nframe}{nrow,ncol}.pos);
                        %2nd arg blocks{quantStep,nframe}{nrow, ncol}.imgData, ...
                end
                
                % Apply DCT transform and quantize
                [blocks{quantStep,nframe}{nrow,ncol}.resDCT,...
                        blocks{quantStep,nframe}{nrow,ncol}.resDCTquant, ...
                        blocks{quantStep,nframe}{nrow,ncol}.MSEres ] = ...
                        encode_intraframe2(blocks{quantStep,nframe}{nrow,ncol}.residual, ...
                        delta(quantStep));
                    
                 if nframe>1
                    %reconstruct image from residual and motion vector
                     resimg = decode_intraframe2(blocks{quantStep,nframe}{nrow,ncol}.resDCTquant);
                     prevPos = blocks{quantStep,nframe}{nrow,ncol}.pos + ...
                         blocks{quantStep,nframe}{nrow,ncol}.motionVec;
                     previmgpart = Vrec_Inter_Frame{quantStep,nframe-1}...
                         (prevPos(1):prevPos(1)+15, prevPos(2):prevPos(2)+15);

                     Vreceived_Inter{quantStep,nframe}{nrow, ncol} = previmgpart + resimg;
                 else
                     Vreceived_Inter{quantStep,nframe}{nrow, ncol} =...
                         decode_intraframe2(blocks{quantStep, nframe}{nrow,ncol}.quantDCT);
                 end
            end
        end
        Vrec_Inter_Frame{quantStep,nframe} = cell2mat(Vreceived_Inter{quantStep,nframe});
    end
end


%% PSNR and rate calculation

% codebooks for each coefficients for each quantizer step size
codebooks_mot(numel(delta)).codewords = [];
codebooks_mot(numel(delta)).codelength = [];
codebooks_mot(numel(delta)).entropy = [];

coefVec_mot = zeros(numel(delta), 2*50*frame_size(1)*frame_size(2)/16^2 );


for quantStep=1:numel(delta)    % loop through all quantization steps
    idxMot = 1;
    for nframe = 1:length(V) % loop over all frames
        for nrow = 1:M
            for ncol = 1:N
                % loop through all coefficients of a 16x16
                coefVec_mot(quantStep, idxMot:idxMot+1) = ...
                    blocks{quantStep, nframe}{nrow,ncol}.pos;
                idxMot = idxMot + 2;
            end
        end
        
    end
end

Ratefinal_mot = zeros(1,numel(delta));

for quantStep = 1:numel(delta)
    [codebooks_mot(quantStep).codewords, ...
        codebooks_mot(quantStep).codelength, ...
        codebooks_mot(quantStep).entropy] = ...
        jzlk_generateCode(coefVec_mot(quantStep,:));
end

% For each quantization level, take all coefficients at a certain position
% Then calculate the entropy for this i-th coefficient
[codebooks_res, Ratefinal_res, MSEfinal_res] = ...
    jzlk_getCodebooks(blocks, 'resDCTquant', 'MSEres');
        
Ratekbps_res = Ratefinal_res.*30*frame_size(1)*frame_size(2)/1000;

PSNR_res = 10*log10(255^2./MSEfinal_res);

% Plot PSNR vs Rate in kbits/sec
% Does this plot really make sense? Not sure...
figure(1);
plot(Ratekbps_res, PSNR_res, 'LineWidth', 2);
grid on;
hold on
xlabel('Rate [kbps]');
ylabel('PSNR [dB]');

% Up to here it should work

%% Allow Intra, CR and Inter Mode
% This part doesn't work correctly yet

for quantStep = 1:length(delta)  % loop over step sizes of quantizer
    
    % lambda for cost function according to instructions
    lambda = 0.2*delta(quantStep)^2;
    
       
    for nframe = 1:length(V) % loop over all frames, comparison between two frames: -1
        nframe
        
        M = size(V{nframe},1)/16;
        N = size(V{nframe},2)/16;
        
        
        % loop over all 16x16 blocks
        for ii = 1:M
            for jj =1:N
                
                % Get rates and add another bit for mode indication
                R_intra = blocks{quantStep,nframe}{ii,jj}.RIntra + 1/16^2;
                R_copy = blocks{quantStep,nframe}{ii,jj}.RCopy + 1/16^2;
                
                Rres_inter = jzlk_getRateStruct(...
                    blocks{quantStep,nframe}{ii,jj}.resDCTquant, ...
                    codebooks_res, quantStep);
                Roffset_inter = 2/16^2;
                Rpos_inter = jzlk_getRateStruct(...
                    blocks{quantStep,nframe}{ii,jj}.pos, ...
                    codebooks_mot, quantStep);
                R_inter = Rres_inter + Roffset_inter + Rpos_inter;
                
                Dist_intra = blocks{quantStep,nframe}{ii,jj}.MSEIntra;
                Dist_copy = blocks{quantStep,nframe}{ii,jj}.MSECopy;
                Dist_inter = blocks{quantStep,nframe}{ii,jj}.MSEInter;

                
                if nframe==1
                    % the first frame has to be transmitted in intra mode
                    J_copy = inf;
                    J_inter= inf;
                else
                    % calculate cost functions
                    J_copy = Dist_copy + lambda*R_copy;
                    J_inter = Dist_inter + lambda*R_inter;
                end
                
                J_intra = Dist_intra + lambda*R_intra;
                
                minIdx = find(min([J_intra J_copy J_inter]));
                minIdx = minIdx(1);
                
                % compare cost functions and decide on mode
                if minIdx == 1 % intra mode
                    blocks{quantStep,nframe}{ii,jj}.quantDCT_CR = DCTCoef;
                    blocks{quantStep,nframe}{ii,jj}.decision = 1;
                    blocks{quantStep,nframe}{ii,jj}.R = R_intra; 
                    blocks{quantStep,nframe}{ii,jj}.MSE_CR = Dist_intra;
                elseif minIdx == 2 % copy mode
                    blocks{quantStep,nframe}{ii,jj}.quantDCT_CR = ...
                        blocks{quantStep,nframe-1}{ii,jj}.quantDCT_CR;
                    blocks{quantStep,nframe}{ii,jj}.decision = 2;
                    blocks{quantStep,nframe}{ii,jj}.R = R_copy; 
                    blocks{quantStep,nframe}{ii,jj}.MSE_CR = Dist_copy;
                elseif minIdx == 3 % inter mode
                    blocks{quantStep,nframe}{ii,jj}.quantDCT_CR = ...
                        blocks{quantStep,nframe-1}{ii,jj}.quantDCT_CR;
                    blocks{quantStep,nframe}{ii,jj}.decision = 3;
                    blocks{quantStep,nframe}{ii,jj}.R = R_inter; 
                    blocks{quantStep,nframe}{ii,jj}.MSE_CR = Dist_copy;
                end
                
                % it already contains 2 bit for decision
                blocks{quantStep,nframe}{ii,jj}.RIntra = R_intra;
                blocks{quantStep,nframe}{ii,jj}.RCopy = R_copy;
                blocks{quantStep,nframe}{ii,jj}.RInter = R_inter;
                
                
            end
        end
        
    end
   
end


