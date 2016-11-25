function [ rate ] = jzlk_fwtRate( fwtCoef, scale )
%Calculates the minimum rate needed to transmit an array of FWT coeffcients
%
%   Author: Lars Kuger

subEntropy = zeros(4,1);

if scale==1
    midx1 = floor(1/2*size(fwtCoef,1));
    midx2 = floor(1/2*size(fwtCoef,2));
else
    midx1 = floor(1/2^(scale-1)*size(fwtCoef,1));
    midx2 = floor(1/2^(scale-1)*size(fwtCoef,2));
end

subband11 = fwtCoef(1:midx1, 1:midx2);
subband12 = fwtCoef(1:midx1, midx2+1:end);
subband21 = fwtCoef(midx1+1:end, 1:midx2);
subband22 = fwtCoef(midx1+1:end, midx2+1:end);

if scale == 1
    subEntropy(1) = jzlk_entropy(subband11);
else
    subEntropy(1) = jzlk_fwtRate(subband11, scale-1);
end
subEntropy(2) = jzlk_entropy(subband12);
subEntropy(3) = jzlk_entropy(subband21);
subEntropy(4) = jzlk_entropy(subband22);

rate = mean(subEntropy);

end

