function [ motionVec, residual ] = jzlk_findMotionVec( image, prevBlock, prevPosVec)
%Returns the motion vector (dx,dy) that minimizes the mean square error
%(MSE) of the block prediction
%   image: current image
%   prevBlock: block from the previous image which is used as predictor
%   prevPosVec: position of the prevBlock in the previous image
%
%   motionVec: motion vector


range = 10;
[xSize, ySize] = size(prevBlock);

% prevent out of bound errors
xmin = max(prevPosVec(1)-range+1,1);
xmax = min(prevPosVec(1)+range-1,size(image,1)-size(prevBlock,1)+1);

ymin = max(prevPosVec(2)-range+1,1);
ymax = min(prevPosVec(2)+range-1,size(image,2)-size(prevBlock,2)+1);

distortion = zeros(xmax-xmin+1, ymax-ymin+1);

for ix=xmin:xmax
    % index that always starts at 1
    xtmp = ix-xmin+1;
    for iy=ymin:ymax
       ytmp = iy-ymin+1;
       tmpBlock = image(ix:ix+xSize-1, iy:iy+ySize-1);
       distortion(xtmp,ytmp) = sum(abs(tmpBlock(:)-prevBlock(:)).^2);
    end
end

% find index where distortion is minimal (serial index)
posVecIdx = find(distortion==min(distortion(:)));
posVecIdx = posVecIdx(1);

% convert index into two coordinates
posVec = [mod(posVecIdx, size(distortion,1))+xmin-1 ...
            ceil(posVecIdx/size(distortion,1))+ymin-1 ];

motionVec = posVec - prevPosVec;
        
residual = image(posVec(1):posVec(1)+xSize-1, ...
                posVec(2):posVec(2) + ySize-1) - prevBlock;

end

