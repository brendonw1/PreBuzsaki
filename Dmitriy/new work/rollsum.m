function rollsum = rollsum(m,n)
%rollsum = rollsum(m,n)
%   calculates the n-order rolling sum of the matrix

m = sum(m);
for c = 1:size(m,2)
   rollsum(c) = sum(m(max([1 c-n]):min([size(m,2) c+n])));
end