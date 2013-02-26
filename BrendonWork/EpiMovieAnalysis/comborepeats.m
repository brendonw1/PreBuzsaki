function [realt,reals,realts]=comborepeats(sorted,goodperslice);

tic
% goodperslice=2;
warning off MATLAB:conversionToLogical
warning off MATLAB:divideByZero

for y=1:size(sorted,2);%for each slice
    if ~isempty(sorted{y}.tstrain)%j;%if there were tstrain movies for this slice, then...
        for z=1:size(sorted{y}.tstrain,2)
            coll=logical(sum(sorted{y}.tstrain(z).ons,1));%collapse data from all frames into a single chunk of data
            if sum(coll,2)>=10;%if total number of cells on in this movie is greater than 10:
                goodt(y,z)=1;%record that this movie was big enough... in this form for easy measuring of size
            end
        end
    end
    if ~isempty(sorted{y}.spont)%j;%if there were tstrain movies for this slice, then...
        for z=1:size(sorted{y}.spont,2)
            coll=logical(sum(sorted{y}.spont(z).ons,1));%collapse data from all frames into a single chunk of data
            if sum(coll,2)>=10;%if total number of cells on in this movie is greater than 10:
                goods(y,z)=1;%record that this movie was big enough... in this form for easy measuring of size
            end
        end
    end
end

for a=1:size(sorted,2);%for each slice
    a
    n=sum(goodt(a,:),2);
    if n>=goodperslice;%if there is more than one movie with more than 10 cells coming on from slice "a"
         g=find(goodt(a,:));
         mo=min([n 5]);%go up to number of good spont movies plus number of good stim movies, or 5, whichever is less.
         for order=1:mo;%for every good movie
            ind=nchoosek(1:n,order);
            average=[];
            p=ind;%%%%making up for commenting out next two lines
%             for w=1:size(ind,1);%for every comparison
%                 p=perms(ind(w,:));%find all permutations of order
                for u=1:size(p,1);
                    availons=[];
%                     compare=ones(size(sorted{a}.tstrain(p(u,1)).ons));%establish a matrix that will be continuously compared
                    for v=1:size(p,2);%for every index in that comparison, we'll do serial logical multiplications of collapsed movies
                        movienumber=g(p(u,v));%take the number of the movie specified by finding which good movie it reprsents.                        
                        if v==1;
                            compare=sorted{a}.tstrain(movienumber).ons;
                        else
                            [compare,trash]=findbestrepeats(compare,sorted{a}.tstrain(movienumber).ons);%find best repeats between those two
                        end
                        availons(end+1)=sum(sum(sum(sorted{a}.tstrain(movienumber).ons)));    
                    end
                    numer=sum(sum(sum(compare)));%how many cells overlapped between these
                    denom=min(availons);%find the max number of possible overlaps, based on finding the movie with the fewest cells on
                    average(end+1)=numer/denom;
                end
%             end
            avgt(a,order)=mean(average);
            useablet(a,order)=1;
         end
    end
    n=sum(goods(a,:),2);
    if n>=goodperslice;%if there is more than one movie with more than 10 cells coming on from slice "a"
         g=find(goods(a,:));
         mo=min([n 5]);%go up to number of good spont movies plus number of good stim movies, or 5, whichever is less.
         for order=1:mo;%for every good movie
            ind=nchoosek(1:n,order);
            average=[];
            p=ind;
%             for w=1:size(ind,1);%for every comparison
%                 p=perms(ind(w,:));%find all permutations of order
                for u=1:size(p,1);
                    availons=[];
%                     compare=ones(size(sorted{a}.spont(p(u,1)).ons));%establish a matrix that will be continuously compared
                    for v=1:size(p,2);%for every index in that comparison, we'll do serial logical multiplications of collapsed movies
                        movienumber=g(p(u,v));%take the number of the movie specified by finding which good movie it reprsents.                        
                        if v==1;
                            compare=sorted{a}.spont(movienumber).ons;
                        else
                            [compare,trash]=findbestrepeats(compare,sorted{a}.spont(movienumber).ons);%find best repeats between those two
                        end
                        availons(end+1)=sum(sum(sum(sorted{a}.spont(movienumber).ons)));
                    end
                    numer=sum(sum(sum(compare)));%how many cells overlapped between these
                    denom=min(availons);%find the max number of possible overlaps, based on finding the movie with the fewest cells on
                    average(end+1)=numer/denom;
                end
%             end
            avgs(a,order)=mean(average);
            useables(a,order)=1;
         end
    end
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
%                 for w=1:size(whichtrain,1);%for every combo of train movies
%                     pt=perms(whichtrain(w,:));
                    for u=1:size(pt,1);%for each permutation in order
                        availonst=[];
%                         comparet=ones(size(sorted{a}.tstrain(pt(u,1)).ons));%establish a matrix that will be continuously compared
                        for v=1:size(pt,2);%for every index in that comparison, we'll do serial logical multiplications of collapsed movies
                            movienumber=gt(pt(u,v));%take the number of the movie specified by finding which good movie it reprsents.
                            if v==1;
                                comparet=sorted{a}.tstrain(movienumber).ons;
                            else
                                [comparet,trash]=findbestrepeats(compare,sorted{a}.tstrain(movienumber).ons);%find best repeats between those two
                            end
                            availonst(end+1)=sum(sum(sum(sorted{a}.tstrain(movienumber).ons)));
                            ps=whichspont;
%                             for xx=1:size(whichspont,1);%for every combo of spont movies
%                                 ps=perms(whichspont(xx,:));
                                for x=1:size(ps,1);
                                    availonss=[];
                                    comparets=comparet;
                                    for y=1:size(ps,2);%for every index of that combo
                                        movienumber=gs(ps(x,y));%take the number of the movie specified by finding which good movie it reprsents.
                                        [comparets,trash]=findbestrepeats(comparets,sorted{a}.spont(movienumber).ons);%find best repeats between those two
                                        availonss(end+1)=sum(sum(sum(sorted{a}.spont(movienumber).ons)));
                                    end
                                    numer=sum(sum(sum(comparets)));
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
end
for a=1:size(avgs,2);%for each order
    comp=find(useables(:,a));%find indices of slices where comparisons were done
    reals(a)=mean(avgs(comp,a));%take the mean of those and store
end
for a=1:size(avgts,2);%for each order
    comp=find(useablets(:,a));%find indices of slices where comparisons were done
    realts(a)=mean(avgts(comp,a));%take the mean of those and store
end

figure;
hold on
plot(realt,'g');
plot(reals)
plot(realts,'r');


% for a=1:size(t,2);comp=find(t(:,a));realt(a)=mean(t(comp,a));end
% % figure;
% hold on
% plot(mt,'r');
% plot(ms)
% title('Triggered in Red.  Spont in Blue');
% toc