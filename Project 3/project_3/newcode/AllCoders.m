% Project 3
% EQ2330 Image and Video Processing
% Fall Term 2016, KTH
% Authors: Jan Zimmermann, Lars Kuger

%%
% clear;
% close all;
% clc;
%% load video

disp('Start initialization...');

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
Vreceived = cell(numel(delta),50);
Vreceived_blk = cell(numel(delta),50);

disp('Finished initialization.');

%% start with intra frame coding
%seperate all frames into blocks of 16 then blocks of 8, apply dct2 and quantization

%Initialize all Matrices

Vblk16 = cell(length(V), 1);

blocks = cell(length(delta), length(V));

disp('Start coding in intra frame mode...');

for quantStep = 1:length(delta)  % loop over step sizes of quantizer
    for nframe = 1:length(V) % loop over all frames
        
        
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


% PSNR and rate calculation for pure Intra Mode

disp('Calculate PSNR and rate for intra mode...');

[codebooks, Intra.rate, Intra.MSE] = jzlk_getCodebooks(blocks, 'quantDCT', 'MSEIntra');
        
Intra.Rkbps = Intra.rate.*30*frame_size(1)*frame_size(2)/1000;

Intra.PSNR = 10*log10(255^2./Intra.MSE);


disp('Finish intra mode coding.');

%% Start with mode decisions for intra and conditional replenishment mode
% Calculation of Lagrangian cost function

disp('Start coding with mode decision for intra and copy mode...');

for quantStep = 1:length(delta)  % loop over step sizes of quantizer
    
    % lambda for cost function according to instructions
    lambda = 0.2*delta(quantStep)^2;
    
    for nframe = 1:length(V) % loop over all frames, comparison between two frames: -1
        
        M = size(V{nframe},1)/16;
        N = size(V{nframe},2)/16;
        
        % loop over all 16x16 blocks
        for ii = 1:M
            for jj =1:N
                
                % we already calculatd these before
                DCTCoef = blocks{quantStep,nframe}{ii,jj}.quantDCT; 
                Dist_intra = blocks{quantStep,nframe}{ii,jj}.MSEIntra;
                
                % get rate for intra coding
                R_intra = jzlk_getRateStruct(DCTCoef, codebooks, quantStep, 'coef');
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
CR.rate = zeros(1,numel(delta));
CR.MSE = zeros(1,numel(delta));
for quantStep=1:numel(delta)
    for nframe=1:numel(V)
        curBlock = [blocks{quantStep, nframe}{:,:}];
        CR.rate(quantStep) = CR.rate(quantStep) + ...
            mean([curBlock.R_CR]) / numel(V);
        CR.MSE(quantStep) = CR.MSE(quantStep) + ...
            mean([curBlock.MSE_CR]) / numel(V);
    end
end

CR.Rkbps = CR.rate.*30*frame_size(1)*frame_size(2)/1000;
CR.PSNR = 10*log10(255^2./CR.MSE);


disp('Finish coding with mode decision for intra and copy mode.');



%% Start calculating residuals for Inter Mode

%MSEfinal_spatial = zeros(length(delta),1);

disp('Start calculating residuals for inter mode...');

for quantStep = 1:length(delta)  % loop over step sizes of quantizer
    for nframe = 1:length(V) % loop over all frames
         
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
                else
                    % the first frame has no previous frame
                    [blocks{quantStep,nframe}{nrow,ncol}.motionVec,...
                     blocks{quantStep,nframe}{nrow,ncol}.residual ] = ...
                        jzlk_findMotionVec(V{nframe}, ... 
                        Vblk16{nframe}{nrow,ncol},...
                        blocks{quantStep,nframe}{nrow,ncol}.pos);
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
                 
                 % To be tested
                 %MSEfinal_spatial(quantStep) = MSEfinal_spatial(quantStep)...
                 %    + sum(abs(Vreceived_Inter{quantStep,nframe}{nrow,ncol}(:)-...
                 %    Vblk16{nframe}{nrow,ncol}(:)).^2)/(M*N*length(V)*256);
            end
        end
        Vrec_Inter_Frame{quantStep,nframe} = cell2mat(Vreceived_Inter{quantStep,nframe});
    end
end


disp('Generate VLCs...');
% PSNR and rate calculation

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
                    blocks{quantStep, nframe}{nrow,ncol}.motionVec;
                idxMot = idxMot + 2;
            end
        end
        
    end
end

%Ratefinal_mot = zeros(1,numel(delta));

