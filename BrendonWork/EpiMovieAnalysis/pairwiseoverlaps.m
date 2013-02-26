function [sliceoverlaps]=pairwiseoverlaps(sorted,goodperslice);
% function [ttoverlaps,ssoverlaps,tsoverlaps,sliceoverlaps]=pairwiseoverlaps(sorted);
% function [ttoverlaps,ssoverlaps,wwoverlaps,tsoverlaps,twoverlaps,swoverlaps,sliceoverlaps]=pairwiseoverlaps(sorted);
% function [ttoverlaps,ssoverlaps,tsoverlaps,meanslicerepeat]=findallrepeats(sorted,reshuffsorted);

% goodperslice=2;
cellspermovie=5;

warning off MATLAB:conversionToLogical
warning off MATLAB:divideByZero
goodw(size(sorted,2),1)=0;
goodt(size(sorted,2),1)=0;
goods(size(sorted,2),1)=0;
for c=1:size(sorted,2);%for each slice
    if ~isempty(sorted{c}.tstrain)%j;%if there were tstrain movies for this slice, then...
        for d=1:size(sorted{c}.tstrain,2)
            collt{c}(d,:)=sum(sorted{c}.tstrain(d).ons,1);%collapse data from all frames into a single chunk of data
            collt{c}=logical(collt{c});%a cell that is on in a movie=1 (not more if it is on multiple times)
            if sum(collt{c}(d,:),2)>=cellspermovie;%if total number of cells on in this movie is greater than cellspermovie:
                goodt(c,d)=1;%record that this movie was big enough... in this form for easy measuring of size
            end
        end
    end
    if ~isempty(sorted{c}.spont)%j;%if there were tstrain movies for this slice, then...
        for d=1:size(sorted{c}.spont,2)
            colls{c}(d,:)=sum(sorted{c}.spont(d).ons,1);%collapse data from all frames into a single chunk of data
            colls{c}=logical(colls{c});%a cell that is on in a movie=1 (not more if it is on multiple times)
            if sum(colls{c}(d,:),2)>=cellspermovie;%if total number of cells on in this movie is greater than 5:
                goods(c,d)=1;%record that this movie was big enough... in this form for easy measuring of size
            end
        end
    end
