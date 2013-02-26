function [tt,ss,ts,tg,sg]=overlap(sorted);

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
%sumcolltrain is % for each cell
colltrain={};
tt(1).total3o3=0;
tt(1).totalnotto3o3=0;
tt(1).totalnotto2o3=0;
tt(1).totalnotto1o3=0;
tt(1).total0o3=0;
ss(1).total3o3=0;
ss(1).totalnotto3o3=0;
ss(1).totalnotto2o3=0;
ss(1).totalnotto1o3=0;
ss(1).total0o3=0;
tt(1).totalslices=0;
tt(1).totalmovies=0;
ss(1).totalslices=0;
ss(1).totalmovies=0;
sliceswithboth=[];
tg=[];
sg=[];
% regress=[];
for a=1:size(sorted,2);%for each slice
    if sum(goodtstrain(a,:),2)>1;%if there is more than one movie with more than 10 cells coming on from slice "a"
        tt(1).totalslices=tt(1).totalslices+1;
        tt(1).totalmovies=tt(1).totalmovies+sum(goodtstrain(a,:),2);
        sumcolltstrain{a}=zeros(1,length(sorted{a}.contours));
        goodthisslice=find(goodtstrain(a,:));%gives dim2 coords of good movies
        for b=1:size(goodthisslice,2)%for each good tstrain movie
            sumcolltstrain{a}=sumcolltstrain{a}+colltstrain{a}(goodthisslice(b),:);%for each cell, how many movies is it on in?
        end
        sumcolltstrain{a}=sumcolltstrain{a}/size(goodthisslice,2);%for each cell, what percent of movies is it on
        
        tt(a).which3o3=find(sumcolltstrain{a}>=1);%find cells on in 100% of movies
        tt(a).howmany3o3=size(tt(a).which3o3,2);%count how many that is
        tt(a).whichnotto3o3=find(sumcolltstrain{a}>=(2/3) & sumcolltstrain{a}<1);%find cells on 2/3 or more (less than 100%)
        tt(a).howmanynotto3o3=size(tt(a).whichnotto3o3,2);%count how many cells that is
        tt(a).whichnotto2o3=find(sumcolltstrain{a}>=(1/3) & sumcolltstrain{a}<(2/3));%find cells on 1/3 or moe (less than 2/3) of time
        tt(a).howmanynotto2o3=size(tt(a).whichnotto2o3,2);%count how many cells that is
        tt(a).whichnotto1o3=find(sumcolltstrain{a}>0 & sumcolltstrain{a}<(1/3));%find cells on above 0 an below 1/3 of time
        tt(a).howmanynotto1o3=size(tt(a).whichnotto1o3,2);%count how many cells that is
        tt(a).which0o3=find(sumcolltstrain{a}==0);%find cells that never turn on (0%)
        tt(a).howmany0o3=size(tt(a).which0o3,2);%count how many cells that is

        tt(1).total3o3=tt(1).total3o3+tt(a).howmany3o3;
        tt(1).totalnotto3o3=tt(1).totalnotto3o3+tt(a).howmanynotto3o3;
        tt(1).totalnotto2o3=tt(1).totalnotto2o3+tt(a).howmanynotto2o3;
        tt(1).totalnotto1o3=tt(1).totalnotto1o3+tt(a).howmanynotto1o3;
        tt(1).total0o3=tt(1).total0o3+tt(a).howmany0o3;
    end
    if sum(goodspont(a,:),2)>1;%if there is more than one movie with more than 10 cells coming on from slice "a"
        ss(1).totalslices=ss(1).totalslices+1;
        ss(1).totalmovies=ss(1).totalmovies+sum(goodspont(a,:),2);
        sumcollspont{a}=zeros(1,length(sorted{a}.contours));
        goodthisslice=find(goodspont(a,:));%gives dim2 coords of good movies
        for b=1:size(goodthisslice,2)%for each good spont movie
            sumcollspont{a}=sumcollspont{a}+collspont{a}(goodthisslice(b),:);%for each cell, how many movies is it on in?
        end
        sumcollspont{a}=sumcollspont{a}/size(goodthisslice,2);%for each cell, what percent of movies is it on

        ss(a).which3o3=find(sumcollspont{a}>=1);%find cells on in 100% of movies
        ss(a).howmany3o3=size(ss(a).which3o3,2);%count how many that is
        ss(a).whichnotto3o3=find(sumcollspont{a}>=(2/3) & sumcollspont{a}<1);%find cells on 2/3 or more (less than 100%)
        ss(a).howmanynotto3o3=size(ss(a).whichnotto3o3,2);%count how many cells that is
        ss(a).whichnotto2o3=find(sumcollspont{a}>=(1/3) & sumcollspont{a}<(2/3));%find cells on 1/3 or moe (less than 2/3) of time
        ss(a).howmanynotto2o3=size(ss(a).whichnotto2o3,2);%count how many cells that is
        ss(a).whichnotto1o3=find(sumcollspont{a}>0 & sumcollspont{a}<(1/3));%find cells on above 0 an below 1/3 of time
        ss(a).howmanynotto1o3=size(ss(a).whichnotto1o3,2);%count how many cells that is
        ss(a).which0o3=find(sumcollspont{a}==0);%find cells that never turn on (0%)
        ss(a).howmany0o3=size(ss(a).which0o3,2);%count how many cells that is
        
        ss(1).total3o3=ss(1).total3o3+ss(a).howmany3o3;
        ss(1).totalnotto3o3=ss(1).totalnotto3o3+ss(a).howmanynotto3o3;
        ss(1).totalnotto2o3=ss(1).totalnotto2o3+ss(a).howmanynotto2o3;
        ss(1).totalnotto1o3=ss(1).totalnotto1o3+ss(a).howmanynotto1o3;
        ss(1).total0o3=ss(1).total0o3+ss(a).howmany0o3;
        
    end 
    if sum(goodtstrain(a,:),2)>1 & sum(goodspont(a,:),2)>1;%if there is more than one movie with more than 10 cells coming on from slice "a"
