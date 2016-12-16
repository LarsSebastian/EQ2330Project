function [ frameblkOUT ] = decode_intraframe2( frameblkDCT )
%Takes a 16x16 frame, splits it into 4 8x8 blocks, performs IDCT
%   Detailed explanation goes here


%divide block 16x16 block into 4 8x8 blocks
frameblk_8_dct = mat2cell(frameblkDCT, repmat(8, 1, 2), repmat(8, 1, 2)); 

%perform dct2 for all 8x8 blocks 
frameblk_8  = cellfun(@idct2, frameblk_8_dct, 'UniformOutput', 0);  


% resolve 8x8 blocks -->16x16 blocks with dct coefficients (used for entropy calculation)
frameblkOUT = cell2mat(frameblk_8);

%% resolve 8x8 block --> 16x16 blocks for distortion calculation
%frameblkOUT = cell2mat(frameblk);


end




