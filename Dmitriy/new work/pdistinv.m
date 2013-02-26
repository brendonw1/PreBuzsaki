function pdistinv = pdistinv(m)
%pdistinv = pdistinv(m)
%   inverse function of PDIST

[x y] = meshgrid(1:size(m,1));
x = reshape(x,prod(size(x)),1);
y = reshape(y,prod(size(y)),1);
k = x-y;
f = find(k<0);
x = x(f);
y = y(f);

pdistinv = diag(m(x,y));