for quantStep = 1:numel(delta)
    [codebooks_mot(quantStep).codewords, ...
        codebooks_mot(quantStep).codelength, ...
        codebooks_mot(quantStep).entropy] = ...
        jzlk_generateCode(coefVec_mot(quantStep,:));
end

% Get codebook for residuals
[codebooks_res, ~, ~] = ...
    jzlk_getCodebooks(blocks, 'resDCTquant', 'MSEres');
        

disp('Finish generating codes for residuals and motion vectors.');

%% Allow Intra, CR and Inter Mode

disp('Start coding with mode decision for intra, copy and inter mode...');

for quantStep = 1:length(delta)  % loop over step sizes of quantizer
    
    % lambda for cost function according to instructions
    lambda = 0.2*delta(quantStep)^2;
    
       
    for nframe = 1:length(V) % loop over all frames, comparison between two frames: -1
        
        M = size(V{nframe},1)/16;
        N = size(V{nframe},2)/16;
        
        
        % loop over all 16x16 blocks
        for nrow = 1:M
            for ncol =1:N
                
                % Get rates and add another bit for mode indication
                R_intra = blocks{quantStep,nframe}{nrow,ncol}.RIntra + 1/16^2;
                R_copy = 2/16^2;
                
                Rres_inter = jzlk_getRateStruct(...
                    blocks{quantStep,nframe}{nrow,ncol}.resDCTquant, ...
                    codebooks_res, quantStep, 'coef');
                Roffset_inter = 2/16^2;
                Rpos_inter = jzlk_getRateStruct(...
                    blocks{quantStep,nframe}{nrow,ncol}.motionVec, ...
                    codebooks_mot, quantStep, 'motion')*2./16^2;
                R_inter = Rres_inter + Roffset_inter + Rpos_inter;
                
                Dist_intra = blocks{quantStep,nframe}{nrow,ncol}.MSEIntra;               
                %Dist_inter = blocks{quantStep,nframe}{ii,jj}.MSEInter;

                
                if nframe==1
                    % the first frame has to be transmitted in intra mode
                    J_copy = inf;
                    J_inter= inf;
                    
                    % Calculations for Inter Mode
                    % get residual and motion vector
                    [blocks{quantStep,nframe}{nrow,ncol}.motionVecAll,...
                     blocks{quantStep,nframe}{nrow,ncol}.residualAll ] = ...
                        jzlk_findMotionVec(V{nframe}, ... 
                        Vblk16{nframe}{nrow,ncol},...
                        blocks{quantStep,nframe}{nrow,ncol}.pos);
                    
                    % Apply DCT transform and quantize
                    [blocks{quantStep,nframe}{nrow,ncol}.resDCTAll,...
                        blocks{quantStep,nframe}{nrow,ncol}.resDCTquantAll, ...
                        blocks{quantStep,nframe}{nrow,ncol}.MSEresAll ] = ...
                        encode_intraframe2(blocks{quantStep,nframe}{nrow,ncol}.residualAll, ...
                        delta(quantStep));
                    
                else
                    % Calculate the distortion between the previously sent
                    % coefficients and the UNquantized DCT coefficients of the
                    % current frame
                    framePrevSent = Vreceived_blk{quantStep,nframe-1}{nrow,ncol};
                    frameCur = blocks{quantStep,nframe}{nrow,ncol}.imgData;
                    Dist_copy = sum(abs(framePrevSent(:)-frameCur(:)).^2)/16^2;
                    
                    % Calculations for Inter Mode
                    % get residual and motion vector
                    [blocks{quantStep,nframe}{nrow,ncol}.motionVecAll,...
                     blocks{quantStep,nframe}{nrow,ncol}.residualAll ] = ...
                        jzlk_findMotionVec(Vreceived{quantStep,nframe-1}, ... 
                        Vblk16{nframe}{nrow,ncol},...
                        blocks{quantStep,nframe}{nrow,ncol}.pos);
                    
                    % Apply DCT transform and quantize
                    [blocks{quantStep,nframe}{nrow,ncol}.resDCTAll,...
                        blocks{quantStep,nframe}{nrow,ncol}.resDCTquantAll, ...
                        blocks{quantStep,nframe}{nrow,ncol}.MSEresAll ] = ...
                        encode_intraframe2(blocks{quantStep,nframe}{nrow,ncol}.residualAll, ...
                        delta(quantStep));
                    
                     %reconstruct image from residual and motion vector
                     resimg = decode_intraframe2(blocks{quantStep,nframe}{nrow,ncol}.resDCTquantAll);
                     prevPos = blocks{quantStep,nframe}{nrow,ncol}.pos + ...
                         blocks{quantStep,nframe}{nrow,ncol}.motionVecAll;
                     previmgpart = Vreceived{quantStep,nframe-1}...
                         (prevPos(1):prevPos(1)+15, prevPos(2):prevPos(2)+15);

                     reconstructedImg = previmgpart + resimg;
                     
                     % To be tested
                     Dist_inter = sum(abs(reconstructedImg(:)-...
                     Vblk16{nframe}{nrow,ncol}(:)).^2)/(16^2);
                    
                    
                    % calculate cost functions
                    J_copy = Dist_copy + lambda*R_copy;
                    J_inter = Dist_inter + lambda*R_inter;
                end
                
                J_intra = Dist_intra + lambda*R_intra;
                
                Jtot = [J_intra J_copy J_inter];
                minIdx = find(Jtot == min(Jtot));
                minIdx = minIdx(1);
                
                % compare cost functions and decide on mode
                if minIdx == 1 % intra mode
                    blocks{quantStep,nframe}{nrow,ncol}.receivedDCTAll = ...
                        blocks{quantStep,nframe}{nrow,ncol}.quantDCT;
                    blocks{quantStep,nframe}{nrow,ncol}.decision_All = 1;
                    blocks{quantStep,nframe}{nrow,ncol}.R_All = R_intra; 
                    blocks{quantStep,nframe}{nrow,ncol}.MSE_All = Dist_intra;
                    Vreceived{quantStep,nframe}{nrow,ncol} = ...
                        decode_intraframe2(blocks{quantStep,nframe}{nrow,ncol}.quantDCT);
                elseif minIdx == 2 % copy mode
                    blocks{quantStep,nframe}{nrow,ncol}.receivedDCTAll = ...
                        blocks{quantStep,nframe-1}{nrow,ncol}.receivedDCTAll;
                    blocks{quantStep,nframe}{nrow,ncol}.decision_All = 2;
                    blocks{quantStep,nframe}{nrow,ncol}.R_All = R_copy; 
                    blocks{quantStep,nframe}{nrow,ncol}.MSE_All = Dist_copy;
                    Vreceived{quantStep,nframe}{nrow,ncol} = ...
                    decode_intraframe2(blocks{quantStep,nframe}{nrow,ncol}.receivedDCTAll);
                elseif minIdx == 3 % inter mode
                    [~, blocks{quantStep,nframe}{nrow,ncol}.receivedDCTAll, ~] = ...
                        encode_intraframe2(reconstructedImg, delta(quantStep));
                    blocks{quantStep,nframe}{nrow,ncol}.decision_All = 3;
                    blocks{quantStep,nframe}{nrow,ncol}.R_All = R_inter; 
                    blocks{quantStep,nframe}{nrow,ncol}.MSE_All = Dist_inter;
                    Vreceived{quantStep,nframe}{nrow,ncol} = reconstructedImg;
                end
                
                
            end
        end
        Vreceived_blk{quantStep,nframe} = Vreceived{quantStep,nframe};
        Vreceived{quantStep,nframe} = cell2mat(Vreceived{quantStep,nframe});
    end
