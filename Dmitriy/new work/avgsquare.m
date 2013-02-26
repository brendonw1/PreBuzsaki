function avgsquare = avgsquare(m,n)
%avgsquare = avgsquare(m,n)
%   outputs a matrix that contains the average values of m in 2n+1-sided squares

sm = zeros(size(m,1),size(m,2));
for a = 1:2*n+1
   for b = 1:2*n+1
      sm(n+1:end-n,n+1:end-n) = sm(n+1:end-n,n+1:end-n) + m(a:end-2*n+a-1,b:end-2*n+b-1);
   end
end
avgsquare = sm / (2*n+1)^2;