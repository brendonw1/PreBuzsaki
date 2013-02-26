function allps = GatherPlotManyCellResistances(numreshuffs)

d = getdir(cd);
meanUr = [];
meanDr = [];
% allps = zeros(1,length(d));
ExcelCell{1,1} = 'Cell Name';
ExcelCell{1,2} = 'Mean DS mO';
ExcelCell{1,3} = 'Mean US mO';
ExcelCell{1,4} = 'P of Reshuffs Greater than Orig';
ExcelCell{1,5} = '# UP Samples';
ExcelCell{1,6} = '# UP States';
ExcelCell{1,7} = '# Files';

ExcelCell{2,1} = [];
ExcelCell{2,2} = [];
ExcelCell{2,3} = [];
ExcelCell{2,3} = [];
ExcelCell{2,5} = [];
ExcelCell{2,6} = [];
ExcelCell{2,7} = [];
nummats = 0;

for didx = 1:length(d);
    if strcmp('.mat',d(didx).name(end-3:end))
        nummats = nummats+1;
        out = GatherUpDownConductancesOneCell(d(didx).name);
        meanUr(end+1) = out.UMeanMeanResists;
        meanDr(end+1) = out.DMeanMeanResists;
        thisdiff = meanDr(end)-meanUr(end);
        ExcelCell{didx+2,1} = d(didx).name(9:end-4);
        ExcelCell{didx+2,2} = meanDr(end)/1e6;
        ExcelCell{didx+2,3} = meanUr(end)/1e6;
        ExcelCell{didx+2,5} = out.NumberofSamples;
        ExcelCell{didx+2,6} = out.NumberofUPstates;
        ExcelCell{didx+2,7} = out.NumberofFiles;

        out = GatherUPDownConductancesOneCellReshuff(numreshuffs,d(didx).name);
        reshuffdiffs = (out(1).DMeanMeanResists - out(1).UMeanMeanResists);
        p = sum(reshuffdiffs>thisdiff)/numreshuffs;
        subplot(2,1,2);
        hist(reshuffdiffs,100)
        hold on;
        plot(thisdiff,10,'*','color','r')
        title({'Reshuffled (blue bars) vs observed (red star) differences between DOWN and UP state Resistances',...
            ['Reshuffled: ',num2str(mean(reshuffdiffs)/1e6),' \pm ',num2str(std(reshuffdiffs)/1e6),' MOhm.  p = ',num2str(p)]})
        disp(didx)
        allps(didx) = p;
        ExcelCell{didx+2,4} = p;
    end
end

x=clock;
ExcelName = ['ResistancesResults',num2str(x(1)),'-',num2str(x(2)),'-',num2str(x(3)),'-',num2str(x(4)),num2str(x(5))];
xlswrite(ExcelName,ExcelCell)

%% plot each cell's up and down means
XsDr = 1:3:(3*nummats-2);
XsUr = 2:3:(3*nummats-1);
figure('name','Up vs Down resistance each cell')
bar(XsDr,meanDr,.3)
hold on
bar(XsUr,meanUr,.3,'facecolor','red')
title(['DOWN (blue) and UP (red) resistances for each of the ',num2str(nummats),' cells measured'])

%% mean DOWN and UP with errorbars
[means,sds]=errorbargraphmeansd(meanDr,meanUr);
title({['Mean DOWN state resistance: ',num2str(means(1)/1e6),'\pm',num2str(sds(1)/1e6),' MOhm'],...
    ['Mean UP state resistance: ',num2str(means(2)/1e6),'\pm',num2str(sds(2)/1e6),' MOhm']});
set(gcf,'name','Up vs Down resistance pop mean')

%% mean within-cell differences
diffs = meanDr-meanUr;
diffsdata = bwdatadist(diffs);
subplot(2,1,1)
title(['Differences between UP and DOWN states: ',num2str(mean(diffs/1e6)),'+/-',num2str(std(diffs)/1e6),' MOhm']);
set(gcf,'name','Down minus Up resistances for pop')

