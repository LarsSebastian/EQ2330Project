function [ framesum_intra, framesum_copy, framesum_motion ] = calc_decisionsPerFrame( blocks3 )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

framesum_intra = zeros(1,length(blocks3));
framesum_copy = zeros(1,length(blocks3));
framesum_motion = zeros(1,length(blocks3));

[M1,N1] = size(blocks3{1,1});

for k = 1:length(blocks3);
    for i = 1:M1
        for j = 1:N1
            decision = blocks3{1, k}{i,j}.decision_All;
            
            if decision == 1
                framesum_intra(1,k) = framesum_intra(1,k) + 1;
            elseif decision == 2
                framesum_copy(1,k) = framesum_copy(1,k) + 1;
            elseif decision == 3
                framesum_motion(1,k) = framesum_motion(1,k) + 1;
            end
            
            
        end
    end
end



end

