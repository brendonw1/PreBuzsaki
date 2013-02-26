function [tstraincluster, spontcluster, tstraincolumns, tstrainlayers, spontcolumns, spontlayers]=bigcluster(sorted);
%analyzes amount of clustering in collapsed movies, max frames of movies
%and frames before and after the max frame by calling on "evalclustering".

warning off MATLAB:conversionToLogical
warning off MATLAB:divideByZero

tstraincollcluster=[];
tstraincollxcluster=[];
tstraincollycluster=[];
tstraincollpercentile=[];
tstrainmaxcluster=[];
tstrainmaxxcluster=[];
tstrainmaxycluster=[];
tstrainmaxpercentile=[];
tstrainmaxp1cluster=[];
tstrainmaxp1xcluster=[];
tstrainmaxp1ycluster=[];
tstrainmaxp1percentile=[];
tstrainmaxp1ratio=[];
tstrainmaxp2cluster=[];
tstrainmaxp2xcluster=[];
tstrainmaxp2ycluster=[];
tstrainmaxp2percentile=[];
tstrainmaxp2ratio=[];
tstrainmaxm1cluster=[];
tstrainmaxm1xcluster=[];
tstrainmaxm1ycluster=[];
tstrainmaxm1percentile=[];
tstrainmaxm1ratio=[];
tstrainmaxm2cluster=[];
tstrainmaxm2xcluster=[];
tstrainmaxm2ycluster=[];
tstrainmaxm2percentile=[];
tstrainmaxm2ratio=[];

spontcollcluster=[];
spontcollxcluster=[];
spontcollycluster=[];
spontcollpercentile=[];
spontmaxcluster=[];
spontmaxxcluster=[];
spontmaxycluster=[];
spontmaxpercentile=[];
spontmaxp1cluster=[];
spontmaxp1xcluster=[];
spontmaxp1ycluster=[];
spontmaxp1percentile=[];
spontmaxp1ratio=[];
spontmaxp2cluster=[];
spontmaxp2xcluster=[];
spontmaxp2ycluster=[];
spontmaxp2percentile=[];
spontmaxp2ratio=[];
spontmaxm1cluster=[];
spontmaxm1xcluster=[];
spontmaxm1ycluster=[];
spontmaxm1percentile=[];
spontmaxm1ratio=[];
spontmaxm2cluster=[];
spontmaxm2xcluster=[];
spontmaxm2ycluster=[];
spontmaxm2percentile=[];
spontmaxm2ratio=[];

for c=1:size(sorted,2);%for each slice
    c
    if ~isempty(sorted{c}.tstrain)%j;%if there were tstrain movies for this slice, then...
        for d=1:size(sorted{c}.tstrain,2)
            d
            colltstrain{c}(d,:)=sum(sorted{c}.tstrain(d).ons,1);%collapse data from all frames into a single chunk of data
            colltstrain{c}=logical(colltstrain{c});%a cell that is on in a movie=1 (not more if it is on multiple times)            
            if sum(colltstrain{c}(d,:),2)>=10;%if total number of cells on in this movie is greater than 10:
