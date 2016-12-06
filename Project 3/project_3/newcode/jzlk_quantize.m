function [ y ] = jzlk_quantize( x, delta )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

y = delta*floor(x/delta+1/2);



end

