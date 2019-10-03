function [A] =UpScale16To10bit(A)
bit=10;
A = A./(2^16 - 1).*(2^bit -1); %scaling to 10-bit precision
%clipping
A(A<0) = 0;
A(A>(2^bit -1)) = (2^bit -1);
%rounding to integer
A = (uint16(A));
end




