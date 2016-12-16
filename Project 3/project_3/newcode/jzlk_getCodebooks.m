function [ codebooks, Ratefinal, MSEfinal ] = jzlk_getCodebooks( blocks, fieldname, MSEfield)
%Generates codebooks and calculates rates 
%   Q: how many quantization steps
%   F: Number of frames
%   frame_size: 

Q = size(blocks,1);
F = size(blocks,2);
[M,N] = size(blocks{1,1});
frame_size = 16*[M,N];


% codebooks for each coefficients for each quantizer step size
codebooks(256,Q).codewords = [];
codebooks(256,Q).codelength = [];
codebooks(256,Q).entropy = [];

coefVec = zeros(256, Q, 50*frame_size(1)*frame_size(2)/16^2 );

% averaged MSE
MSEfinal    = zeros(1,Q);

% For each quantization level, take all coefficients at a certain position
% Then calculate the entropy for this i-th coefficient
for quantStep=1:Q    % loop through all quantization steps
    idx = 1;
    for nframe = 1:F % loop over all frames
        for nrow = 1:M
            for ncol = 1:N
                % loop through all coefficients of a 16x16
                for coefIdx = 1:16^2          
                    coefVec(coefIdx, quantStep, idx) = ...
                        blocks{quantStep, nframe}{nrow,ncol}.(fieldname)(coefIdx);
                end
                idx = idx +1;
            end
        end
        
         b = [blocks{quantStep,nframe}{:,:}];
         MSEfinal(quantStep) = mean([b.(MSEfield)]);
    end
end


Ratefinal = zeros(1,Q);

for quantStep = 1:Q
    for coefIdx = 1:256
         % Generate VLC for a set of i-th coefficients
         [ codebooks(coefIdx, quantStep).codewords, ...
          codebooks(coefIdx, quantStep).codelength, ...
          codebooks(coefIdx, quantStep).entropy] = ...
                                        jzlk_generateCode(coefVec(coefIdx,quantStep,:));
    end
    Ratefinal(quantStep) = mean([codebooks(:,quantStep).entropy]);
end

end

