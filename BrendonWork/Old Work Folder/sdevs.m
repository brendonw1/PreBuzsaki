function ons=detector(values,outs,backs);

% function [df, mt, st, base, sn]=sdevs(values);
% values is derived from the function "contourvalues" and contains the
% mean value inside each contour over a number of frames and a number of
% movies.  The dimensions are frames x movies x cells.  All analysis is
% done on a version of values where the value of each frame is subtracted
% from the following frame... derivative over time of the cell values: this
% matrix is df and has the same dimensions as values.

dfb=diff(backs,1,1);
dfb=repmat(dfb,[1, 1, size(values,3)]);

df=diff(values,1,1);
% df=df-dfb

mt=mean(df,1);%find the mean value of each cell across all frames within each movie
mt=repmat(mt,[size(df,1) 1 1]);%replicating over frames, so that matrix is same size as multi-frame matrix

st=std(df,1);%find the standard deviation of each cell across all frames within each movie
st=repmat(st,[size(df,1) 1 1]);%replicating over frames, so that matrix is same size as multi-frame matrix

ul=mt+st;%matrix of mean + sd for each cell in each movie
ll=mt-st;%matrix of mean - sd for each cell in each movie

ul=df-ul;
ll=ll-df;
a=find(ul>0);%find frames where cell is more than 1 SD above mean for that movie
b=find(ll>0);%find frames where cell is more than 1 SD below mean for that movie

flat=df;%will be a series of flattened out profiles for each cell across frames for each movie
flat(a)=mt(a);%where was above 1SD above mean, set equal to mean for that cell for that movie 
flat(b)=mt(b);%where was below 1SD below mean, set equal to mean for that cell for that movie

h=hanning(7);%create a filter
h=h/sum(h);%normalize
base=zeros(size(df,1), size(df,2), size(df,3));
for a=1:size(df,2);%for each movie
    for b=1:size(df,3);%for each cell
        c=conv(flat(:,a,b),h);%convolve frames df for each cell with hanning filter
        base(:,a,b)=c(4:end-3);
    end
end
noise=flat-base;%estimate noise
sn=std(noise);
sn=repmat(sn,[size(df,1) 1 1]);

threshlow=base-2*sn;%threshold for quenching events (increased calcium)... 2 SD of noise below baseline
% threshhigh=base+2*sn;%for recovery from quenching (decreasing calcium)... 2 SD of noise above baseline
threshresult=threshlow-df;
threshons=find(threshresult>0);
threshons2=zeros(size(df));
threshons2(threshons)=1;

limresult=df-2;
limons=find(limresult<0);
limons2=zeros(size(df));
limons2(limons)=1;

localbackresult=df-diff(outs,1,1);
localbackons=find(localbackresult<-.8);
localbackons2=zeros(size(df));
localbackons2(localbackons)=1;

backresult=df-dfb;
backons=find(backresult<0);
backons2=zeros(size(df));
backons2(backons)=1;

% ons=limons2+threshons2+localbackons2+backons2;
% ons(find(ons<4))=0;
% ons(find(ons==4))=1;
ons=localbackons2+backons2;





% figure;
% plot(trace,'k');
% hold on;
% % plot(flattrace,'r');
% % plot(mt,'g');
% % plot(mt+st,'g');
% % plot(mt-st,'g');
% plot(base,'b');
% plot(threshlow,':');
% % plot(threshhigh,'b');