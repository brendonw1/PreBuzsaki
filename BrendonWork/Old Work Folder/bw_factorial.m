function bw_factorial = bw_factorial(n)

if n == 1
    bw_factorial = 1;
else
    bw_factorial = n*eval(['bw_factorial(' num2str(n-1) ')']);
end