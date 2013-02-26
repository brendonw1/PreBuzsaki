function [tstrainvariance,spontvariance]=variancevsmax(sorted);

%do variability from max to max, maxm1 to maxm1, etc...
%else?
%ttest to look for different pops?
%variability using spont #'s and vice versa

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
tusemax=zeros(size(sorted,2),1);
tusemaxm3=zeros(size(sorted,2),1);
tusemaxm2=zeros(size(sorted,2),1);
tusemaxm1=zeros(size(sorted,2),1);
tusemaxp1=zeros(size(sorted,2),1);
tusemaxp2=zeros(size(sorted,2),1);
tusemaxp3=zeros(size(sorted,2),1);

susemax=zeros(size(sorted,2),1);
susemaxm3=zeros(size(sorted,2),1);
susemaxm2=zeros(size(sorted,2),1);
susemaxm1=zeros(size(sorted,2),1);
susemaxp1=zeros(size(sorted,2),1);
susemaxp2=zeros(size(sorted,2),1);
susemaxp3=zeros(size(sorted,2),1);

for a=1:size(sorted,2);%for each slice
    if sum(goodtstrain(a,:),2)>1;%if there is more than one movie with more than 10 cells coming on from slice "a"
        tstrainchanceon{a}=zeros(1,length(sorted{a}.contours));
        goodthisslice=find(goodtstrain(a,:));%gives dim2 coords of good movies
        for b=1:size(goodthisslice,2)%for each good tstrain movie
            tstrainchanceon{a}=tstrainchanceon{a}+colltstrain{a}(goodthisslice(b),:);%for each cell, how many movies is it on in?
        end
        tstrainchanceon{a}=tstrainchanceon{a}/size(goodthisslice,2);%for each cell, what percent of movies is it on
        tstrainchanceoff{a}=1-tstrainchanceon{a};
        for j=1:length(goodthisslice);%for every good movie
            [trash,maxfr]=max(sum(sorted{a}.tstrain(goodthisslice(j)).ons,2));
            if maxfr>3;
                maxm3=maxfr-3;
                maxm3=logical(sorted{a}.tstrain(goodthisslice(j)).ons(maxm3,:));
                tstrainmaxm3(a,goodthisslice(j))=mean(cat(2,tstrainchanceoff{a}(maxm3),tstrainchanceon{a}(~maxm3)));
                tusemaxm3(a,goodthisslice(j))=1;
            end
            if maxfr>2;
                maxm2=maxfr-2;
                maxm2=logical(sorted{a}.tstrain(goodthisslice(j)).ons(maxm2,:));
                tstrainmaxm2(a,goodthisslice(j))=mean(cat(2,tstrainchanceoff{a}(maxm2),tstrainchanceon{a}(~maxm2)));
                tusemaxm2(a,goodthisslice(j))=1;
            end
            if maxfr>1;
                maxm1=maxfr-1;
                maxm1=logical(sorted{a}.tstrain(goodthisslice(j)).ons(maxm1,:));
                tstrainmaxm1(a,goodthisslice(j))=mean(cat(2,tstrainchanceoff{a}(maxm1),tstrainchanceon{a}(~maxm1)));
                tusemaxm1(a,goodthisslice(j))=1;
            end
            if maxfr<size(sorted{a}.tstrain(goodthisslice(j)).ons,1)-0;
                maxp1=maxfr+1;
                maxp1=logical(sorted{a}.tstrain(goodthisslice(j)).ons(maxp1,:));
                tstrainmaxp1(a,goodthisslice(j))=mean(cat(2,tstrainchanceoff{a}(maxp1),tstrainchanceon{a}(~maxp1)));
                tusemaxp1(a,goodthisslice(j))=1;
            end
            if maxfr<size(sorted{a}.tstrain(goodthisslice(j)).ons,1)-1;
                maxp2=maxfr+2;
                maxp2=logical(sorted{a}.tstrain(goodthisslice(j)).ons(maxp2,:));
                tstrainmaxp2(a,goodthisslice(j))=mean(cat(2,tstrainchanceoff{a}(maxp2),tstrainchanceon{a}(~maxp2)));
                tusemaxp2(a,goodthisslice(j))=1;
            end
            if maxfr<size(sorted{a}.tstrain(goodthisslice(j)).ons,1)-2;
                maxp3=maxfr+3;
                maxp3=logical(sorted{a}.tstrain(goodthisslice(j)).ons(maxp3,:));
                tstrainmaxp3(a,goodthisslice(j))=mean(cat(2,tstrainchanceoff{a}(maxp3),tstrainchanceon{a}(~maxp3)));
                tusemaxp3(a,goodthisslice(j))=1;
            end            
            maxfr=logical(sorted{a}.tstrain(goodthisslice(j)).ons(maxfr,:));
            tstrainmax(a,goodthisslice(j))=mean(cat(2,tstrainchanceoff{a}(maxfr),tstrainchanceon{a}(~maxfr)));
            tusemax(a,goodthisslice(j))=1;
        end 
    end
    if sum(goodspont(a,:),2)>1;%if there is more than one movie with more than 10 cells coming on from slice "a"
        spontchanceon{a}=zeros(1,length(sorted{a}.contours));
        goodthisslice=find(goodspont(a,:));%gives dim2 coords of good movies
        for b=1:size(goodthisslice,2)%for each good spont movie
            spontchanceon{a}=spontchanceon{a}+collspont{a}(goodthisslice(b),:);%for each cell, how many movies is it on in?
        end
        spontchanceon{a}=spontchanceon{a}/size(goodthisslice,2);%for each cell, what percent of movies is it on
        spontchanceoff{a}=1-spontchanceon{a};
        for j=1:length(goodthisslice);%for every good movie
            [trash,maxfr]=max(sum(sorted{a}.spont(goodthisslice(j)).ons,2));
            if maxfr>3;
                maxm3=maxfr-3;
                maxm3=logical(sorted{a}.spont(goodthisslice(j)).ons(maxm3,:));
                spontmaxm3(a,goodthisslice(j))=mean(cat(2,spontchanceoff{a}(maxm3),spontchanceon{a}(~maxm3)));
                susemaxm3(a,goodthisslice(j))=1;
            end
            if maxfr>2;
                maxm2=maxfr-2;
                maxm2=logical(sorted{a}.spont(goodthisslice(j)).ons(maxm2,:));
                spontmaxm2(a,goodthisslice(j))=mean(cat(2,spontchanceoff{a}(maxm2),spontchanceon{a}(~maxm2)));
                susemaxm2(a,goodthisslice(j))=1;                
            end
            if maxfr>1;
                maxm1=maxfr-1;
                maxm1=logical(sorted{a}.spont(goodthisslice(j)).ons(maxm1,:));
                spontmaxm1(a,goodthisslice(j))=mean(cat(2,spontchanceoff{a}(maxm1),spontchanceon{a}(~maxm1)));
                susemaxm1(a,goodthisslice(j))=1;                
            end
            if maxfr<size(sorted{a}.spont(goodthisslice(j)).ons,1)-0;
                maxp1=maxfr+1;
                maxp1=logical(sorted{a}.spont(goodthisslice(j)).ons(maxp1,:));
                spontmaxp1(a,goodthisslice(j))=mean(cat(2,spontchanceoff{a}(maxp1),spontchanceon{a}(~maxp1)));
                susemaxp1(a,goodthisslice(j))=1;                
            end
            if maxfr<size(sorted{a}.spont(goodthisslice(j)).ons,1)-1;
                maxp2=maxfr+2;
                maxp2=logical(sorted{a}.spont(goodthisslice(j)).ons(maxp2,:));
                spontmaxp2(a,goodthisslice(j))=mean(cat(2,spontchanceoff{a}(maxp2),spontchanceon{a}(~maxp2)));
                susemaxp2(a,goodthisslice(j))=1;                
            end
            if maxfr<size(sorted{a}.spont(goodthisslice(j)).ons,1)-2;
                maxp3=maxfr+3;
                maxp3=logical(sorted{a}.spont(goodthisslice(j)).ons(maxp3,:));
                spontmaxp3(a,goodthisslice(j))=mean(cat(2,spontchanceoff{a}(maxp3),spontchanceon{a}(~maxp3)));
                susemaxp3(a,goodthisslice(j))=1;                
            end            
            maxfr=logical(sorted{a}.spont(goodthisslice(j)).ons(maxfr,:));
            spontmax(a,goodthisslice(j))=mean(cat(2,spontchanceoff{a}(maxfr),spontchanceon{a}(~maxfr)));
            susemax(a,goodthisslice(j))=1;                
        end 
    end
    if sum(goodtstrain(a,:),2)>1 & sum(goodspont(a,:),2)>1;%if there is more than one movie with more than 10 cells coming on from slice "a"
    end
