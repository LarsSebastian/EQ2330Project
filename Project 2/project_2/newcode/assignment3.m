% Assignment 3 of Project 2
% EQ2330 Image and Video Processing
% Fall Term 2016, KTH
% Authors: Jan Zimmermann, Lars Kuger

% Load different filter banks/wavelet functions
load coeffs

% the larger the scale, the fewer bits/pixel are required for lossless
% transmission
scale = 1;

% Plot image with scale 4
image = imread('harbour512x512.tif');
optcoef = jzlk_fwt2Direct(image, db4, scale);
figure;
imshow(uint8(optcoef));
imagehat = jzlk_ifwt2Direct(optcoef,db4,scale);
figure;
imshow(uint8(imagehat));
reconstructionErr = sum(sum((image-imagehat).^2));
fprintf('The reconstruction error is %.10f.\n', reconstructionErr);

%% Measure PSNR
scale = 1;

% images to use for analysis
images = {'harbour512x512.tif', 'boats512x512.tif', 'peppers512x512.tif'};
nrimg = size(images,2);

% stepsize 2^exp. Note that for very small steps or high scales, the PSNR 
% will eventually diverge to infinity, e.g. lossless compression
expmin = 0;
expmax = 9;
steps = expmax-expmin;

% initialize the arrays
d = zeros(steps,nrimg);         % distortion
MSEcoef = zeros(steps,nrimg);   % Mean Square Error in frequency domain
PSNR = zeros(steps,nrimg);      % Peak Signal to Noise Ratio
rate = zeros(steps,nrimg);      % rate in bits/pixel
stepsize = zeros(steps,1);      % quantizer stepsize

% do this for all images
for jj=1:nrimg
    image = imread(images{jj});
    
    % Coefficients without quantization
    optcoef = jzlk_fwt2Direct(image, db4, scale);
    
    % With quantization
    for ii=expmin:expmax
        % stepsize
        delta = 2^ii;
        stepsize(ii-expmin+1) = delta;
        
        % 2D FWT
        ynew = jzlk_fwt2Direct(image, db4, scale);
        
        % Quantize coefficients
        ynew = jzlk_quantize(ynew,delta);
        
        % Calculate entropy (optimal rate)
        rate(ii-expmin+1,jj) = jzlk_fwtRate(ynew, scale);
        
        % 2D IFWT
        imagenew = jzlk_ifwt2Direct(ynew, db4, scale);
        
        % Save Distortion, MSE for wavelet coefficients and PSNR
        d(ii-expmin+1,jj) = sum(sum((imagenew-image).^2))/numel(image);
        MSEcoef(ii-expmin+1,jj) = sum(sum((optcoef-ynew).^2))/numel(optcoef);
        PSNR(ii-expmin+1,jj) = 10*log10(255^2./MSEcoef(ii-expmin+1,jj));
    end
end

% In order to get one PSNR-rate curve, interpolate PSNR in non-db
nrate = linspace(max(min(rate)), min(max(rate)), 10);
PSNRnondb = 10.^(PSNR./10);
PSNRnondbinterp = zeros(size(PSNRnondb));
PSNRnondbinterp(:,1) = interp1(rate(:,1), PSNRnondb(:,1), nrate, 'linear');
PSNRnondbinterp(:,2) = interp1(rate(:,2), PSNRnondb(:,2), nrate, 'linear');
PSNRnondbinterp(:,3) = interp1(rate(:,3), PSNRnondb(:,3), nrate, 'linear');
PSNRavg = 10*log10(mean(PSNRnondbinterp')');


%% Plots

linetypes = {'--o','-.x', '-*'};
figure;

% plot PSNR vs stepsize
% subplot(1,2,1);
% for jj=1:nrimg
%    semilogx(stepsize,PSNR(:,jj), linetypes{jj});
%    hold on;
% end
% grid on;
% title('Lossy image compression');
% xlabel('Quantizer step-size');
% xlim([min(stepsize) max(stepsize)]);
% xticks(stepsize);
% xticklabels(stepsize);
% ylabel('PSNR [dB]');
% legend(images);

% plot PSNR vs rate
% subplot(1,2,2);
% for jj=1:nrimg
%     plot(rate(:,jj),PSNR(:,jj), linetypes{jj});
%     hold on;
% end
plot(nrate, PSNRavg, 'LineWidth',2);
grid on;
title(sprintf('Lossy image compression, Scale=%d', scale));
xlabel('Optimum Rate [bits/pixel]');
%xlim([min(rate(:,1)) max(rate(:,jj)]);
%xticks(nrate);
%xticklabels(nrate);
ylabel('PSNR [dB]');
%imgavg = {'harbour512x512.tif', 'boats512x512.tif', 'peppers512x512.tif', 'Average'};
%legend(imgavg, 'Location', 'northwest');
legend('Average of 3 images','Location', 'northwest');



% figure;
% 
% % plot distortion vs stepsize
% subplot(1,2,1);
% for jj=1:nrimg
%     plot(rate(:,jj),d(:,jj), linetypes{jj});
%     hold on;
% end
% grid on;
% title('Lossy image compression');
% xlabel('Rate');
% %xlim([min(stepsize) max(stepsize)]);
% %xticks(stepsize);
% %xticklabels(stepsize);
% ylabel('Distortion');
% legend(images, 'Location', 'northwest');
% 
% subplot(1,2,2);
% % plot MSEcoef vs stepsize
% for jj=1:nrimg
%     semilogx(stepsize,MSEcoef(:,jj), linetypes{jj});
%     hold on;
% end
% grid on;
% title('Lossy image compression');
% xlabel('Quantizer step-size');
% xlim([min(stepsize) max(stepsize)]);
% xticks(stepsize);
% xticklabels(stepsize);
% ylabel('MSE FWT Coefficients');
% legend(images, 'Location', 'northwest');