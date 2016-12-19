function [ sum_intra, sum_copy, sum_motion, num_decision ] = calc_absDecisionNum( blocks3 )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


sum_intra = 0;
sum_copy = 0;
sum_motion = 0;

[M1,N1] = size(blocks3{1,1})

for k = 1:length(blocks3);
    for i = 1:M1
        for j = 1:N1
            decision = blocks3{1, k}{i,j}.decision_All;
            
            if decision == 1
                sum_intra = sum_intra + 1;
            elseif decision == 2
                sum_copy = sum_copy + 1;
            elseif decision == 3
                sum_motion = sum_motion + 1;
            end
            
            
        end
    end
end

num_decision = length(blocks3)*M1*N1

end

