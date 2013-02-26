function [localbackons2,threshons2,derivlimons2,ons]=detector(values,outs,derivvalues,derivoutvalues,backs);

% function [df, mt, st, base, sn]=sdevs(values);
% values is derived from the function "contourvalues" and contains the
% mean value inside each contour over a number of frames and a number of
% movies.  The dimensions are frames x movies x cells.  All analysis is
% done on a version of values where the value of each frame is subtracted
% from the following frame... derivative over time of the cell values: this
% matrix is df and has the same dimensions as values.

warning off MATLAB:divideByZero

% dfb=diff(backs,1,1);
backs=repmat(backs,[1, 1, size(values,3)]);

% df=diff(values,1,1);
% dfo=diff(outs,1,1);
% df=df-dfb

mt=mean(values,1);%find the mean value of each cell across all frames within each movie
mt=repmat(mt,[size(values,1) 1 1]);%replicating over frames, so that matrix is same size as multi-frame matrix
% mto=mean(dfo,1);
% mto=repmat(mto,[size(df,1) 1 1]);%same as with mt, but now with outvalues
mb=mean(backs,1);
mb=repmat(mb,[size(values,1) 1 1]);%

zerobacks=backs-mb;%set mean of background for each frame to zero for each movie... so can be subtracted from frame values of contours;

zerovalues=values-mt;%set mean of each cell in each movie to 0
zerovalues=zerovalues-zerobacks;%subtract background fluctuation
% dfom=dfo-mto;%set mean of outer contours to 0 for each movie
% dfom=dfom-dfbm;

st=std(values,1);%find the standard deviation of each cell across all frames within each movie
st=repmat(st,[size(values,1) 1 1]);%replicating over frames, so that matrix is same size as multi-frame matrix
ul=mt+st;%matrix of mean + sd for each cell in each movie
ll=mt-st;%matrix of mean - sd for each cell in each movie
ul=values-ul;
ll=ll-values;
a=find(ul>0);%find frames where cell is more than 1 SD above mean for that movie
b=find(ll>0);%find frames where cell is more than 1 SD below mean for that movie


flat=zerovalues;%will be a series of flattened out profiles for each cell across frames for each movie
% flat(a)=mt(a);%where was above 1SD above mean, set equal to mean for that cell for that movie 
% flat(b)=mt(b);%where was below 1SD below mean, set equal to mean for that cell for that movie
flat(a)=0; 
flat(b)=0;

h=hanning(7);%create a filter
h=h/sum(h);%normalize
base=zeros(size(zerovalues,1), size(zerovalues,2), size(zerovalues,3));
for a=1:size(zerovalues,2);%for each movie
    for b=1:size(zerovalues,3);%for each cell
        c=conv(flat(:,a,b),h);%convolve frames df for each cell with hanning filter
        base(:,a,b)=c(4:end-3);
    end
end
noise=flat-base;%estimate noise
sn=std(noise);
sn=repmat(sn,[size(values,1) 1 1]);

threshlow=base-3.5*sn;%threshold for quenching events (increased calcium)... 2 SD of noise below baseline
% threshhigh=base+2*sn;%for recovery from quenching (decreasing calcium)... 2 SD of noise above baseline

threshons=find(threshlow-zerovalues>0);
threshons2=zeros(size(zerovalues));
threshons2(threshons)=1;

limresult=values-2;
limons=find(limresult<0);
limons2=zeros(size(values));
limons2(limons)=1;

localbackresult=derivvalues-derivoutvalues;
localbackons=find(localbackresult>15);
localbackons2=zeros(size(values));
localbackons2(localbackons)=1;

derivlimresult=derivvalues-0;
derivlimons=find(derivlimresult>0);
derivlimons2=zeros(size(values));
derivlimons2(derivlimons)=1;

% backresult=df-dfb;
% backons=find(backresult<0);
% backons2=zeros(size(df));
% backons2(backons)=1;

% threshlow2=base-2*sn;
% localbackonsx=find(localbackresult<-70);
% threshonsx=find(threshlow2-df>0);
% ons21=zeros(size(df));
% ons22=zeros(size(df));
% ons21(localbackonsx)=1;
% ons22(threshonsx)=1;
% ons2=ons22+ons21;
% ons2(find(ons2<2))=0;
% ons2(find(ons2==2))=1;
% 
% ons=ons2;

ons=limons2+threshons2+localbackons2+derivlimons2;
ons(find(ons<4))=0;
ons(find(ons==4))=1;



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