end

tstrainvariance.maxm3=tstrainmaxm3;
tstrainvariance.usemaxm3=tusemaxm3;
tstrainvariance.maxm2=tstrainmaxm2;
tstrainvariance.usemaxm2=tusemaxm2;
tstrainvariance.maxm1=tstrainmaxm1;
tstrainvariance.usemaxm1=tusemaxm1;
tstrainvariance.max=tstrainmax;
tstrainvariance.usemax=tusemax;
tstrainvariance.maxp1=tstrainmaxp1;
tstrainvariance.usemaxp1=tusemaxp1;
tstrainvariance.maxp2=tstrainmaxp2;
tstrainvariance.usemaxp2=tusemaxp2;
tstrainvariance.maxp3=tstrainmaxp3;
tstrainvariance.usemaxp3=tusemaxp3;

spontvariance.maxm3=spontmaxm3;
spontvariance.usemaxm3=susemaxm3;
spontvariance.maxm2=spontmaxm2;
spontvariance.usemaxm2=susemaxm2;
spontvariance.maxm1=spontmaxm1;
spontvariance.usemaxm1=susemaxm1;
spontvariance.max=spontmax;
spontvariance.usemax=susemax;
spontvariance.maxp1=spontmaxp1;
spontvariance.usemaxp1=susemaxp1;
spontvariance.maxp2=spontmaxp2;
spontvariance.usemaxp2=susemaxp2;
spontvariance.maxp3=spontmaxp3;
spontvariance.usemaxp3=susemaxp3;


