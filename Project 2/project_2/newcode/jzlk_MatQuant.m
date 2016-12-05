function [ Q ] = jzlk_MatQuant( mat, step_size )
%Quantization of given matrix with given step size

[M,N] = size(mat);
Q = zeros(M,N);

for i = 1:M
    for j = 1:N
        Q(i,j) = step_size*floor(double(mat(i,j))/step_size + 0.5);
    end
end


end

