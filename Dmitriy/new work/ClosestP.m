function ClosestP = ClosestP(ct,f,tr)
%ClosestP = ClosestP(ct,f,tr)
%   determines the P value of the closest-cell arrangement

f = reshape(f,1,prod(size(f)));
if size(f,2) < 2
    ClosestP = 1;
    return;
end


cr = ct(f,1)+i*ct(f,2);
for c = 1:size(f,2)
    cl = ct(f(c),1)+i*ct(f(c),2);
    k = abs(cr-cl);
    nm(c) = min(k(find(k>0)));
end
nm = mean(nm);

for t = 1:tr
    j = randperm(size(ct,1));
    f = j(1:size(f,2));
    cr = ct(f,1)+i*ct(f,2);
    for c = 1:size(f,2)
        cl = ct(f(c),1)+i*ct(f(c),2);
        k = abs(cr-cl);
        dm(c) = min(k(find(k>0)));
    end
    cm(t) = mean(dm);
end

ClosestP = size(find(cm<nm),2)/tr;