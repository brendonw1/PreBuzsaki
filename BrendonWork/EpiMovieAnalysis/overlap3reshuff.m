function [tt,ss,ts,tg,sg]=overlap(sorted);

goodperslice=2;

warning off MATLAB:conversionToLogical
warning off MATLAB:divideByZero

for c=1:size(sorted,2);%for each slice
    if ~isempty(sorted{c}.tstrain)%j;%if there were tstrain movies for this slice, then...
        slicecolltstrain{c}=zeros(1,length(sorted{c}.contours));%establish matrix
        for d=1:size(sorted{c}.tstrain,2)
            colltstrain{c}(d,:)=sum(sorted{c}.tstrain(d).ons,1);%collapse data from all frames into a single chunk of data
            colltstrain{c}=logical(colltstrain{c});%a cell that is on in a movie=1 (not more if it is on multiple times)
            slicecolltstrain{c}=colltstrain{c}(d,:)+slicecolltstrain{c};%collapse all cells on from the tstrain movies for a slice
            if sum(colltstrain{c}(d,:),2)>=10;%if total number of cells on in this movie is greater than 10:
                goodtstrain(c,d)=1;%record that this movie was big enough... in this form for easy measuring of size
            end
        end
    end
    if ~isempty(sorted{c}.spont)%j;%if there were tstrain movies for this slice, then...
        slicecollspont{c}=zeros(1,length(sorted{c}.contours));
        for d=1:size(sorted{c}.spont,2)
            collspont{c}(d,:)=sum(sorted{c}.spont(d).ons,1);%collapse data from all frames into a single chunk of data
            collspont{c}=logical(collspont{c});%a cell that is on in a movie=1 (not more if it is on multiple times)
            slicecollspont{c}=collspont{c}(d,:)+slicecollspont{c};%collapse all cells on from the tstrain movies for a slice
            if sum(collspont{c}(d,:),2)>=10;%if total number of cells on in this movie is greater than 5:
                goodspont(c,d)=1;%record that this movie was big enough... in this form for easy measuring of size
            end
        end
    end
end
colltrain={};
sumcolltstrain={};
sumcollspont={};
tt.whichcore=[];
tt.howmanycore=[];
ss.whichcore=[];
ss.howmanycore=[];
ts.whichcore=[];
ts.howmanycore=[];tg=[];
sg=[];
for a=1:size(sorted,2);%for each slice
    if sum(goodtstrain(a,:),2)>=goodperslice;%if there is more than one movie with more than 10 cells coming on from slice "a"
        sumcolltstrain{a}=zeros(1,length(sorted{a}.contours));
        goodthisslice=find(goodtstrain(a,:));%gives dim2 coords of good movies
        for b=1:size(goodthisslice,2)%for each good tstrain movie
            sumcolltstrain{a}=sumcolltstrain{a}+colltstrain{a}(goodthisslice(b),:);%for each cell, how many movies is it on in?
        end
        sumcolltstrain{a}=sumcolltstrain{a}/size(goodthisslice,2);%for each cell, what percent of movies is it on
        
        tt(a).whichcore=find(sumcolltstrain{a}>=(.8) & sumcolltstrain{a}<=1);%find cells on 2/3 or more (less than 100%)
    end
    if sum(goodspont(a,:),2)>=goodperslice;%if there is more than one movie with more than 10 cells coming on from slice "a"
        sumcollspont{a}=zeros(1,length(sorted{a}.contours));
        goodthisslice=find(goodspont(a,:));%gives dim2 coords of good movies
        for b=1:size(goodthisslice,2)%for each good spont movie
            sumcollspont{a}=sumcollspont{a}+collspont{a}(goodthisslice(b),:);%for each cell, how many movies is it on in?
        end
        sumcollspont{a}=sumcollspont{a}/size(goodthisslice,2);%for each cell, what percent of movies is it on
        
        ss(a).whichcore=find(sumcollspont{a}>=(.8) & sumcollspont{a}<=1);%find cells on 2/3 or more (less than 100%)  
    end 
    if size(tt,2)==a & size(ss,2)==a;%if there is more than one movie with more than 10 cells coming on from slice "a"
        tscore{a}=intersect(tt(a).whichcore,ss(a).whichcore);
        howmanytscore(a)=length(tscore{a});
        howmanytcore(a)=length(tt(a).whichcore);
        howmanyscore(a)=length(ss(a).whichcore);
    end
    if size(tt,2)==a & size(sumcollspont,2)==a;%if a ttcore, regardless of situation with ss
        tcoresall{a}=intersect(tt(a).whichcore,find(sumcollspont{a}));
        howmanytcoresall(a)=length(tcoresall{a});
        howmanysall(a)=length(find(sumcollspont{a}));
    end
    if size(ss,2)==a & size(sumcolltstrain,2)==a;%if a ttcore, regardless of situation with ss
        scoresall{a}=intersect(ss(a).whichcore,find(sumcolltstrain{a}));
        howmanyscoretall(a)=length(scoresall{a});
        howmanytall(a)=length(find(sumcolltstrain{a}));
    end
end

[a,b,c,d,e,f]=fourpercents(howmanytscore,howmanytcore,howmanyscore);
a=100*a;
b=100*b;
c=100*c;
d=100*d;
e=100*e;
f=100*f;
disp('Average percent of cells in core of spont and in core of train / cells in core of train'),disp(a);
disp('SD of percent of cells in core of spont and in core of train / cells in core of train'),disp(e);
disp('Overall percent of cells in core of spont and in core of train / cells in core of trains'),disp(b);
disp('Average percent of cells in core of spont and in core of train / cells in core of spont'),disp(c);
disp('SD of percent of cells in core of spont and in core of train / cells in core of spont'),disp(f);
disp('Overall percent of cells in core of spont and in core of train / cells in core of spont'),disp(d);
disp ('------------------');

[a,b,c,d,e,f]=fourpercents(howmanytcoresall,howmanytcore,howmanysall);
a=100*a;
b=100*b;
c=100*c;
d=100*d;
e=100*e;
f=100*f;
disp('Average percent of cells in core of train and any spont / cells in core of train'),disp(a);
disp('SD of percent of cells in core of train and any spont / cells in core of train'),disp(e);
disp('Overall percent of cells in core of train and any spont / cells in core of trains'),disp(b);
disp('Average percent of cells in core of train and any spont / active cells in spont'),disp(c);
disp('SD of percent of cells in core of train and any spont / active cells in spont'),disp(f);
disp('Overall percent of cells in core of train and any spont / active cells in spont'),disp(d);
disp ('------------------');


[a,b,c,d,e,f]=fourpercents(howmanyscoretall,howmanyscore,howmanytall);
a=100*a;
b=100*b;
c=100*c;
d=100*d;
e=100*e;
f=100*f;
disp('Average percent of cells in core of spont and any train / cells in core of spont'),disp(a);
disp('SD of percent of cells in core of spont and any train / cells in core of spont'),disp(e);
disp('Overall percent of cells in core of spont and any train / cells in core of spont'),disp(b);
disp('Average percent of cells in core of spont and any train / active cells in train'),disp(c);
disp('SD of percent of cells in core of spont and any train / active cells in train'),disp(f);
disp('Overall percent of cells in core of spont and any train / active cells in train'),disp(d);
disp ('------------------');

figure;hist(howmanyscoretall(find(howmanyscoretall))./howmanytall(find(howmanyscoretall)));
