function [ B ] = jzlk_DCTII( A )
%Calculates DCT-II coefficients for given matrix


% a1 = A(1,:);
% 
% m = length(a1);
% i = 1;
% a1 = [a1, a1(end:-1:1)];
% while i <= m
%     if mod(i,2) ~= 0
%         a1 = [a1(1:i-1), 0, a1(i:end)];
%         m = length(a1);
%     end
%     i = i +1;
%     
% end
% % a2 = a1(end:-1:1);
% 
% a = a1;
% 
% B = real(fft(a));
% B = B(1:M);
% 
% B(1,1) = B(1,1)/(2*sqrt(N));
% B(2:end) = B(2:end).*sqrt(2/N)/2;

% A_star = zeros(4*M, 4*N);
% k = 2;
% for i = 1:M
%     
%     l = 2;
%     for j = 1:N
%         
%         A_star(k,l) = A(i,j);
%         l = l +2;        
%     end
%     k = k +2;
% end
% 
% B = real(fft2(A_star));
% 
% B_star = B(1:M, 1:N);
% B_star(1:M, 1) = B_star(1:M,1)/sqrt(M);
% B_star(1, 1:N) = B_star(1, 1:N)/sqrt(N);
% 
% B_star(2:M, 2:N) = B_star(2:M, 2:N).*sqrt(2/M).*sqrt(2/N);

[M,N] = size(A)

B = zeros(M,N);



for p = 1:N
    for q = 1:M
        
        if q == 1
            alphap = 1/sqrt(M);
        else
            alphap = sqrt(2/M);
        end

        if p == 1
            alphaq = 1/sqrt(N);
        else
            alphaq = sqrt(2/N);
        end
        
        sum = 0;
        for i = 1:M
            for j = 1:N
                arg1 = (pi*(2*(i-1)+1)*(p-1))/(2*M);
                arg2 = (pi*(2*(j-1)+1)*(q-1))/(2*N);
                sum = sum + double(A(i,j))*cos(arg1)*cos(arg2);
            end
        end
        B(p,q) = alphap*alphaq*sum;
    end
end


                

                
                
                




end

