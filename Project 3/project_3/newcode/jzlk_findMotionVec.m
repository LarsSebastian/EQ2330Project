function [ motionVec, residual ] = jzlk_findMotionVec( prevImage, curBlock, curPosVec)
%Returns the motion vector (dx,dy) that minimizes the mean square error
%(MSE) of the block prediction
%   image: current image
%   prevBlock: block from the previous image which is used as predictor
%   prevPosVec: position of the prevBlock in the previous image
%
%   motionVec: motion vector


range = 10;
[xSize, ySize] = size(curBlock);

% prevent out of bound errors
xmin = max(curPosVec(1)-range+1,1);
xmax = min(curPosVec(1)+range-1,size(prevImage,1)-size(curBlock,1)+1);

ymin = max(curPosVec(2)-range+1,1);
ymax = min(curPosVec(2)+range-1,size(prevImage,2)-size(curBlock,2)+1);

distortion = zeros(xmax-xmin+1, ymax-ymin+1);

for ix=xmin:xmax
    % index that always starts at 1
    xtmp = ix-xmin+1;
    for iy=ymin:ymax
       ytmp = iy-ymin+1;
       tmpBlock = prevImage(ix:ix+xSize-1, iy:iy+ySize-1);
       distortion(xtmp,ytmp) = sum(abs(tmpBlock(:)-curBlock(:)).^2);
    end
end

% find index where distortion is minimal (serial index)
posVecIdx = find(distortion==min(distortion(:)));
posVecIdx = posVecIdx(1);

% convert index into two coordinates
[p1, p2] = ind2sub(size(distortion), posVecIdx);
p1 = p1+xmin-1;
p2 = p2+ymin-1;
posVec = [p1, p2];
%posVec = [mod(posVecIdx, size(distortion,1))+xmin-1 ...
%            ceil(posVecIdx/size(distortion,1))+ymin-1 ];

motionVec =   posVec -  curPosVec;
        
residual = curBlock - prevImage(posVec(1):posVec(1)+xSize-1, ...
                posVec(2):posVec(2) + ySize-1);

end

