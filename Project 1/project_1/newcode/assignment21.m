% Assignment 2.1 for Project 1 in EQ2330
% Fall Term 2016
% Course EQ2330 Image and Video Processing
% Project 1
% Authors: Jan Zimmermann, Lars Kuger

% pick one image from directory images
picName = 'lena512.bmp';

% read image and make it a vector
orgimg  = imread(picName, 'bmp');
[N, M] = size(orgimg);
imVec      = orgimg(:);


%% create histogram

% specify bin edges
figure;
subplot(2,2,1);
imhist(imVec);
title(sprintf('Histogram of picture %s', picName'));
xlabel('Gray level');
ylabel('# of occurence');

%% simulate low contrast image

a = 0.2;
b = 50;

% check if a and b are valid
if a<=0 || a >= 1
   fprintf('Error: a must be in the range 0 to 1 but a=%f', a); 
   return;
end
if b<=0 || b >= 255*(1-a)
   fprintf('Error: b must be in the range 0 to 255*(1-a) but b= %f', b);
   return;
end

% g(x, y) = min(max(⌊a · f (x, y) + b⌉, 0), 255)
% max and min operations as well as roundings are automatically done by 
% matlab since img is in uint8 format
% to test this, just uncomment the following line
% diff = round(a*double(orgimg)+b) - double((a*orgimg+b));
lcimg = a*orgimg + b;
lcimVec = lcimg(:);

% plot the corresponding histogram
subplot(2,2,2)
imhist(lcimVec);
lchvalues = imhist(lcimVec);
title(sprintf('Histogram of low contrast picture %s', picName'));
xlabel('Gray level');
ylabel('# of occurence');


%% Implement histogram equalization

% probability density function and cumulative distribution function
imgpdf = 1/(N*M) * lchvalues;
imgcdf = cumsum(imgpdf);
cdf8bit = imgcdf*(2^8 -1);

% equalization
eqimg = zeros(N, M, 'uint8');
for xx=1:N
   for yy=1:M
       eqimg(xx, yy) = cdf8bit(lcimg(xx,yy));
   end
end

% plot the corresponding histogram for the equalized image
subplot(2,2,3)
imhist(eqimg(:));
eqvalues = imhist(eqimg(:));
title(sprintf('Histogram of equalized l-c image %s', picName'));
xlabel('Gray level');
ylabel('# of occurence');


%% Plot the images

% plot original image, low contrast image and equalized low contrast image
figure; 
subplot(2,2,1)
imshow(orgimg);
title(sprintf('Original image %s', picName));
subplot(2,2,2);
imshow(lcimg);
title(sprintf('Low contrast image %s', picName));
subplot(2,2,3);
imshow(eqimg);
title(sprintf('Equalized l-c image %s', picName));
