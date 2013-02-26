function ons=usebackdevs(values,backs);

% lbacks=diff(backs);
% df=diff(values);%sequences of the differences between each frame for each cell
% bbacks=repmat(lbacks,[1,1,size(df,3)]);
% df=df-bbacks;

df=values-repmat(backs,[1 1 size(values,3)]);


%%%%%%%%finding baseline of each cell in each movie
mt=mean(df,1);%find the mean value of each cell across all frames within each movie
mt=repmat(mt,[size(df,1) 1 1]);%replicating over frames, so that matrix is same size as multi-frame matrix
st=std(df,1);%find the standard deviation of each cell across all frames within each movie
st=repmat(st,[size(df,1) 1 1]);%replicating over frames, so that matrix is same size as multi-frame matrix

% mb=mean(backs,1);
% mb=repmat(mb,[size(values,1) 1 1]);%
% zerobacks=backs-mb;%set mean of background for each frame to zero for each movie... so can be subtracted from frame values of contours;
% zerovalues=values-mt;%set mean of each cell in each movie to 0
% zerovalues=zerovalues-zerobacks;%subtract background fluctuation
% 
lbacks=backs(1:end);
sb=std(lbacks);%a measure of the noise level of the image
sb=repmat(sb,size(df));

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

threshlow=base-4*sb;%threshold for quenching events (increased calcium)... 2 SD of noise below baseline
% threshhigh=base+2*sn;%for recovery from quenching (decreasing calcium)... 2 SD of noise above baseline
threshresult=threshlow-df;
threshons=find(threshresult>0);
ons=zeros(size(df));
ons(threshons)=1;

