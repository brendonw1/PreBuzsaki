[x y butt] = ginput(1);
if butt > 1
    return
end

matr = [];
for c = 1:length(cn)
    for d = 1:length(cn{c})
        if polyarea(cn{c}{d}(:,1),cn{c}{d}(:,2)) > lowar(c) & polyarea(cn{c}{d}(:,1),cn{c}{d}(:,2)) < highar(c)
            matr = [matr; [HippoCentroid(cn{c}{d}) c d]];
        end
    end
end
dst = sum((matr(:,1:2)-repmat([x y],size(matr,1),1)).^2,2);
[dummy i] = min(dst);
tempcn = [];
for d = [1:matr(i,4)-1 matr(i,4)+1:length(cn{matr(i,3)})]
    tempcn{length(tempcn)+1} = cn{matr(i,3)}{d};
end
cn{matr(i,3)} = [];
for d = 1:length(tempcn)
    cn{matr(i,3)}{d} = tempcn{d};
end

tmp = num;
num = matr(i,3);
HippoDrawCells
num = tmp;