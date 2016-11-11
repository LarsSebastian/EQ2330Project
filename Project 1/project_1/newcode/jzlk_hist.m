function [h] = jzlk_hist( image, ptitle )
%Creates histogram of image
%   Detailed explanation goes here

h = histogram(image(:), 0:256);
title(ptitle);
xlabel('Gray level');
ylabel('# of occurence');

end

