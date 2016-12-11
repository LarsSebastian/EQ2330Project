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

%% seperate all frames into blocks of 16 then blocks of 8, apply dct2 and quantization

%Initialize all Matrices

Vblk16 = cell(length(V), 1);
Vblk16DCT = cell(length(delta), length(V)); % blocks of 16x16 containing 8x8 DCT coef
MSE = cell(length(delta), length(V));



for i = 1:length(delta)  % loop over step sizes of quantizer
    for j = 1:length(V) % loop over all frames
        j
        
        
        Vblk16{j} = mat2cell(V{j}, repmat(16, 1, frame_size(2)/16), ...
            repmat(16, 1, frame_size(1)/16)); %divide each frame into blocks of 16x16
        [M,N] = size(Vblk16{j}); % how many 16x16 block fit into one frame
        
        for ii = 1:M
            for jj =1:N
                [Vblk16DCT{i,j}{ii,jj}, MSE{i,j}(ii,jj)] = ...
                    encode_intraframe2(Vblk16{j}{ii,jj}, delta(i));
            end
        end

    end
end

%% PSNR and rate calculation


entropyRate = zeros(256,numel(delta));
% codebooks for each coefficients for each quantizer step size
% each cell is (codewordLength, codewordValue)
numIndicator = 2;
codebooks = cell(256, numel(delta));
MSEfinal    = zeros(1,numel(delta));

% For each quantization level, take all coefficients at a certain position
% (i,j) in any 8x8 block, no matter in what frame or where in such a frame.
% Then calculate the entropy for this i-th coefficient
for quantStep=1:numel(delta)    % loop through all quantization steps
    quantCoef = Vblk16DCT(quantStep,:);
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
        entropyRate(coefIdx, quantStep) = jzlk_entropy2(coefVec);
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
xlabel('Rate [kbps]');
ylabel('PSNR [dB]');
