function reshuffoverlap3(sorted,flatshuffsorted);
% function [scores,sact,tcores,tact]=overlap3(sorted,flatshuffsorted);
% function [tt,ss,ts,tg,sg]=overlap3(sorted);

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
% 
% for a=1:size(sorted,2);%for each slice... we'll make numbers of movies the same for both spont and stim in each slice
%     m=min([sum(goodtstrain(a,:)) sum(goodspont(a,:))]);%figure out whether less spont or less stim movies
%     t=find(goodtstrain(a,:));
%     s=find(goodspont(a,:));
%     t=t(1:m);
%     s=s(1:m);
%     goodtstrain(a,:)=zeros(1,size(goodtstrain,2));
%     goodtstrain(a,t)=1;
%     goodspont(a,:)=zeros(1,size(goodspont,2));
%     goodspont(a,s)=1;
% end


colltrain={};
sumcolltstrain={};
sumcollspont={};
tt.whichcore=[];
tt.whichactive=[];
ss.whichcore=[];
ss.whichactive=[];
ts.whichcore=[];
ts.whichactive=[];
% tg=[];
% sg=[];
for a=1:size(sorted,2);%for each slice
    if sum(goodtstrain(a,:),2)>=1;%if there is more than one movie with more than 10 cells coming on from slice "a"
        sumcolltstrain{a}=zeros(1,length(sorted{a}.contours));
        goodthisslice=find(goodtstrain(a,:));%gives dim2 coords of good movies
        for b=1:size(goodthisslice,2)%for each good tstrain movie
            sumcolltstrain{a}=sumcolltstrain{a}+colltstrain{a}(goodthisslice(b),:);%for each cell, how many movies is it on in?
        end
        sumcolltstrain{a}=sumcolltstrain{a}/size(goodthisslice,2);%for each cell, what percent of movies is it on
        if sum(goodtstrain(a,:),2)>=goodperslice;%if there is more than one movie with more than 10 cells coming on from slice "a"
            tt(a).whichcore=find(sumcolltstrain{a}>=1);%find cells on in 100% of movies
        end
        tt(a).whichactive=find(sumcolltstrain{a});%record which cells were active
    end
    if sum(goodspont(a,:),2)>=1;%if there is one movie with more than 10 cells coming on from slice "a"
        sumcollspont{a}=zeros(1,length(sorted{a}.contours));
        goodthisslice=find(goodspont(a,:));%gives dim2 coords of good movies
        for b=1:size(goodthisslice,2)%for each good spont movie
            sumcollspont{a}=sumcollspont{a}+collspont{a}(goodthisslice(b),:);%for each cell, how many movies is it on in?
        end
        sumcollspont{a}=sumcollspont{a}/size(goodthisslice,2);%for each cell, what percent of movies is it on
        if sum(goodspont(a,:),2)>=goodperslice;%if at least two good movies
            ss(a).whichcore=find(sumcollspont{a}>=1);%find cells on in 100% of movies
        end
        ss(a).whichactive=find(sumcollspont{a});%record which cells were active
    end 
    if sum(goodtstrain(a,:),2)>=goodperslice & sum(goodspont(a,:),2)>=goodperslice;%if there is more than one movie with more than 10 cells coming on from slice "a"
        tscore{a}=intersect(tt(a).whichcore,ss(a).whichcore);
        howmanytscore(a)=length(tscore{a});
    end
    if  sum(goodtstrain(a,:),2)>=goodperslice & sum(goodspont(a,:),2);%if a ttcore, and at least one good spont movie
        tcoresall{a}=intersect(tt(a).whichcore,find(sumcollspont{a}));
        howmanytcoresall(a)=length(tcoresall{a});
    end
    if sum(goodspont(a,:),2)>=goodperslice & sum(goodtstrain(a,:),2);%if a sscore, and at least one good tstrain movie
        scoretall{a}=intersect(ss(a).whichcore,find(sumcolltstrain{a}));
        howmanyscoretall(a)=length(scoretall{a});
    end
end
for a=1:size(sorted,2);
    scores(a)=length(ss(a).whichcore);
    sact(a)=length(ss(a).whichactive);
    tcores(a)=length(tt(a).whichcore);
    tact(a)=length(tt(a).whichactive);
