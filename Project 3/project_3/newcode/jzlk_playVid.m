function [  ] = jzlk_playVid( frames, rate )
%Play videos that consist of images in cell arrays easily
%   Use for example jzlk_playVid(Vreceived_Intra(1,:), 30)

figure;
for ii=1:length(frames)
    imshow(uint8(frames{ii}));
    pause(1/rate);
end

end

