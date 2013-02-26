function basicmovieanalysisplasticity(sorted,goodperslice);

% goodperslice=2;
cellspermovie=5;

warning off MATLAB:conversionToLogical
warning off MATLAB:divideByZero

goodtstrain(size(sorted,2),1)=0;
goodspont(size(sorted,2),1)=0;
for c=1:size(sorted,2);%for each slice
    if ~isempty(sorted{c}.tstrain)%j;%if there were tstrain movies for this slice, then...
%         slicecolltstrain{c}=zeros(1,length(sorted{c}.contours));%establish matrix
        for d=1:size(sorted{c}.tstrain,2)%for tstrain each movie in this slice
            colltstrain{c}(d,:)=sum(sorted{c}.tstrain(d).ons,1);%collapse data from all frames into a single chunk of data
            colltstrain{c}=logical(colltstrain{c});%a cell that is on in a movie=1 (not more if it is on multiple times)
%             slicecolltstrain{c}=colltstrain{c}(d,:)+slicecolltstrain{c};%collapse all cells on from the tstrain movies for a slice
            if sum(colltstrain{c}(d,:),2)>=cellspermovie;%if total number of cells on in this movie is greater than cellspermovie:
                goodtstrain(c,d)=1;%record whether this movie had enough activity... in this form for easy measuring of size
            end
        end
    end
    if ~isempty(sorted{c}.spont)%j;%if there were tstrain movies for this slice, then...
%         slicecollspont{c}=zeros(1,length(sorted{c}.contours));
        for d=1:size(sorted{c}.spont,2);%for spont each movie in this slice
            collspont{c}(d,:)=sum(sorted{c}.spont(d).ons,1);%collapse data from all frames into a single chunk of data
            collspont{c}=logical(collspont{c});%a cell that is on in a movie=1 (not more if it is on multiple times)
%             slicecollspont{c}=collspont{c}(d,:)+slicecollspont{c};%collapse all cells on from the tstrain movies for a slice
            if sum(collspont{c}(d,:),2)>=cellspermovie;%if total number of cells on in this movie is greater than 5:
                goodspont(c,d)=1;%record whether this movie had enough activity... in this form for easy measuring of size
            end
        end
    end
%     if ~isempty(sorted{c}.wdtrain)%j;%if there were tstrain movies for this slice, then...
% %         slicecollwdtrain{c}=zeros(1,length(sorted{c}.contours));
%         for d=1:size(sorted{c}.wdtrain,2);
%             collwdtrain{c}(d,:)=sum(sorted{c}.wdtrain(d).ons,1);%collapse data from all frames into a single chunk of data
%             collwdtrain{c}=logical(collwdtrain{c});%a cell that is on in a movie=1 (not more if it is on multiple times)
% %             slicecollwdtrain{c}=collwdtrain{c}(d,:)+slicecollwdtrain{c};%collapse all cells on from the tstrain movies for a slice
%             if sum(collwdtrain{c}(d,:),2)>=cellspermovie;%if total number of cells on in this movie is greater than 5:
%                 goodwdtrain(c,d)=1;%record that this movie was big enough... in this form for easy measuring of size
%             end
%         end
%     end
end
% for a=1:size(sorted,2);%for each slice... we'll make numbers of movies the same for both spont and stim in each slice
%     m=min([sum(goodtstrain(a,:)) sum(goodspont(a,:))]);%figure out whether less spont or less stim movies
%     t=find(goodtstrain(a,:));
%     s=find(goodspont(a,:));
%     t=t(1:m);
%     s=s(1:m);
%     goodtstrain(a,:)=zeros(1,size(goodtstrain,2));
%     goodtstrain(a,t)=1;
%     goodspont(a,:)=zeros(1,size(goodspont,2));
%     goodspont(a,s)=1;
% end

