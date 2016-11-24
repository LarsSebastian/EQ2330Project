function [ xhat ] = jzlk_ifwtDirect( y, hphi )
%Inverse Fast Wavelet Transform direct implementation
%operates on each column of y separately
%   y       input [detailCoef; approxCoef]
%   hphi    Prototype Scaling Vector
%   xhat    Reconstructed signal
%
%   Incoming prototype is hphi(n) = g0(n)
%   Generate h0(n) = g0(-n)
%   Generate g1(n) = -1^{n+1} h0(n)
%   Generate h1(n) = g1(-n)
%
%   Author: Lars Kuger

[N,M] = size(y);

K = numel(hphi);

% Generate filters
if size(hphi,1)==1
    g0 = hphi';
else
    g0 = hphi;
end
h0 = flipud(g0);
g1 = h0;
g1(1:2:end) = -g1(1:2:end); % sign flip
h1 = flipud(g1);

% Extract coefs from signal y
yLow = y(1:end/2,:);
yHigh = y(end/2+1:end,:);

yHighus = upsample(yHigh, 2); % upsample operates on columns
yLowus = upsample(yLow, 2);

% Filter
YH = fft(yHighus, N);
YL = fft(yLowus, N);
G1 = repmat(fft(g1,N),1,M);
G0 = repmat(fft(g0,N),1,M);
xHigh = ifft(YH.*G1);
xLow = ifft(YL.*G0);

xhat = xHigh + xLow;

xhat = circshift(xhat, N-K+1, 1); %shift along columns

end

