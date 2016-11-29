function [ entropy ] = jzlk_entropy( subband )
%Returns entropy based on histogram

figure;
h = histogram(subband(:), 'Normalization', 'probability');

p = h.Values;
close;
p(p==0) = [];
entropy = -sum(p.*log2(p));


end