%                 goodtstrain(c,d)=1;%record that this movie was big enough
                [tstraincollcluster(end+1), tstraincollxcluster(end+1), tstraincollycluster(end+1), tstraincollpercentile(end+1)]=evalclustering(colltstrain{c}(d,:),sorted{c}.contours);
                maxframe=sum(sorted{c}.tstrain(d).ons,2);
                [garbage,maxframe]=max(maxframe);
                if sum(sorted{c}.tstrain(d).ons(maxframe,:))>5;
                    [tstrainmaxcluster(end+1), tstrainmaxxcluster(end+1), tstrainmaxycluster(end+1), tstrainmaxpercentile(end+1)]=evalclustering(sorted{c}.tstrain(d).ons(maxframe,:),sorted{c}.contours);
                end
                if maxframe+1<=size(sorted{c}.tstrain(d).ons,1) & sum(sorted{c}.tstrain(d).ons(maxframe+1,:))>=5;
                    [tstrainmaxp1cluster(end+1), tstrainmaxp1xcluster(end+1), tstrainmaxp1ycluster(end+1), tstrainmaxp1percentile(end+1)]=evalclustering(sorted{c}.tstrain(d).ons(maxframe+1,:),sorted{c}.contours);
                    tstrainmaxp1ratio(end+1)=tstrainmaxp1percentile(end)/tstrainmaxpercentile(end);
                end
                if maxframe+2<=size(sorted{c}.tstrain(d).ons,1) & sum(sorted{c}.tstrain(d).ons(maxframe+2,:))>=5;
                    [tstrainmaxp2cluster(end+1), tstrainmaxp2xcluster(end+1), tstrainmaxp2ycluster(end+1), tstrainmaxp2percentile(end+1)]=evalclustering(sorted{c}.tstrain(d).ons(maxframe+2,:),sorted{c}.contours);
                    tstrainmaxp2ratio(end+1)=tstrainmaxp2percentile(end)/tstrainmaxpercentile(end);    
                end
                if maxframe-1>0 & sum(sorted{c}.tstrain(d).ons(maxframe-1,:))>=5;
                    [tstrainmaxm1cluster(end+1), tstrainmaxm1xcluster(end+1), tstrainmaxm1ycluster(end+1), tstrainmaxm1percentile(end+1)]=evalclustering(sorted{c}.tstrain(d).ons(maxframe-1,:),sorted{c}.contours);
                    tstrainmaxm1ratio(end+1)=tstrainmaxm1percentile(end)/tstrainmaxpercentile(end);    
                end
                if maxframe-2>0 & sum(sorted{c}.tstrain(d).ons(maxframe-2,:))>=5;
                    [tstrainmaxm2cluster(end+1), tstrainmaxm2xcluster(end+1), tstrainmaxm2ycluster(end+1), tstrainmaxm2percentile(end+1)]=evalclustering(sorted{c}.tstrain(d).ons(maxframe-2,:),sorted{c}.contours);
                    tstrainmaxm2ratio(end+1)=tstrainmaxm2percentile(end)/tstrainmaxpercentile(end);    
                end    
            end
        end
    end
    if ~isempty(sorted{c}.spont)%j;%if there were tstrain movies for this slice, then...
        for d=1:size(sorted{c}.spont,2)
            collspont{c}(d,:)=sum(sorted{c}.spont(d).ons,1);%collapse data from all frames into a single chunk of data
            collspont{c}=logical(collspont{c});%a cell that is on in a movie=1 (not more if it is on multiple times)
            if sum(collspont{c}(d,:),2)>=10;%if total number of cells on in this movie is greater than 10:
%                 goodspont(c,d)=1;%record that this movie was big enough
                [spontcollcluster(end+1), spontcollxcluster(end+1), spontcollycluster(end+1), spontcollpercentile(end+1)]=evalclustering(collspont{c}(d,:),sorted{c}.contours);
                maxframe=sum(sorted{c}.spont(d).ons,2);
                [garbage,maxframe]=max(maxframe);
                if sum(sorted{c}.spont(d).ons(maxframe,:))>5;
                    [spontmaxcluster(end+1), spontmaxxcluster(end+1), spontmaxycluster(end+1), spontmaxpercentile(end+1)]=evalclustering(sorted{c}.spont(d).ons(maxframe,:),sorted{c}.contours);
                end
                if maxframe+1<=size(sorted{c}.spont(d).ons,1) & sum(sorted{c}.spont(d).ons(maxframe+1,:))>=5;
                    [spontmaxp1cluster(end+1), spontmaxp1xcluster(end+1), spontmaxp1ycluster(end+1), spontmaxp1percentile(end+1)]=evalclustering(sorted{c}.spont(d).ons(maxframe+1,:),sorted{c}.contours);
                    spontmaxp1ratio(end+1)=spontmaxp1percentile(end)/spontmaxpercentile(end);    
                end
                if maxframe+2<=size(sorted{c}.spont(d).ons,1) & sum(sorted{c}.spont(d).ons(maxframe+2,:))>=5;
                    [spontmaxp2cluster(end+1), spontmaxp2xcluster(end+1), spontmaxp2ycluster(end+1), spontmaxp2percentile(end+1)]=evalclustering(sorted{c}.spont(d).ons(maxframe+2,:),sorted{c}.contours);
                    spontmaxp2ratio(end+1)=spontmaxp2percentile(end)/spontmaxpercentile(end);    
                end
                if maxframe-1>0 & sum(sorted{c}.spont(d).ons(maxframe-1,:))>=5;
                    [spontmaxm1cluster(end+1), spontmaxm1xcluster(end+1), spontmaxm1ycluster(end+1), spontmaxm1percentile(end+1)]=evalclustering(sorted{c}.spont(d).ons(maxframe-1,:),sorted{c}.contours);
                    spontmaxm1ratio(end+1)=spontmaxm1percentile(end)/spontmaxpercentile(end);    
                end
                if maxframe-2>0 & sum(sorted{c}.spont(d).ons(maxframe-2,:))>=5;
                    [spontmaxm2cluster(end+1), spontmaxm2xcluster(end+1), spontmaxm2ycluster(end+1), spontmaxm2percentile(end+1)]=evalclustering(sorted{c}.spont(d).ons(maxframe-2,:),sorted{c}.contours);
                    spontmaxm2ratio(end+1)=spontmaxm2percentile(end)/spontmaxpercentile(end);    
                end        
            end
        end
    end
