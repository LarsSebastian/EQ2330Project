function [ xhat ] = jzlk_ifwtDirect( y, hphi )
%Inverse Fast Wavelet Transform
%   y       input [approxCoef, detailCoef]
%   hphi    Prototype Scaling Vector
%   xhat    Reconstructed signal
%
%   Incoming prototype is hphi(n) = g0(n)
%   Generate h0(n) = g0(-n)
%   Generate g1(n) = -1^{n+1} h0(n)
%   Generate h1(n) = g1(-n)

N = numel(y);
K = numel(hphi);

yHigh = y(1:end/2);
yLow = y(end/2+1:end);

g0 = hphi;
h0 = fliplr(g0);
g1 = h0;
g1(1:2:end) = -g1(1:2:end); % sign flip
h1 = fliplr(g1);

yHighus = upsample(yHigh, 2);
yLowus = upsample(yLow, 2);

% Filter
xHigh = ifft(fft(yHighus,N).* fft(g1, N));
xLow = ifft(fft(yLowus,N).*fft(g0, N));

xhat = xHigh + xLow;

xhat = circshift(xhat, N-K+1);

end

