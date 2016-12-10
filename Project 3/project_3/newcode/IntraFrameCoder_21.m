% Assignment 2.1 of Project 3
% EQ2330 Image and Video Processing
% Fall Term 2016, KTH
% Authors: Jan Zimmermann, Lars Kuger

%%
clear all;
clc;
%% load video

%file_name = 'mother-daughter_qcif.yuv';
file_name = 'foreman_qcif.yuv';
frame_size = [176 144]; %taken from example 

V = yuv_import_y(file_name,frame_size,50);

delta = [2^3, 2^4, 2^5, 2^6];
%delta = 2^4;

%% seperate all frames into blocks of 16 then blocks of 8, apply dct2 and quantization

%Initialize all Matrices

Vblk16 = cell(length(V), 1);
R = cell(length(delta), length(V));
PSNR = cell(length(delta), length(V));



for i = 1:length(delta)  % loop over step sizes of quantizer
    for j = 1:length(V) % loop over all frames
        j
        
        
        Vblk16{j} = mat2cell(V{j}, repmat(16, 1, frame_size(2)/16), repmat(16, 1, frame_size(1)/16)); %divide each frame into blocks of 16x16
        [M,N] = size(Vblk16{j});
        
        for ii = 1:M
            for jj =1:N
                [R{j,i}(ii,jj), PSNR{j,i}(ii,jj)] = encode_intraframe(Vblk16{j}{ii,jj}, delta(i));
            end
        end



    end
end

%% average PSNR, average rate

%average PSNR
PSNRavg(1,1) = mean(PSNR(:,1));
PSNRavg(1,2) = mean(PSNR(:,2));
PSNRavg(1,3) = mean(PSNR(:,3));
PSNRavg(1,4) = mean(PSNR(:,4));

%average rate over all frames * frame rate
Ravg(1,1) = mean(R(:, 1))*30;
Ravg(1,2) = mean(R(:, 2))*30;
Ravg(1,3) = mean(R(:, 3))*30;
Ravg(1,4) = mean(R(:, 4))*30;

figure;
plot(Ravg, PSNRavg, '+');
xlable('average Rate');
ylable('average PSNR');





        