end

not=find(tstraincollcluster==0);%find movies that are not clustered
x=length(find(tstraincollxcluster(not)));%find how many columns
y=length(find(tstraincollxcluster(not)));%find how many columns
tstraincolumns.tstraincollpercentsignif=100*x/size(tstraincollcluster,2);
tstrainlayers.tstraincollpercentsignif=100*y/size(tstraincollcluster,2);

not=find(tstrainmaxcluster==0);%find movies that are not clustered
x=length(find(tstrainmaxxcluster(not)));%find how many columns
y=length(find(tstrainmaxxcluster(not)));%find how many columns
tstraincolumns.tstrainmaxpercentsignif=100*x/size(tstrainmaxcluster,2);
tstrainlayers.tstrainmaxpercentsignif=100*y/size(tstrainmaxcluster,2);

not=find(tstrainp1cluster==0);%find movies that are not clustered
x=length(find(tstrainp1xcluster(not)));%find how many columns
y=length(find(tstrainp1xcluster(not)));%find how many columns
tstraincolumns.tstrainp1percentsignif=100*x/size(tstrainp1cluster,2);
tstrainlayers.tstrainp1percentsignif=100*y/size(tstrainp1cluster,2);

not=find(tstrainp2cluster==0);%find movies that are not clustered
x=length(find(tstrainp2xcluster(not)));%find how many columns
y=length(find(tstrainp2xcluster(not)));%find how many columns
tstraincolumns.tstrainp2percentsignif=100*x/size(tstrainp2cluster,2);
tstrainlayers.tstrainp2percentsignif=100*y/size(tstrainp2cluster,2);

not=find(tstrainm1cluster==0);%find movies that are not clustered
x=length(find(tstrainm1xcluster(not)));%find how many columns
y=length(find(tstrainm1xcluster(not)));%find how many columns
tstraincolumns.tstrainm1percentsignif=100*x/size(tstrainm1cluster,2);
tstrainlayers.tstrainm1percentsignif=100*y/size(tstrainm1cluster,2);

not=find(tstrainm2cluster==0);%find movies that are not clustered
x=length(find(tstrainm2xcluster(not)));%find how many columns
y=length(find(tstrainm2xcluster(not)));%find how many columns
tstraincolumns.tstrainm2percentsignif=100*x/size(tstrainm2cluster,2);
tstrainlayers.tstrainm2percentsignif=100*y/size(tstrainm2cluster,2);

%%%%%%%%%

not=find(spontcollcluster==0);%find movies that are not clustered
x=length(find(spontcollxcluster(not)));%find how many columns
y=length(find(spontcollxcluster(not)));%find how many columns
spontcolumns.spontcollpercentsignif=100*x/size(spontcollcluster,2);
spontlayers.spontcollpercentsignif=100*y/size(spontcollcluster,2);

not=find(spontmaxcluster==0);%find movies that are not clustered
x=length(find(spontmaxxcluster(not)));%find how many columns
y=length(find(spontmaxxcluster(not)));%find how many columns
spontcolumns.spontmaxpercentsignif=100*x/size(spontmaxcluster,2);
spontlayers.spontmaxpercentsignif=100*y/size(spontmaxcluster,2);

not=find(spontp1cluster==0);%find movies that are not clustered
x=length(find(spontp1xcluster(not)));%find how many columns
y=length(find(spontp1xcluster(not)));%find how many columns
spontcolumns.spontp1percentsignif=100*x/size(spontp1cluster,2);
spontlayers.spontp1percentsignif=100*y/size(spontp1cluster,2);

