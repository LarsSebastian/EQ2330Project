load coeffs


%% Testing if 1D FWT works
x = [   0 1 1 0 0.5 0.7 0 0.3;
        1 2 0 6 4   7   8 3 ]';

y = jzlk_fwtDirect(x, db4);

xhat = jzlk_ifwtDirect(y,db4);

diff = x - xhat;


%% Testing if 2D FWT works
image = imread('harbour512x512.tif');
scale = 4;
ynew = jzlk_fwt2Direct(image, haar, scale);
imagenew = jzlk_ifwt2Direct(ynew, haar, scale);
figure;
imshow(uint8(ynew))
figure;
imshow(imagenew);