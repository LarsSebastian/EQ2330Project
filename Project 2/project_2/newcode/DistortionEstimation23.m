% Assignment 2.3 for Project 2 in EQ2330
% Fall Term 2016
% Course EQ2330 Image and Video Processing
% Project 2
% Authors: Lars Kuger, Jan Zimmermann

%% clear workspace and command window
clear all;
clc;


%% Calculate distortion
%% loop over all quantzation stepsizes, initiliazation of variables
delta = [2^0 2^1 2^2 2^3 2^4 2^5 2^6 2^7 2^8 2^9];
R = zeros(length(delta), 3);
PSNR = [];
PSNRdis = [];
images = {'harbour512x512', 'boats512x512', 'peppers512x512'};


for t = 1:length(images) %length(images);
    for u = 1:length(delta)
       
        u
        %% Load image
        I = imread(images{t}, 'tif');

        [M,N] = size(I);

        if mod(M,8) ~= 0 || mod(N,8) ~=0
            disp('Image not divisible by 8');
        end

        %% separate images into blocks of 8x8
        
        I8 = mat2cell(I, repmat(8, 1, M/8), repmat(8, 1, N/8));
        
        
        %% perform DCTII and quantization on images
        I8_dctquant = cell(M/8, N/8);
        
        I8_dct = cellfun(@dct2, I8, 'UniformOutput', 0); 
        
        for i = 1:M/8
            for j = 1:N/8
                I8_dctquant{i,j} = jzlk_quantize(I8_dct{i,j}, delta(u));
            end
        end



        %% Calculate Distortion using MSE (get quantized, unblocked image first)

        
        I8_quant = cellfun(@idct2, I8_dctquant, 'UniformOutput', 0); 
        I_quant = cell2mat(I8_quant);
        I_dct = cell2mat(I8_dct);
        I_dctquant = cell2mat(I8_dctquant);
        
       

        %% Calculate Distortion, MSE and PSNR

        D = abs(I- uint8(I_quant)).^2;
        MSE = sum(D(:))/(M*N);

        D_dct = abs(I_dct - I_dctquant).^2;
        MSE_dct = sum(D_dct(:))/(M*N);

        PSNR(u,t) = 10*log10(255^2/MSE);
        PSNRdis(u,t) = 10*log10(255^2/MSE_dct);

        %% Calculate Entropy-Matrix for different coefficient indexes : A11, B11,... A12, B12,...

        coeff_vec = [];
        
        EntropyMat = zeros(8,8);
        
        
        for k = 1:8
            for l = 1:8
                coeff_vec = cellfun(@(x) x(k,l), I8_dctquant, 'UniformOutput', false);
                coeff_vec = cell2mat(coeff_vec);
                EntropyMat(k,l) = jzlk_entropy2(coeff_vec);
            end
        end

        R(u,t) = mean(EntropyMat(:));
        
        %% Calculate Rate, when no transformation is performed, (Copied
% from Lars Kuger and adjusted)
        Itmpquant = uint8(jzlk_quantize(double(I),delta(u)));
        tmpdis = sum(sum(abs(Itmpquant-I).^2))/numel(I);
        PSNRnodct(u,t) = 10*log10(255^2./tmpdis);
        ratenodct(u,t) = jzlk_entropy2(Itmpquant);
    end
end

%% In order to get one PSNR-rate curve, interpolate PSNR in non-db (Copied
% from Lars Kuger and adjusted)
nrate = linspace(max(min(R)), min(max(R)), 10);
PSNRnondb = 10.^(PSNR./10);
PSNRnondbinterp = zeros(size(PSNRnondb));
PSNRnondbinterp(:,1) = interp1(R(:,1), PSNRnondb(:,1), nrate, 'linear');
PSNRnondbinterp(:,2) = interp1(R(:,2), PSNRnondb(:,2), nrate, 'linear');
PSNRnondbinterp(:,3) = interp1(R(:,3), PSNRnondb(:,3), nrate, 'linear');
PSNRavg = 10*log10(mean(PSNRnondbinterp')');

PSNRdisnondb = 10.^(PSNRdis./10);
PSNRdisnondbinterp = zeros(size(PSNRdisnondb));
PSNRdisnondbinterp(:,1) = interp1(R(:,1), PSNRdisnondb(:,1), nrate, 'linear');
PSNRdisnondbinterp(:,2) = interp1(R(:,2), PSNRdisnondb(:,2), nrate, 'linear');
PSNRdisnondbinterp(:,3) = interp1(R(:,3), PSNRdisnondb(:,3), nrate, 'linear');
PSNRdisavg = 10*log10(mean(PSNRdisnondbinterp')');

idx = isinf(PSNRnodct);
PSNRnodct(idx) = []; % remove elements that are infinite
PSNRnodct = reshape(PSNRnodct, [], 3);
ratenodct(idx) = [];
ratenodct = reshape(ratenodct, [], 3);
PSNRnofwtnondb = 10.^((PSNRnodct)./10);
PSNRnofwtnondbinterp = zeros(length(nrate),size(PSNRnofwtnondb,2));
PSNRnofwtnondbinterp(:,1) = interp1(ratenodct(:,1), PSNRnofwtnondb(:,1), nrate, 'linear');
PSNRnofwtnondbinterp(:,2) = interp1(ratenodct(:,2), PSNRnofwtnondb(:,2), nrate, 'linear');
PSNRnofwtnondbinterp(:,3) = interp1(ratenodct(:,3), PSNRnofwtnondb(:,3), nrate, 'linear');
PSNRnofwtavg = 10*log10(mean(PSNRnofwtnondbinterp')');





%% plot

fig2 = figure(2);

plot(R, PSNR);
xlabel('bit-rate');
ylabel('PSNR [dB]');

fig3 = figure(3);

plot(R, PSNRdis);
xlabel('bit-rate');
ylabel('PSNR [dB]');

fig4 = figure(4)
plot(nrate, PSNRavg);

fig5 = figure(5)
plot(nrate, PSNRdisavg);

figure;

plot(nrate, PSNRavg, '-','LineWidth',2);
grid on;
hold on;
plot(nrate, PSNRdisavg, 'r--', 'LineWidth', 2);
plot(nrate, PSNRnofwtavg, 'k-.', 'LineWidth',2);
title(sprintf('DCT Lossy image compression'));
xlabel('Optimum Rate [bits/pixel]');
ylabel('PSNR [dB]');
legend({'PSNR wrt coef MSE','PSNR wrt distortion', 'PSNR no DCT'},'Location', 'northwest');
