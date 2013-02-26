function [randomt,randoms,randomts,randomaverages,realt,reals,realts,averages,useables,useablet,useablets]=combooverlapwithreshuff(sorted,reshuffsorted,goodperslice);

% goodperslice=2;
numbloops=1000;

warning off MATLAB:conversionToLogical
warning off MATLAB:divideByZero

goodt=zeros(size(sorted,2),1);
goods=zeros(size(sorted,2),1);

for c=1:size(sorted,2);%for each slice
    if ~isempty(sorted{c}.tstrain)%j;%if there were tstrain movies for this slice, then...
        for d=1:size(sorted{c}.tstrain,2)
            collt{c}(d,:)=sum(sorted{c}.tstrain(d).ons,1);%collapse data from all frames into a single chunk of data
            collt{c}=logical(collt{c});%a cell that is on in a movie=1 (not more if it is on multiple times)
            if sum(collt{c}(d,:),2)>=10;%if total number of cells on in this movie is greater than 10:
                goodt(c,d)=1;%record that this movie was big enough... in this form for easy measuring of size
            end
        end
    end
    if ~isempty(sorted{c}.spont)%j;%if there were tstrain movies for this slice, then...
        for d=1:size(sorted{c}.spont,2)
            colls{c}(d,:)=sum(sorted{c}.spont(d).ons,1);%collapse data from all frames into a single chunk of data
            colls{c}=logical(colls{c});%a cell that is on in a movie=1 (not more if it is on multiple times)
            if sum(colls{c}(d,:),2)>=10;%if total number of cells on in this movie is greater than 5:
                goods(c,d)=1;%record that this movie was big enough... in this form for easy measuring of size
            end
        end
    end
end

for z=1:numbloops;
    z
	for a=1:size(sorted,2);%for each slice
        n=sum(goodt(a,:),2);
        if n>=goodperslice;%if there is more than one movie with more than 10 cells coming on from slice "a"
             g=find(goodt(a,:));
             for order=1:n;%for every good movie
                ind=nchoosek(1:n,order);
                average=[];
                useablet(z,a,order)=1;    
                for u=1:size(ind,1);%for every comparison
                    availons=[];
                    compare=ones(1,size(collt{a},2));%establish a matrix that will be continuously compared
                    for v=1:size(ind,2);%for every index in that comparison, we'll do serial logical multiplications of collapsed movies
                        movienumber=g(ind(u,v));%take the number of the movie specified by finding which good movie it reprsents.
                        movie=reshuffsorted{a}.tstrain(movienumber).ons(1,:,z);
%                         movie=reshufflewhichcells(collt{a}(movienumber,:));
                        compare=movie.*compare;
                        compare=logical(compare);
                        availons(v)=sum(movie);
                    end
                    numer=sum(compare);%how many cells overlapped between these
                    denom=min(availons);%find the max number of possible overlaps, based on finding the movie with the fewest cells on
                    average(u)=numer/denom;
                end
                avgt(z,a,order)=mean(average);
             end
        end
        n=sum(goods(a,:),2);
        if n>=goodperslice;%if there is more than one movie with more than 10 cells coming on from slice "a"
             g=find(goods(a,:));
             for order=1:n;%for every good movie
                ind=nchoosek(1:n,order);
                average=[];
                useables(z,a,order)=1;    
                for u=1:size(ind,1);%for every comparison
                    availons=[];
                    compare=ones(1,size(colls{a},2));%establish a matrix that will be continuously compared
                    for v=1:size(ind,2);%for every index in that comparison, we'll do serial logical multiplications of collapsed movies
                        movienumber=g(ind(u,v));%take the number of the movie specified by finding which good movie it reprsents.
                        movie=reshuffsorted{a}.spont(movienumber).ons(1,:,z);
