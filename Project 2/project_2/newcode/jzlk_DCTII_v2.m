function [ x, A ] = jzlk_DCTII_v2( y )
%Calculates DCT-II coefficients for given matrix


[M,N] = size(y);
%% Calculate Matrix A

A = zeros(M,N);

for i = 0:M-1
    for j = 0:N-1
        
        if i == 0
            alpha = sqrt(1/M);
        else
            alpha = sqrt(2/M);
        end
        
        A(j+1, i+1) = alpha*cos((2*j+1)*i*pi/(2*M));
        
    end
end

%% Calculate DCT with A

x = A'*double(y)*A;
        


end