not=find(spontp2cluster==0);%find movies that are not clustered
x=length(find(spontp2xcluster(not)));%find how many columns
y=length(find(spontp2xcluster(not)));%find how many columns
spontcolumns.spontp2percentsignif=100*x/size(spontp2cluster,2);
spontlayers.spontp2percentsignif=100*y/size(spontp2cluster,2);

not=find(spontm1cluster==0);%find movies that are not clustered
x=length(find(spontm1xcluster(not)));%find how many columns
y=length(find(spontm1xcluster(not)));%find how many columns
spontcolumns.spontm1percentsignif=100*x/size(spontm1cluster,2);
spontlayers.spontm1percentsignif=100*y/size(spontm1cluster,2);

not=find(spontm2cluster==0);%find movies that are not clustered
x=length(find(spontm2xcluster(not)));%find how many columns
y=length(find(spontm2xcluster(not)));%find how many columns
spontcolumns.spontm2percentsignif=100*x/size(spontm2cluster,2);
spontlayers.spontm2percentsignif=100*y/size(spontm2cluster,2);


%%%%%%%%%%

tstraincluster.tstraincollpercentsignif=100*sum(tstraincollcluster)/size(tstraincollcluster,2);
tstraincluster.tstraincollaveragepercentile=mean(tstraincollpercentile);
tstraincluster.tstraincollstdpercentile=std(tstraincollpercentile);
tstraincluster.numbtstraincoll=length(tstraincollcluster);

tstraincluster.tstrainmaxpercentsignif=100*sum(tstrainmaxcluster)/size(tstrainmaxcluster,2);
tstraincluster.tstrainmaxaveragepercentile=mean(tstrainmaxpercentile);
tstraincluster.tstrainmaxstdpercentile=std(tstrainmaxpercentile);
tstraincluster.numbtstrainmax=length(tstrainmaxcluster);

tstraincluster.tstrainmaxp1percentsignif=100*sum(tstrainmaxp1cluster)/size(tstrainmaxp1cluster,2);
tstraincluster.tstrainmaxp1averagepercentile=mean(tstrainmaxp1percentile);
tstraincluster.tstrainmaxp1stdpercentile=std(tstrainmaxp1percentile);
tstraincluster.numbtstrainmaxp1=length(tstrainmaxp1cluster);

tstraincluster.tstrainmaxp2percentsignif=100*sum(tstrainmaxp2cluster)/size(tstrainmaxp2cluster,2);
tstraincluster.tstrainmaxp2averagepercentile=mean(tstrainmaxp2percentile);
tstraincluster.tstrainmaxp2stdpercentile=std(tstrainmaxp2percentile);
tstraincluster.numbtstrainmaxp2=length(tstrainmaxp2cluster);

tstraincluster.tstrainmaxm1percentsignif=100*sum(tstrainmaxm1cluster)/size(tstrainmaxm1cluster,2);
tstraincluster.tstrainmaxm1averagepercentile=mean(tstrainmaxm1percentile);
tstraincluster.tstrainmaxm1stdpercentile=std(tstrainmaxm1percentile);
tstraincluster.numbtstrainmaxm1=length(tstrainmaxm1cluster);

tstraincluster.tstrainmaxm2percentsignif=100*sum(tstrainmaxm2cluster)/size(tstrainmaxm2cluster,2);
tstraincluster.tstrainmaxm2averagepercentile=mean(tstrainmaxm2percentile);
tstraincluster.tstrainmaxm2stdpercentile=std(trainmaxm2percentile);
tstraincluster.numbtstrainmaxm2=length(tstrainmaxm2cluster);

tstraincluster.tstrainmaxp1ratioaverage=mean(tstrainmaxp1ratio);
tstraincluster.tstrainmaxp1ratiostd=std(tstrainmaxp1ratio);
tstraincluster.tstrainmaxp2ratioaverage=mean(tstrainmaxp2ratio);
tstraincluster.tstrainmaxp2ratiostd=std(tstrainmaxp2ratio);
tstraincluster.tstrainmaxm1ratioaverage=mean(tstrainmaxm1ratio);
tstraincluster.tstrainmaxm1ratiostd=std(tstrainmaxm1ratio);
tstraincluster.tstrainmaxm2ratioaverage=mean(tstrainmaxm2ratio);
tstraincluster.tstrainmaxm2ratiostd=std(tstrainmaxm2ratio);

%%%%%%%%

spontcluster.spontcollpercentsignif=100*sum(spontcollcluster)/size(spontcollcluster,2);
spontcluster.spontcollaveragepercentile=mean(spontcollpercentile);
spontcluster.spontcollstdpercentile=std(spontcollpercentile);
spontcluster.numbspontcoll=length(spontcollcluster);

