function p2fit = p2fit(x0,mt)
%function used by poiss2fit

x = 0:size(mt,2)-1;
r1 = abs(x0(1));
r2 = abs(x0(3));
k1 = fix(abs(x0(2)))+1;
k2 = fix(abs(x0(4)))+1;
j = x0(5);

y = (r1.*x).^(k1-1).*r1.*exp(-r1.*x)./gamma(k1) + (r2.*x).^(k2-1).*r2.*exp(-r2.*x)./gamma(k2) + j;

p2fit = norm(y-mt);