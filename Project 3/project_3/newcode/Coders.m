% Assignment 2.1 of Project 3
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
Vblk16DCT = cell(length(delta), length(V)); % blocks of 16x16 containing 8x8 DCT coef
% blocks of 16x16 containing 8x8 DCT coef. This contains basically the sent
% coefficients for the various quantization steps
Vblk16DCTquant = cell(length(delta), length(V));
MSE = cell(length(delta), length(V));



for i = 1:length(delta)  % loop over step sizes of quantizer
    for j = 1:length(V) % loop over all frames
        j
        
        
        Vblk16{j} = mat2cell(V{j}, repmat(16, 1, frame_size(2)/16), ...
            repmat(16, 1, frame_size(1)/16)); %divide each frame into blocks of 16x16
        
        
        [M,N] = size(Vblk16{j}); % how many 16x16 block fit into one frame
        
        for ii = 1:M
            for jj =1:N
                [Vblk16DCT{i,j}{ii,jj}, Vblk16DCTquant{i,j}{ii,jj}, MSE{i,j}(ii,jj)] = ...
                    encode_intraframe2(Vblk16{j}{ii,jj}, delta(i));
            end
        end

    end
end

%% PSNR and rate calculation


entropyRate = zeros(256,numel(delta));
% codebooks for each coefficients for each quantizer step size
% each cell is (codewordLength, codewordValue)
codebooks = cell(256, numel(delta));
MSEfinal    = zeros(1,numel(delta));

% For each quantization level, take all coefficients at a certain position
% (i,j) in any 8x8 block, no matter in what frame or where in such a frame.
% Then calculate the entropy for this i-th coefficient
for quantStep=1:numel(delta)    % loop through all quantization steps
    quantCoef = Vblk16DCTquant(quantStep,:);
    MSEsummands = zeros(50,1);
    quantMSE = MSE(quantStep,:);
    
    for coefIdx = 1:16^2          % loop through all coefficients of a 16x16
        idx = 1;
        coefVec = zeros(50*frame_size(1)*frame_size(2)/16^2,1);
        coefIdx
        
        for frameNo=1:length(V) % loop through all frames
            frameQuantCoef = quantCoef{frameNo};
            frameQuantMSE = quantMSE{frameNo};
            if coefIdx==1
                % Only add one mean for each frame
                MSEsummands(frameNo) =  mean(frameQuantMSE(:));
            end
            for ii16x16=1:M
                for jj16x16=1:N
                    block16x16 = frameQuantCoef{ii16x16,jj16x16};
                    coefSerial = block16x16(:);
                    coefVec(idx) = coefSerial(coefIdx);
                    idx = idx + 1;
                end
            end
        end
        %entropyRate(coefIdx, quantStep) = jzlk_entropy2(coefVec);
        [ codeVal, codeLength, entropyRate(coefIdx, quantStep)] = ...
            jzlk_generateCode(coefVec);
        codebooks{coefIdx, quantStep} = {codeLength, codeVal};
    end
    MSEfinal(quantStep) = mean(MSEsummands);
end

Ratefinal   = mean(entropyRate);
Ratekbps = Ratefinal.*30*frame_size(1)*frame_size(2)/1000;

PSNR = 10*log10(255^2./MSEfinal);

%% average PSNR, average rate
% 

figure;
plot(Ratekbps, PSNR, 'LineWidth', 2);
grid on;
hold on
xlabel('Rate [kbps]');
ylabel('PSNR [dB]');


%% Start with conditional replenishment

% This is basically the sent coefficients to conditional replenishment
Vblk16DCT_CR = cell(length(delta), length(V));

%% Calculation of Lagrangian cost function

decision = cell(length(V), length(delta));
R = cell(length(V),length(delta));
MSE_CR = cell(length(V), length(delta));

for i = 1:length(delta)  % loop over step sizes of quantizer
    lambda = 0.2*delta(i)^2; % squared?
    
    % send first frame in intra mode 
    j = 1
    % loop over all 16x16 blocks
    for ii = 1:M
        for jj =1:N
            % we already calculatd this before
            %[DCTCoef1,  Dist_intra1] = encode_intraframe2(Vblk16_1{ii,jj}, delta(i));
            DCTCoef = Vblk16DCTquant{i,j}{ii,jj}; 
            Dist_intra = MSE{i,j}(ii,jj);

            R_intra = jzlk_getRate(DCTCoef, codebooks, i);
            R_intra = R_intra + 1/16^2;  % this means 1 bit per pixel for 
                                         % indication, right?
                                         
            Vblk16DCT_CR{i,j}{ii,jj} = DCTCoef;
            decision{j,i}{ii,jj} = 1;
            R{j,i}(ii,jj) = R_intra; 
            MSE_CR{j,i}(ii,jj) = Dist_intra;
        end
    end
    
       
    for j = 2:length(V) % loop over all frames, comparison between two frames: -1
        j
        
        
        M = size(V{j},1)/16;
        N = size(V{j},2)/16;
        
        
        % loop over all 16x16 blocks
        for ii = 1:M
            for jj =1:N
                
                % we already calculatd these before
                DCTCoef = Vblk16DCTquant{i,j}{ii,jj}; 
                Dist_intra = MSE{i,j}(ii,jj);
                
                R_intra = jzlk_getRate(DCTCoef, codebooks, i);
                R_intra = R_intra + 1/16^2;  % this means 1 bit per block
                
                % 
                framePrevSent = Vblk16DCT_CR{i,j-1}{ii,jj};
                frameCur = Vblk16DCT{i,j}{ii,jj};
                Dist_copy = sum(abs(framePrevSent(:)-frameCur(:)).^2)/16^2;
                
                R_copy = 1/16^2; % 1 bit per pixel for indication
                
                J_intra = Dist_intra + lambda*R_intra;
                J_copy = Dist_copy + lambda*R_copy;
                
                if J_intra < J_copy
                    Vblk16DCT_CR{i,j}{ii,jj} = DCTCoef;
                    decision{j,i}{ii,jj} = 1;
                    R{j,i}(ii,jj) = R_intra; 
                    MSE_CR{j,i}(ii,jj) = Dist_intra;
                else
                    Vblk16DCT_CR{i,j}{ii,jj} = Vblk16DCT_CR{i,j-1}{ii,jj};
                    decision{j,i}{ii,jj} = 2;
                    R{j,i}(ii,jj) = R_copy; 
                    MSE_CR{j,i}(ii,jj) = Dist_copy;
                end
                
                
            end
        end
        
    end
   
end



% calculate rate and PSNR
Rfinal_CR = zeros(1,numel(delta));
MSEfinal_CR = zeros(1,numel(delta));
for quantStep=1:numel(delta)
    for frameNo=1:numel(V)
        Rfinal_CR(quantStep) = Rfinal_CR(quantStep) + ...
            mean(R{frameNo, quantStep}(:)) / numel(V);
        MSEfinal_CR(quantStep) = MSEfinal_CR(quantStep) + ...
            mean(MSE_CR{frameNo, quantStep}(:)) / numel(V);
    end
end

R_CRkbps = Rfinal_CR.*30*frame_size(1)*frame_size(2)/1000;
PSNR_CR = 10*log10(255^2./MSEfinal_CR);

%% plot

figure(1);
plot(R_CRkbps, PSNR_CR, 'r', 'LineWidth', 2);
legend('Intra Mode', 'Conditional Replenishment Mode');