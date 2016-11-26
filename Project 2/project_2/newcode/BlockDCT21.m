% Assignment 2.1 for Project 2 in EQ2330
% Fall Term 2016
% Course EQ2330 Image and Video Processing
% Project 2
% Authors: Lars Kuger, Jan Zimmermann

% %% clear workspace and command window
% clear all;
% clc;

%% load image

I = imread('airfield512x512', 'tif');

[M,N] = size(I);

if mod(M,8) ~= 0 || mod(N,8) ~=0
    disp('Image not divisible by 8');
end

% figure;
% imshow(I);

%% separate images into blocks of 8x8
I8 = cell(M/8, N/8);

for i = 1:M/8
    for j = 1:N/8
        I8{i,j} = I(i:i+7, j:j+7);
    end
end

%% perform DCT-II on blocks

I8_dct = cell(M/8, N/8);

for i = 1:M/8
    for j = 1:N/8
        I8_dct{i,j} = jzlk_DCTII_v2(I8{i,j});
    end
end

%% Quantization

I8_dct_quant{i,j} = cell(M/8, N/8);

for i = 1:M/8
    for j = 1:N/8
        I8_dct_quant{i,j} = jzlk_MatQuant(I8_dct{i,j}, 2^4);
    end
end

% mat = [-10:1:10];
% 
% matquant = jzlk_MatQuant(mat, 2^3);
% 
% fig1 = figure(1);
% plot(mat, matquant, '*');
% grid on;



