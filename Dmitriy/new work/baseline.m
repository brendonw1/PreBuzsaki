function baseline = baseline(x,ni)

ind = fix([1 (1:ni)/ni*size(x,2)]);
for c = 1:ni
   vl = x(ind(c):ind(c+1));
   vl = fliplr(sort(vl));
   n = round(size(vl,2)*0.5);
   y(c) = mean(vl(1:n));
end
v = mean([ind(2:end); ind(1:end-1)]);
xx = 1:size(x,2);
baseline = spline(v,y,xx);