% resDs = resampledataset(meanDr,10000);%reshuffle 
% resUs = resampledataset(meanDr,10000);
% resdiffs = mean(resDs) - mean(resUs);
% figure;hist(resdiffs,100)
% resdiffs = resampledataset(diffs,10000);

%% mean percent change ratio
perc = diffs./meanDr;
percdata = bwdatadist(perc);
subplot(2,1,1)
title({['Percent changes between UP and DOWN states (percent of DOWN): '],...
    [num2str(mean(perc)),'+/-',num2str(std(perc)),' MOhm']});
set(gcf,'name','Down vs Up percent resistances for pop')

%% plot diff pvalues
figure('name','Pvalue for UP difference for each cell');
subplot(2,1,1);
plot(allps,ones(size(allps)),'o','color','k');
hold on;
plot([0.05 0.05],[0 2],'r');
signif = sum(allps<=0.05);
nonsignif = length(allps)-signif;
title([num2str(signif),' cells show lower resistance in UP than DOWN.  ',num2str(nonsignif),' do not'])

subplot(2,1,2);
plot(allps,ones(size(allps)),'o','color','k');
hold on;
plot([0.05 0.05],[0 2],'r');
xlim([0 .1])

%1 how many cells have Significantly higher DOWN than UP
    % reshuffle up Rs and down Rs for each cell... like reshuffle which is
    % U and which is D.  Then subtract.
    
    
%2 is the population diff greater than zero or than expected
   % reshuffle U and D resistances, disrupting pairing.  Then see if
   % subtraction of real is greater than subtraction of randomized... not
   % good I think?
   % THIS IS SIGNIF 4/10000
   
   % or take real subtractions.  Resample?  See if real is greater than
   % mean from that dataset
   % yes
   % THIS IS NOT SIGNIF... real dataset at about 50th %ile of resample
   
   




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dataout=bwdatadist(varargin)

% From Emiliano
%Function to plot the distribution histogram of a data set.
%
%The number of non-empty bins is decided according to:
%1) Sturges' rule: bins=1+log2(N).
%2) Freedman-Diaconis rule: bins=2*IQR(data)*N^(-1/3).
%
%Histograms using both binning rules are graphed.
%If an output variable is provided, the x and y axes of the histograms, as
%well as the descriptive statistics of the data are in the output structure.
%
%The only mandatory input to this function is a vector (1 x N or N x 1) with the data.
%
%To include a label for the X axis of the histograms, use a text string as
%the second input argument to the function. This argument is optional.
%
%To limit the maximum number of bins, use the third input to the function.
%If no input is provided, the default limit of 100 bins is used.
%
%Examples:
%Syntax with output, X label, and a limit of 50 bins
%dataout=datadist(data, 'X Axis label', 50);
%
%Syntax without output, with X label and default bin limit
%datadist(data, 'X Axis label');
%
%by Emiliano Rial Verde
%Created in 2003.
%Modified in 2007.
%Last modification in Matlab R2006a.

if nargin==1
    data=varargin{1};
    xtextlabel='Insert X Axis Label Here';
    binlimit=100;
elseif nargin==2
    data=varargin{1};
    xtextlabel=varargin{2};
    binlimit=100;
elseif nargin==3
    data=varargin{1};
    xtextlabel=varargin{2};
    binlimit=varargin{3};
    if binlimit<=0
        errordlg('Maximum number of bins must be positive');
        return
    end
else
    return
end

xmax=max(data);
xmin=min(data);
N=length(data);

sturges=ceil(1+log2(N));
freedmandiaconis=ceil(2*iqr(data)*(N^(-1/3)));

distcys=0;
bins=min([sturges binlimit])-1;
while sum(distcys>0)<min([sturges binlimit]) %This is to ensure that the chosen bin number represents NON-EMPTY bins
    bins=bins+1;
    c=xmin:(xmax-xmin)/bins:xmax;
    distcys=[];
    b=0;
    for i=2:length(c)
        distcys=[distcys sum(data<=c(i))-b];
        b=sum(data<=c(i));
    end
    if length(distcys)>binlimit-1 %Limits the number of bins
        break
    end
