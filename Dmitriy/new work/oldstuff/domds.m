function [coords, ishyper] = domds(m,neig,tol,maxit);

%[coords, ishyper] = domds(m,neig,tol,maxit)
%   Does multidimensional scaling on the distance matrix m
%    Finds neig most important coordinates with tolerance tol
%    Stops after maxit iterations in eigenvalue calculations
%
%    coords -- NxD matrix of coordinates (N points in D dimensions)
%    ishyper -- row vector of 0's and 1's specifying which dimensions
%               are hyperbolic

m = dbcent(m);

%Find the coordinates
options.tol = tol;
options.maxit = maxit;
options.disp = 0;
[vc,vl] = eigs(-m,neig,'LM',options);
vl = diag(vl)';
vc = vc .* repmat(sqrt(abs(vl)),size(vc,1),1);
vl = round(vl*10^10)/10^10;
vc = round(vc*10^10)/10^10;
nonz = find(vl);
vc = vc(:,nonz) / sqrt(2);
vl = vl(nonz);

if size(vc,2) < neig
   vc = [vc zeros(size(vc,1),neig-size(vc,2))];
end
coords = vc;
ishyper = ~sign(sign(vl)+1);

function dbcent = dbcent(a)

m = a .^ 2;
n = size(m,1);
dbcent = m - repmat(sum(m,2),1,n)/n - repmat(sum(m,1),n,1)/n + sum(sum(m))/n^2;