spontcluster.spontmaxpercentsignif=100*sum(spontmaxcluster)/size(spontmaxcluster,2);
spontcluster.spontmaxaveragepercentile=mean(spontmaxpercentile);
spontcluster.spontmaxstdpercentile=std(spontmaxpercentile);
spontcluster.numbspontmax=length(spontmaxcluster);

spontcluster.spontmaxp1percentsignif=100*sum(spontmaxp1cluster)/size(spontmaxp1cluster,2);
spontcluster.spontmaxp1averagepercentile=mean(spontmaxp1percentile);
spontcluster.spontmaxp1stdpercentile=std(spontmaxp1percentile);
spontcluster.numbspontmaxp1=length(spontmaxp1cluster);

spontcluster.spontmaxp2percentsignif=100*sum(spontmaxp2cluster)/size(spontmaxp2cluster,2);
spontcluster.spontmaxp2averagepercentile=mean(spontmaxp2percentile);
spontcluster.spontmaxp2stdpercentile=std(spontmaxp2percentile);
spontcluster.numbspontmaxp2=length(spontmaxp2cluster);

spontcluster.spontmaxm1percentsignif=100*sum(spontmaxm1cluster)/size(spontmaxm1cluster,2);
spontcluster.spontmaxm1averagepercentile=mean(spontmaxm1percentile);
spontcluster.spontmaxm1averagepercentile=std(spontmaxm1percentile);
spontcluster.numbspontmaxm1=length(spontmaxm1cluster);

spontcluster.spontmaxm2percentsignif=100*sum(spontmaxm2cluster)/size(spontmaxm2cluster,2);
spontcluster.spontmaxm2averagepercentile=mean(spontmaxm2percentile);
spontcluster.spontmaxm2stdpercentile=std(spontmaxm2percentile);
spontcluster.numbspontmaxm2=length(spontmaxm2cluster);

spontcluster.spontmaxp1ratioaverage=mean(spontmaxp1ratio);
spontcluster.spontmaxp1ratiostd=std(spontmaxp1ratio);
spontcluster.spontmaxp2ratioaverage=mean(spontmaxp2ratio);
spontcluster.spontmaxp2ratiostd=std(spontmaxp2ratio);
spontcluster.spontmaxm1ratioaverage=mean(spontmaxm1ratio);
spontcluster.spontmaxm1ratiostd=std(spontmaxm1ratio);
spontcluster.spontmaxm2ratioaverage=mean(spontmaxm2ratio);
spontcluster.spontmaxm2ratiostd=std(spontmaxm2ratio);

% 
% for a=1:size(sorted,2);%for each slice
%     if sum(goodtstrain(a,:),2)>1;%if there is more than one movie with more than 10 cells coming on from slice "a"
% 
%         
%         
% %         tstraintotstrain(1).totalslices=tstraintotstrain(1).totalslices+1;
% %         tstraintotstrain(1).totalmovies=tstraintotstrain(1).totalmovies+sum(goodtstrain(a,:),2);
% %         sumcolltstrain{a}=zeros(1,length(sorted{a}.contours));
% %         goodthisslice=find(goodtstrain(a,:));%gives dim2 coords of good movies
% %         for b=1:size(goodthisslice,2)%for each good tstrain movie
% %             sumcolltstrain{a}=sumcolltstrain{a}+colltstrain{a}(goodthisslice(b),:);%for each cell, how many movies is it on in?
% %         end
%     end
%     if sum(goodspont(a,:),2)>1;%if there is more than one movie with more than 10 cells coming on from slice "a"
%         sponttospont(1).totalslices=sponttospont(1).totalslices+1;
%         sponttospont(1).totalmovies=sponttospont(1).totalmovies+sum(goodspont(a,:),2);
%         sumcollspont{a}=zeros(1,length(sorted{a}.contours));
%         goodthisslice=find(goodspont(a,:));%gives dim2 coords of good movies
%         for b=1:size(goodthisslice,2)%for each good spont movie
%             sumcollspont{a}=sumcollspont{a}+collspont{a}(goodthisslice(b),:);%for each cell, how many movies is it on in?
%         end
%     end 
%     if sum(goodtstrain(a,:),2)>1 & sum(goodspont(a,:),2)>1;%if there is more than one movie with more than 10
%     end
% end