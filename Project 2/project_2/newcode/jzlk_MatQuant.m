function [ Q ] = jzlk_MatQuant( mat, step_size )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[M,N] = size(mat);
Q = zeros(M,N);

for i = 1:M
    for j = 1:N
        
%         if mat(i,j) < 0 
%             disp('mat smaller than zero');
%         end
%         if mat(i,j)/step_size < 0
%             disp('smaller than zero');
%         end
        
        Q(i,j) = step_size*floor(double(mat(i,j))/step_size + 0.5);
    end
end


end