maxinboth=logical(sum(spontvariance.usemax,2)).*logical(sum(tstrainvariance.usemax,2));
maxinboth=find(maxinboth);
% figure;hold on
for g=1:length(maxinboth);
%     plot(mean(tstrainvariance.max(maxinboth(g),:)),mean(spontvariance.max(maxinboth(g),:)),'*');
    maxratio(g)=mean(tstrainvariance.max(maxinboth(g),:))/mean(spontvariance.max(maxinboth(g),:));
end
maxm3inboth=logical(sum(spontvariance.usemaxm3,2)).*logical(sum(tstrainvariance.usemaxm3,2));
maxm3inboth=find(maxm3inboth);
% figure;hold on
for g=1:length(maxm3inboth);
%     plot(mean(tstrainvariance.maxm3(maxm3inboth(g),:)),mean(spontvariance.maxm3(maxm3inboth(g),:)),'*');
    maxm3ratio(g)=mean(tstrainvariance.maxm3(maxm3inboth(g),:))/mean(spontvariance.maxm3(maxm3inboth(g),:));
end
maxm2inboth=logical(sum(spontvariance.usemaxm2,2)).*logical(sum(tstrainvariance.usemaxm2,2));
maxm2inboth=find(maxm2inboth);
% figure;hold on
for g=1:length(maxm2inboth);
%     plot(mean(tstrainvariance.maxm2(maxm2inboth(g),:)),mean(spontvariance.maxm2(maxm2inboth(g),:)),'*');
    maxm2ratio(g)=mean(tstrainvariance.maxm2(maxm2inboth(g),:))/mean(spontvariance.maxm2(maxm2inboth(g),:));
end
maxm1inboth=logical(sum(spontvariance.usemaxm1,2)).*logical(sum(tstrainvariance.usemaxm1,2));
maxm1inboth=find(maxm1inboth);
% figure;hold on
for g=1:length(maxm1inboth);
%     plot(mean(tstrainvariance.maxm1(maxm1inboth(g),:)),mean(spontvariance.maxm1(maxm1inboth(g),:)),'*');
    maxm1ratio(g)=mean(tstrainvariance.maxm1(maxm1inboth(g),:))/mean(spontvariance.maxm1(maxm1inboth(g),:));
end
maxp1inboth=logical(sum(spontvariance.usemaxp1,2)).*logical(sum(tstrainvariance.usemaxp1,2));
maxp1inboth=find(maxp1inboth);
% figure;hold on
for g=1:length(maxp1inboth);
%     plot(mean(tstrainvariance.maxp1(maxp1inboth(g),:)),mean(spontvariance.maxp1(maxp1inboth(g),:)),'*');
    maxp1ratio(g)=mean(tstrainvariance.maxp1(maxp1inboth(g),:))/mean(spontvariance.maxp1(maxp1inboth(g),:));
