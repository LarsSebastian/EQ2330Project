% Assignment 3 of Project 3
% EQ2330 Image and Video Processing
% Fall Term 2016, KTH
% Authors: Jan Zimmermann, Lars Kuger

%% 
clc;
clear all;

%% load video

file_name = 'foreman_qcif.yuv';
frame_size = [176 144]; %taken from example 

V = yuv_import_y(file_name,frame_size,50);

%delta = [2^3, 2^4, 2^5, 2^6];
delta = 2^4;

%% Calculation of Lagrangian cost function

decision = cell(length(V), length(delta));
R = cell(length(delta), length(V));
PSNR = cell(length(delta), length(V));

for i = 1:length(delta)  % loop over step sizes of quantizer
    lambda = 0.2*delta(i)^2; % squared?
    for j = 1:length(V)-1 % loop over all frames, comparison between two frames: -1
        j
        
        % frame j divided into blocks of 16x16
        Vblk16_1 = mat2cell(V{j}, repmat(16, 1, frame_size(2)/16), ...
            repmat(16, 1, frame_size(1)/16)); 
        
        % frame j+1 divided into blocks of 16x16
        Vblk16_2 = mat2cell(V{j+1}, repmat(16, 1, frame_size(2)/16), ...
            repmat(16, 1, frame_size(1)/16));
        
        [M,N] = size(Vblk16_1);
        
        % loop over all 16x16 blocks
        for ii = 1:M
            for jj =1:N
                
                
                [DCTCoef,  Dist_intra] = encode_intraframe2(Vblk16_1{ii,jj}, delta(i));
                R_intra = jzlk_getRate(DCTCoef, codebooks, i);
                R_intra = R_intra + 1;
                
                Dist_copy = sum(abs((Vblk16_1{ii,jj}(:) - Vblk16_2{ii,jj}(:))).^2)*1/(256);
                R_copy = 1;
                
                J_intra = Dist_intra + lambda*R_intra;
                J_copy = Dist_copy + lambda*R_copy;
                
                if J_intra < J_copy
                    decision{j,i}{ii,jj} = 1;
                    R{j,i}(ii,jj) = J_intra; 
                    PSNR{j,i}(ii,jj) = 10*log10(255^2/Dist_intra);
                else
                    decision{j,i}{ii,jj} = 2;
                    R{j,i}(ii,jj) = J_copy; 
                    PSNR{j,i}(ii,jj) = 10*log10(255^2/Dist_copy);
                end
                
                
                
                
            end
        end
        
    end
end