tmovies=0;
wmovies=0;
smovies=0;
ttotalcells=0;
stotalcells=0;
wtotalcells=0;
tracker=0;
tslices=[];
sslices=[];
wslices=[];
tmovieons=[];
smovieons=[];
wmovieons=[];
tmoviepercons=[];
smoviepercons=[];
wmoviepercons=[];
for a=1:size(sorted,2);%for each slice
    if sum(goodtstrain(a,:),2)>=goodperslice;%if there is more than one movie with more than cellspermovie cells coming on from slice "a"
        ttotalcells=ttotalcells+size(sorted{a}.contours,2);
        tracker=a;
        tslices(end+1)=a;
        tmovon=[];
        tmeanmovon=[];
        sumcolltstrain{a}=zeros(1,length(sorted{a}.contours));
        goodthisslice=find(goodtstrain(a,:));%gives dim2 coords of good movies
        for b=1:size(goodthisslice,2)%for each good tstrain movie
            sumcolltstrain{a}=sumcolltstrain{a}+colltstrain{a}(goodthisslice(b),:);%for each cell, how many movies is it on in? 
            tmovon(b)=sum(colltstrain{a}(goodthisslice(b),:));
            tmovieons(end+1)=sum(colltstrain{a}(goodthisslice(b),:));
            tmoviepercons(end+1)=sum(colltstrain{a}(goodthisslice(b),:))./size(colltstrain{a}(goodthisslice(b),:),2);
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
    if sum(goodspont(a,:),2)>=goodperslice;%if there is more than one movie with more than cellspermovie cells coming on from slice "a"
        stotalcells=stotalcells+size(sorted{a}.contours,2);
        sslices(end+1)=a;
        smovon=[];
        smeanmovon=[];
        sumcollspont{a}=zeros(1,length(sorted{a}.contours));
        goodthisslice=find(goodspont(a,:));%gives dim2 coords of good movies
        for b=1:size(goodthisslice,2)%for each good spont movie
            sumcollspont{a}=sumcollspont{a}+collspont{a}(goodthisslice(b),:);%for each cell, how many movies is it on in?
            smovon(b)=sum(collspont{a}(goodthisslice(b),:));
            smovieons(end+1)=sum(collspont{a}(goodthisslice(b),:));
            smoviepercons(end+1)=sum(collspont{a}(goodthisslice(b),:))./size(collspont{a}(goodthisslice(b),:),2);
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
%     if sum(goodwdtrain(a,:),2)>=goodperslice;%if there is more than one movie with more than cellspermovie cells coming on from slice "a"
%         wtotalcells=wtotalcells+size(sorted{a}.contours,2);
%         wslices(end+1)=a;
%         wmovon=[];
%         wmeanmovon=[];
%         sumcollwdtrain{a}=zeros(1,length(sorted{a}.contours));
%         goodthisslice=find(goodwdtrain(a,:));%gives dim2 coords of good movies
%         for b=1:size(goodthisslice,2)%for each good wdtrain movie
%             wumcollwdtrain{a}=sumcollwdtrain{a}+collwdtrain{a}(goodthisslice(b),:);%for each cell, how many movies is it on in?
%             wmovon(b)=sum(collwdtrain{a}(goodthisslice(b),:));
%             wmovieons(end+1)=sum(collwdtrain{a}(goodthisslice(b),:));
%             wmoviepercons(end+1)=sum(collwdtrain{a}(goodthisslice(b),:))./size(collwdtrain{a}(goodthisslice(b),:),2);
%             wpercmovon(b)=sum(collwdtrain{a}(goodthisslice(b),:))./size(collwdtrain{a}(goodthisslice(b),:),2);
%             wmovies=wmovies+1;
%         end
%         sumcollwdtrain{a}=sumcollwdtrain{a}/size(goodthisslice,2);%for each cell, what percent of movies is it on
%         activewn(a)=sum(logical(sumcollwdtrain{a}));
%         activewd(a)=size(sumcollwdtrain{a},2);
%         wmeanon(a)=mean(wmovon);
%         wmeanpercon(a)=mean(wpercmovon);
%         wsdon(a)=std(wmovon);
%         wsdpercon(a)=std(wpercmovon);       
%         wcvon(a)=wsdon(a)/wmeanon(a);
%         wcvpercon(a)=wsdpercon(a)/wmeanpercon(a);
%     end 
end
disp('-------------------------');
disp('-------------------------');
disp(['Minimum number of good-enough movies per type per slice = ',num2str(goodperslice)]);
disp(['Total Trig Slices = ',num2str(length(tslices))]);
disp(['Total Trig Movies = ',num2str(tmovies)]);
disp(['Total Trig Cells Analyzed = ',num2str(ttotalcells)]);
disp(['Total Spont Slices = ',num2str(length(sslices))]);
disp(['Total Spont Movies = ',num2str(smovies)]);
disp(['Total Spont Cells Analyzed = ',num2str(stotalcells)]);
disp(['Total WDTrain Slices = ',num2str(length(wslices))]);
disp(['Total WDTrain Movies = ',num2str(wmovies)]);
disp(['Total WDTrain Cells Analyzed = ',num2str(wtotalcells)]);
disp('-------------------------');
sons=[];for a=1:length(sslices);sons(end+1)=size(find(sumcollspont{sslices(a)}),2);end
tons=[];for a=1:length(tslices);tons(end+1)=size(find(sumcolltstrain{tslices(a)}),2);end
wons=[];for a=1:length(tslices);tons(end+1)=size(find(sumcolltstrain{tslices(a)}),2);end
disp(['Total Cells which ever came on in Trig, Spont, WDTrain = ',num2str(sum(tons)),'  ',num2str(sum(sons)),'  ',num2str(sum(wons))]);
disp(['Percent of all Cells which ever came on in Trig, Spont, WDTrain = ',num2str(100*sum(tons)/ttotalcells),'  ',num2str(100*sum(sons)/stotalcells),'  ',num2str(100*sum(wons)/wtotalcells)]);
disp('-------------------------');
disp('-------------------------');
% disp(['Mean number of cells active per slice in Trig, Spont, WDTrain= ',num2str(mean(activetn(tslices))),'  ',num2str(mean(activesn(sslices))),'  ',num2str(mean(activewn(wslices)))]);
% disp(['SD of number of cells active per slice in Spont = ',num2str(std(activetn(tslices))),'  ',num2str(std(activesn(sslices))),'  ',num2str(std(activewn(wslices)))]);
[h,p]=ttest2(activetn(tslices),activesn(sslices));
disp(['p value of this difference = ',num2str(p)]);
disp(['Mean percent of cells active per slice in Trig and Spont= ',num2str(100*mean(activetn(tslices)./activetd(tslices))),'  ',num2str(100*mean(activesn(sslices)./activesd(sslices)))]);
disp(['SD of percent of cells active per slice in Spont = ',num2str(100*std(activetn(tslices)./activetd(tslices))),'  ',num2str(100*std(activesn(sslices)./activesd(sslices)))]);
[h,p]=ttest2(activetn(tslices)./activetd(tslices),activesn(sslices)./activesd(sslices));
disp(['p value of this difference = ',num2str(p)]);
disp('-------------------------');
disp('-------------------------');
disp(['Mean number of cells active per movie in Trig, Spont = ',num2str(mean(tmovieons)),'  ',num2str(mean(smovieons))]);
disp(['SD of number of cells active per movie in Trig, Spont = ',num2str(std(tmovieons)),'  ',num2str(std(smovieons))]);
[h,p]=ttest2(tmovieons,smovieons);
disp(['p value of this difference = ',num2str(p)]);
disp(['Mean percent of cells active per movie in Trig, Spont = ',num2str(100*mean(tmoviepercons)),'  ',num2str(100*mean(smoviepercons))]);
disp(['SD of percent of cells active per movie in Trig, Spont = ',num2str(100*std(tmoviepercons)),'  ',num2str(100*std(smoviepercons))]);
[h,p]=ttest2(tmoviepercons,smoviepercons);
disp(['p value of this difference = ',num2str(p)]);
disp('-------------------------');
disp('-------------------------');
disp(['Mean of mean per slice number of cells active per movie in Trig, Spont = ',num2str(mean(tmeanon(tslices))),'  ',num2str(mean(smeanon(sslices)))]);
[h,p]=ttest2(tmeanon(tslices),smeanon(sslices));
disp(['p value of this difference = ',num2str(p)]);
disp(['Mean of SD per slice number of cells active per movie in Trig, Spont = ',num2str(mean(tsdon(tslices))),'  ',num2str(mean(ssdon(sslices)))]);
[h,p]=ttest2(tsdon(tslices),ssdon(sslices));
disp(['p value of this difference = ',num2str(p)]);
disp(['Mean of CV per slice number of cells active per movie in Trig, Spont = ',num2str(mean(tcvon(tslices))),'  ',num2str(mean(scvon(sslices)))]);
[h,p]=ttest2(tcvon(tslices),scvon(sslices));
disp(['p value of this difference = ',num2str(p)]);
disp('-------------------------');
disp(['Mean of mean per slice percent of cells active per movie in Trig, Spont = ',num2str(100*mean(tmeanpercon(tslices))),'  ',num2str(100*mean(smeanpercon(sslices)))]);
[h,p]=ttest2(tmeanpercon(tslices),smeanpercon(sslices));
disp(['p value of this difference = ',num2str(p)]);
disp(['Mean of SD per slice percent of cells active per movie in Trig, Spont = ',num2str(100*mean(tsdpercon(tslices))),'  ',num2str(100*mean(ssdpercon(sslices)))]);
[h,p]=ttest2(tsdpercon(tslices),ssdpercon(sslices));
disp(['p value of this difference = ',num2str(p)]);
disp(['Mean of CV per slice percent of cells active per movie in Trig, Spont = ',num2str(100*mean(tcvpercon(tslices))),'  ',num2str(100*mean(scvpercon(sslices)))]);
[h,p]=ttest2(tcvpercon(tslices),scvpercon(sslices));
disp(['p value of this difference = ',num2str(p)]);
disp('-------------------------');
disp('-------------------------');

