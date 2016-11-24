% Assignment 3 of Project 2
% EQ2330 Image and Video Processing
% Fall Term 2016, KTH
% Authors: Jan Zimmermann, Lars Kuger

load coeffs


%% Measure PSNR

images = {'harbour512x512.tif', 'boats512x512.tif', 'peppers512x512.tif'};

nrimg = size(images,2);

d = zeros(10,nrimg); % distortion
MSEcoef = zeros(10,nrimg);
PSNR = zeros(10,nrimg); % Peak Signal to Noise Ratio
stepsize = zeros(10,1); % quantizer stepsize

for jj=1:nrimg
    image = imread(images{jj});
    
    % Without quantization
    optcoef = jzlk_fwt2Direct(image, db4, scale);
    
    % With quantization
    for ii=0:9
        delta = 2^ii;
        stepsize(ii+1) = delta;
        ynew = jzlk_fwt2Direct(image, db4, scale);
        ynew = jzlk_quantize(ynew,delta);
        imagenew = jzlk_ifwt2Direct(ynew, db4, scale);
        
        d(ii+1,jj) = sum(sum((imagenew-image).^2))/numel(image);
        MSEcoef(ii+1,jj) = sum(sum((optcoef-ynew).^2))/numel(optcoef);
        PSNR(ii+1,jj) = 10*log10(255^2./d(ii+1,jj));
    end
end


%% Plots

linetypes = {'--o','-.x', '-*'};
figure;
for jj=1:nrimg
    semilogx(stepsize,PSNR(:,jj), linetypes{jj});
    hold on;
end
grid on;
title('Lossy image compression');
xlabel('Quantizer step-size');
xlim([min(stepsize) max(stepsize)]);
xticks(stepsize);
xticklabels(stepsize);
ylabel('PSNR [dB]');
legend(images);





figure;

subplot(1,2,1);
for jj=1:nrimg
    semilogx(stepsize,d(:,jj), linetypes{jj});
    hold on;
end
grid on;
title('Lossy image compression');
xlabel('Quantizer step-size');
xlim([min(stepsize) max(stepsize)]);
xticks(stepsize);
xticklabels(stepsize);
ylabel('Distortion');
legend(images);

subplot(1,2,2);
for jj=1:nrimg
    semilogx(stepsize,MSEcoef(:,jj), linetypes{jj});
    hold on;
end
grid on;
title('Lossy image compression');
xlabel('Quantizer step-size');
xlim([min(stepsize) max(stepsize)]);
xticks(stepsize);
xticklabels(stepsize);
ylabel('MSE FWT Coefficients');
legend(images);