%         sliceswithboth(end+1)=a;
        tg=cat(2,tg,sumcolltstrain{a});
        sg=cat(2,sg,sumcollspont{a});
        
        ts(1).alltstoallspontwhich{a}=intersect(find(sumcolltstrain{a}), find(sumcollspont{a}));%tells which cells are commonly on in spont and train in a slice 
        ts(1).alltstoallsponthowmany(a)=size(ts(1).alltstoallspontwhich{a},2);%tells how many cells are on in both spont and stim in a slice
        
        ts(1).tr3o3toallspontwhich{a}=intersect(tt(a).which3o3,find(sumcollspont{a}));%which cells that are always on in tstrains are also on in spont
        ts(1).tr3o3toallsponthowmany(a)=size(ts(1).tr3o3toallspontwhich{a},2);%how many cells is that
                
        ts(1).sp3o3toalltstrainwhich{a}=intersect(ss(a).which3o3,find(sumcolltstrain{a}));
        ts(1).sp3o3toalltstrainhowmany(a)=size(ts(1).sp3o3toalltstrainwhich{a},2);%how many cells is that
   
        ts(1).tr3o3tosp3o3which{a}=intersect(tt(a).which3o3,ss(a).which3o3);%which cells were on in both 100% of spont and 100% of stim
        ts(1).tr3o3tosp3o3howmany(a)=size(ts(1).tr3o3tosp3o3which{a},2);%how many cells is that
        
        ts(1).spontavailons(a)=size(find(sumcollspont{a}),2);%grand total number of cells on in good spont movies in their slice
        ts(1).tstrainavailons(a)=size(find(sumcolltstrain{a}),2);%grand total number of cells on in good tstrain movies in their slice
        ts(1).tr3o3availons(a)=tt(a).howmany3o3;%grand total number of cells on in 100% of tstrains
        ts(1).sp3o3availons(a)=ss(a).howmany3o3;%grand total number of cells on in 100% of spont

