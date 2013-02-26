function cxcorr = cxcorr(a,b)
%performs cross correlation by attaching values from the
%beginning of the array to the end whenever necessary

a = a - mean(a);
a = a/std(a);
b = b - mean(b);
b = b/std(b);
n = size(a,2);
b = [b b b];
m = [];
for c = -n+1:n-1
   m = [m sum(a.*b(n+1+c:2*n+c))];
end

cxcorr = m;