ttotals=[];
for r=1:size(sumcolltstrain,2);
    ttotals=cat(2,ttotals,sumcolltstrain{r});
end
stotals=[];
for r=1:size(sumcollspont,2);
    stotals=cat(2,stotals,sumcollspont{r});
end
disp(['Mean repetition index of all cells in Trig, Spont movies: ',num2str(mean(ttotals)),'  ',num2str(mean(stotals))])
[h,p]=ttest2(ttotals,stotals);
disp(['p value of this difference = ',num2str(p),' ... note this includes a much larger n than other comparisons']);
disp(['Mean repetition index of active cells in Trig, Spont movies: ',num2str(mean(ttotals(find(ttotals)))),'  ',num2str(mean(stotals(find(stotals))))])
[h,p]=ttest2(ttotals(find(ttotals)),stotals(find(stotals)));
disp(['p value of this difference = ',num2str(p),' ... note this includes a much larger n than other comparisons']);
disp('-------------------------');
for a=1:length(tslices);
    tslicerep(a)=mean(sumcolltstrain{tslices(a)}(find(sumcolltstrain{tslices(a)})));
    tsdslicerep(a)=std(sumcolltstrain{tslices(a)}(find(sumcolltstrain{tslices(a)})));
end
for a=1:length(sslices);
    sslicerep(a)=mean(sumcollspont{sslices(a)}(find(sumcollspont{sslices(a)})));
    ssdslicerep(a)=std(sumcollspont{sslices(a)}(find(sumcollspont{sslices(a)})));