%%%%%%%%%%%%%%%%%%%%
        ttcore=cat(2,tt(a).which3o3,tt(a).whichnotto3o3);
        sscore=cat(2,ss(a).which3o3,ss(a).whichnotto3o3);

        ts(1).trcoretoallspontwhich{a}=intersect(ttcore,find(sumcollspont{a}));%which cells that are always on in tstrains are also on in spont
        ts(1).trcoretoallsponthowmany(a)=size(ts(1).trcoretoallspontwhich{a},2);%how many cells is that
                
        ts(1).spcoretoalltstrainwhich{a}=intersect(sscore,find(sumcolltstrain{a}));
        ts(1).spcoretoalltstrainhowmany(a)=size(ts(1).spcoretoalltstrainwhich{a},2);%how many cells is that
   
        ts(1).trcoretospcorewhich{a}=intersect(ttcore,sscore);%which cells were on in both 100% of spont and 100% of stim
        ts(1).trcoretospcorehowmany(a)=size(ts(1).trcoretospcorewhich{a},2);%how many cells is that
        

        ts(1).trcoreavailons(a)=length(ttcore);%grand total number of cells on in 100% of tstrains
        ts(1).spcoreavailons(a)=length(sscore);%grand total number of cells on in 100% of spont        
    end
end

[a,b,c,d,e,f]=fourpercents(ts.alltstoallsponthowmany,ts.spontavailons,ts.tstrainavailons);
a=100*a;
b=100*b;
c=100*c;
d=100*d;
e=100*e;
f=100*f;
disp('Average percent of cells shared by tstrain and spont / spont cells: '),disp(a);
disp('SD of percent of cells shared by tstrain and spont / spont cells: '),disp(e);
disp('Overall percent of cells shared by tstrain and spont / spont cells: '),disp(b);
disp('Average percent of cells shared by tstrain and spont / train cells: '),disp(c);
disp('SD of percent of cells shared by tstrain and spont / train cells: '),disp(f);
disp('Overall percent of cells shared by tstrain and spont / train cells: '),disp(d);
disp ('------------------');

[a,b,c,d,e,f]=fourpercents(ts.tr3o3toallsponthowmany,ts.tr3o3availons,ts.spontavailons);
a=100*a;
b=100*b;
c=100*c;
d=100*d;
e=100*e;
f=100*f;
disp('Average percent of cells shared by 100% of trains and by any spont / cells on in 100% of trains'),disp(a);
disp('SD of percent of cells shared by 100% of trains and by any spont / cells on in 100% of trains'),disp(e);
disp('Overall percent of cells shared by 100% of trains and by any spont / cells on in 100% of trains'),disp(b);
disp('Average percent of cells shared by 100% of trains and by any spont / cells on in spont'),disp(c);
disp('SD of percent of cells shared by 100% of trains and by any spont / cells on in spont'),disp(f);
disp('Overall percent of cells shared by 100% of trains and by any spont / cells on in spont'),disp(d);
disp ('------------------');

[a,b,c,d,e,f]=fourpercents(ts.sp3o3toalltstrainhowmany,ts.sp3o3availons,ts.tstrainavailons);
a=100*a;
b=100*b;
c=100*c;
d=100*d;
e=100*e;
f=100*f;
disp('Average percent of cells shared by 100% of spont and by any train / cells on in 100% of spont'),disp(a);
disp('SD of percent of cells shared by 100% of spont and by any train / cells on in 100% of spont'),disp(e);
disp('Overall percent of cells shared by 100% of spont and by any train / cells on in 100% of spont'),disp(b);
disp('Average percent of cells shared by 100% of spont and by any train / cells on in any train'),disp(c);
disp('SD of percent of cells shared by 100% of spont and by any train / cells on in any train'),disp(f);
disp('Overall percent of cells shared by 100% of spont and by any train / cells on in any train'),disp(d);
disp ('------------------');

