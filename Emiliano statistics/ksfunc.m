function [interval, ctrl, trt, ksp]=ksfunc(ctrl, trt)

%Function to perform Kolmogorov-Smirnov test
%
%
%by Emiliano Rial Verde
%Year 2002.

a=ctrl;
b=trt;
amin=floor(min(a));
amax=ceil(max(a));
bmin=floor(min(b));
bmax=ceil(max(b));
intervalnum=(size(a,1)+size(b,1))*10;
interval=[];
interval=([min([amin bmin]):abs(max([amax bmax])-min([amin bmin]))/intervalnum:max([amax bmax])])';
c=[];
d=[];
for i=1:size(interval,1)
   c=[c; sum(a<=interval(i,1))/size(a,1)];
   d=[d; sum(b<=interval(i,1))/size(b,1)];
end
[h, ksp, ks]=kstest2(a,b);
n=size(a,1)*size(b,1)/(size(a,1)+size(b,1));

ctrl=c;
trt=d;