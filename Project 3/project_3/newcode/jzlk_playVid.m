function [  ] = jzlk_playVid( frames, rate )
%Play videos that consist of images in cell arrays easily
%   Use for example jzlk_playVid(Vreceived_Intra(1,:), 30)

figure;

data = uint8(frames{1});
h = imshow(data);
pause(1/rate);

for ii=1:length(frames)
    h.CData = uint8(frames{ii});
    pause(1/rate);
end

end

