function thresholds = thresholds(fin,mn,mx,num)
%thresholds = thresholds(fin,mn,mx,num)
%
%   calculates the thresholds vector for the rasterplot file fin
%   calculates thresholds from mn frames before to mx frames after
%   performs interval reshufflings num times

load(fin);

thr = zeros(num,mn+mx+1);
for t = 1:num
    ir = [];
    for c = 1:size(spk,2);
        ir{c} = intres(spk{c},sz)+1;
    end
    rsh = rast2mat(ir,sz);
    f = find(sum(rsh)==max(sum(rsh)));
    f = f(1);
    while f < mn+1 | f > sz-mx
        for c = 1:size(spk,2);
            j = spk{c};
            j = j(intersect(find(j>1),find(j<sz)));
            ir{c} = intres(j,sz)+1;
        end
        rsh = rast2mat(ir,sz);
        f = find(sum(rsh)==max(sum(rsh)));
        f = f(1);
    end
    for c = -mn:mx
        thr(t,c+mn+1) = sum(rsh(:,f+c));
    end
    if mod(t,10)==0; fprintf('.'); end
end

for c = 1:mn+mx+1
    arn = sort(thr(:,c));
    th(c) = arn(fix(num*0.95));
end

thresholds = th;