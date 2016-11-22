function [ yHighOUT, yLowOUT ] = jzlk_liftingFilter( signalIN, scalingIN)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% NOT YET FINISHED

% Transfer function coefficients
PNum = [-1/2 -1/2];
PDen = [0 1];
UNum = [1/4 1/4];
UDen = [1];

x = wextend(1, 'ppd', signalIN, numel(signalIN));

loops = 0;
while PDen(1)==0
    PDen = PDen(2:end);
    circshift(x,1);
    
    loops = loops+1;
    if loops>10
        break;
    end
end

x2n = x(2:2:end);
x2n1 = x(1:2:end);

N = numel(x2n);
M = numel(x2n1);
if N~=M
   disp('Error: Signal length odd.');
   return;
end

x2n = signalIN(2:2:end);
x2n1=signalIN(1:2:end);

a = filter(PNum, PDen, x2n);
yHighOUT = x2n1 + a;

b = filter(UNum, UDen, yHighOUT);
yLowOUT = x2n + b;


% Scale
yHighOUT = 1/sqrt(2) * yHighOUT;
yLowOUT = sqrt(2) * yLowOUT;


end

