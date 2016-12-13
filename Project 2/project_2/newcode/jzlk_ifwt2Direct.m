function [ imagehat ] = jzlk_ifwt2Direct( y, hphi, scale )
%2D Fast Wavelet Transform on an image
%   y       transformed image
%   hphi    prototype scaling vector
%   scale   how often was FWT applied
%   image   reconstructed image
%
%   Author: Lars Kuger

xhat = y;

for ii=scale:-1:1
    midx1 = floor(1/2^(ii-1)*size(y,1));
    midx2 = floor(1/2^(ii-1)*size(y,2));
    imagePart = xhat(1:midx1, 1:midx2);
    
    %First along columns
    imageC = jzlk_ifwtDirect(imagePart, hphi);

    %Now along rows
    xhatPart = jzlk_ifwtDirect(imageC', hphi)';
    
    xhat(1:midx1, 1:midx2) = xhatPart;
end

imagehat = xhat;

end

