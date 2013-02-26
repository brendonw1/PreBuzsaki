function fitexp = fitexp(x)
%fitexp = fitexp(x)
%   fits a cubic function to the maxima of the trace

ni = 10;
ind = fix([1 (1:ni)/ni*size(x,2)]);
for c = 1:ni
   vl = x(ind(c):ind(c+1));
   mx(c) = max(vl);
end
mx = [max(x(1:fix(ind(2)/ni))) mx];
xs = repmat(ind',1,4).^repmat((0:3),size(ind,2),1);
coeff = xs\mx';
app = (repmat((1:size(x,2))',1,4).^repmat((0:3),size(x,2),1))*coeff;
fitexp = x-app';