%     if ~isempty(sorted{c}.tssingle)%j;%if there were tstrain movies for this slice, then...
%         for d=1:size(sorted{c}.tssingle,2)
%             collg{c}(d,:)=sum(sorted{c}.tssingle(d).ons(1:7,:),1);%collapse data from all frames into a single chunk of data
%             collg{c}=logical(collg{c});%a cell that is on in a movie=1 (not more if it is on multiple times)
%             if (sum(collg{c}(d,:),2)<cellspermovie) & (sum(collg{c}(d,:),2)>0);%if total number of cells on in this movie is greater than cellspermovie:
%                 goodg(c,d)=1;%record that this movie was big enough... in this form for easy measuring of size
%             end
%         end
%     end
    if ~isempty(sorted{c}.wdtrain)%j;%if there were tstrain movies for this slice, then...
        for d=1:size(sorted{c}.wdtrain,2)
            collw{c}(d,:)=sum(sorted{c}.wdtrain(d).ons,1);%collapse data from all frames into a single chunk of data
            collw{c}=logical(collw{c});%a cell that is on in a movie=1 (not more if it is on multiple times)
            if sum(collw{c}(d,:),2)>=cellspermovie;%if total number of cells on in this movie is greater than 5:
                goodw(c,d)=1;%record that this movie was big enough... in this form for easy measuring of size
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
    sliceoverlaps(a).tt=[];
    sliceoverlaps(a).ss=[];
    sliceoverlaps(a).ww=[];
    sliceoverlaps(a).ts=[];
    sliceoverlaps(a).tw=[];
    sliceoverlaps(a).sw=[];
    n=sum(goodt(a,:),2);
    if n>=goodperslice;%if there is more than one movie with more than cellspermovie cells coming on from slice "a"
        g=find(goodt(a,:));
        for b=1:length(g);%for each good movie 
            for c=b+1:length(g);%for each not yet compared movie
                ttoverlaps{a,g(b),g(c)}=collt{a}(g(b),:).*collt{a}(g(c),:);%find best repeats between those two
                denom=min([sum(collt{a}(g(b),:)) sum(collt{a}(g(c),:))]);
                sliceoverlaps(a).tt(end+1)=sum(ttoverlaps{a,g(b),g(c)})/denom;
            end
        end
    end
    n=sum(goods(a,:),2);
    if n>=goodperslice;%if there is more than one movie with more than cellspermovie cells coming on from slice "a"
        g=find(goods(a,:));
        for b=1:length(g);%for each good movie 
            for c=b+1:length(g);%for each not yet compared movie
                ssoverlaps{a,g(b),g(c)}=colls{a}(g(b),:).*colls{a}(g(c),:);%find best repeats between those two
                denom=min([sum(colls{a}(g(b),:)) sum(colls{a}(g(c),:))]);
                sliceoverlaps(a).ss(end+1)=sum(ssoverlaps{a,g(b),g(c)})/denom;
            end
        end
    end   
    n=sum(goodw(a,:),2);
    if n>=goodperslice;%if there is more than one movie with more than cellspermovie cells coming on from slice "a"
        g=find(goodw(a,:));
        for b=1:length(g);%for each good movie 
            for c=b+1:length(g);%for each not yet compared movie
                wwoverlaps{a,g(b),g(c)}=collw{a}(g(b),:).*collw{a}(g(c),:);%find best repeats between those two
                denom=min([sum(collw{a}(g(b),:)) sum(collw{a}(g(c),:))]);
                sliceoverlaps(a).ww(end+1)=sum(wwoverlaps{a,g(b),g(c)})/denom;
            end
        end
    end
    if sum(goods(a,:),2)>=1 & sum(goodt(a,:),2)>=1;%if both spont and stim in this slice have at least one good movie
        gs=find(goods(a,:));
        gt=find(goodt(a,:));
        for b=1:length(gt);
            for c=1:length(gs);
                tsoverlaps{a,gt(b),gs(c)}=collt{a}(gt(b),:).*colls{a}(gs(c),:);%find best repeats between those two
                denom=min([sum(collt{a}(gt(b),:)) sum(colls{a}(gs(c),:))]);
                sliceoverlaps(a).ts(end+1)=sum(tsoverlaps{a,gt(b),gs(c)})/denom;
            end
        end
    end
    if sum(goodt(a,:),2)>=1 & sum(goodw(a,:),2)>=1;%if both spont and stim in this slice have at least one good movie
        gt=find(goodt(a,:));
        gw=find(goodw(a,:));
        for b=1:length(gt);
            for c=1:length(gw);
                twoverlaps{a,gt(b),gw(c)}=collt{a}(gt(b),:).*collw{a}(gw(c),:);%find best repeats between those two
                denom=min([sum(collt{a}(gt(b),:)) sum(collw{a}(gw(c),:))]);
                sliceoverlaps(a).tw(end+1)=sum(twoverlaps{a,gt(b),gw(c)})/denom;
            end
        end
    end
    if sum(goods(a,:),2)>=1 & sum(goodw(a,:),2)>=1;%if both spont and stim in this slice have at least one good movie
        gs=find(goods(a,:));
        gw=find(goodw(a,:));
        for b=1:length(gs);
            for c=1:length(gw);
                swoverlaps{a,gs(b),gw(c)}=colls{a}(gs(b),:).*collw{a}(gw(c),:);%find best repeats between those two
                denom=min([sum(colls{a}(gs(b),:)) sum(collw{a}(gw(c),:))]);
                sliceoverlaps(a).sw(end+1)=sum(swoverlaps{a,gs(b),gw(c)})/denom;
            end
        end
    end
end