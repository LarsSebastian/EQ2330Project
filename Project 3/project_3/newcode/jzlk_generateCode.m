function [ codeVal, codeLength, entropy ] = jzlk_generateCode( subband )
%Calculates code for coefficients

serSub = subband(:);
sMin = min(serSub);
sMax = max(serSub);

codeVal = zeros(sMax - sMin+1,1);

% make histogram manually
for ii=1:sMax-sMin+1
    val = sMin-1+ii;
    counts(ii) = sum(serSub == val);
    codeVal(ii) = val;
end

% normalize histogram, i.e. calculate pmf
sum1 = sum(counts);
p = counts./sum1;

% remove 0 values (otherwise NaN errors)
codeVal(p==0) = [];
p(p==0) = [];

% ideal shannon code (not ceiled!)
codeLength = -log2(p);

% calculate entropy
entropy = sum(p.*codeLength);

end
