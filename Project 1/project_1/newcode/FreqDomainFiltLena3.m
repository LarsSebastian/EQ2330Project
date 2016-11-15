% Assignment 2.2 for Project 1 in EQ2330
% Fall Term 2016
% Course EQ2330 Image and Video Processing
% Project 1
% Authors: Jan Zimmermann, Lars Kuger

%% Clear variables and Command Window
clc;
clear all;

%% Load Image

f = imread('lena512.bmp');

[M,N] = size(f);

%% Image Bluring and adding noise

h = myblurgen('gaussian', 8);
noise_mean = 0;
noise_var = 0.0833; % Why 32? Maybe 0.0833 instead?
noise_gaussian = mynoisegen('gaussian', M, N, noise_mean, noise_var);

f_blured = conv2(double(f), h, 'same');
g = f_blured +noise_gaussian;



%% Fast Fourier Transform 
F = fft2(f);
G = fft2(g);
H = fft2(h);

Fmagn = abs(F);
Gmagn = abs(G);

%% Image restoration with own function

f_restored = jzlk_wienerFilter(g, h, noise_var);


%% Image restoration
 
% nsr = noise_var/var(double(f(:)));
% f_restored = deconvwnr(g, h, nsr);
% 
% for i = 1:M
%     for j = 1:N
%         f_restored(i,j) = min(max(f_restored(i,j), 0), 255);
%     end
% end


%% Plots

fig1 = figure(1);
subplot(1,2,1);
imshow(f);
title('original image');

subplot(1,2,2);
imshow(uint8(g));
title('blured and noisy image');

fig2 = figure(2);
subplot(1,2,1);
imagesc(fftshift(log(Fmagn)));
title('Spectrum of original image');

subplot(1,2,2);
imagesc(fftshift(log(Gmagn)));
title('Spectrum of blured and noisy image');


fig3 = figure(3);
subplot(1,2,1);
imshow(uint8(g));
title('blured and noisy image');

subplot(1,2,2);
imshow(uint8(f_restored));
title('restored image');
