function [ fhat ] = jzlk_wienerFilter( g, h, sigma2 )
%Implements Wiener Filtering by simplified formular eq.5.8-6
%  FHat(u,v) = 1/H(u,v) * |H(u,v)|^2 / (|H(u,v)|^2+K) G(u,v)

[M,N] = size(g);
[V,W] = size(h);

% Aliasing could be prevented by padding with zeros. This will lead to some
% sort of dark margin though (0=black), so instead replicate such that the 
% blurry margin will be aproximately the same colour as the actual edge 
% of the image
g = padarray(g, size(h), 'replicate');

% Taper edges to remove disturbing lines. Refer to p. 275 or chapter 
% 5.11.5, course book 3rd edition for description of the problem. Instead
% of windowing which would also effect pixels in the center here edge
% tapering is used. Refer to 
% https://se.mathworks.com/help/images/avoiding-ringing-in-deblurred-
% images.html?searchHighlight=edgetaper
window = hamming(32);
PSF = window * window';
PSF = PSF ./ sum(PSF(:));
gTapered =  edgetaper(double(g),PSF);

% Repeat the procedure to smooth edges
for ii=1:15
    gTapered =  edgetaper(double(gTapered),PSF);
end


% Make Fourier transforms of same size
tSize = size(gTapered);
G = fft2(gTapered, tSize(1), tSize(2));
H = fft2(h, tSize(1), tSize(2));

% The exact value for K is given by K = sigma2/var(f)
K =  4*sigma2 / var(double(g(:)));


% Calculate Wiener Transfer Function
H2 = abs(H).^2;
TransferFcn = H2./(H.*(H2+K)); % eq 5.8-6

% Get estimated original image from disturbed image
Fhat = TransferFcn .* G;

% Take inverse Fourier transform to go back to spatial domain
fhat = uint8(ifft2(Fhat));

% Extract only relevant pixels
off1 = ceil((V+1)/2);
off2 = ceil((W+1)/2);
fhat = fhat(off1:M+off1-1, off2:N+off2-1);

end