end    
spont2=find(sum(goodspont,2)>=2);
train2=find(sum(goodtstrain,2)>=2);
perctcore=sum(tcores(train2))/sum(tact(train2));
percscore=sum(scores(spont2))/sum(sact(spont2));
both=intersect(find(scores),find(tcores));
tsbyt=sum(howmanytscore(both))/sum(tcores(both));
tsbys=sum(howmanytscore(both))/sum(scores(both));
tcoreandsall=intersect(find(tcores),find(sum(goodspont,2)));
scoreandtall=intersect(find(scores),find(sum(goodtstrain,2)));
tcoresallbytcore=sum(howmanytcoresall(tcoreandsall))/sum(tcores(tcoreandsall));
tcoresallbysall=sum(howmanytcoresall(tcoreandsall))/sum(sact(tcoreandsall));
scoretallbyscore=sum(howmanyscoretall(scoreandtall))/sum(scores(scoreandtall));
scoretallbytall=sum(howmanyscoretall(scoreandtall))/sum(tact(scoreandtall));


for z=1:1000;%for each reshuffled dataset
    z
	for a=1:size(sorted,2);%for each slice
        if sum(goodtstrain(a,:),2)>=1;%if there is more than one movie with more than 10 cells coming on from slice "a"
            sumcolltstrain{a}=zeros(1,length(sorted{a}.contours));
            goodthisslice=find(goodtstrain(a,:));%gives dim2 coords of good movies
            for b=1:size(goodthisslice,2)%for each good tstrain movie
                sumcolltstrain{a}=sumcolltstrain{a}+flatshuffsorted{a}.tstrain(goodthisslice(b)).ons(1,:,z);%for each cell, how many movies is it on in?
            end
            sumcolltstrain{a}=sumcolltstrain{a}/size(goodthisslice,2);%for each cell, what percent of movies is it on
            if sum(goodtstrain(a,:),2)>=goodperslice;%if at least two good movies
                rtt(z,a).whichcore=find(sumcolltstrain{a}>=1);%find cells on in 100% of movies
            end
            rtt(z,a).whichactive=find(sumcolltstrain{a});%record which cells were active
        end
        if sum(goodspont(a,:),2)>=1;%if there is more than one movie with more than 10 cells coming on from slice "a"
            sumcollspont{a}=zeros(1,length(sorted{a}.contours));
            goodthisslice=find(goodspont(a,:));%gives dim2 coords of good movies
            for b=1:size(goodthisslice,2)%for each good spont movie
                sumcollspont{a}=sumcollspont{a}+flatshuffsorted{a}.spont(goodthisslice(b)).ons(1,:,z);%for each cell, how many movies is it on in?
            end
            sumcollspont{a}=sumcollspont{a}/size(goodthisslice,2);%for each cell, what percent of movies is it on
            if sum(goodspont(a,:),2)>=goodperslice;%if at least two good movies
                rss(z,a).whichcore=find(sumcollspont{a}>=1);%find cells on in 100% of movies
            end
            rss(z,a).whichactive=find(sumcollspont{a});%record which cells were active
        end 
        if sum(goodtstrain(a,:),2)>=goodperslice & sum(goodspont(a,:),2)>=goodperslice;%if there is more than one movie with more than 10 cells coming on from slice "a"
            tscore{a}=intersect(rtt(z,a).whichcore,rss(z,a).whichcore);
            howmanytscore(a)=length(tscore{a});
        end
        if  sum(goodtstrain(a,:),2)>=goodperslice & sum(goodspont(a,:),2);%if a ttcore, and at least one good spont movie
            tcoresall{a}=intersect(rtt(z,a).whichcore,find(sumcollspont{a}));
            howmanytcoresall(a)=length(tcoresall{a});
        end
        if sum(goodspont(a,:),2)>=goodperslice & sum(goodtstrain(a,:),2);%if a sscore, and at least one good tstrain movie
            scoretall{a}=intersect(rss(z,a).whichcore,find(sumcolltstrain{a}));
            howmanyscoretall(a)=length(scoretall{a});
        end
	end
    for a=1:size(sorted,2);
        rscores(z,a)=length(rss(z,a).whichcore);
        rsact(z,a)=length(rss(z,a).whichactive);
        rtcores(z,a)=length(rtt(z,a).whichcore);
        rtact(z,a)=length(rtt(z,a).whichactive);
	end    
    both=intersect(find(rscores(z,:)),find(rtcores(z,:)));
%     rtsbyt(z)=sum(howmanytscore(both))/sum(rtcores(z,both));
%     rtsbys(z)=sum(howmanytscore(both))/sum(rscores(z,both));
    tcoreandsall=intersect(find(rtcores(z,:)),find(sum(goodspont,2)));
    scoreandtall=intersect(find(rscores(z,:)),find(sum(goodtstrain,2)));
	rtcoresallbytcore(z)=sum(howmanytcoresall(tcoreandsall))/sum(rtcores(z,tcoreandsall));
	rtcoresallbysall(z)=sum(howmanytcoresall(tcoreandsall))/sum(rsact(z,tcoreandsall));
	rscoretallbyscore(z)=sum(howmanyscoretall(scoreandtall))/sum(rscores(z,scoreandtall));
	rscoretallbytall(z)=sum(howmanyscoretall(scoreandtall))/sum(rtact(z,scoreandtall));
    distperctcore(z)=sum(rtcores(z,train2))/sum(rtact(z,train2));
    distpercscore(z)=sum(rscores(z,spont2))/sum(rsact(z,spont2));
