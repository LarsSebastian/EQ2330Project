function [ rate ] = jzlk_getRateStruct( DCTcoef, codebooks, quantStep )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

validateattributes(codebooks, {'struct'}, {'nonempty'}, mfilename);

serDCTcoef = DCTcoef(:);
rate = 0;

for coefIdx=1:numel(serDCTcoef)
    % get the correct codebook for each coefficients and quantization
    % stepsize
    %coefCode = codebooks{coefIdx, quantStep};
    codeLength = codebooks(coefIdx, quantStep).codelength;
    codeVal = codebooks(coefIdx, quantStep).codewords;
    
    % find codeword length for the coefficients
    rate = rate + codeLength(serDCTcoef(coefIdx) == codeVal);
end

rate = rate / numel(serDCTcoef);

end

