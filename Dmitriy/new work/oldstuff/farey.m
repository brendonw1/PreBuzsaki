function farey = farey(n)
%farey(n)
%   Returns a Farey sequence where each number is p/q, q <= n

[x,y] = meshgrid(1:n);
z = x./y;
z = reshape(z,1,n^2);
z = [0 unique(z)];
farey = sort(z(find(z <= 1)));