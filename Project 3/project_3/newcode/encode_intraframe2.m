function [ frameblk_dct_quant, MSE_blk  ] = encode_intraframe2( frameblk, delta )
%Takes a 16x16 frame, splits it into 4 8x8 blocks, performs DCT, then
%quantization on the DCT coefficients
%   Detailed explanation goes here


%divide block 16x16 block into 4 8x8 blocks
frameblk_8 = mat2cell(frameblk, repmat(8, 1, 2), repmat(8, 1, 2)); 

%perform dct2 for all 8x8 blocks 
frameblk_8_dct  = cellfun(@dct2, frameblk_8, 'UniformOutput', 0);  

% quantize every coefficient with step size from loop
frameblk_8_dct_quant = cellfun(@(x) jzlk_quantize(x,delta), frameblk_8_dct, 'UniformOutput', 0); 

% resolve 8x8 blocks -->16x16 blocks with dct coefficients (used for entropy calculation)
frameblk_dct_quant = cell2mat(frameblk_8_dct_quant);

%% resolve 8x8 block --> 16x16 blocks for distortion calculation
frameblk_dct = cell2mat(frameblk_8_dct);

MSE_blk = sum(abs((frameblk_dct_quant(:) - frameblk_dct(:))).^2)*1/(16^2); %Parsivals Theorem (correct?)


end




