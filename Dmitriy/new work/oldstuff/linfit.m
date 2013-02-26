function coeffs = linfit(mt)
%coeffs = linfit(mt)
%   fits a line that passes through the origin to a set of points

for c = 1:size(mt,1)
   mt(c,:) = mt(c,:)/norm(mt(c,:));
end
opts.Display = 'off';
opts.TolX = 0.00001;
opts.TolFun = 0.00001;
for c = 1:5
   [x(:,c) fval(c)] = fminsearch('lfit',rand(size(mt,2),1)*10,opts,mt);
end
f = find(fval==min(fval));
coeffs = x(:,f(1));
coeffs = coeffs/norm(coeffs);