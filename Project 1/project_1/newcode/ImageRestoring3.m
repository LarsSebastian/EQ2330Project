% Assignment 2.2 for Project 1 in EQ2330
% Fall Term 2016
% Course EQ2330 Image and Video Processing
% Project 1
% Authors: Jan Zimmermann, Lars Kuger

%% Clear variables and Command Window
clc;
clear all;

%% Load Image

g = imread('man512_outoffocus.bmp');

[M,N] = size(g);

%% Bluring and Noise

h = myblurgen('gaussian', 8);

noise_var = 0.0833;






%% Image restoration
 
nsr = noise_var/var(double(g(:)));
f_restored = deconvwnr(g, h, nsr);

for i = 1:M
    for j = 1:N
        f_restored(i,j) = min(max(f_restored(i,j), 0), 255);
    end
end


%% Plots



fig3 = figure(3);
subplot(1,2,1);
imshow(uint8(g));
title('blured and noisy image');

subplot(1,2,2);
imshow(uint8(f_restored));
title('restored image');









