function DistinctP = DistinctP(ct,fp,gp,num)
%DistinctP(ct,f,g,num)
%   determines the probability that distributions f and g in ct are distinct

fp = reshape(fp,1,prod(size(fp)));
gp = reshape(gp,1,prod(size(gp)));

f = setdiff(fp,gp);
g = setdiff(gp,fp);

if isempty(f) | isempty(g)
    DistinctP = 1;
    return;
end

meanf = mean(ct(f,:));
meang = mean(ct(g,:));
distc = norm(meanf-meang);
k = [zeros(1,size(f,2)) ones(1,size(g,2))];
cl = [f g];
for t = 1:num
    k = k(randperm(size(k,2)));
    f = cl(find(k==0));
    g = cl(find(k==1));
    meanf = mean(ct(f,:));
    meang = mean(ct(g,:));
    distr(t) = norm(meanf-meang);
end

DistinctP = size(find(distr > distc),2)/num;