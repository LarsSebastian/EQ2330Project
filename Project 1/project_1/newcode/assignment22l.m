% Assignment 2.2 for Project 1 in EQ2330
% Fall Term 2016
% Course EQ2330 Image and Video Processing
% Project 1
% Authors: Jan Zimmermann, Lars Kuger

% pick one image from directory images
picName = 'lena512.bmp';

% read image
orgimg  = imread(picName, 'bmp');
[M, N] = size(orgimg);

%% Generate Noise and Disturb Images

% Gaussian distributed noise
sigma2 = 64;
mu = 0;
gaussnoise = mynoisegen('gaussian', M, N, mu, sigma2);
im_gaussn = double(orgimg) + gaussnoise;
im_gaussn = uint8(im_gaussn);

% Salt pepper noise
im_saltp = orgimg;
n = mynoisegen('saltpepper', 512, 512, .05, .05);
im_saltp(n==0) = 0; % set the gray value to 0 at the positions where n==0
im_saltp(n==1) = 255;

%% Plot images and histograms

histfig = figure;

% Histogram of original image
subplot(3,3,1);
jzlk_hist(orgimg, 'Histogram without noise');

% Histogram with Gaussian noise
subplot(3,3,2);
jzlk_hist(im_gaussn, 'Histogram with Gaussian Noise');

% Histogram with salt pepper noise
subplot(3,3,3);
jzlk_hist(im_saltp, 'Histogram with salt pepper noise');


imfig = figure;

% image with Gaussian noise
subplot(2,3,1);
imshow(im_gaussn);
title('Image with Gaussian Noise');

% image with salt peppers noise
subplot(2,3,4);
imshow(im_saltp);
title('Image with Salt Pepper Noise');


%% Mean filter

% mean filter
mfilter = 1/9*ones(3);

% conv2 will zero pad automatically and return only relevant part when
% 'same' is given as a parameter
im_gaussn_mfilt = uint8(conv2(double(im_gaussn),mfilter, 'same'));
im_saltp_mfilt = uint8(conv2(double(im_saltp), mfilter, 'same'));

% histograms
figure(histfig);

subplot(3,3,5);
jzlk_hist(im_gaussn_mfilt, 'Histogram - Gaussian Noise - Filtered');

subplot(3,3,6);
jzlk_hist(im_saltp_mfilt, 'Histogram - Salt Pepper Noise - Filtered');

% images
figure(imfig);

subplot(2,3,2);
imshow(im_gaussn_mfilt);
title('Gaussian Noise - Mean');

subplot(2,3,5);
imshow(im_saltp_mfilt);
title('Salt Pepper - Mean');


%% Median filter

% Apply 3x3 median filter, zero padding is automatically done
im_gaussn_median = medfilt2(im_gaussn);
im_saltp_median = medfilt2(im_saltp);

% histograms
figure(histfig);

subplot(3,3,8);
jzlk_hist(im_gaussn_median, 'Histogram - Gaussian Noise - Median');

subplot(3,3,9);
jzlk_hist(im_saltp_median, 'Histogram - Salt Pepper - Median');

% images
figure(imfig);

subplot(2,3,3);
imshow(im_gaussn_median);
title('Gaussian Noise - Median');

subplot(2,3,6);
imshow(im_saltp_median);
title('Salt Pepper - Median');


