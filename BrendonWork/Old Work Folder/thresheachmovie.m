function [ons,thresholds]=thresheachmovie(conts,values,backs,lengths);

df=values-repmat(backs,[1 size(values,2)]);;

lengths=cumsum(lengths);%gives end frame of each movie in initial sequence
lengths=lengths-(1:length(lengths));%corrects for the fact that now movies are df movies
lengths(2:(length(lengths)+1))=lengths;
lengths(1)=0;

count=1;
while count<=(length(lengths)-1);%for each movie
    movie=df((lengths(count)+1):lengths(count+1),:);
    %%%%%%%%finding baseline of each cell in each movie
	mt=mean(movie,1);%find the mean value of each cell across all frames within each movie
	mt=repmat(mt,[size(movie,1) 1]);%replicating over frames, so that matrix is same size as multi-frame matrix
	st=std(movie,1);%find the standard deviation of each cell across all frames within each movie
	st=repmat(st,[size(movie,1) 1]);%replicating over frames, so that matrix is same size as multi-frame matrix
	ul=mt+st;%matrix of mean + sd for each cell in each movie
	ll=mt-st;%matrix of mean - sd for each cell in each movie
	ul=movie-ul;
	ll=ll-movie;
	a=find(ul>0);%find frames where cell is more than 1 SD above mean for that movie
	b=find(ll>0);%find frames where cell is more than 1 SD below mean for that movie
	flat=movie;%will be a series of flattened out profiles for each cell across frames for each movie
	flat(a)=mt(a);%where was above 1SD above mean, set equal to mean for that cell for that movie 
	flat(b)=mt(b);%where was below 1SD below mean, set equal to mean for that cell for that movie
	h=hanning(7);%create a filter
	h=h/sum(h);%normalize
	base=zeros(size(movie));
    for b=1:size(movie,2);%for each cell
        c=conv(flat(:,b),h);%convolve frames df for each cell with hanning filter
        base(:,b)=c(4:end-3);
    end
	%%%%%%%%baseline found
    
    movienumber=num2str(count);
    statement=strcat ('Enter threshold for movie ',movienumber,': ');
    thresh=input(statement);
    threshlow=base-thresh;%threshold for quenching events (increased calcium)
	% threshhigh=base+2*sn;%for recovery from quenching (decreasing calcium)
	t=threshlow-movie;
	t=find(t>0);%find where movie value is lower than the lower threshold
	tempons=zeros(size(movie));
	tempons(t)=1;
    thresholds(count)=thresh;
	
	for f=0:size(movie,1)-1;%for each frame
        figure;
        highlightons(conts,tempons((size(movie,1)-f),:));%display all frames
    end
    
    answer = input('Is this a good threshold for this movie? Enter y/n: ','s');
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