% Assignment 2.2 for Project 1 in EQ2330
% Fall Term 2016
% Course EQ2330 Image and Video Processing
% Project 1
% Authors: Jan Zimmermann, Lars Kuger

%% Clear variables and Command Window
clc;
clear all;

%% Load Image

%I = imread('images/lena512.bmp');
I = imread('images/lena512.bmp');

%% Noise Generation with mynoisegen

noise_gaussian = mynoisegen('gaussian', 512, 512, 0, 64);
noise_saltpepper = mynoisegen('saltpepper', 512, 512, .05, .05);

%% Apply noise to image and plot histogram

I_gaussian = double(I) + noise_gaussian;

I_saltpepper = I;
I_saltpepper(noise_saltpepper == 0) = 0;
I_saltpepper(noise_saltpepper == 1) = 255;
I_saltpepper = uint8(I_saltpepper);


%% Create mean filter and apply to noisy image

mean_filt = ones(3,3)*1/9;

I_gaussian_meanfilt = conv2(double(I_gaussian), double(mean_filt), 'same');
I_saltpepper_meanfilt = conv2(double(I_saltpepper), double(mean_filt), 'same');


%% Create median filter and apply to noisy image
I_gaussian_zeropad = I_gaussian;

while round(length(I_gaussian_zeropad)/3) ~= length(I_gaussian_zeropad)/3
    zero_pad = zeros(1,length(I_gaussian));
    I_gaussian_zeropad = [I_gaussian, zero_pad'];
    I_gaussian_zeropad = [I_gaussian_zeropad; [zero_pad 0]];
    
    I_saltpepper_zeropad = [I_saltpepper, zero_pad'];
    I_saltpepper_zeropad = [I_saltpepper_zeropad; [zero_pad 0]];
end

for i = 2:3:length(I_gaussian_zeropad)
    for j = 2:3:length(I_gaussian_zeropad)
        grey_val_gaussian = [];
        grey_val_saltpepper = [];
        
        
        for k = -1:+1
            for l = -1:+1
                grey_val_gaussian = [grey_val_gaussian, I_gaussian_zeropad(i+k, j+l)];
                grey_val_saltpepper = [grey_val_saltpepper, I_saltpepper_zeropad(i+k, j+l)];
            end
        end
        
        med_gaussian = median(grey_val_gaussian);
        med_saltpepper = median(grey_val_saltpepper);
        
        I_gaussian_medfilt(i-1:i+1, j-1:j+1) = med_gaussian;
        I_saltpepper_medfilt(i-1:i+1, j-1:j+1) = med_saltpepper;
    end
end

I_gaussian_medfilt = I_gaussian_medfilt(1:length(I_gaussian), 1:length(I_gaussian));
I_saltpepper_medfilt = I_saltpepper_medfilt(1:length(I_gaussian), 1:length(I_gaussian));

fig1 = figure(1);

subplot(2,3,1)
imhist(uint8(I_gaussian));
title('Gaussian noise');

subplot(2,3,2)
imhist(uint8(I_gaussian_meanfilt));
title('Gaussian noise- mean filter');

subplot(2,3,3)
imhist(uint8(I_gaussian_medfilt));
title('Gaussian noise- median filter');

subplot(2,3,4)
imhist(I_saltpepper);
title('SaltPepper noise');

subplot(2,3,5)
imhist(uint8(I_saltpepper_meanfilt));
title('SaltPepper noise - mean filter');

subplot(2,3,6)
imhist(I_saltpepper_medfilt);
title('SaltPepper noise - median filter');


fig2 = figure(2);

subplot(2,3,1)
imshow(uint8(I_gaussian));
title('Gaussian noise');

subplot(2,3,2)
imshow(uint8(I_gaussian_meanfilt));
title('Gaussian noise- mean filter');

subplot(2,3,3)
imshow(uint8(I_gaussian_medfilt));
title('Gaussian noise- median filter');

subplot(2,3,4)
imshow(I_saltpepper);
title('SaltPepper noise');

subplot(2,3,5)
imshow(uint8(I_saltpepper_meanfilt));
title('SaltPepper noise - mean filter');

subplot(2,3,6)
imshow(I_saltpepper_medfilt);
title('SaltPepper noise - mean filter');



