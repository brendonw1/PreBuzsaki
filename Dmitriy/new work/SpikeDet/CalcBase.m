function BaseLine = CalcBase(x,ni)
%Calculates the baseline of x with ni intervals

ind = fix(1:(size(x,2)-1)/ni:size(x,2));
v = fix(1:(size(x,2)-1)/(ni-1):size(x,2));
for c = 1:ni
   vl = x(ind(c):ind(c+1));
   vl = fliplr(sort(vl));
   n = round(size(vl,2)/2);
   y(c) = mean(vl(1:n));
end
xx = 1:size(x,2);
BaseLine = spline(v,y,xx);