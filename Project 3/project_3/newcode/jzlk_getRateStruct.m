function [ rate ] = jzlk_getRateStruct( input, codebooks, quantStep, flag )
%UNTITLED3 Summary of this function goes here
%   flag: either 'coef' or 'motion'

validateattributes(codebooks, {'struct'}, {'nonempty'}, mfilename);
validateattributes(flag, {'char'}, {'nonempty'}, mfilename);

rate = 0;

if strcmp(flag,'coef')
    serDCTcoef = input(:);

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
    
elseif strcmp(flag,'motion')
    motionVec = input(:);
    codeLength = codebooks(quantStep).codelength;
    codeVal = codebooks(quantStep).codewords;
    
    for idx=1:numel(motionVec)
        rate = rate + codeLength(motionVec(idx) == codeVal);
    end
    
    rate = rate / numel(motionVec);
    
end

end

