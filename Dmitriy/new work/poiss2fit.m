function poiss2fit = poiss2fit(mt)
%poiss2fit = poiss2fit(mt)
%   fits a sum of two Poisson functions to the data

opts.Display = 'off';
opts.TolX = 0.00001;
opts.TolFun = 0.00001;
for c = 1:10
   [x(c,:) fval(c)] = fminsearch('p2fit',rand(1,5)*10+1,opts,mt);
   fprintf('.');
end
f = find(fval==min(fval));

r1 = abs(x(f,1));
r2 = abs(x(f,3));
k1 = fix(abs(x(f,2)))+1;
k2 = fix(abs(x(f,4)))+1;
j = x(f,5);
x = -10:0.01:200;
poiss2fit = (r1.*x).^(k1-1).*r1.*exp(-r1.*x)./gamma(k1) + (r2.*x).^(k2-1).*r2.*exp(-r2.*x)./gamma(k2) + j;