%                         movie=reshufflewhichcells(colls{a}(movienumber,:));
                        compare=movie.*compare;
                        compare=logical(compare);
                        availons(v)=sum(movie);
                    end
                    numer=sum(compare);%how many cells overlapped between these
                    denom=min(availons);%find the max number of possible overlaps, based on finding the movie with the fewest cells on
                    average(u)=numer/denom;%find the percent of possible overlaps that are overlaps
                end
                avgs(z,a,order)=mean(average);%find and store the average percent overlap for comparisons of this number of movies for this slice
            end
        end
        n=sum(goodt(a,:),2);%all good train movies
        m=sum(goods(a,:),2);%all good spont movies
        if n>=1 & m>=1;%if both spont and stim in this slice have at least one good movie
            gs=find(goods(a,:));
            gt=find(goodt(a,:));
	%         mo=min([n+m 5]);%go up to number of good spont movies plus number of good stim movies, or 5, whichever is less.
            for order=2:n+m;%for combos of between 2 and 5 movies (must have one spont and one tstrain in each comparison)
                average=[];
                maxt=min([n order-1]);
                mint=max([1 order-m]);
                for numtrain=mint:maxt%how many spont movies
                    numspont=order-numtrain;%how many train movies
                    whichtrain=nchoosek(1:n,numtrain);%find all combos of (numtrain) trains within all the train movies (n)
                    whichspont=nchoosek(1:m,numspont);%find all combos of (numspont) sponts within all the spont movies (m)
                    for u=1:size(whichtrain,1);%for every combo of train movies
                        availonst=[];
                        comparet=ones(1,size(colls{a},2));%establish a matrix that will be continuously compared
                        for v=1:size(whichtrain,2);%for every index in that comparison, we'll do serial logical multiplications of collapsed movies
                            movienumber=gt(whichtrain(u,v));%take the number of the movie specified by finding which good movie it reprsents.
                            movie=reshuffsorted{a}.tstrain(movienumber).ons(1,:,z);
                            comparet=movie.*comparet;
                            comparet=logical(comparet);
                            availonst(end+1)=sum(collt{a}(movienumber,:));
                            for x=1:size(whichspont,1);%for every combo of spont movies
                                availonss=[];
                                comparets=comparet;
                                for y=1:size(whichspont,2);%for every index of that combo
                                    movienumber=gs(whichspont(x,y));%take the number of the movie specified by finding which good movie it reprsents.
                                    movie=reshuffsorted{a}.spont(movienumber).ons(1,:,z);
                                    comparets=movie.*comparets;
                                    comparest=logical(comparets);
                                    availonss(end+1)=sum(colls{a}(movienumber,:));
                                end
                                numer=sum(comparets);
                                availons=cat(2,availonst,availonss);
                                denom=min(availons);
                                average(end+1)=numer/denom;
                            end
                        end
                    end
                end
                avgts(z,a,order)=mean(average);%find and store the average percent overlap for comparisons of this number of movies for this slice
                useablets(z,a,order)=1;%store whether this order of combos was executed for this movie 
            end
        end
	end
end

randomaverages.ss=avgs;%for easier output
randomaverages.tt=avgt;
randomaverages.ts=avgts;

[averages,realt,reals,realts]=combooverlap(sorted,goodperslice);%get values from the real data

minuseable=4;%exclude in further analysis any slices with less than this many good comparisons
for a=1:size(useablet,2);
    if sum(useablet(1,a,:))<=minuseable;
        useablet(:,a,:)=0;
    end
end
for a=1:size(useables,2);
    if sum(useables(1,a,:))<=minuseable;
        useables(:,a,:)=0;
    end
end
for a=1:size(useablets,2);
    if sum(useablets(1,a,:))<=minuseable;
        useablets(:,a,:)=0;
    end
end


for a=1:size(avgt,3);%for every order
    use=useablet(:,:,a);
    x=avgt(:,:,a);
    f=find(use);
    distribt{a}=sort(x(f));
    pt(a)=length(find(distribt{a}>=realt(a)))/numbloops;
    randomt(a)=mean(x(f));