end
distcxs=[];
for i=2:length(c)
   distcxs=[distcxs mean([c(i) c(i-1)])];
end

distcyfd=0;
bins=min([freedmandiaconis binlimit])-1;
while sum(distcyfd>0)<min([freedmandiaconis binlimit]) %This is to ensure that the chosen bin number represents NON-EMPTY bins
    bins=bins+1;
    c=xmin:(xmax-xmin)/bins:xmax;
    distcyfd=[];
    b=0;
    for i=2:length(c)
        distcyfd=[distcyfd sum(data<=c(i))-b];
        b=sum(data<=c(i));
    end
    if length(distcyfd)>binlimit-1 %Limits the number of bins
        break
    end
end
distcxfd=[];
for i=2:length(c)
   distcxfd=[distcxfd mean([c(i) c(i-1)])];
end

datamean=mean(data);
datasem=std(data)/sqrt(length(data));
datamedian=median(data);
dataiqr=prctile(data, [25 75]);

if nargout==0
else
    dataout.datadistxs=distcxs;
    dataout.datadistys=distcys;
    dataout.sturges=sturges;
    dataout.datadistxfd=distcxfd;
    dataout.datadistyfd=distcyfd;
    dataout.freedmandiaconis=freedmandiaconis;
    dataout.datamean=datamean;
    dataout.datasem=datasem;
    dataout.datamedian=datamedian;
    dataout.dataiqr=dataiqr;
end

if xmin<0
    a=xmin*1.05;
elseif xmin==0
    a=-0.05;
else
    a=xmin*0.95;
end
if xmax<0
    b=xmax*0.95;
elseif xmax==0
    b=0.05;
else
    b=xmax*1.05;
end

figure;
subplot(2,1,1);
bar(distcxs, distcys, 'y');
set(gca, 'ylim', [0 max(distcys)*1.3], 'ylabel', text('string', ['Number of events (total=', num2str(N), ')'], 'FontWeight', 'bold'), ...
   'xlim', [a b], 'xlabel', text('string', xtextlabel, 'FontWeight', 'bold'), 'FontWeight', 'bold');
title('Frequency distribution. Black: mean \pm SEM. Blue: median & IQR.', 'FontWeight', 'bold');
hold on;
plot(datamean, max(distcys)*1.1, 'ks', 'markerfacecolor', 'k');
line([datamean-datasem; datamean+datasem], [max(distcys)*1.1; max(distcys)*1.1], 'color', 'k');
plot(datamedian, max(distcys)*1.2, 'bs', 'markerfacecolor', 'b');
line(dataiqr, [max(distcys)*1.2; max(distcys)*1.2], 'color', 'b');
hold off;
set(gcf, 'Units', 'normalized', 'Name', ['Frequency Histogram. Sturges=', num2str(sturges), '. Limit=', num2str(binlimit), '.']);
c=get(gcf, 'Position');
c(2)=(c(2)-c(4))*.7;

% figure;
subplot(2,1,2);
% set(gcf, 'Units', 'normalized', 'Position', c, 'Name', ['Frequency Histogram. Freedman-Diaconis=', num2str(freedmandiaconis), '. Limit=', num2str(binlimit), '.']);
% bar(distcxfd, distcyfd, 'y');
plot(data,ones(size(data)),'o')
set(gca, 'ylim', [0 4], 'ylabel', text('string', ['Number of events (total=', num2str(N), ')'], 'FontWeight', 'bold'), ...
   'xlim', [a b], 'xlabel', text('string', xtextlabel, 'FontWeight', 'bold'), 'FontWeight', 'bold');
title('Distribution. Black: mean \pm SEM. Blue: median & IQR.', 'FontWeight', 'bold');
hold on;
plot(datamean, 2, 'ks', 'markerfacecolor', 'k');
line([datamean-datasem; datamean+datasem], [2; 2], 'color', 'k');
plot(datamedian, 3, 'bs', 'markerfacecolor', 'b');
line(dataiqr, [3; 3], 'color', 'b');
hold off;
