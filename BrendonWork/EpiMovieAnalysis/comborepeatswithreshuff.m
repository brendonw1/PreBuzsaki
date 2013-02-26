% function [realt,reals,realts,avgs,avgt,avgts,useables,useablet,useablets]=comborepeatswithreshuff(sorted);
function [randomt,randoms,randomts,realt,reals,realts,avgs,avgt,avgts,useables,useablet,useablets]=comborepeatswithreshuff(sorted);
 
tic
numbloops=100;

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
    name=['reshuffcellisi',num2str(a)];
    eval(['load ',name]);
    for z=1:numbloops;
        n=sum(goodt(a,:),2);
        if n>1;%if there is more than one movie with more than 10 cells coming on from slice "a"
             g=find(goodt(a,:));
             mo=min([n 5]);%go up to number of good spont movies plus number of good stim movies, or 5, whichever is less.
             for order=1:mo;%for every good movie
                ind=nchoosek(1:n,order);
                average=[];
                useablet(z,a,order)=1;
                p=ind;%%%%making up for commenting out next two lines
	%             for w=1:size(ind,1);%for every comparison
	%                 p=perms(ind(w,:));%find all permutations of order
                    for u=1:size(p,1);
                        availons=[];
	%                     compare=ones(size(sorted{a}.tstrain(p(u,1)).ons));%establish a matrix that will be continuously compared
                        for v=1:size(p,2);%for every index in that comparison, we'll do serial logical multiplications of collapsed movies
                            movienumber=g(p(u,v));%take the number of the movie specified by finding which good movie it reprsents.                        
                            mv=['movi=',name,'(',num2str(movienumber),',z).tstrain;'];
                            eval(mv);
                            if v==1;
                                compare=movi;
                            else
                                [compare,trash]=findbestrepeats(compare,movi);%find best repeats between those two
                            end
                            availons(end+1)=sum(sum(sum(movi)));    
                        end
                        numer=sum(sum(sum(compare)));%how many cells overlapped between these
                        denom=min(availons);%find the max number of possible overlaps, based on finding the movie with the fewest cells on
                        average(end+1)=numer/denom;
                    end
	%             end
                avgt(z,a,order)=mean(average);
             end
        end
        n=sum(goods(a,:),2);
        if n>1;%if there is more than one movie with more than 10 cells coming on from slice "a"
             g=find(goods(a,:));
             mo=min([n 5]);%go up to number of good spont movies plus number of good stim movies, or 5, whichever is less.
             for order=1:mo;%for every good movie
                ind=nchoosek(1:n,order);
                average=[];
                useables(z,a,order)=1;    
                p=ind;
	%             for w=1:size(ind,1);%for every comparison
	%                 p=perms(ind(w,:));%find all permutations of order
                    for u=1:size(p,1);
                        availons=[];
	%                     compare=ones(size(sorted{a}.spont(p(u,1)).ons));%establish a matrix that will be continuously compared
                        for v=1:size(p,2);%for every index in that comparison, we'll do serial logical multiplications of collapsed movies
                            movienumber=g(p(u,v));%take the number of the movie specified by finding which good movie it reprsents.                        
                            mv=['movi=',name,'(',num2str(movienumber),',z).spont;'];
                            eval(mv);
                            if v==1;
                                compare=movi;
                            else
                                [compare,trash]=findbestrepeats(compare,movi);%find best repeats between those two
                            end
                            availons(end+1)=sum(sum(sum(movi)));
                        end
                        numer=sum(sum(sum(compare)));%how many cells overlapped between these
                        denom=min(availons);%find the max number of possible overlaps, based on finding the movie with the fewest cells on
                        average(end+1)=numer/denom;
                    end
	%             end
                avgs(z,a,order)=mean(average);
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
                useablets(z,a,order)=1;    
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
                                mv=['movi=',name,'(',num2str(movienumber),',z).tstrain;'];
                                eval(mv);
                                if v==1;
                                    comparet=movi;
                                else
                                    [comparet,trash]=findbestrepeats(compare,movi);%find best repeats between those two
                                end
                                availonst(end+1)=sum(sum(sum(movi)));
                                ps=whichspont;
	%                             for xx=1:size(whichspont,1);%for every combo of spont movies
	%                                 ps=perms(whichspont(xx,:));
                                    for x=1:size(ps,1);
                                        availonss=[];
                                        comparets=comparet;
                                        for y=1:size(ps,2);%for every index of that combo
                                            movienumber=gs(ps(x,y));%take the number of the movie specified by finding which good movie it reprsents.
                                            mv=['movi=',name,'(',num2str(movienumber),',z).spont;'];
                                            eval(mv);
                                            [comparets,trash]=findbestrepeats(comparets,movi);%find best repeats between those two
                                            availonss(end+1)=sum(sum(sum(movi)));
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
                avgts(z,a,order)=mean(average);%find and store the average percent overlap for comparisons of this number of movies for this slice
            end
        end
	end
    eval(['clear ',name]);
end

[realt,reals,realts]=comborepeats(sorted);

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

for y=1:numbloops;
    y
    fortau=[];
    for b=1:size(avgt,3);
        use=useablet(y,:,b);
        ft=avgt(y,:,b);
        x=find(use);
        fortau(b)=mean(ft(x));
    end
    fortau=fortau(find(fortau>0));
    if ~isempty(fortau);
        p=polyfit(1:length(fortau),log(fortau),1);
        taut(y)=1/p(1);
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
        taus(y)=1/p(1);
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
    fortau=fortau(find(fortau>0));
    if ~isempty(fortau);
        p=polyfit(1:length(fortau),log(fortau),1);
        tauts(y)=1/p(1);
    else
        tauts(y)=0;
    end
end
taus=sort(taus);
taut=sort(taut);
tauts=sort(tauts);

taureals=polyfit(1:length(reals),log(reals),1);
taureals=1/taureals(1);
taurealt=polyfit(1:length(realt),log(realt),1);
taurealt=1/taurealt(1);
taurealts=polyfit(2:length(realts),log(realts(2:end)),1);
taurealts=1/taurealts(1);

ptaus=length(find(taus<=taureals));
if ptaus==numbloops;
    ptaus=.001;
end
ptaut=length(find(taut<=taurealt));
if ptaut==numbloops;
    ptaut=.001;
end
ptauts=length(find(tauts<=taurealts));
if ptauts==numbloops;
    ptauts=.001;
end

figure;
hold on
plot(realt,'g');
plot(reals)
plot(realts,'r')
title('Triggered in Red.  Spont in Green');
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

toc