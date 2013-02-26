function [realt,reals,realts,averages]=comborepeats4(sorted,goodperslice)
tic
% goodperslice=2;
cellspermovie=5;
warning off MATLAB:conversionToLogical
warning off MATLAB:divideByZero
% names={['tstrain'] ['tssingle'] ['spont'] ['wdsingle'] ['wdtrain']};
% goodnames={['goodt'] ['goodtss'] ['goods'] ['goodwds'] ['goodwdt']};
% suffixes={['t'] ['tss'] ['s'] ['wds'] ['wdt']};
% goodw(size(sorted,2),1)=0;
% goodt(size(sorted,2),1)=0;
% goods(size(sorted,2),1)=0;
names={['tstrain'] ['spont']};
suffixes={['t'] ['s']};
for n=1:length(names);
    name=names{n};
    goodname=['good',suffixes{n}];
    suffix=suffixes{n};
	for y=1:size(sorted,2);%for each slice
        eval(['tf=~isempty(sorted{y}.',name,');'])
        if tf%j;%if there were tstrain movies for this slice, then...
            eval(['k=size(sorted{y}.',name,',2);'])
            for z=1:k
                eval(['tf=iscell(sorted{y}.',name,'(z).echo);'])
                if tf
                    eval(['cutoff=sorted{y}.',name,'(z).echo{1}(1);'])
                else
                    eval(['cutoff=size(sorted{y}.',name,'(z).ons,1);'])
                end
                eval(['nonechoons=sorted{y}.',name,'(z).ons(1:cutoff,:);'])
                coll=logical(sum(nonechoons,1));%collapse data from all frames into a single chunk of data
                if sum(coll,2)>=cellspermovie;%if total number of cells on in this movie is greater than cellspermovie:
                    eval([goodname,'(y,z)=1;'])%record that this movie was big enough... in this form for easy measuring of size
                end
            end
        end
    end
	for a=1:size(sorted,2);%for each slice
        a
        eval(['n=sum(',goodname,'(a,:),2);'])%find total number of good movies for this slice
        if n>=goodperslice;%if there is more than one movie with more than cellspermovie cells coming on from slice "a"
             eval(['g=find(',goodname,'(a,:));']);%generate a vector listing which movies are good
             mo=min([n 5]);%go up to number of good tstrain movies, or 5, whichever is less.
             for order=1:mo;%for every good movie
                ind=nchoosek(1:n,order);
                average=[];
                p=ind;%%%%making up for commenting out next two lines
	%             for w=1:size(ind,1);%for every comparison
	%                 p=perms(ind(w,:));%find all permutations of order
                    for u=1:size(p,1);
                        availons=[];
	%                     compare=ones(size(sorted{a}.tstrain(p(u,1)).ons)
	%                     ;%establish a matrix that will be continuously compared
                        for v=1:size(p,2);%for every index in that comparison, we'll do serial comparisons of movies
                            movienumber=g(p(u,v));%take the number of the movie specified by finding which good movie it repesents.                        
                            eval(['tf=iscell(sorted{a}.',name,'(movienumber).echo);'])
                            if tf
                                eval(['cutoff=sorted{a}.',name,'(movienumber).echo{1}(1);'])
                            else
                                eval(['cutoff=size(sorted{a}.',name,'(movienumber).ons,1);'])
                            end
                            eval(['nonechoons=sorted{a}.',name,'(movienumber).ons(1:cutoff,:);'])
                            if v==1;
                                compare=nonechoons;
                            else
                                [compare,trash]=findbestrepeats(compare,nonechoons);%find best repeats between those two
                            end
                            availons(end+1)=sum(logical(sum(nonechoons))); 
                        end
                        numer=sum(logical(sum(compare)));%how many cells overlapped between these
                        denom=min(availons);%find the max number of possible overlaps, based on finding the movie with the fewest cells on
                        average(end+1)=numer/denom;
                    end
	%             end
                eval(['avg',suffix,'(a,order)=mean(average);'])
                eval(['useable',suffix,'(a,order)=1;'])
             end
        end
    end
end
        
for a=1:size(sorted,2);%for each slice
    n=sum(goodt(a,:),2);%all good train movies
    m=sum(goods(a,:),2);%all good spont movies
    if n>=1 & m>=1;%if both spont and stim in this slice have at least one good movie
        gs=find(goods(a,:));
        gt=find(goodt(a,:));
        mo=min([n+m 5]);%go up to number of good spont movies plus number of good stim movies, or 5, whichever is less.
        for order=2:mo;%for combos of between 2 and 5 movies (must have one spont and one tstrain in each comparison)
            average=[];
            maxt=min([n order-1]);
            mint=max([1 order-m]);
            for numtrain=mint:maxt%how many spont movies
                numspont=order-numtrain;%how many train movies
                whichtrain=nchoosek(1:n,numtrain);%find all combos of (numtrain) trains within all the train movies (n)
                whichspont=nchoosek(1:m,numspont);%find all combos of (numspont) sponts within all the spont movies (m)
                pt=whichtrain;
%                 for w=1:size(whichtrain,1);%for every combo of train
%                 movies
%                     pt=perms(whichtrain(w,:));
                    for u=1:size(pt,1);%for each permutation in order
                        availonst=[];
%                         comparet=ones(size(sorted{a}.tstrain(pt(u,1)).ons));%establish a matrix that will be continuously compared
                        for v=1:size(pt,2);%for every index in that comparison, we'll do serial logical multiplications of collapsed movies
                            movienumber=gt(pt(u,v));%take the number of the movie specified by finding which good movie it reprsents.
                            if iscell(sorted{a}.tstrain(movienumber).echo);
                                cutoff=sorted{a}.tstrain(movienumber).echo{1}(1);
                            else
                                cutoff=size(sorted{a}.tstrain(movienumber).ons,1);
                            end
                            nonechoons=sorted{a}.tstrain(movienumber).ons(1:cutoff,:);
                            if v==1;
                                comparet=nonechoons;
                            else
                                [comparet,trash]=findbestrepeats(comparet,nonechoons);%find best repeats between those two
                            end
                            availonst(end+1)=sum(logical(sum(nonechoons))); 
                            ps=whichspont;
%                             for xx=1:size(whichspont,1);%for every combo
%                             of spont movies
%                                 ps=perms(whichspont(xx,:));
                                for x=1:size(ps,1);
                                    availonss=[];
                                    comparets=comparet;
                                    for y=1:size(ps,2);%for every index of that combo
                                        movienumber=gs(ps(x,y));%take the number of the movie specified by finding which good movie it reprsents.
                                        if iscell(sorted{a}.spont(movienumber).echo);
                                            cutoff=sorted{a}.spont(movienumber).echo{1}(1);
                                        else
                                            cutoff=size(sorted{a}.spont(movienumber).ons,1);
                                        end
                                        nonechoons=sorted{a}.spont(movienumber).ons(1:cutoff,:);
                                        [comparets,trash]=findbestrepeats(comparets,nonechoons);%find best repeats between those two
                                        availonss(end+1)=sum(logical(sum(nonechoons)));
                                    end
                                    numer=sum(logical(sum(comparets)));
                                    availons=cat(2,availonst,availonss);
                                    denom=min(availons);
                                    average(end+1)=numer/denom;
                                end
%                             end
                        end 
                    end
            end
%             end
            avgts(a,order)=mean(average);%find and store the average percent overlap for comparisons of this number of movies for this slice
            useablets(a,order)=1;%store whether this order of combos was executed for this movie 
        end
    end
end
for a=1:size(avgt,2);%for each order
    comp=find(useablet(:,a));%find indices of slices where comparisons were done
    realt(a)=mean(avgt(comp,a));%take the mean of those and store
    realsdt(a)=std(avgt(comp,a));
end
for a=1:size(avgs,2);%for each order
    comp=find(useables(:,a));%find indices of slices where comparisons were done
    reals(a)=mean(avgs(comp,a));%take the mean of those and store
    realsds(a)=std(avgs(comp,a));
end
for a=1:size(avgts,2);%for each order
    comp=find(useablets(:,a));%find indices of slices where comparisons were done
    realts(a)=mean(avgts(comp,a));%take the mean of those and store
    realsdts(a)=std(avgts(comp,a));
end
figure;
hold on
plot(realt,'g');
plot(reals)
plot(realts,'r');
ylim([0 1])
averages.tt=avgt;
averages.ss=avgs;
averages.ts=avgts;
figure;
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
% for a=1:size(t,2);comp=find(t(:,a));realt(a)=mean(t(comp,a));end
% % figure;
% hold on
% plot(mt,'r');
% plot(ms)
% title('Triggered in Red.  Spont in Blue');
% toc