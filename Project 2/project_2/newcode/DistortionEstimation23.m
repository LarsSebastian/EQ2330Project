% Assignment 2.1 for Project 2 in EQ2330
% Fall Term 2016
% Course EQ2330 Image and Video Processing
% Project 2
% Authors: Lars Kuger, Jan Zimmermann

%% clear workspace and command window
clear all;
clc;

%% Load image, perform blockwise DCT-II and quantize
%BlockDCT21;

%% Calculate distortion
%% loop over all quantzation stepsizes
delta = [2^0 2^1 2^2 2^3 2^4 2^5 2^6 2^7 2^8 2^9];
R = [];
PSNR = [];


for u = 1:length(delta)
    u
    %% Load image
    I = imread('peppers512x512', 'tif');

    [M,N] = size(I);

    if mod(M,8) ~= 0 || mod(N,8) ~=0
        disp('Image not divisible by 8');
    end

    %% separate images into blocks of 8x8
    I8 = cell(M/8, N/8);
    k = 1;
    for i = 1:M/8
        l = 1;
        for j = 1:N/8
            I8{i,j} = I(k:k+7, l:l+7);
            l = l + 8;
        end
        k = k + 8;
    end
    %% perform DCTII on images
    I8_dct = cell(M/8, N/8);

    for i = 1:M/8
        for j = 1:N/8
            I8_dct{i,j} = dct2(I8{i,j});
        end
    end

    %% Perform quantization
    I8_dctquant = cell(M/8, N/8);

    for i = 1:M/8
        for j = 1:N/8
            I8_dctquant{i,j} = jzlk_quantize(I8_dct{i,j}, delta(u));
        end
    end

    %% Calculate Distortion using MSE (get quantized, unblocked image first)
    k = 1;
    l = 1;
    I8_quant = cell(M/8, N/8);

    for i = 1:M/8
        l = 1;
        for j = 1:N/8
            I_quant(k:k+7,l:l+7) = uint8(idct2(I8_dctquant{i,j}));
            l = l +8;
        end
        k = k+8;
    end


    D = abs(I-I_quant).^2;
    MSE = sum(D(:))/(M*N);

    % fig1 = figure(1);
    % imshow(I_quant);

    PSNR = [PSNR 10*log10(255^2/MSE)];

    %% Calculate Entropy-Matrix for different coefficient indexes : A11, B11,... A12, B12,...

    coeff_vec = [];
    EntropyMat = zeros(8,8);

    for k = 1:8
        for l = 1:8
            for i = 1:M/8
                for j = 1:N/8                
                    coeff_vec = [coeff_vec I8_dctquant{i,j}(k,l)];
                end
            end
            EntropyMat(k,l) = jzlk_entropy(coeff_vec);
        end
    end

    R = [R mean(EntropyMat(:))];
end


%% plot

fig2 = figure(2);

plot(R, PSNR);
xlabel('bit-rate');
ylabel('PSNR [dB]');