end


% calculate rate and PSNR
Inter.rate = zeros(1,numel(delta));
Inter.MSE = zeros(1,numel(delta));
for quantStep=1:numel(delta)
    for nframe=1:numel(V)
        curBlock = [blocks{quantStep, nframe}{:,:}];
        Inter.rate(quantStep) = Inter.rate(quantStep) + ...
            mean([curBlock.R_All]) / numel(V);
        Inter.MSE(quantStep) = Inter.MSE(quantStep) + ...
            mean([curBlock.MSE_All]) / numel(V);
    end
end

Inter.Rkbps = Inter.rate.*30*frame_size(1)*frame_size(2)/1000;
Inter.PSNR = 10*log10(255^2./Inter.MSE);



%% Make the plots

% jzlk_generatePlot(Vreceived, 2, blocks, 3, 'decision_All');
% 
% % Plot PSNR vs Rate in kbits/sec
% figure;
% plot(Intra.Rkbps, Intra.PSNR, 'o-','LineWidth', 2);
% grid on;
% hold on
% xlabel('Rate [kbps]');
% ylabel('PSNR [dB]');
% 
% plot(CR.Rkbps, CR.PSNR, 'rx-.', 'LineWidth', 2);
% 
% plot(Inter.Rkbps, Inter.PSNR, 'k--', 'LineWidth', 2);
% legend('Intra Mode', 'Intra and Copy Mode', 'Intra, Copy and Inter Mode', ...
%     'Location', 'northwest');
% 
% disp('Finish coding.');