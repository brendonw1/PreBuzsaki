function [distcy, distcx]=datadist(data)
%
%Function to plot the distribution histogram of a dataset.
%The number of bins is decided according to Sturge's Rule: k=1+3.332*Log10(N).
%If the values are negative, use the absolutes.
%
%
%by Emiliano Rial Verde
%Year 2003.

a=[];
a=ceil(max(data));
xmaxlimc=a;
b=[];
b=floor(min(data));
xminlimc=b;

sturge=ceil(1+3.332*log10(max(size(data))));
%sturge=1000
c=[];
c=b:a/sturge:a;
a=[];
b=0;
for i=2:size(c,2)
   a=[a sum(data<c(i))-b];
   b=sum(data<c(i));
end
cc=[];
for i=2:size(c,2)
   cc=[cc mean([c(i) c(i-1)])];
end
distcy=a;
distcx=cc;

datamean=mean(data);
datasem=std(data)/sqrt(size(data,1));
datamedian=median(data);
datamad=medianad(data);

figure;
h1=bar(distcx, distcy, 'y');
set(gca, 'ylim', [0 max(distcy)*1.3], 'ylabel', text('string', ['Number of events (total=', num2str(size(data,1)), ')'], 'FontWeight', 'bold'), ...
   'xlim', [xminlimc xmaxlimc], 'xlabel', text('string', 'Amplitude (pA)', 'FontWeight', 'bold'), 'FontWeight', 'bold');
title('Frequency distribution; Black: mean \pmsem; Blue: median \pmmad', 'FontWeight', 'bold');
hold on;
plot(datamean, max(distcy)*1.1, 'ks', 'markerfacecolor', 'k');
line([datamean-datasem; datamean+datasem], [max(distcy)*1.1; max(distcy)*1.1], 'color', 'k');
plot(datamedian, max(distcy)*1.2, 'bs', 'markerfacecolor', 'b');
line([datamedian-datamad; datamedian+datamad], [max(distcy)*1.2; max(distcy)*1.2], 'color', 'b');
hold off;