end
for a=1:size(avgs,3);%for every order
    use=useables(:,:,a);
    x=avgs(:,:,a);
    f=find(use);
    distribs{a}=sort(x(f));
    ps(a)=length(find(distribs{a}>=reals(a)))/numbloops;
    randoms(a)=mean(x(f));
end
for a=1:size(avgts,3);%for every order
    use=useablets(:,:,a);
    x=avgts(:,:,a);
    f=find(use);
    distribts{a}=sort(x(f));
    pts(a)=length(find(distribts{a}>=realts(a)))/numbloops;
    randomts(a)=mean(x(f));
end

for y=1:numbloops;%for each fake data
    disp(y)
    fortau=[];
    for b=1:size(avgt,3);%for comparison of each number of movies
        use=useablet(y,:,b);
        ft=avgt(y,:,b);
        x=find(use);
        fortau(b)=mean(ft(x));%save the comparison means for the entire population of one reshuffling of all slice data
    end
    fortau=fortau(find(fortau>0));
    if ~isempty(fortau);
        p=polyfit(1:length(fortau),log(fortau),1);
        taut(y)=p(1);
    else
        taut(y)=0;
    end
    fortau=[];
    for b=1:size(avgs,3);
        use=useables(y,:,b);
        ft=avgs(y,:,b);
        x=find(use);
        fortau(b)=mean(ft(x));
    end
    fortau=fortau(find(fortau>0));
    if ~isempty(fortau);
        p=polyfit(1:length(fortau),log(fortau),1);
        taus(y)=p(1);
    else
        taus(y)=0;
    end
    fortau=[];
    for b=1:size(avgts,3);
        use=useablets(y,:,b);
        ft=avgts(y,:,b);
        x=find(use);
        fortau(b)=mean(ft(x));
    end
%     fortau=fortau(2:end);%self-to self comparison makes no sense for ts
    fortau=fortau(find(fortau>0));
    if ~isempty(fortau);
        p=polyfit(2:length(fortau)+1,log(fortau),1);
        tauts(y)=p(1);
    else
        tauts(y)=0;
    end
end
taus=sort(taus);
taut=sort(taut);
tauts=sort(tauts);

taureals=polyfit(1:length(reals),log(reals),1);
taureals=taureals(1);
taurealt=polyfit(1:length(realt),log(realt),1);
taurealt=taurealt(1);
taurealts=polyfit(2:length(realts),log(realts(2:end)),1);
taurealts=taurealts(1);

ptaus=length(find(taus>=taureals))/numbloops;
if ptaus==0;
    ptaus=.001;
end
ptaut=length(find(taut>=taurealt))/numbloops;
if ptaut==0;
    ptaut=.001;
end
ptauts=length(find(tauts>=taurealts))/numbloops;
if ptauts==0;
    ptauts=.001;
end

figure;
hold on
plot(realt,'g');
plot(reals)
plot(realts,'r')
title('T in Green, S in Blue, TS in Red');
plot(randomt,':','color','g');
plot(randoms,':');
plot(randomts,':','color','r');

figure;
hist(taut);
hold on;
plot(taurealt,1,'*','color','r')
title(['Distribution of taus from reshuffled trig movies.  Triggered p value = ',num2str(ptaut)]);

figure;
hist(taus);
hold on;
plot(taureals,1,'*','color','r')
title(['Distribution of taus from reshuffled spont movies.  Spontaneous p value = ',num2str(ptaus)]);

figure;
hist(tauts);
hold on;
plot(taurealts,1,'*','color','r')
title(['Distribution of taus from reshuffled trig and spont movies.  Trig vs Spont p value = ',num2str(ptauts)]);


