function [ y ] = jzlk_fwtDirect( x, hphi )
%Fast Wavelet Transform direct implementation
%operates on each column of x separately
%   x       input signal
%   hphi    prototype scaling vector
%   y       output signal [detailCoef; approximationCoef]
%
%   Refer to p.493 and p.521 in the coursebook
%
%   Incoming prototype is hphi(n) = g0(n)
%   Generate h0(n) = g0(-n)
%   Generate g1(n) = -1^{n+1} h0(n)
%   Generate h1(n) = g1(-n)
%
%   Author: Lars Kuger

% number rows, number columns
[N, M] = size(x);


if mod(N,2)==1
    disp('Error: Length of input is odd.');
    return;
end

% Construct filters (always along columns)
if size(hphi,1)==1
    g0 = hphi';
else
    g0 = hphi;
end
h0 = flipud(g0);
g1 = h0;
g1(1:2:end) = -g1(1:2:end); % sign flip
h1 = flipud(g1);


% Filter complete array
X = fft(x,N);
H1= repmat(fft(h1,N),1,M);
H0= repmat(fft(h0,N),1,M);
yHigh = ifft(X.*H1);
yLow  = ifft(X.*H0);

y = [yLow(1:2:N,:); yHigh(1:2:N,:)];

end

