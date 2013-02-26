%Script to perform Kolmogorov-Smirnov test
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

ksfig=figure(500);
set(ksfig, 'numbertitle', 'off', ...
   'name', 'Frequency distribution.', ...
   'tag', 'ksfig', ...
   'units', 'normalized', ...
   'position', [.005 .35 .5469 .5469]);
orient landscape;
plot(interval, c, 'linewidth', [2]);
hold on;
plot(interval, d, 'r', 'linewidth', [2]);
set(gca, 'ylim', [0 1], 'ylabel', text('string', 'Cumulative frequency', 'FontWeight', 'bold'), ...
   'xlabel', text('string', 'Insert name of X axis here!', 'FontWeight', 'bold'), 'FontWeight', 'bold');
title(['Kolmogorov-Smirnov p=', num2str(ksp)], 'FontWeight', 'bold');
text(interval(1,1),[1], ' Blue: Ctrl. Red: Trt.', ...
   'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'FontWeight', 'bold');
