function [ entropy ] = jzlk_entropy( subband )
%Returns entropy based on the function jzlk_generateCode

[ ~, ~, entropy] = jzlk_generateCode(subband);

% WRONG DO NOT USE ANYMORE
% figure;
% h = histogram(subband(:), 'Normalization', 'probability');
% 
% p = h.Values;
% close;
% p(p==0) = [];
% entropy = -sum(p.*log2(p));


end

