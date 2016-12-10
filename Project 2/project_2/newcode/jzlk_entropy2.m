function [ entropy ] = jzlk_entropy2( subband )
%Calculates entropy for given subband




x = hist(subband(:), 2*max(abs(subband)));%, 0:2^8-1);

sum1 = sum(x);


p = x./sum1;

p(p==0) = [];
entropy = -sum(p.*log2(p));

end