end
disp(['Mean of per-slice-mean repetition index of active cells in Trig, Spont movies: ',num2str(mean(tslicerep)),'  ',num2str(mean(sslicerep))])
disp(['SD of per-slice-mean repetition index of active cells in Trig, Spont movies: ',num2str(std(tslicerep)),'  ',num2str(std(sslicerep))])
[h,p]=ttest2(tslicerep,sslicerep);
disp(['p value of this difference = ',num2str(p)]);
disp(['Mean of per-slice-SD repetition index of active cells in Trig, Spont movies: ',num2str(mean(tsdslicerep)),'  ',num2str(mean(ssdslicerep))])
disp(['SD of per-slice-SD repetition index of active cells in Trig, Spont movies: ',num2str(std(tsdslicerep)),'  ',num2str(std(ssdslicerep))])
[h,p]=ttest2(tsdslicerep,ssdslicerep);
disp(['p value of this difference = ',num2str(p)]);



[sliceoverlaps]=pairwiseoverlaps(sorted,2);
ttmeanpairo=[];
ttsdpairo=[];
ssmeanpairo=[];
sssdpairo=[];
wwmeanpairo=[];
wwsdpairo=[];
tsmeanpairo=[];
tssdpairo=[];
tnc=[];
snc=[];
tsnc=[];
wnc=[];
for a=1:size(sorted,2);
    if size(sliceoverlaps(a).ss,2)>1;
        snc(end+1)=a;%find slices with more than one pairwise comparison... sd's can only be on these
    end
    if size(sliceoverlaps(a).tt,2)>1;
        tnc(end+1)=a;%find slices with more than one pairwise comparison... sd's can only be on these
    end
    if size(sliceoverlaps(a).ts,2)>1;
        tsnc(end+1)=a;%find slices with more than one pairwise comparison... sd's can only be on these
    end
