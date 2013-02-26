function [ttotals,stotals,tstrainpercents,spontpercents,tshufftotals,sshufftotals]=reshuffoverlapbyhisto(sorted,flatshuffsorted);

warning off MATLAB:conversionToLogical
warning off MATLAB:divideByZero

goodtstrain(size(sorted,2),1)=0;
goodspont(size(sorted,2),1)=0;
for c=1:size(sorted,2);%for each slice
    if ~isempty(sorted{c}.tstrain)%j;%if there were tstrain movies for this slice, then...
%         slicecolltstrain{c}=zeros(1,length(sorted{c}.contours));%establish matrix
        for d=1:size(sorted{c}.tstrain,2)%for each movie
            colltstrain{c}(d,:)=sum(sorted{c}.tstrain(d).ons,1);%collapse data from all frames into a single chunk of data
            colltstrain{c}=logical(colltstrain{c});%a cell that is on in a movie=1 (not more if it is on multiple times)
%             slicecolltstrain{c}=colltstrain{c}(d,:)+slicecolltstrain{c};%collapse all cells on from the tstrain movies for a slice
            if sum(colltstrain{c}(d,:),2)>=10;%if total number of cells on in this movie is greater than 10:
                goodtstrain(c,d)=1;%record that this movie was big enough... in this form for easy measuring of size
            end
        end
    end
    if ~isempty(sorted{c}.spont)%j;%if there were tstrain movies for this slice, then...
%         slicecollspont{c}=zeros(1,length(sorted{c}.contours));
        for d=1:size(sorted{c}.spont,2);
            collspont{c}(d,:)=sum(sorted{c}.spont(d).ons,1);%collapse data from all frames into a single chunk of data
            collspont{c}=logical(collspont{c});%a cell that is on in a movie=1 (not more if it is on multiple times)
%             slicecollspont{c}=collspont{c}(d,:)+slicecollspont{c};%collapse all cells on from the tstrain movies for a slice
            if sum(collspont{c}(d,:),2)>=10;%if total number of cells on in this movie is greater than 5:
                goodspont(c,d)=1;%record that this movie was big enough... in this form for easy measuring of size
            end
        end
    end
end
for a=1:size(sorted,2);%for each slice... we'll make numbers of movies the same for both spont and stim in each slice
    m=min([sum(goodtstrain(a,:)) sum(goodspont(a,:))]);%figure out whether less spont or less stim movies
    t=find(goodtstrain(a,:));
    s=find(goodspont(a,:));
    t=t(1:m);
    s=s(1:m);
    goodtstrain(a,:)=zeros(1,size(goodtstrain,2));
    goodtstrain(a,t)=1;
    goodspont(a,:)=zeros(1,size(goodspont,2));
    goodspont(a,s)=1;
end


tmovies=0;
tslices=0;
smovies=0;
sslices=0;
tmovieons=[];
smovieons=[];
for a=1:size(sorted,2);%for each slice
    if sum(goodtstrain(a,:),2)>1;%if there is more than one movie with more than 10 cells coming on from slice "a"
        tslices=tslices+1;
        tmovon=[];
        tmeanmovon=[];
        sumcolltstrain{a}=zeros(1,length(sorted{a}.contours));
        goodthisslice=find(goodtstrain(a,:));%gives dim2 coords of good movies
        for b=1:size(goodthisslice,2)%for each good tstrain movie
            sumcolltstrain{a}=sumcolltstrain{a}+colltstrain{a}(goodthisslice(b),:);%for each cell, how many movies is it on in? 
            tmovon(b)=sum(colltstrain{a}(goodthisslice(b),:));
            tmovieons(end+1)=sum(colltstrain{a}(goodthisslice(b),:));
            tpercmovon(b)=sum(colltstrain{a}(goodthisslice(b),:))./size(colltstrain{a}(goodthisslice(b),:),2);
            tmovies=tmovies+1;
        end
        sumcolltstrain{a}=sumcolltstrain{a}/size(goodthisslice,2);%for each cell, what percent of movies is it on
        activetn(a)=sum(logical(sumcolltstrain{a}));
        activetd(a)=size(sumcolltstrain{a},2);
        tmeanon(a)=mean(tmovon);
        tmeanpercon(a)=mean(tpercmovon);
        tsdon(a)=std(tmovon);
        tsdpercon(a)=std(tpercmovon);
        tcvon(a)=tsdon(a)/tmeanon(a);
        tcvpercon(a)=tsdpercon(a)/tmeanpercon(a);
        
    end
    if sum(goodspont(a,:),2)>1;%if there is more than one movie with more than 10 cells coming on from slice "a"
        sslices=sslices+1;
        smovon=[];
        smeanmovon=[];
        sumcollspont{a}=zeros(1,length(sorted{a}.contours));
        goodthisslice=find(goodspont(a,:));%gives dim2 coords of good movies
        for b=1:size(goodthisslice,2)%for each good spont movie
            sumcollspont{a}=sumcollspont{a}+collspont{a}(goodthisslice(b),:);%for each cell, how many movies is it on in?
            smovon(b)=sum(collspont{a}(goodthisslice(b),:));
            smovieons(end+1)=sum(collspont{a}(goodthisslice(b),:));
            spercmovon(b)=sum(collspont{a}(goodthisslice(b),:))./size(collspont{a}(goodthisslice(b),:),2);
            smovies=smovies+1;
        end
        sumcollspont{a}=sumcollspont{a}/size(goodthisslice,2);%for each cell, what percent of movies is it on
        activesn(a)=sum(logical(sumcollspont{a}));
        activesd(a)=size(sumcollspont{a},2);
        smeanon(a)=mean(smovon);
        smeanpercon(a)=mean(spercmovon);
        ssdon(a)=std(smovon);
        ssdpercon(a)=std(spercmovon);       
        scvon(a)=ssdon(a)/smeanon(a);
        scvpercon(a)=ssdpercon(a)/smeanpercon(a);
    end 
