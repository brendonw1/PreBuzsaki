function [ncorr,del] = mycorr(a,b,prec)

[x y] = meshgrid(a,b);
ints = y - x;
ints = reshape(ints,1,prod(size(ints)));
[ints pr] = meshgrid(ints,-prec:prec);
ints = reshape(ints+pr,1,prod(size(ints)));
hs = histc(ints,min(ints):max(ints));
bar(hs)
hs = hs-sign(hs);
ncorr = max(hs);
del = find(hs==max(hs))+min(ints)-1;