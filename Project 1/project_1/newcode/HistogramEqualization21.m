% Assignment 2.1 for Project 1 in EQ2330
% Fall Term 2016
% Course EQ2330 Image and Video Processing
% Project 1
% Authors: Jan Zimmermann, Lars Kuger

%% Clear variables and Command Window
clc;
clear all;

%% Load Image

I = imread('images/lena512.bmp');
[M,N] = size(I);

%% Plot Histogram
fig1 = figure(1);
imhist(I);
xlabel('gray levels');
ylabel('# of occurrence');
title('original histogram');

%% low-contrast image

a = 0.2;  % 0 < a < 1
b = 50;   % 0 < b < 255(1-a)

Ilow = a*I+b;

% fig2 = figure(2);
% imshow(uint8(Ilow));

fig3 = figure(3);
set(gca,'fontsize',18)
imhist(Ilow);
xlabel('gray levels');
ylabel('# of occurrence');
title('low contrast histogram');

%% Histogram Equalization
num_greyval = imhist(Ilow);
p_vec = num_greyval./(M*N);

for i =1:length(p_vec)
    sum_vec =  cumsum(p_vec(1:i));
    g(i) = sum_vec(end);
end
g = g*255;

for i = 1:N
    for j = 1:M
        Ieq(i,j) = g(Ilow(i,j));
    end
end


fig4 = figure(4);
imhist(uint8(Ieq));
xlabel('gray levels');
ylabel('# of occurrence');
title('equalized histogram');
ylim([0, 11000])