end
maxp2inboth=logical(sum(spontvariance.usemaxp2,2)).*logical(sum(tstrainvariance.usemaxp2,2));
maxp2inboth=find(maxp2inboth);
% figure;hold on
for g=1:length(maxp2inboth);
%     plot(mean(tstrainvariance.maxp2(maxp2inboth(g),:)),mean(spontvariance.maxp2(maxp2inboth(g),:)),'*');
    maxp2ratio(g)=mean(tstrainvariance.maxp2(maxp2inboth(g),:))/mean(spontvariance.maxp2(maxp2inboth(g),:));
end
maxp3inboth=logical(sum(spontvariance.usemaxp3,2)).*logical(sum(tstrainvariance.usemaxp3,2));
maxp3inboth=find(maxp3inboth);
% figure;hold on
for g=1:length(maxp3inboth);
%     plot(mean(tstrainvariance.maxp3(maxp3inboth(g),:)),mean(spontvariance.maxp3(maxp3inboth(g),:)),'*');
    maxp3ratio(g)=mean(tstrainvariance.maxp3(maxp3inboth(g),:))/mean(spontvariance.maxp3(maxp3inboth(g),:));
end

figure;
errorbar([exp(mean(log(maxm3ratio))) exp(mean(log(maxm2ratio))) exp(mean(log(maxm1ratio))) exp(mean(log(maxratio))) exp(mean(log(maxp1ratio))) exp(mean(log(maxp2ratio))) exp(mean(log(maxp3ratio)))],...
    [exp(std(log(maxm3ratio))) exp(std(log(maxm2ratio))) exp(std(log(maxm1ratio))) exp(std(log(maxratio))) exp(std(log(maxp1ratio))) exp(std(log(maxp2ratio))) exp(std(log(maxp3ratio)))])
title('ratio of tstrain over spont within the same slice');
%below: for displaying graphs
t=[mean(tstrainvariance.max(find(spontvariance.usemaxm3))),...
        mean(tstrainvariance.max(find(spontvariance.usemaxm2))),...
            mean(tstrainvariance.max(find(spontvariance.usemaxm1))),...
                mean(tstrainvariance.max(find(spontvariance.usemax))),...
                    mean(tstrainvariance.max(find(spontvariance.usemaxp1))),...
                        mean(tstrainvariance.max(find(spontvariance.usemaxp2))),...
                            mean(tstrainvariance.max(find(spontvariance.usemaxp3)))];

t2=[std(tstrainvariance.max(find(spontvariance.usemaxm3))),...
        std(tstrainvariance.max(find(spontvariance.usemaxm2))),...
            std(tstrainvariance.max(find(spontvariance.usemaxm1))),...
                std(tstrainvariance.max(find(spontvariance.usemax))),...
                    std(tstrainvariance.max(find(spontvariance.usemaxp1))),...
                        std(tstrainvariance.max(find(spontvariance.usemaxp2))),...
                            std(tstrainvariance.max(find(spontvariance.usemaxp3)))];                    
                    
s=[mean(spontvariance.max(find(spontvariance.usemaxm3))),...
        mean(spontvariance.max(find(spontvariance.usemaxm2))),...
            mean(spontvariance.max(find(spontvariance.usemaxm1))),...
                mean(spontvariance.max(find(spontvariance.usemax))),...
                    mean(spontvariance.max(find(spontvariance.usemaxp1))),...
                        mean(spontvariance.max(find(spontvariance.usemaxp2))),...
                            mean(spontvariance.max(find(spontvariance.usemaxp3)))];

s2=[std(spontvariance.max(find(spontvariance.usemaxm3))),...
        std(spontvariance.max(find(spontvariance.usemaxm2))),...
            std(spontvariance.max(find(spontvariance.usemaxm1))),...
                std(spontvariance.max(find(spontvariance.usemax))),...
                    std(spontvariance.max(find(spontvariance.usemaxp1))),...
                        std(spontvariance.max(find(spontvariance.usemaxp2))),...
                            std(spontvariance.max(find(spontvariance.usemaxp3)))];                  
                    
figure;
errorbar(t,t2);
hold on;
errorbar(s,s2,'r');
title('Train in blue.  Spont in red');

                    