end

both=intersect(find(scores),find(tcores));

for z=1:1000;%finding chance of getting overlapping t&s cores, given the cores we have
    z
	for a=1:length(both);
        t=zeros(1,length(sorted{both(a)}.contours));
        t(1:length(tt(both(a)).whichcore))=1;
        t=reshufflewhichcells(t);%reshuffling our cores... what is chance of overlap
        s=zeros(1,length(sorted{both(a)}.contours));
        s(1:length(ss(both(a)).whichcore))=1;
        s=reshufflewhichcells(s);
        rtsbys(z)=length(intersect(find(s),find(t)))/length(ss(both(a)).whichcore);
        rtsbyt(z)=length(intersect(find(s),find(t)))/length(tt(both(a)).whichcore);
	end
end


figure;hist(100*distperctcore,100)
hold on
plot(100*perctcore,1,'*','color','r')
m=100*mean(distperctcore);
s=100*std(distperctcore);
xlabel('Percent of active Trig cells that are in cores')
ylabel('Observations');
title('Distribution in random Trig data sets vs observed (red)')
legend(['Obs = ',num2str(100*perctcore)],['Mean = ',num2str(m),', SD = ',num2str(s)])

figure;hist(100*distpercscore,100)
hold on
plot(100*percscore,1,'*','color','r')
m=100*mean(distpercscore);
s=100*std(distpercscore);
xlabel('Percent of active Spont cells that are in cores')
ylabel('Observations');
title('Distribution in random Spont data sets vs observed (red)')
legend(['Obs = ',num2str(100*percscore)],['Mean = ',num2str(m),', SD = ',num2str(s)])

%%%%%%%%%%%
figure;hist(100*rtcoresallbytcore,100)
hold on
plot(100*tcoresallbytcore,1,'*','color','r')
m=100*mean(rtcoresallbytcore);
s=100*std(rtcoresallbytcore);
xlabel('Percent of T core cells that are in also in spont')
ylabel('Observations');
title('Distribution in random data sets vs observed (red)')
legend(['Obs = ',num2str(100*tcoresallbytcore)],['Mean = ',num2str(m),', SD = ',num2str(s)])

figure;hist(100*rtcoresallbysall,100)
hold on
plot(100*tcoresallbysall,1,'*','color','r')
m=100*mean(rtcoresallbysall);
s=100*std(rtcoresallbysall);
xlabel('Percent of Spont cells that are T core cells')
ylabel('Observations');
title('Distribution in random data sets vs observed (red)')
legend(['Obs = ',num2str(100*tcoresallbysall)],['Mean = ',num2str(m),', SD = ',num2str(s)])

figure;hist(100*rscoretallbyscore,100)
hold on
plot(100*scoretallbyscore,1,'*','color','r')
m=100*mean(rscoretallbyscore);
s=100*std(rscoretallbyscore);
xlabel('Percent of S core cells that are in also in Trig')
ylabel('Observations');
title('Distribution in random data sets vs observed (red)')
legend(['Obs = ',num2str(100*scoretallbyscore)],['Mean = ',num2str(m),', SD = ',num2str(s)])

figure;hist(100*rscoretallbytall,100)
hold on
plot(100*scoretallbytall,1,'*','color','r')
m=100*mean(rscoretallbytall);
s=100*std(rscoretallbytall);
xlabel('Percent of Trig cells that are S core cells')
ylabel('Observations');
title('Distribution in random data sets vs observed (red)')
legend(['Obs = ',num2str(100*scoretallbytall)],['Mean = ',num2str(m),', SD = ',num2str(s)])
%%%%%%%
figure;hist(100*rtsbyt,100)
hold on
plot(100*tsbyt,1,'*','color','r')
m=100*mean(rtsbyt);
s=100*std(rtsbyt);
xlabel('Percent if T Cores that are also in S cores')
ylabel('Observations');
title('Distribution in random data sets vs observed (red)')
legend(['Obs = ',num2str(100*tsbyt)],['Mean = ',num2str(m),', SD = ',num2str(s)])

figure;hist(100*rtsbys,100)
hold on
plot(100*tsbys,1,'*','color','r')
m=100*mean(rtsbys);
s=100*std(rtsbys);
xlabel('Percent if S Cores that are also in T cores')
ylabel('Observations');
title('Distribution in random data sets vs observed (red)')
legend(['Obs = ',num2str(100*tsbys)],['Mean = ',num2str(m),', SD = ',num2str(s)])