meanrandomaverages.tt=squeeze(mean(randomaverages.tt,1));
meanrandomaverages.ss=squeeze(mean(randomaverages.ss,1));
meanrandomaverages.ts=squeeze(mean(randomaverages.ts,1));
ratios.tt=averages.tt./meanrandomaverages.tt;
ratios.ss=averages.ss./meanrandomaverages.ss;
ratios.ts=averages.ts./meanrandomaverages.ts;

a=2;
ttrand=intersect(find(~isnan(meanrandomaverages.tt(:,a))),find(meanrandomaverages.tt(:,a)));
ttreal=intersect(find(~isnan(averages.tt(:,a))),find(averages.tt(:,a)));
ssrand=intersect(find(~isnan(meanrandomaverages.ss(:,a))),find(meanrandomaverages.ss(:,a)));
ssreal=intersect(find(~isnan(averages.ss(:,a))),find(averages.ss(:,a)));
tsrand=intersect(find(~isnan(meanrandomaverages.ts(:,a))),find(meanrandomaverages.ts(:,a)));
tsreal=intersect(find(~isnan(averages.ts(:,a))),find(averages.ts(:,a)));

figure;
hold on;
bar(1:8,[mean(meanrandomaverages.tt(ttrand,a)) mean(averages.tt(ttreal,a)) 0 mean(meanrandomaverages.ss(ssrand,a)) mean(averages.ss(ssreal,a)) 0 mean(meanrandomaverages.ts(tsrand,a)) mean(averages.ts(tsreal,a))])
errorbar([mean(meanrandomaverages.tt(ttrand,a)) mean(averages.tt(ttreal,a)) 0 mean(meanrandomaverages.ss(ssrand,a)) mean(averages.ss(ssreal,a)) 0 mean(meanrandomaverages.ts(tsrand,a)) mean(averages.ts(tsreal,a))],[std(meanrandomaverages.tt(ttrand,a)) std(averages.tt(ttreal,a)) 0 std(meanrandomaverages.ss(ssrand,a)) std(averages.ss(ssreal,a)) 0 std(meanrandomaverages.ts(tsrand,a)) std(averages.ts(tsreal,a))],'.')
 


for a=2:4;%for each of 5(arbitrary) comparisons
    notnan=~isnan(ratios.tt(:,a));
    statsratios.meantt(a)=mean(ratios.tt(notnan,a));
    statsratios.maxtt(a)=max(ratios.tt(notnan,a));
    statsratios.mintt(a)=min(ratios.tt(notnan,a));
    notnan=~isnan(ratios.ss(:,a));
    statsratios.meanss(a)=mean(ratios.ss(notnan,a));
    statsratios.maxss(a)=max(ratios.ss(notnan,a));
    statsratios.minss(a)=min(ratios.ss(notnan,a));
    notnan=~isnan(ratios.ts(:,a));
    statsratios.meants(a)=mean(ratios.ts(notnan,a));
    statsratios.maxts(a)=max(ratios.ts(notnan,a));
    statsratios.mints(a)=min(ratios.ts(notnan,a));
end

%plotting ratio of real vs reshuffled
figure;
hold on;
bar((4*(2:4)-3),log(statsratios.meantt(2:4)),.2,'g');
errorbar((4*(2:4)-3),log(statsratios.meantt(2:4)),log(statsratios.mintt(2:4)),log(statsratios.maxtt(2:4)),'.')
bar((4*(2:4)-2),log(statsratios.meanss(2:4)),.2,'b');
errorbar((4*(2:4)-2),log(statsratios.meanss(2:4)),log(statsratios.minss(2:4)),log(statsratios.maxss(2:4)),'.')
bar((4*(2:4)-1),log(statsratios.meants(2:4)),.2,'r');
errorbar((4*(2:4)-1),log(statsratios.meants(2:4)),log(statsratios.mints(2:4)),log(statsratios.maxts(2:4)),'.')
xlabel('nothing')
ylabel('log of ratio between real data and reshuffled data for each slice')
title('Green is tt, Blue is ss, Red is ts.  Error bars represent RANGE');
