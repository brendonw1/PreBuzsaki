function LayerP = LayerP(ct,f,d,bin,tr)
%LayerP = LayerP(ct,f,d,bin)
%   determines the P value of the layer/column arrangement
%   of cells f in the coordinate matrix ct with bin size bin
%   d values: 1 = column, 2 = layer

bin = fix(bin/2);
chst = zeros(1,fix(max(ct(:,d)))+1);
for c = 1:size(ct,1)
    rng = max([1 round(ct(c,d))-bin]):min([round(ct(c,d))+bin size(chst,2)]);
    chst(rng) = chst(rng)+1;
end

fhst = zeros(1,fix(max(ct(:,d)))+1);
f = reshape(f,prod(size(f)),1);
for c = 1:size(f,1)
    rng = max([1 round(ct(f(c),d))-bin]):min([round(ct(f(c),d))+bin size(chst,2)]);
    fhst(rng) = fhst(rng)+1;
end
hs = fhst./(chst+eps);
nm = max(hs(bin+1:size(hs,2)-bin));
%bar(fhst./(chst+eps));

for t = 1:tr
    fhst = zeros(1,fix(max(ct(:,d)))+1);
    f = fix(rand(size(f,1),1)*size(ct,1))+1;
    for c = 1:size(f,1)
        rng = max([1 round(ct(f(c),d))-bin]):min([round(ct(f(c),d))+bin size(chst,2)]);
        fhst(rng) = fhst(rng)+1;
    end
    hs = fhst./(chst+eps);
    cm(t) = max(hs(bin+1:size(hs,2)-bin));
end

cm = fliplr(sort(cm));
LayerP(1) = cm(fix(0.05*tr));
LayerP(2) = cm(fix(0.01*tr));
LayerP(3) = cm(fix(0.001*tr));
LayerP(4) = size(find(cm>nm),2)/tr;