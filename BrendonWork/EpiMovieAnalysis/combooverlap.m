function [averages,realt,reals,realts]=combooverlap(sorted,goodperslice);
% function [avgt,useablet,avgs,useables]=combooverlap(sorted);
% function [avgt,avgs]=combooverlap(sorted,whichshuffledsorted);

warning off MATLAB:conversionToLogical
warning off MATLAB:divideByZero

% goodperslice=2;
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
% for a=1:size(sorted,2);%for each slice... we'll make numbers of movies the same for both spont and stim in each slice
%     m=min([sum(goodt(a,:)) sum(goods(a,:))]);%figure out whether less spont or less stim movies
%     t=find(goodt(a,:));
%     s=find(goods(a,:));
%     t=t(1:m);
%     s=s(1:m);
%     goodt(a,:)=zeros(1,size(goodt,2));
%     goodt(a,t)=1;
%     goods(a,:)=zeros(1,size(goods,2));
%     goods(a,s)=1;
% end
for a=1:size(sorted,2);%for each slice
    n=sum(goodt(a,:),2);
    if n>=goodperslice;%if there is more than one movie with more than 10 cells coming on from slice "a"
         g=find(goodt(a,:));
         for order=1:n;%for every good movie
            ind=nchoosek(1:n,order);
            average=[];
            for u=1:size(ind,1);%for every comparison
                availons=[];
                compare=ones(1,size(collt{a},2));%establish a matrix that will be continuously compared
                for v=1:size(ind,2);%for every index in that comparison, we'll do serial logical multiplications of collapsed movies
                    movienumber=g(ind(u,v));%take the number of the movie specified by finding which good movie it reprsents.
                    compare=collt{a}(movienumber,:).*compare;
                    compare=logical(compare);
                    availons(v)=sum(collt{a}(movienumber,:));
                end
                numer=sum(compare);%how many cells overlapped between these
                denom=min(availons);%find the max number of possible overlaps, based on finding the movie with the fewest cells on
                average(u)=numer/denom;
            end
            avgt(a,order)=mean(average);
            useablet(a,order)=1;
         end
    end
    n=sum(goods(a,:),2);
    if n>=goodperslice;%if there is more than one movie with more than 10 cells coming on from slice "a"
         g=find(goods(a,:));
         for order=1:n;%for every good movie
            ind=nchoosek(1:n,order);
            average=[];
            for u=1:size(ind,1);%for every comparison
                availons=[];
                compare=ones(1,size(colls{a},2));%establish a matrix that will be continuously compared
                for v=1:size(ind,2);%for every index in that comparison, we'll do serial logical multiplications of collapsed movies
                    movienumber=g(ind(u,v));%take the number of the movie specified by finding which good movie it reprsents.
                    compare=colls{a}(movienumber,:).*compare;
                    compare=logical(compare);
                    availons(v)=sum(colls{a}(movienumber,:));
                end
                numer=sum(compare);%how many cells overlapped between these
                denom=min(availons);%find the max number of possible overlaps, based on finding the movie with the fewest cells on
                average(u)=numer/denom;%find the percent of possible overlaps that are overlaps
            end
            avgs(a,order)=mean(average);%find and store the average percent overlap for comparisons of this number of movies for this slice
            useables(a,order)=1;    
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
                        comparet=collt{a}(movienumber,:).*comparet;
                        comparet=logical(comparet);
                        availonst(end+1)=sum(collt{a}(movienumber,:));
                        for x=1:size(whichspont,1);%for every combo of spont movies
                            availonss=[];
                            comparets=comparet;
                            for y=1:size(whichspont,2);%for every index of that combo
                                movienumber=gs(whichspont(x,y));%take the number of the movie specified by finding which good movie it reprsents.
                                comparets=colls{a}(movienumber,:).*comparets;
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
            avgts(a,order)=mean(average);%find and store the average percent overlap for comparisons of this number of movies for this slice
            useablets(a,order)=1;%store whether this order of combos was executed for this movie 
        end
    end
end


% for a=1:size(avgt,2);%for each order
%     comp=find(useablet(:,a));%find indices of slices where comparisons were done
%     realt(a)=mean(avgt(comp,a));%take the mean of those and store
% end
% for a=1:size(avgs,2);%for each order
%     comp=find(useables(:,a));%find indices of slices where comparisons were done
%     reals(a)=mean(avgs(comp,a));%take the mean of those and store
% end
% for a=1:size(avgts,2);%for each order
%     comp=find(useablets(:,a));%find indices of slices where comparisons were done
%     realts(a)=mean(avgts(comp,a));%take the mean of those and store
% end

minuseable=4;
realt=[];
for a=1:size(avgt,1);
    if length(find(avgt(a,:)))>=minuseable;
        realt(end+1,:)=avgt(a,:);
    end
end
reals=[];
for a=1:size(avgs,1);
    if length(find(avgs(a,:)))>=minuseable;
        reals(end+1,:)=avgs(a,:);
    end
end
realts=[];
for a=1:size(avgts,1);
    if length(find(avgts(a,:)))>=minuseable;
        realts(end+1,:)=avgts(a,:);
    end
end
realt=mean(realt,1);
reals=mean(reals,1);
realts=mean(realts,1);
realts(1)=1/0;

figure;
hold on
plot(realt,'g');
plot(reals)
plot(realts,'r')
% xlim([1 5])
% ylim([0 1])

averages.tt=avgt;
averages.ss=avgs;
averages.ts=avgts;

figure;%display all data from all slices, as lines connecting points for data in each slice
for a=1:size(averages.tt,1);
	hold on
	plot(find(averages.tt(a,:)),averages.tt(a,find(averages.tt(a,:))),'g')
end
ylim([0 1])

for a=1:size(averages.ss,1);
	hold on
	plot(find(averages.ss(a,:)),averages.ss(a,find(averages.ss(a,:))),'b')
end
ylim([0 1])

for a=1:size(averages.ts,1);
	hold on
	plot(find(averages.ts(a,:)),averages.ts(a,find(averages.ts(a,:))),'r')
end
ylim([0 1])

hold on
plot(realt,'g','LineWidth',3);
plot(reals,'b','LineWidth',3)
plot(realts,'r','LineWidth',3);

title('Green is tt, Blue is ss, Red is ts');
