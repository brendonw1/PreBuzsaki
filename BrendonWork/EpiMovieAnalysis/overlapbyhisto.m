function [ttotals,stotals,t,s]=overlapbyhisto(sorted);

warning off MATLAB:conversionToLogical
warning off MATLAB:divideByZero

for c=1:size(sorted,2);%for each slice
    if ~isempty(sorted{c}.tstrain)%j;%if there were tstrain movies for this slice, then...
        slicecolltstrain{c}=zeros(1,length(sorted{c}.contours));%establish matrix
        for d=1:size(sorted{c}.tstrain,2)
            colltstrain{c}(d,:)=sum(sorted{c}.tstrain(d).ons,1);%collapse data from all frames into a single chunk of data
            colltstrain{c}=logical(colltstrain{c});%a cell that is on in a movie=1 (not more if it is on multiple times)
%             slicecolltstrain{c}=colltstrain{c}(d,:)+slicecolltstrain{c};%collapse all cells on from the tstrain movies for a slice
            if sum(colltstrain{c}(d,:),2)>10;%if total number of cells on in this movie is greater than 10:
                goodtstrain(c,d)=1;%record that this movie was big enough... in this form for easy measuring of size
            end
        end
    end
    if ~isempty(sorted{c}.spont)%j;%if there were tstrain movies for this slice, then...
        slicecollspont{c}=zeros(1,length(sorted{c}.contours));
        for d=1:size(sorted{c}.spont,2)
            collspont{c}(d,:)=sum(sorted{c}.spont(d).ons,1);%collapse data from all frames into a single chunk of data
            collspont{c}=logical(collspont{c});%a cell that is on in a movie=1 (not more if it is on multiple times)
%             slicecollspont{c}=collspont{c}(d,:)+slicecollspont{c};%collapse all cells on from the tstrain movies for a slice
            if sum(collspont{c}(d,:),2)>5;%if total number of cells on in this movie is greater than 5:
                goodspont(c,d)=1;%record that this movie was big enough... in this form for easy measuring of size
            end
        end
    end
end
for a=1:size(sorted,2);%for each slice
    if sum(goodtstrain(a,:),2)>1;%if there is more than one movie with more than 10 cells coming on from slice "a"
        sumcolltstrain{a}=zeros(1,length(sorted{a}.contours));
        goodthisslice=find(goodtstrain(a,:));%gives dim2 coords of good movies
        for b=1:size(goodthisslice,2)%for each good tstrain movie
            sumcolltstrain{a}=sumcolltstrain{a}+colltstrain{a}(goodthisslice(b),:);%for each cell, how many movies is it on in?
        end
        sumcolltstrain{a}=sumcolltstrain{a}/size(goodthisslice,2);%for each cell, what percent of movies is it on
    end
    if sum(goodspont(a,:),2)>1;%if there is more than one movie with more than 10 cells coming on from slice "a"
        sumcollspont{a}=zeros(1,length(sorted{a}.contours));
        goodthisslice=find(goodspont(a,:));%gives dim2 coords of good movies
        for b=1:size(goodthisslice,2)%for each good spont movie
            sumcollspont{a}=sumcollspont{a}+collspont{a}(goodthisslice(b),:);%for each cell, how many movies is it on in?
        end
        sumcollspont{a}=sumcollspont{a}/size(goodthisslice,2);%for each cell, what percent of movies is it on
    end 
end

ttotals=[];for r=1:size(sumcolltstrain,2);ttotals=cat(2,ttotals,sumcolltstrain{r});end
stotals=[];for r=1:size(sumcollspont,2);stotals=cat(2,stotals,sumcollspont{r});end
figure;hist(ttotals);
title('Hist of triggered cells by percent active');
figure;hist(stotals);
title('Hist of spontaneous cells by percent active');

t=[];
s=[];
for r=1:size(sorted,2);
    if ~isempty(sumcolltstrain{r} & ~isempty(sumcollspont{r}));
        t=cat(2,t,sumcolltstrain{r});
        s=cat(2,s,sumcollspont{r});
    end;
end
figure;
hist2(t,s,10);
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
% figure;
% bar3(bins);