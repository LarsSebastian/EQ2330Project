function [ rate ] = jzlk_getRate( DCTcoef, codebooks, quantStep )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

serDCTcoef = DCTcoef(:);
rate = 0;

for coefIdx=1:numel(serDCTcoef)
    % get the correct codebook for each coefficients and quantization
    % stepsize
    coefCode = codebooks{coefIdx, quantStep};
    codeLength = coefCode{:,1};
    codeVal = coefCode{:,2};
    
    % find codeword length for the coefficients
    rate = rate + codeLength(serDCTcoef(coefIdx) == codeVal);
end

rate = rate / numel(serDCTcoef);

end

