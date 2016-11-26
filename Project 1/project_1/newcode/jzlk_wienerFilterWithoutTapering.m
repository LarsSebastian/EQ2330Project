function [ fhat ] = jzlk_wienerFilterWithoutTapering( g, h, sigma2 )
%Implements Wiener Filtering by simplified formular eq.5.8-6 without
%tapering the edges
%  FHat(u,v) = 1/H(u,v) * |H(u,v)|^2 / (|H(u,v)|^2+K) G(u,v)

[M,N] = size(g);
[V,W] = size(h);

% Prevent aliasing due to circular convolution
g = padarray(g, size(h));

% Make Fourier transforms of same size
G = fft2(g, size(g,1), size(g,2));
H = fft2(h, size(g,1), size(g,2));

% The exact value for K is given by K = sigma2/var(f). Approximate var(f)
% by var(g)/2
K = 2* sigma2 / var(double(g(:)));

% Calculate Wiener Transfer Function
H2 = abs(H).^2;
TransferFcn = H2./(H.*(H2+K)); % eq 5.8-6

% Get estimated original image from disturbed image
Fhat = TransferFcn .* G;

% Take inverse Fourier transform to go back to spatial domain
fhat = ifft2(Fhat);

% Extract only relevant pixels
off1 = ceil((V+1)/2);
off2 = ceil((W+1)/2);
fhat = uint8(fhat(off1:M+off1, off2:N+off2));

end

