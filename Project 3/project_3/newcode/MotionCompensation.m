%% Compute statistics for residual signals by encoding all blocks with 
%inter mode --> for every block: residual + motion vector
%
% still missing: additional rate for transmitting 


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

 % blocks of 16x16 containing 8x8 DCT coef BEFORE quantization
residualsDCT = cell(length(delta), length(V));

% blocks of 16x16 containing 8x8 DCT coef after quantization. These are 
% basically the sent coefficients for the various quantization steps
residualsDCTquant = cell(length(delta), length(V));

% Mean Square Error for each block
MSE = cell(length(delta), length(V));

% Cell Matrix of motion vectors for each block
motionVecs = cell(length(delta), length(V));

% Cell Matrix containing the residuals
residuals = cell(length(delta), length(V));



for i = 1:length(delta)  % loop over step sizes of quantizer
    for j = 1:length(V) % loop over all frames
        j
        
        %divide each frame into blocks of 16x16
        Vblk16{j} = mat2cell(V{j}, repmat(16, 1, frame_size(2)/16), ...
            repmat(16, 1, frame_size(1)/16)); 
        
        % how many 16x16 block fit into one frame
        [M,N] = size(Vblk16{j}); 
        
        % calculate motion vector and residual matrix for every block
        
        for ii = 1:M
            for jj =1:N
                prevPosVec = [(ii-1)*16+1 (jj-1)*16+1];
                if j >= 2
                    [motionVecs{i,j}{ii,jj}, residuals{i,j}{ii,jj}] = jzlk_findMotionVec(V{j}, Vblk16{j-1}{ii,jj}, prevPosVec);
                
                    % Apply DCT transform and quantize
                    [residualsDCT{i,j}{ii,jj}, residualsDCTquant{i,j}{ii,jj}, ...
                        MSE{i,j}(ii,jj)] = ...
                        encode_intraframe2(residuals{i,j}{ii,jj}, delta(i));
                else
                    continue;
                end
            end
        end

    end
end


%% PSNR and rate calculation

% entropy for each coefficient #i, i=1,...,256
entropyRate_res = zeros(256,numel(delta));

% codebooks for each coefficients for each quantizer step size
% each cell is (codewordLength, codewordValue)
codebooks_res = cell(256, numel(delta));

% averaged MSE
MSEfinal_res    = zeros(1,numel(delta));

% For each quantization level, take all coefficients at a certain position
% Then calculate the entropy for this i-th coefficient
for quantStep=1:numel(delta)    % loop through all quantization steps
    quantCoef = residualsDCTquant(quantStep,:);
    MSEsummands = zeros(50,1);
    quantMSE = MSE(quantStep,:);
    
    % loop through all coefficients of a 16x16
    for coefIdx = 1:16^2          
        idx = 1;
        coefVec = zeros(50*frame_size(1)*frame_size(2)/16^2,1);
        coefIdx
        
        % loop through all frames
        for frameNo=2:length(V)
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
                    % Add the i-th coefficient to the coefVec
                    coefVec(idx) = coefSerial(coefIdx);
                    idx = idx + 1;
                end
            end
        end

        % Generate VLC for a set of i-th coefficients
        [ codeVal, codeLength, entropyRate_res(coefIdx, quantStep)] = ...
            jzlk_generateCode(coefVec);
        
        % save the corresponding codebook for the VLC
        codebooks_res{coefIdx, quantStep} = {codeLength, codeVal};
    end
    
    % Average the MSEs 
    MSEfinal_res(quantStep) = mean(MSEsummands);
end

Ratefinal   = mean(entropyRate_res);
Ratekbps = Ratefinal.*30*frame_size(1)*frame_size(2)/1000;

PSNR = 10*log10(255^2./MSEfinal_res);

%% Plot PSNR vs Rate in kbits/sec

figure;
plot(Ratekbps, PSNR, 'LineWidth', 2);
grid on;
hold on
xlabel('Rate [kbps]');
ylabel('PSNR [dB]');
