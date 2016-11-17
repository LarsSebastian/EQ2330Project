function [ fhat ] = jzlk_wienerFilter( g, h, sigma2 )
%Implements Wiener Filtering by simplified formular eq.5.8-6
%  FHat(u,v) = 1/H(u,v) * |H(u,v)|^2 / (|H(u,v)|^2+K) G(u,v)

% Taper edges to remove disturbing lines
PSF = fspecial('gaussian',60,10);
gTapered =  edgetaper(g,PSF);

% Make Fourier transforms of same size
G = fft2(gTapered);
H = fft2(h, size(gTapered,1), size(gTapered,2));

% The exact value for K is given by K = sigma2/var(f). Approximate var(f)
% by var(g)/2
K = 2* sigma2 / var(g(:));

% Calculate Wiener Transfer Function
H2 = abs(H).^2;
TransferFcn = H2./(H.*(H2+K)); % eq 5.8-6

% Get estimated original image from disturbed image
Fhat = TransferFcn .* G;

% Take inverse Fourier transform to go back to spatial domain
fhat = uint8(ifft2(Fhat));

end

