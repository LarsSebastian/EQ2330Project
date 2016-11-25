function [ y ] = jzlk_fwt2Direct( image, hphi, scale )
%2D Fast Wavelet Transform on an image
%   image   input image
%   hphi    prototype scaling vector
%   scale   how often is FWT applied
%   y       transformed image
%
%   Author: Lars Kuger

y = double(image);

for ii=1:scale
    
    %Extract relevant part 
    midx1 = floor(1/2^(ii-1)*size(image,1));
    midx2 = floor(1/2^(ii-1)*size(image,2));
    imagePart = y(1:midx1, 1:midx2);

    %First along rows
    yRPart = jzlk_fwtDirect(imagePart', hphi)';

    %Now along columns
    yPart = jzlk_fwtDirect(yRPart, hphi);
    
    %Replace the old image part with the wavelet coefficients
    y(1:midx1, 1:midx2) = yPart;
end

end

