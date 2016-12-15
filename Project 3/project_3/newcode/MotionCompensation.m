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


%% ONLY DO INTER FRAME CODING
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
                        jzlk_findMotionVec(V{nframe}, ...
                        blocks{quantStep,nframe-1}{nrow, ncol}.imgData,...
                        blocks{quantStep,nframe-1}{nrow,ncol}.pos);
                else
                    % the first frame has no previous frame
                    [blocks{quantStep,nframe}{nrow,ncol}.motionVec,...
                     blocks{quantStep,nframe}{nrow,ncol}.residual ] = ...
                        jzlk_findMotionVec(V{nframe}, ...
                        blocks{quantStep,nframe}{nrow, ncol}.imgData, ...
                        blocks{quantStep,nframe}{nrow,ncol}.pos);
                end
                
                % Apply DCT transform and quantize
                    [blocks{quantStep,nframe}{nrow,ncol}.resDCT,...
                        blocks{quantStep,nframe}{nrow,ncol}.resDCTquant, ...
                        blocks{quantStep,nframe}{nrow,ncol}.MSE ] = ...
                        encode_intraframe2(blocks{quantStep,nframe}{nrow,ncol}.residual, ...
                        delta(quantStep));
            end
        end

    end
end


%% PSNR and rate calculation

% codebooks for each coefficients for each quantizer step size
codebooks_res(256,numel(delta)).codewords = [];
codebooks_res(256,numel(delta)).codelength = [];
codebooks_res(256,numel(delta)).entropy = [];

coefVec = zeros(256, numel(delta), 50*frame_size(1)*frame_size(2)/16^2 );

% averaged MSE
MSEfinal_res    = zeros(1,numel(delta));

% For each quantization level, take all coefficients at a certain position
% Then calculate the entropy for this i-th coefficient
for quantStep=1:numel(delta)    % loop through all quantization steps
    idx = 1;
    for nframe = 1:length(V) % loop over all frames
        for nrow = 1:M
            for ncol = 1:N
                % loop through all coefficients of a 16x16
                for coefIdx = 1:16^2          
                    %coefVec = zeros(50*frame_size(1)*frame_size(2)/16^2,1);
                    %coefIdx

                    coefVec(coefIdx, quantStep, idx) = ...
                        blocks{quantStep, nframe}{nrow,ncol}.resDCTquant(coefIdx);
                end
                idx = idx +1;
            end
        end
        
        b = [blocks{quantStep,nframe}{:,:}];
        MSEfinal_res(quantStep) = mean([b.MSE]);
    end
end

Ratefinal_res = zeros(1,numel(delta));

for quantStep = 1:numel(delta)
    for coefIdx = 1:256
         % Generate VLC for a set of i-th coefficients
         [ codebooks_res(coefIdx, quantStep).codewords, ...
          codebooks_res(coefIdx, quantStep).codelength, ...
          codebooks_res(coefIdx, quantStep).entropy] = ...
                                        jzlk_generateCode(coefVec(coefIdx,quantStep,:));
    end
    Ratefinal_res(quantStep) = mean([codebooks_res(:,quantStep).entropy]);
end
        
Ratekbps_res = Ratefinal_res.*30*frame_size(1)*frame_size(2)/1000;

PSNR = 10*log10(255^2./MSEfinal_res);

%% Now use mode such that we decide for every block 

%% Plot PSNR vs Rate in kbits/sec

figure;
plot(Ratekbps_res, PSNR, 'LineWidth', 2);
grid on;
hold on
xlabel('Rate [kbps]');
ylabel('PSNR [dB]');
