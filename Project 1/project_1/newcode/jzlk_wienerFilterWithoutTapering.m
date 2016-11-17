function [ fhat ] = jzlk_wienerFilterWithoutTapering( g, h, sigma2 )
%Implements Wiener Filtering by simplified formular eq.5.8-6 without
%tapering the edges
%  FHat(u,v) = 1/H(u,v) * |H(u,v)|^2 / (|H(u,v)|^2+K) G(u,v)

totSize = size(g) + size(h);

% Make Fourier transforms of same size
G = fft2(g, totSize(1), totSize(2));
H = fft2(h, totSize(1), totSize(2));

% The exact value for K is given by K = sigma2/var(f). Approximate var(f)
% by var(g)/2
K = 2* sigma2 / var(g(:));

% Calculate Wiener Transfer Function
H2 = abs(H).^2;
TransferFcn = H2./(H.*(H2+K)); % eq 5.8-6

% Get estimated original image from disturbed image
Fhat = TransferFcn .* G;

% Take inverse Fourier transform to go back to spatial domain
fhat = ifft2(Fhat);

% Extract only relevant pixels
fhat = uint8(fhat(1:size(g,1), 1:size(g,2)));

end