[a,b,c,d,e,f]=fourpercents(ts.tr3o3tosp3o3howmany,ts.sp3o3availons,ts.tr3o3availons);
a=100*a;
b=100*b;
c=100*c;
d=100*d;
e=100*e;
f=100*f;
disp('Average percent of cells shared by 100% of spont and 100% of train / cells on in 100% of spont'),disp(a);
disp('SD of percent of cells shared by 100% of spont and 100% of train / cells on in 100% of spont'),disp(e);
disp('Overall percent of cells shared by 100% of spont and 100% of train / cells on in 100% of spont'),disp(b);
disp('Average percent of cells shared by 100% of spont and 100% of train / cells on in 100% of trains'),disp(c);
disp('SD of percent of cells shared by 100% of spont and 100% of train / cells on in 100% of trains'),disp(f);
disp('Overall percent of cells shared by 100% of spont and 100% of train / cells on in 100% of trains'),disp(d);
disp ('------------------');
disp ('------------------');
disp ('------------------');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[a,b,c,d,e,f]=fourpercents(ts.alltstoallsponthowmany,ts.spontavailons,ts.tstrainavailons);
a=100*a;
b=100*b;
c=100*c;
d=100*d;
e=100*e;
f=100*f;
disp('Average percent of cells shared by tstrain and spont / spont cells: '),disp(a);
disp('SD of percent of cells shared by tstrain and spont / spont cells: '),disp(e);
disp('Overall percent of cells shared by tstrain and spont / spont cells: '),disp(b);
disp('Average percent of cells shared by tstrain and spont / train cells: '),disp(c);
disp('SD of percent of cells shared by tstrain and spont / train cells: '),disp(f);
disp('Overall percent of cells shared by tstrain and spont / train cells: '),disp(d);
disp ('------------------');

[a,b,c,d,e,f]=fourpercents(ts.trcoretoallsponthowmany,ts.trcoreavailons,ts.spontavailons);
a=100*a;
b=100*b;
c=100*c;
d=100*d;
e=100*e;
f=100*f;
disp('Average percent of cells in core of trains and by any spont / cells in core of trains'),disp(a);
disp('SD of percent of cells in core of trains and by any spont / cells in core of trains'),disp(e);
disp('Overall percent of cells in core of trains and by any spont / cells in core of trains'),disp(b);
disp('Average percent of cells in core of trains and by any spont / cells on in spont'),disp(c);
disp('SD of percent of cells in core of trains and by any spont / cells on in spont'),disp(f);
disp('Overall percent of cells in core of trains and by any spont / cells on in spont'),disp(d);
disp ('------------------');

[a,b,c,d,e,f]=fourpercents(ts.spcoretoalltstrainhowmany,ts.spcoreavailons,ts.tstrainavailons);
a=100*a;
b=100*b;
c=100*c;
d=100*d;
e=100*e;
f=100*f;
disp('Average percent of cells in core of spont and by any train / cells in core of spont'),disp(a);
disp('SD of percent of cells in core of spont and by any train / cells in core of spont'),disp(e);
disp('Overall percent of cells in core of spont and by any train / cells in core of spont'),disp(b);
disp('Average percent of cells in core of spont and by any train / cells on in any train'),disp(c);
disp('SD of percent of cells in core of spont and by any train / cells on in any train'),disp(f);
disp('Overall percent of cells in core of spont and by any train / cells on in any train'),disp(d);
disp ('------------------');

[a,b,c,d,e,f]=fourpercents(ts.trcoretospcorehowmany,ts.spcoreavailons,ts.trcoreavailons);
a=100*a;
b=100*b;
c=100*c;
d=100*d;
e=100*e;
f=100*f;
disp('Average percent of cells in core of spont and in core of train / cells in core of spont'),disp(a);
disp('SD of percent of cells in core of spont and in core of train / cells in core of spont'),disp(e);
disp('Overall percent of cells in core of spont and in core of train / cells in core of spont'),disp(b);
disp('Average percent of cells in core of spont and in core of train / cells in core of trains'),disp(c);
disp('SD of percent of cells in core of spont and in core of train / cells in core of trains'),disp(f);
disp('Overall percent of cells in core of spont and in core of train / cells in core of trains'),disp(d);
disp ('------------------');
disp ('------------------');
disp ('------------------');

plot(tg,sg,'.');