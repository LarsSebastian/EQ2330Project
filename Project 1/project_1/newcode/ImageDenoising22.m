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
[M,N] = size(I);

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
I_saltpepper_zeropad = I_saltpepper;

I_gaussian_zeropad = [zeros(1,M); I_gaussian_zeropad; zeros(1,M)];
I_gaussian_zeropad = [zeros(M+2,1), I_gaussian_zeropad, zeros(M+2,1)];

I_saltpepper_zeropad = [zeros(1,M); I_saltpepper_zeropad; zeros(1,M)];
I_saltpepper_zeropad = [zeros(M+2,1), I_saltpepper_zeropad, zeros(M+2,1)];

% while round(length(I_gaussian_zeropad)/3) ~= length(I_gaussian_zeropad)/3
%     zero_pad = zeros(1,length(I_gaussian));
%     I_gaussian_zeropad = [I_gaussian, zero_pad'];
%     I_gaussian_zeropad = [I_gaussian_zeropad; [zero_pad 0]];
%     
%     I_saltpepper_zeropad = [I_saltpepper, zero_pad'];
%     I_saltpepper_zeropad = [I_saltpepper_zeropad; [zero_pad 0]];
% end

for i = 2:1:length(I_gaussian_zeropad)-1
    for j = 2:1:length(I_gaussian_zeropad)-1
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
        
        I_gaussian_medfilt(i,j) = med_gaussian;
        I_saltpepper_medfilt(i,j) = med_saltpepper;
    end
end

I_gaussian_medfilt = I_gaussian_medfilt(2:end, 2:end);
I_saltpepper_medfilt = I_saltpepper_medfilt(2:end, 2:end);

fig1 = figure(1);

subplot(2,3,1)
hist(uint8(I_gaussian(:)), [0:255]);
set(gca,'fontsize',12)
title('Gaussian noise');
xlabel('gray levels');
ylabel('# of occurrence');
axis([0 256 0 3000])


subplot(2,3,2)
set(gca,'fontsize',12)
hist(uint8(I_gaussian_meanfilt(:)), 0:255);
title('Gaussian noise- mean filter');
xlabel('gray levels');
ylabel('# of occurrence');
axis([0 256 0 3000])


subplot(2,3,3)
set(gca,'fontsize',12)
hist(uint8(I_gaussian_medfilt(:)), 0:255);
title('Gaussian noise- median filter');
xlabel('gray levels');
ylabel('# of occurrence');
axis([0 256 0 3000])


subplot(2,3,4)
set(gca,'fontsize',12)
hist(I_saltpepper(:), 0:255);
title('SaltPepper noise');
xlabel('gray levels');
ylabel('# of occurrence');
axis([0 256 0 3000])


subplot(2,3,5)
set(gca,'fontsize',12)
hist(uint8(I_saltpepper_meanfilt(:)), 0:255);
title('SaltPepper noise - mean filter');
xlabel('gray levels');
ylabel('# of occurrence');
axis([0 256 0 3000])


subplot(2,3,6)
set(gca,'fontsize',12)
hist(I_saltpepper_medfilt(:), 0:255);

title('SaltPepper noise - median filter');
xlabel('gray levels');
ylabel('# of occurrence');
axis([0 256 0 3000])





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

fig3 = figure(3);
% subplot(3,1,1)
set(gca,'fontsize',12)
hist(I(:), 0:255);
title('histogram of clear image');
xlabel('gray levels');
ylabel('# of occurrence');
axis([0 256 0 3000])

% subplot(3,1,2);
% set(gca,'fontsize',12)
% hist(uint8(I_gaussian(:)), 0:255);
% title('histogram of image with gaussian noise');
% xlabel('gray levels');
% ylabel('# of occurrence');
% axis([0 256 0 3000])
% 
% subplot(3,1,3);
% set(gca,'fontsize',12)
% hist(I_saltpepper(:), 0:255);
% title('histogram of image with salt-peper-noise');
% xlabel('gray levels');
% ylabel('# of occurrence');
% axis([0 256 0 3000])





