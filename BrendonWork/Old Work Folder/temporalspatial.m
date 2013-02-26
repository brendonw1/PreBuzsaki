function ons=temporalspatial(values,outvalues);


% df=diff(values);%sequences of the differences between each frame for each cell
% dfo=diff(outvalues);%sequences of the differences between each frame for each cell
%df=df-dfo;

df=values-outvalues;
dfo=outvalues;


%%%%%%%%finding baseline of each cell in each movie
mt=mean(df,1);%find the mean value of each cell across all frames within each movie
mt=repmat(mt,[size(df,1) 1 1]);%replicating over frames, so that matrix is same size as multi-frame matrix
st=std(df,0,1);%find the standard deviation of each cell across all frames within each movie
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
        base(:,a,b)=c(4:end-3);%exclude tips of result of convolved graph 
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%baselines made

backsds=std(dfo,0,1);
backsds=repmat(backsds,[size(df,1) 1 1]);


threshlow=base-4*backsds;%threshold for quenching events (increased calcium)... 2 SD of noise below baseline
% threshhigh=base+2*sn;%for recovery from quenching (decreasing calcium)... 2 SD of noise above baseline
threshresult=threshlow-df;
threshons=find(threshresult>0);
ons=zeros(size(df));
ons(threshons)=1;