end
for a=1:size(sorted,2);
    if ~isempty(sliceoverlaps(a).tt);
        ttmeanpairo(end+1)=mean(sliceoverlaps(a).tt);
    end
    if ~isempty(sliceoverlaps(a).ss);
        ssmeanpairo(end+1)=mean(sliceoverlaps(a).ss);
    end
    if ~isempty(sliceoverlaps(a).ts);
        tsmeanpairo(end+1)=mean(sliceoverlaps(a).ts);
    end
    if ~isempty(sliceoverlaps(a).ww);
        wwmeanpairo(end+1)=mean(sliceoverlaps(a).ww);
    end
end

for a=1:length(snc);
    sssdpairo(end+1)=std(sliceoverlaps(snc(a)).ss);
end
for a=1:length(tnc);
    ttsdpairo(end+1)=std(sliceoverlaps(tnc(a)).tt);
end
for a=1:length(tsnc);
    tssdpairo(end+1)=std(sliceoverlaps(tsnc(a)).ts);
end
for a=1:length(wnc);
    wwsdpairo(end+1)=std(sliceoverlaps(wnc(a)).ww);
end

for a=1:size(sliceoverlaps,2)
	tscount(a)=~isempty(sliceoverlaps(a).ts);
	sscount(a)=~isempty(sliceoverlaps(a).ss);
	ttcount(a)=~isempty(sliceoverlaps(a).tt);
end

disp('-------------------------');
disp('-------------------------');
disp('THE FOLLOWING NUMBERS ARE IN REGARDS TO WHAT PERCENT OF ACTIVE CELLS REPEAT IN PAIRWISE COMPARISONS');
disp(['Number of TT, SS and TS slices compared pairwise: ',num2str(sum(ttcount)),'  ',num2str(sum(sscount)),'  ',num2str(sum(tscount))]);
disp(['Mean Average Pairwise TT, SS and TS Repeats: ',num2str(mean(ttmeanpairo)),'  ',num2str(mean(ssmeanpairo)),'  ',num2str(mean(tsmeanpairo))])
disp(['SD of Average Pairwise TT, SS and TS Repeats: ',num2str(std(ttmeanpairo)),'  ',num2str(std(ssmeanpairo)),'  ',num2str(std(tsmeanpairo))])
disp(['Mean SD Pairwise TT, SS and TS Repeats: ',num2str(mean(ttsdpairo)),'  ',num2str(mean(sssdpairo)),'  ',num2str(mean(tssdpairo))])
disp(['SD of SD Pairwise TT, SS and TS Repeats: ',num2str(std(ttsdpairo)),'  ',num2str(std(sssdpairo)),'  ',num2str(std(tssdpairo))])
[h,p]=ttest2(ttmeanpairo,ssmeanpairo);
disp(['P value of TT to SS means 2 tailed T-test: ',num2str(p)]);
[h,p]=ttest2(ttmeanpairo,tsmeanpairo);
disp(['P value of TT to TS means 2 tailed T-test: ',num2str(p)]);
[h,p]=ttest2(ssmeanpairo,tsmeanpairo);
disp(['P value of SS to TS means 2 tailed T-test: ',num2str(p)]);

[h,p]=ttest2(ttsdpairo,sssdpairo);
disp(['P value of TT to SS sds 2 tailed T-test: ',num2str(p)]);
[h,p]=ttest2(ttsdpairo,tssdpairo);
disp(['P value of TT to TS sds 2 tailed T-test: ',num2str(p)]);
[h,p]=ttest2(sssdpairo,tssdpairo);
disp(['P value of SS to TS sds 2 tailed T-test: ',num2str(p)]);