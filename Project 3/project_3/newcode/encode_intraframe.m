function [ R, PSNR  ] = encode_intraframe( frameblk, delta )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


%divide block 16x16 block into 4 8x8 blocks
frameblk_8 = mat2cell(frameblk, repmat(8, 1, 2), repmat(8, 1, 2)); 

%perform dct2 for all 8x8 blocks 
frameblk_8_dct  = cellfun(@dct2, frameblk_8, 'UniformOutput', 0);  

% quantize every coefficient with step size from loop
frameblk_8_dct_quant = cellfun(@(x) jzlk_quantize(x,delta), frameblk_8_dct, 'UniformOutput', 0); 

% resolve 8x8 blocks -->16x16 blocks with dct coefficients (used for entropy calculation)
frameblk_dct_quant = cell2mat(frameblk_8_dct_quant);

frameblk_dct = cell2mat(frameblk_8_dct);

% %backtransformation into spatial domain after quantization
% frameblk_8_quant = cellfun(@idct2, frameblk_8_dct_quant , 'UniformOutput', 0); 
% 
% %resolve 8x8 --> 16x16 with spatial values
% frameblk_quant = cell2mat(frameblk_8_quant);


EntropyMat = zeros(8,8);
for i = 1:8
    for j = 1:8
        coeff_vec = cellfun(@(x) x(i,j), frameblk_8_dct_quant, 'UniformOutput', false); % get coefficients
        coeff_vec = cell2mat(coeff_vec);
        EntropyMat(i,j) = jzlk_entropy2(coeff_vec(:));
    end
end

R = mean(EntropyMat(:)); %rate per frame

MSE_blk = sum(abs((frameblk_dct_quant(:) - frameblk_dct(:))).^2)*1/(16^4);
PSNR = 10*log10(255^2/MSE_blk);


end




