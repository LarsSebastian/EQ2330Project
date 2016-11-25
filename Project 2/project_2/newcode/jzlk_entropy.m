function [ entropy ] = jzlk_entropy( subband )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

h = histogram(subband(:), 'Normalization', 'probability');

p = h.Values;
p(p==0) = [];
entropy = -sum(p.*log2(p));


end

