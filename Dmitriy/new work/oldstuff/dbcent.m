function dbcent = dbcent(a)

m = a .^ 2;
n = size(m,1);
dbcent = m - repmat(sum(m,2),1,n)/n - repmat(sum(m,1),n,1)/n + sum(sum(m))/n^2;