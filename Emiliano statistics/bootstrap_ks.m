function pval=bootstrap_ks(x,y,rep)
%Function to bootstrap from 2 datasets, calculate the medians and do a Kolmogorov-Smirnov.
%Inputs: x and y are the datasets
%        rep is the number of times that the bootstrap will be repeated
%
%
%by Emiliano Rial Verde
%Year 2003.

xl=max(size(x));
if size(x,2)==xl
   x=x';
end

yl=max(size(y));
if size(y,2)==yl
   y=y';
end

significancex=[];
significancey=[];
for j=1:rep %repetitions   
   index1=ceil(rand(xl,1).*xl);
   significancex=[significancex; median(x(index1))];
   index2=ceil(rand(yl,1).*yl);
   significancey=[significancey; median(y(index2))];
end

%K-S test
[h, pval, ks]=kstest2(significancex, significancey);

%Distribution of medians
medianmax=max([significancex; significancey]);
medianmin=min([significancex; significancey]);
interval=(medianmin:(medianmax-medianmin)/100:medianmax)';

%Cumulative frequency
a=[];
b=[];
for i=1:size(interval,1)
   a=[a; sum(significancex<=interval(i,1))/size(significancex,1)];
   b=[b; sum(significancey<=interval(i,1))/size(significancey,1)];
end
figure
c=plot(interval,a, 'linewidth', [1.5], 'color', 'b');
hold on;
d=plot(interval,b, 'linewidth', [1.5], 'color', 'r');
YLabel('Cummulative frequency', 'fontweight', 'bold');
XLabel('Median values', 'fontweight', 'bold');
title(['Bootstrap N = ', num2str(rep), ' - Kolmogorov-Smirnov p = ', num2str(pval), ' - Blue: ', inputname(1), '. Red: ', inputname(2), '.']);
hold off;