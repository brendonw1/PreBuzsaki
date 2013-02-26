function ncr = ncr(a,N)
%ncr = ncr(a,N)
%   binomial coefficients function
%   outputs  / N \
%            \ a /


ncr = factorial(N)/(factorial(N-a)*factorial(a));