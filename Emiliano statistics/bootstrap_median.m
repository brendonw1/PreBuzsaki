function [outputrec, significance, confin]=bootstrap_median(x,rep,critical)
%Function to bootstrap from 1 dataset and calculate the fraction of bootstrapped datasets
% with median below a critical value.
%Inputs: x is the data set
%        rep is the number of times that the test will be repeated
%        critical is the critical value for the median
%                 if critical is omitted median(x) is used
%
%Outputs: outputrec is the fraction of medians below the critical value
%         significance is the vector with all the bootstrapped medians
%         confin is the vector with the range of the data from the 5th to
%                the 95th percentile
%
%by Emiliano Rial Verde
%Year 2003. Modified 03/29/2004.

if nargin == 2
    critical=median(x);
end

xl=max(size(x));
if size(x,2)==xl
   x=x';
end

significance=[];
for j=1:rep %repetitions
   index1=ceil(rand(xl,1).*xl);
   significance=[significance; median(x(index1))];
end

outputrec=sum(significance>critical)/rep;

confin=[prctile(significance, 5) prctile(significance, 95)]

%Distribution of medians
medianmax=max(significance);
medianmin=min(significance);
interval=(medianmin:(medianmax-medianmin)/100:medianmax)';

%Cumulative frequency
a=[];
for i=1:size(interval,1)
   a=[a; sum(significance<=interval(i,1))/size(significance,1)];
end
figure
b=plot(interval,a, 'linewidth', [1.5]);
line([critical critical], [0 1], 'color', 'k', 'linewidth', [1.5]);
YLabel('Cummulative frequency', 'fontweight', 'bold');
XLabel('Median values', 'fontweight', 'bold');
title(['Bootstrap N = ', num2str(rep), ' - Critical value = ', num2str(critical), ' - Fraction over critical value = ', num2str(outputrec)]);

%Distribution histogram
a=[];
for i=1:size(interval,1)-1
   b=[];
   b=interval(i,1)<=significance & significance<interval(i+1,1);
   a=[a; sum(b)];
end
a=[a;1];
figure
b=bar(interval,a);
line([critical critical], [0 max(get(gca, 'ylim'))], 'color', 'k', 'linewidth', [1.5]);
YLabel('Frequency', 'fontweight', 'bold');
XLabel('Median values', 'fontweight', 'bold');
title(['Bootstrap N = ', num2str(rep), ' - Critical value = ', num2str(critical), ' - Fraction over critical value = ', num2str(outputrec)]);
