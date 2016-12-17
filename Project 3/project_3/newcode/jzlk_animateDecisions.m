function [  ] = jzlk_animateDecisions( blocks, quantStepIdx, fieldname )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

s = size(blocks{1,1});
x = 1:s(1);
y = 1:s(2);


tmp = [blocks{quantStepIdx,1}{:,:}];
decision = [tmp.(fieldname)];
decision = reshape(decision, s);

h = imagesc(decision);
c = colorbar;
colorbar('Ticks',[1,2,3],...
         'TickLabels',{'Intra','Copy','Inter'})
pause(1/2);

for nframe=2:size(blocks,2)
    tmp = [blocks{quantStepIdx,nframe}{:,:}];
    decision = [tmp.(fieldname)];
    decision = reshape(decision, s);
    h.CData = decision;
    title(sprintf('Frame #%d', nframe));
    pause(1/2);
end

end

