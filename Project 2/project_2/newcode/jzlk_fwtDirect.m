function [ y ] = jzlk_fwtDirect( x, hphi )
%Fast Wavelet Transform direct implementation
%   x       input signal
%   hphi    prototype scaling vector
%   y       output signal [approximationCoef, detailCoef]
%
%   Refer to p.493 and p.521 in the coursebook
%
%   Incoming prototype is hphi(n) = g0(n)
%   Generate h0(n) = g0(-n)
%   Generate g1(n) = -1^{n+1} h0(n)
%   Generate h1(n) = g1(-n)

N = numel(x);

if mod(N,2)==1
    disp('Error: Length of input is odd.');
    return;
end

g0 = hphi;
h0 = fliplr(g0);

g1 = h0;
g1(1:2:end) = -g1(1:2:end); % sign flip

h1 = fliplr(g1);


% Filter
yHighOUT = ifft(fft(x,N).*fft(h1, N));
yLowOUT = ifft(fft(x, N).*fft(h0, N));

y = [yHighOUT(1:2:N) yLowOUT(1:2:N)];

end

