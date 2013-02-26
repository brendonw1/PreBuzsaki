function [ons,thresholds]=doublefilter(conts,values,outvalues,backs,lengths);
% Outputs are "ons" which is a logical array of frame number (dim 1) x cell number
% (dim 2).  "Thresholds" is recording of what was entered by the user:
% thresholds used for each movie (local threshold first, whole background
% threshold second).
% Generally, this takes values for each frame for each cell ("values") and finds mean
% and baseline for each cell.  Then it uses a threshold, set by user input
% for each movie, to find brightness (value) changes in each cell that
% represent an "on" event in that cell.  In order for a cell to be
% classified as "on" in a particular frame, it must pass both filters: 1
% which sets a threshold for dip in brightness below the background of the
% whole image "backs" and a second which sets a similar threshold for dip
% in brightness below a local background "outvalues".  
% Lengths is entered by the user in the base workspace and represents the
% length of each movie in frames... movies here are all concatenated
% together.
% Conts is generated in findmatrixnofig.m (along with outconts which will
% allow one to generate outvalues)
% Values, Outvalues, Backs are generated in lengthcontvalues.m

warning off MATLAB:conversionToLogical
dfback=values-repmat(backs,[1 size(values,2)]);
dfout=values-outvalues;

lengths=cumsum(lengths);%gives end frame of each movie in initial sequence
lengths=lengths-(1:length(lengths));%corrects for the fact that now movies are df movies
lengths(2:(length(lengths)+1))=lengths;
lengths(1)=0;

count=1;
while count<=(length(lengths)-1);%for each movie
    movieout=dfout((lengths(count)+1):lengths(count+1),:);
    %%%%%%%%finding baseline of each cell in each movie
	mt=mean(movieout,1);%find the mean value of each cell across all frames within each movie
	mt=repmat(mt,[size(movieout,1) 1]);%replicating over frames, so that matrix is same size as multi-frame matrix
	st=std(movieout,1);%find the standard deviation of each cell across all frames within each movie
	st=repmat(st,[size(movieout,1) 1]);%replicating over frames, so that matrix is same size as multi-frame matrix
	ul=mt+st;%matrix of mean + sd for each cell in each movie
	ll=mt-st;%matrix of mean - sd for each cell in each movie
	ul=movieout-ul;
	ll=ll-movieout;
	a=find(ul>0);%find frames where cell is more than 1 SD above mean for that movie
	b=find(ll>0);%find frames where cell is more than 1 SD below mean for that movie
	flat=movieout;%will be a series of flattened out profiles for each cell across frames for each movie
	flat(a)=mt(a);%where was above 1SD above mean, set equal to mean for that cell for that movie 
	flat(b)=mt(b);%where was below 1SD below mean, set equal to mean for that cell for that movie
	h=hanning(7);%create a filter
	h=h/sum(h);%normalize
	base=zeros(size(movieout));
    for b=1:size(movieout,2);%for each cell
        c=conv(flat(:,b),h);%convolve frames df for each cell with hanning filter
        base(:,b)=c(4:end-3);
    end
	%%%%%%%%baseline found
    movienumber=num2str(count);
    statement=strcat ('Enter local threshold for movie ',movienumber,': ');
    threshout=input(statement);
    threshlow=base-threshout;%threshold for quenching events (increased calcium)
	% threshhigh=base+2*sn;%for recovery from quenching (decreasing calcium)
	t=threshlow-movieout;
	t=find(t>0);%find where movie value is lower than the lower threshold
	temponsout=zeros(size(movieout));
	temponsout(t)=1;
    thresholds(count,1)=threshout;%adding to a record-keeping matrix which will be an output
    
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%new filter
  
    movieback=dfback((lengths(count)+1):lengths(count+1),:);
    %%%%%%%%finding baseline of each cell in each movie
	mt=mean(movieback,1);%find the mean value of each cell across all frames within each movie
	mt=repmat(mt,[size(movieback,1) 1]);%replicating over frames, so that matrix is same size as multi-frame matrix
	st=std(movieback,1);%find the standard deviation of each cell across all frames within each movie
	st=repmat(st,[size(movieback,1) 1]);%replicating over frames, so that matrix is same size as multi-frame matrix
	ul=mt+st;%matrix of mean + sd for each cell in each movie
	ll=mt-st;%matrix of mean - sd for each cell in each movie
	ul=movieback-ul;
	ll=ll-movieback;
	a=find(ul>0);%find frames where cell is more than 1 SD above mean for that movie
	b=find(ll>0);%find frames where cell is more than 1 SD below mean for that movie
	flat=movieback;%will be a series of flattened out profiles for each cell across frames for each movie
	flat(a)=mt(a);%where was above 1SD above mean, set equal to mean for that cell for that movie 
	flat(b)=mt(b);%where was below 1SD below mean, set equal to mean for that cell for that movie
	h=hanning(7);%create a filter
	h=h/sum(h);%normalize
	base=zeros(size(movieback));
    for b=1:size(movieback,2);%for each cell
        c=conv(flat(:,b),h);%convolve frames df for each cell with hanning filter
        base(:,b)=c(4:end-3);
    end
	%%%%%%%%baseline found
    movienumber=num2str(count);
    statement=strcat ('Enter whole-image threshold for movie ',movienumber,': ');
    threshback=input(statement);
    threshlow=base-threshback;%threshold for quenching events (increased calcium)
	% threshhigh=base+2*sn;%for recovery from quenching (decreasing calcium)
	t=threshlow-movieback;
	t=find(t>0);%find where movie value is lower than the lower threshold
	temponsback=zeros(size(movieback));
	temponsback(t)=1;
    thresholds(count,2)=threshback;%adding to a record-keeping matrix which will be an output
    
    %%%%%%%%%making sure the cells fit both filters%%%%%%%%
    tempons=temponsout+temponsback;
    tempons(find(tempons<2))=0;
    tempons=logical(tempons);
    
	for f=0:size(movieout,1)-1;%for each frame
        figure;
        highlightons(conts,tempons((size(movieout,1)-f),:));%display all frames
    end
    
    answer = input('Are these good thresholds for this movie? Enter y/n: ','s');
    ycmp=strcmp('y',answer);
    ncmp=strcmp('n',answer);
    
    while ycmp==0 & ncmp==0;
        disp ('enter y or n');
        answer = input('Is this a good threshold for this movie? Enter y/n: ','s');
        ycmp=strcmp('y',answer);
        ncmp=strcmp('n',answer);
        continue
    end
    
    if ycmp==1;
        ons((lengths(count)+1):lengths(count+1),:)=tempons;
        count=count+1;   
    end
end