end
for z=1:1000;
    z
	for a=1:size(sorted,2);%for each slice
        if sum(goodtstrain(a,:),2)>1;%if there is more than one movie with more than 10 cells coming on from slice "a"
            sct=zeros(1,length(sorted{a}.contours));
            goodthisslice=find(goodtstrain(a,:));%gives dim2 coords of good movies
            for b=1:size(goodthisslice,2)%for each good tstrain movie
                sct=sct+flatshuffsorted{a}.tstrain(goodthisslice(b)).ons(1,:,z);%for each cell, how many movies is it on in?
            end
            sct=sct/size(goodthisslice,2);%for each cell, what percent of movies is it on
            tstrainpercents{a}(:,z)=sct;
        end
        if sum(goodspont(a,:),2)>1;%if there is more than one movie with more than 10 cells coming on from slice "a"
            scs=zeros(1,length(sorted{a}.contours));
            goodthisslice=find(goodspont(a,:));%gives dim2 coords of good movies
            for b=1:size(goodthisslice,2)%for each good spont movie
                scs=scs+flatshuffsorted{a}.spont(goodthisslice(b)).ons(1,:,z);%for each cell, how many movies is it on in?
            end
            scs=scs/size(goodthisslice,2);%for each cell, what percent of movies is it on
            spontpercents{a}(:,z)=scs;
        end
	end
end
tshufftotals=[];
for a=1:size(sorted,2);
    tshufftotals=cat(2,tshufftotals,tstrainpercents{a}(1:end));
end
figure;
percenthist(tshufftotals,100);
title('Overall Trig Distribution from Reshuffled Collapsed Movies');
hold on
tshufftotals=sort(tshufftotals);
plot([tshufftotals(.95*length(tshufftotals)+1) tshufftotals(.95*length(tshufftotals)+1)],[0 1],'r');

sshufftotals=[];
for a=1:size(sorted,2);
    sshufftotals=cat(2,sshufftotals,spontpercents{a}(1:end));
end
figure;
percenthist(sshufftotals,100);
title('Overall Spont Distribution from Reshuffled Collapsed Movies');
hold on
sshufftotals=sort(sshufftotals);
plot([sshufftotals(.95*length(sshufftotals)+1) sshufftotals(.95*length(sshufftotals)+1)],[0 1],'r');

ttotals=[];
for r=1:size(sumcolltstrain,2);
    ttotals=cat(2,ttotals,sumcolltstrain{r});
end
stotals=[];
for r=1:size(sumcollspont,2);
    stotals=cat(2,stotals,sumcollspont{r});
end
figure;
percenthist(ttotals,100);
title('Hist of triggered cells by percent active');
figure;
percenthist(stotals,100);
title('Hist of spontaneous cells by percent active');


% t=[];%setting up for a 2D histo... relating how repeatable each cell is in ts to how repeatable it is in spont
% s=[];
% for r=1:size(sorted,2);
%     if ~isempty(sumcolltstrain{r} & ~isempty(sumcollspont{r}));
%         t=cat(2,t,sumcolltstrain{r});
%         s=cat(2,s,sumcollspont{r});
%     end;
% end
% binnumber=10;
% for q=1:binnumber;
%     qbinmin=1-(q/binnumber);
%     qbinmax=1-(q/binnumber)+1/binnumber;
%     qt1=find(t>qbinmin);
%     qt2=find(t<=qbinmax);
%     qt=intersect(qt1,qt2);
%     for r=1:binnumber;
%         rbinmin=1-(r/binnumber);
%         rbinmax=1-(r/binnumber)+1/binnumber;
%         rs1=find(s>rbinmin);
%         rs2=find(s<=rbinmax);
%         rs=intersect(rs1,rs2);
%         bins(binnumber-(q-1),binnumber-(r-1))=length(intersect(qt,rs));
%     end
% end
% bar3(bins);