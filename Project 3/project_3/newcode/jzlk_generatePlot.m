function [  ] = jzlk_generatePlot( videos1, frameStart, blocks, quantStepIdx, fieldname )
%Generates two figures of frames with corresponding heatmaps
%   Call for example jzlk_generatePlot(Vreceived, 1, 3, blocks, 2,
%   'decision_All') after executing AllCoders.m

s = size(blocks{1,1});

video1 = videos1(quantStepIdx,:);
nrFrames = 3;

% Use these properties to match the two figures
f1 = figure;
f1.PaperPosition = [0.1094 4.0521 8.2812 2.8958];
f1.Position = [354 294 777 182];
f1.OuterPosition = [354 294 777 237];
f1.InnerPosition = [354 294 777 182];

for idx=frameStart:frameStart+nrFrames-1
    figure(f1);
    subplot(1,nrFrames,idx-frameStart+1);
    imshow(uint8(video1{idx}));
    title(sprintf('Frame #%d', idx));
    
end

f2 = figure;
f2.PaperPosition = [0.1510 4.0052 8.1979 2.9896];
f2.Position = [358 69 772 266];
f2.OuterPosition = [358 69 772 321];
f2.InnerPosition = [358 69 772 266];

for idx=frameStart:frameStart+nrFrames-1
    figure(f2);
    subplot(1,nrFrames,idx-frameStart+1);

    tmp = [blocks{quantStepIdx,idx}{:,:}];
    decision = [tmp.(fieldname)];
    decision = reshape(decision, s);
    h = imagesc(decision, [1 3]);
    xlabel('Block Index j');
    ylabel('Block Index i');
    title(sprintf('Frame #%d', idx));
    colorbar('southoutside','TickLabels', [1,2,3], 'Ticks',[1,2,3],...
         'TickLabels',{'Intra','Copy','Inter'})
end


end

