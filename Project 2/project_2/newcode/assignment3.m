% Assignment 3 of Project 2
% EQ2330 Image and Video Processing
% Fall Term 2016, KTH
% Authors: Jan Zimmermann, Lars Kuger

clear all


% Load different filter banks/wavelet functions
load coeffs

%% Plot FWT coefficients with scale 4 for report


scale = 4;

% Plot image with scale 4
image = double(imread('harbour512x512.tif'));
optcoef = jzlk_fwt2Direct(image, db4, scale);
figure;
imshow(uint8(optcoef));
imagehat = jzlk_ifwt2Direct(optcoef,db4,scale);
title(sprintf('FWT Coefficients of harbour512.512.tif, scale=%d', scale));
figure;
imshow(uint8(imagehat));
reconstructionErr = sum(sum((image-imagehat).^2));
fprintf('The reconstruction error is %.10f.\n', reconstructionErr);

%% Measure PSNR
scale = 4;

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
PSNR = zeros(steps,nrimg);      % Peak Signal to Noise Ratio wrt MSE coef
PSNRdis = zeros(steps,nrimg);      % Peak Signal to Noise Ratio wrt distortion
PSNRnofwt = zeros(steps,nrimg); % No FWT, quantization only
ratenofwt = zeros(steps,nrimg);
rate = zeros(steps,nrimg);      % rate in bits/pixel
stepsize = zeros(steps,1);      % quantizer stepsize

% do this for all images
for jj=1:nrimg
    image = imread(images{jj});
    image = double(image);
    
    % Coefficients without quantization
    optcoef = jzlk_fwt2Direct(image, db4, scale);
    
    
    % With quantization
    for ii=expmin:expmax
        
        tmpidx = ii-expmin+1;
        
        % stepsize
        delta = 2^ii;
        stepsize(tmpidx) = delta;
        
        % 2D FWT
        ynew = jzlk_fwt2Direct(image, db4, scale);
        
        % Quantize coefficients
        ynew = jzlk_quantize(ynew,delta);
        
        % Calculate entropy (optimal rate)
        rate(tmpidx,jj) = jzlk_fwtRate(ynew, scale);
        
        % 2D IFWT
        imagenew = jzlk_ifwt2Direct(ynew, db4, scale);
        
        % Save Distortion, MSE for wavelet coefficients and PSNR
        d(tmpidx,jj) = sum(sum((imagenew-image).^2))/numel(image);
        MSEcoef(tmpidx,jj) = sum(sum((optcoef-ynew).^2))/numel(optcoef);
        PSNR(tmpidx,jj) = 10*log10(255^2./MSEcoef(tmpidx,jj));
        PSNRdis(tmpidx,jj) = 10*log10(255^2./d(tmpidx,jj));
        
        % PSNR without fwt
        tmpimg = jzlk_quantize(double(image),delta);
        tmpdis = sum(sum(abs(tmpimg-image).^2))/numel(image);
        PSNRnofwt(tmpidx,jj) = 10*log10(255^2./tmpdis);
        ratenofwt(tmpidx,jj) = jzlk_entropy(tmpimg);
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

% PSNR wrt distortion
PSNRdisnondb = 10.^(PSNRdis./10);
PSNRdisnondbinterp = zeros(size(PSNRdisnondb));
PSNRdisnondbinterp(:,1) = interp1(rate(:,1), PSNRdisnondb(:,1), nrate, 'linear');
PSNRdisnondbinterp(:,2) = interp1(rate(:,2), PSNRdisnondb(:,2), nrate, 'linear');
PSNRdisnondbinterp(:,3) = interp1(rate(:,3), PSNRdisnondb(:,3), nrate, 'linear');
PSNRdisavg = 10*log10(mean(PSNRdisnondbinterp')');

% PSNR for quantized image without FWT
idx = isinf(PSNRnofwt);
PSNRnofwt(idx) = []; % remove elements that are infinite
PSNRnofwt = reshape(PSNRnofwt, [], 3);
ratenofwt(idx) = [];
ratenofwt = reshape(ratenofwt, [], 3);
nrateSpatial = linspace(max(min(ratenofwt)), min(max(ratenofwt)), 10);
PSNRnofwtnondb = 10.^((PSNRnofwt)./10);
PSNRnofwtnondbinterp = zeros(length(nrate),size(PSNRnofwtnondb,2));
PSNRnofwtnondbinterp(:,1) = interp1(ratenofwt(:,1), PSNRnofwtnondb(:,1), nrateSpatial, 'linear');
PSNRnofwtnondbinterp(:,2) = interp1(ratenofwt(:,2), PSNRnofwtnondb(:,2), nrateSpatial, 'linear');
PSNRnofwtnondbinterp(:,3) = interp1(ratenofwt(:,3), PSNRnofwtnondb(:,3), nrateSpatial, 'linear');
PSNRnofwtavg = 10*log10(mean(PSNRnofwtnondbinterp')');



%% Plots

figure;

plot(nrate, PSNRavg, '-x','LineWidth',2);
grid on;
hold on;
plot(nrate, PSNRdisavg, 'r--o', 'LineWidth', 2);
plot(nrateSpatial, PSNRnofwtavg, 'k-.', 'LineWidth',2);
title(sprintf('FWT Lossy image compression, Scale=%d', scale));
xlabel('Optimum Rate [bits/pixel]');
ylabel('PSNR [dB]');
legend({'PSNR wrt coef MSE','PSNR wrt distortion', 'PSNR no FWT' },'Location', 'northwest');
