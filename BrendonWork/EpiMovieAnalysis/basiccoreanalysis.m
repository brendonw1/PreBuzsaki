function basiccoreanalysis(sorted,goodperslice,corethresh);

% goodperslice=2;

coresorted=coresortedts(sorted,goodperslice,corethresh);


warning off MATLAB:conversionToLogical
warning off MATLAB:divideByZero

goodtstrain=zeros(size(coresorted,2),1);
goodspont=zeros(size(coresorted,2),1);

for c=1:size(coresorted,2);%for each slice
    if ~isempty(coresorted{c}.tstrain)%j;%if there were tstrain movies for this slice, then...
        slicecolltstrain{c}=zeros(1,length(coresorted{c}.contours));%establish matrix
        for d=1:size(coresorted{c}.tstrain,2)
            colltstrain{c}(d,:)=sum(coresorted{c}.tstrain(d).ons,1);%collapse data from all frames into a single chunk of data
            colltstrain{c}=logical(colltstrain{c});%a cell that is on in a movie=1 (not more if it is on multiple times)
            slicecolltstrain{c}=colltstrain{c}(d,:)+slicecolltstrain{c};%collapse all cells on from the tstrain movies for a slice
            if sum(colltstrain{c}(d,:),2)>=10;%if total number of cells on in this movie is greater than 10:
                goodtstrain(c,d)=1;%record that this movie was big enough... in this form for easy measuring of size
            end
        end
    end
    if ~isempty(coresorted{c}.spont)%j;%if there were tstrain movies for this slice, then...
        slicecollspont{c}=zeros(1,length(coresorted{c}.contours));
        for d=1:size(coresorted{c}.spont,2)
            collspont{c}(d,:)=sum(coresorted{c}.spont(d).ons,1);%collapse data from all frames into a single chunk of data
            collspont{c}=logical(collspont{c});%a cell that is on in a movie=1 (not more if it is on multiple times)
            slicecollspont{c}=collspont{c}(d,:)+slicecollspont{c};%collapse all cells on from the tstrain movies for a slice
            if sum(collspont{c}(d,:),2)>=10;%if total number of cells on in this movie is greater than 5:
                goodspont(c,d)=1;%record that this movie was big enough... in this form for easy measuring of size
            end
        end
    end
end

% for a=1:size(coresorted,2);%for each slice... we'll make numbers of movies the same for both spont and stim in each slice
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
tcorecells=cell(size(coresorted,2),1);
scorecells=cell(size(coresorted,2),1);
tscorecells=cell(size(coresorted,2),1);
tactcells=cell(size(coresorted,2),1);
sactcells=cell(size(coresorted,2),1);
tsgood=zeros(1,size(coresorted,2));
tm3all(size(coresorted,2),10)=0;
sm3all(size(coresorted,2),10)=0;
tm2all(size(coresorted,2),10)=0;
sm2all(size(coresorted,2),10)=0;
tm1all(size(coresorted,2),10)=0;
sm1all(size(coresorted,2),10)=0;
tmaxall(size(coresorted,2),10)=0;
smaxall(size(coresorted,2),10)=0;
tp1all(size(coresorted,2),10)=0;
sp1all(size(coresorted,2),10)=0;
tp2all(size(coresorted,2),10)=0;
sp2all(size(coresorted,2),10)=0;
tp3all(size(coresorted,2),10)=0;
sp3all(size(coresorted,2),10)=0;
tm3core(size(coresorted,2),10)=0;
sm3core(size(coresorted,2),10)=0;
tm2core(size(coresorted,2),10)=0;
sm2core(size(coresorted,2),10)=0;
tm1core(size(coresorted,2),10)=0;
sm1core(size(coresorted,2),10)=0;
tmaxcore(size(coresorted,2),10)=0;
smaxcore(size(coresorted,2),10)=0;
tp1core(size(coresorted,2),10)=0;
sp1core(size(coresorted,2),10)=0;
tp2core(size(coresorted,2),10)=0;
sp2core(size(coresorted,2),10)=0;
tp3core(size(coresorted,2),10)=0;
sp3core(size(coresorted,2),10)=0;
tm3other(size(coresorted,2),10)=0;
sm3other(size(coresorted,2),10)=0;
tm2other(size(coresorted,2),10)=0;
sm2other(size(coresorted,2),10)=0;
tm1other(size(coresorted,2),10)=0;
sm1other(size(coresorted,2),10)=0;
tmaxother(size(coresorted,2),10)=0;
smaxother(size(coresorted,2),10)=0;
tp1other(size(coresorted,2),10)=0;
sp1other(size(coresorted,2),10)=0;
tp2other(size(coresorted,2),10)=0;
sp2other(size(coresorted,2),10)=0;
tp3other(size(coresorted,2),10)=0;
sp3other(size(coresorted,2),10)=0;
tmaxall(size(coresorted,2),10)=0;
tmaxcore(size(coresorted,2),10)=0;
tmaxother(size(coresorted,2),10)=0;
smaxall(size(coresorted,2),10)=0;
smaxcore(size(coresorted,2),10)=0;
smaxother(size(coresorted,2),10)=0;
ttotalall(size(coresorted,2),10)=0;
ttotalcore(size(coresorted,2),10)=0;
ttotalother(size(coresorted,2),10)=0;
stotalall(size(coresorted,2),10)=0;
stotalcore(size(coresorted,2),10)=0;
stotalother(size(coresorted,2),10)=0;
tonsall(size(coresorted,2),10)=0;
tonscore(size(coresorted,2),10)=0;
tonsother(size(coresorted,2),10)=0;
sonsall(size(coresorted,2),10)=0;
sonscore(size(coresorted,2),10)=0;
sonsother(size(coresorted,2),10)=0;
tm3use(size(coresorted,2),10)=0;
tm2use(size(coresorted,2),10)=0;
tm1use(size(coresorted,2),10)=0;
tmaxuse(size(coresorted,2),10)=0;
tp1use(size(coresorted,2),10)=0;
tp2use(size(coresorted,2),10)=0;
tp3use(size(coresorted,2),10)=0;
sm3use(size(coresorted,2),10)=0;
sm2use(size(coresorted,2),10)=0;
sm1use(size(coresorted,2),10)=0;
smaxuse(size(coresorted,2),10)=0;
sp1use(size(coresorted,2),10)=0;
sp2use(size(coresorted,2),10)=0;
sp3use(size(coresorted,2),10)=0;

for a=1:size(coresorted,2);%for each slice
    if sum(goodtstrain(a,:),2)>=goodperslice;%if there is more than one movie with more than 10 cells coming on from slice "a"
        tcorecells{a}=[];
        tactcells{a}=[];
        goodtrainslice=find(goodtstrain(a,:));%gives dim2 coords of good movies
        for b=1:size(goodtrainslice,2)%for each good tstrain movie
            [trash,maxfr]=max(sum(coresorted{a}.tstrain(goodtrainslice(b)).ons,2));
            if maxfr>3;
                m3=maxfr-3;
                tm3all(a,b)=sum(coresorted{a}.tstrain(goodtrainslice(b)).ons(m3,:));
                tm3core(a,b)=sum(coresorted{a}.ttcore{b}(m3,:));
                tm3other(a,b)=sum(coresorted{a}.ttother{b}(m3,:));
                tm3use(a,b)=1;
            end
            if maxfr>2;
                m2=maxfr-2;
                tm2all(a,b)=sum(coresorted{a}.tstrain(goodtrainslice(b)).ons(m2,:));
                tm2core(a,b)=sum(coresorted{a}.ttcore{b}(m2,:));
                tm2other(a,b)=sum(coresorted{a}.ttother{b}(m2,:));
                tm2use(a,b)=1;
            end
            if maxfr>1;
                m1=maxfr-1;
                tm1all(a,b)=sum(coresorted{a}.tstrain(goodtrainslice(b)).ons(m1,:));
                tm1core(a,b)=sum(coresorted{a}.ttcore{b}(m1,:));
                tm1other(a,b)=sum(coresorted{a}.ttother{b}(m1,:));
                tm1use(a,b)=1;
            end
            if maxfr<size(coresorted{a}.tstrain(goodtrainslice(b)).ons,1)-0;
                p1=maxfr+1;
                tp1all(a,b)=sum(coresorted{a}.tstrain(goodtrainslice(b)).ons(p1,:));
                tp1core(a,b)=sum(coresorted{a}.ttcore{b}(p1,:));
                tp1other(a,b)=sum(coresorted{a}.ttother{b}(p1,:));
                tp1use(a,b)=1;
            end
            if maxfr<size(coresorted{a}.tstrain(goodtrainslice(b)).ons,1)-1;
                p2=maxfr+2;
                tp2all(a,b)=sum(coresorted{a}.tstrain(goodtrainslice(b)).ons(p2,:));
                tp2core(a,b)=sum(coresorted{a}.ttcore{b}(p2,:));
                tp2other(a,b)=sum(coresorted{a}.ttother{b}(p2,:));
                tp2use(a,b)=1;
            end
            if maxfr<size(coresorted{a}.tstrain(goodtrainslice(b)).ons,1)-2;
                p3=maxfr+3;
                tp3all(a,b)=sum(coresorted{a}.tstrain(goodtrainslice(b)).ons(p3,:));
                tp3core(a,b)=sum(coresorted{a}.ttcore{b}(p3,:));
                tp3other(a,b)=sum(coresorted{a}.ttother{b}(p3,:));
                tp3use(a,b)=1;
            end            
            tmaxall(a,b)=sum(coresorted{a}.tstrain(goodtrainslice(b)).ons(maxfr,:));
            tmaxcore(a,b)=sum(coresorted{a}.ttcore{b}(maxfr,:));
            tmaxother(a,b)=sum(coresorted{a}.ttother{b}(maxfr,:));
            ttotalall(a,b)=sum(logical(sum(coresorted{a}.tstrain(goodtrainslice(b)).ons)));
            ttotalcore(a,b)=sum(logical(sum(coresorted{a}.ttcore{b})));
            ttotalother(a,b)=sum(logical(sum(coresorted{a}.ttother{b})));
            tonsall(a,b)=sum(sum(coresorted{a}.tstrain(goodtrainslice(b)).ons));
            tonscore(a,b)=sum(sum(coresorted{a}.ttcore{b}));
            tonsother(a,b)=sum(sum(coresorted{a}.ttother{b}));
            tcorecells{a}=cat(2,tcorecells{a},find(sum(coresorted{a}.ttcore{b})));
            tactcells{a}=cat(2,tactcells{a},find(sum(coresorted{a}.tstrain(goodtrainslice(b)).ons)));
        end 
        tcorecells{a}=unique(tcorecells{a});
        tactcells{a}=unique(tactcells{a});
    end
    if sum(goodspont(a,:),2)>=goodperslice;%if there is more than one movie with more than 10 cells coming on from slice "a"
        scorecells{a}=[];
        sactcells{a}=[];
        goodspontslice=find(goodspont(a,:));%gives dim2 coords of good movies
        for b=1:size(goodspontslice,2)%for each good spont movie
            [trash,maxfr]=max(sum(coresorted{a}.spont(goodspontslice(b)).ons,2));
            if maxfr>3;
                m3=maxfr-3;
                sm3all(a,b)=sum(coresorted{a}.spont(goodspontslice(b)).ons(m3,:));
                sm3core(a,b)=sum(coresorted{a}.sscore{b}(m3,:));
                sm3other(a,b)=sum(coresorted{a}.ssother{b}(m3,:));
                sm3use(a,b)=1;
            end
            if maxfr>2;
                m2=maxfr-2;
                sm2all(a,b)=sum(coresorted{a}.spont(goodspontslice(b)).ons(m2,:));
                sm2core(a,b)=sum(coresorted{a}.sscore{b}(m2,:));
                sm2other(a,b)=sum(coresorted{a}.ssother{b}(m2,:));
                sm2use(a,b)=1;
            end
            if maxfr>1;
                m1=maxfr-1;
                sm1all(a,b)=sum(coresorted{a}.spont(goodspontslice(b)).ons(m1,:));
                sm1core(a,b)=sum(coresorted{a}.sscore{b}(m1,:));
                sm1other(a,b)=sum(coresorted{a}.ssother{b}(m1,:));
                sm1use(a,b)=1;
            end
            if maxfr<size(coresorted{a}.spont(goodspontslice(b)).ons,1)-0;
                p1=maxfr+1;
                sp1all(a,b)=sum(coresorted{a}.spont(goodspontslice(b)).ons(p1,:));
                sp1core(a,b)=sum(coresorted{a}.sscore{b}(p1,:));
                sp1other(a,b)=sum(coresorted{a}.ssother{b}(p1,:));
                sp1use(a,b)=1;
            end
            if maxfr<size(coresorted{a}.spont(goodspontslice(b)).ons,1)-1;
                p2=maxfr+2;
                sp2all(a,b)=sum(coresorted{a}.spont(goodspontslice(b)).ons(p2,:));
                sp2core(a,b)=sum(coresorted{a}.sscore{b}(p2,:));
                sp2other(a,b)=sum(coresorted{a}.ssother{b}(p2,:));
                sp2use(a,b)=1;
            end
            if maxfr<size(coresorted{a}.spont(goodspontslice(b)).ons,1)-2;
                p3=maxfr+3;
                sp3all(a,b)=sum(coresorted{a}.spont(goodspontslice(b)).ons(p3,:));
                sp3core(a,b)=sum(coresorted{a}.sscore{b}(p3,:));
                sp3other(a,b)=sum(coresorted{a}.ssother{b}(p3,:));
                sp3use(a,b)=1;
            end            
            smaxall(a,b)=sum(coresorted{a}.spont(goodspontslice(b)).ons(maxfr,:));
            smaxcore(a,b)=sum(coresorted{a}.sscore{b}(maxfr,:));
            smaxother(a,b)=sum(coresorted{a}.ssother{b}(maxfr,:));
            stotalall(a,b)=sum(logical(sum(coresorted{a}.spont(goodspontslice(b)).ons)));%total cells that came on
            stotalcore(a,b)=sum(logical(sum(coresorted{a}.sscore{b})));%total core cells
            stotalother(a,b)=sum(logical(sum(coresorted{a}.ssother{b})));%total other cells
            sonsall(a,b)=sum(sum(coresorted{a}.spont(goodspontslice(b)).ons));%total times any cell came on
            sonscore(a,b)=sum(sum(coresorted{a}.sscore{b}));%total times any core cell came on
            sonsother(a,b)=sum(sum(coresorted{a}.ssother{b}));%total times any other cell came on
            scorecells{a}=cat(2,scorecells{a},find(sum(coresorted{a}.sscore{b})));
            sactcells{a}=cat(2,sactcells{a},find(sum(coresorted{a}.spont(goodspontslice(b)).ons)));
        end 
        scorecells{a}=unique(scorecells{a});
        sactcells{a}=unique(sactcells{a});
    end    
    if isfield(coresorted{a},'tscorecells')
        if iscell(coresorted{a}.tscorecells)
            if ~isempty(coresorted{a}.tscorecells{1})
                if sum(goodspont(a,:),2)>=1 sum(goodtstrain(a,:),2)>=1;%if there is more than one movie with more than 10 cells coming on from slice "a"
                    tscorecells{a}=[];
                    tsactcells{a}=[];
                    ttsactcells{a}=[];
                    stsactcells{a}=[];
                    goodspontslice=find(goodspont(a,:));%gives dim2 coords of good movies
                    goodtstrainslice=find(goodtstrain(a,:));
                    for b=1:size(goodspontslice,2)%for each good spont movie
%                         tsactcells{a}=cat(2,tsactcells{a},find(sum(coresorted{a}.spont(b).ons,1)));
                        stsactcells{a}=cat(2,stsactcells{a},find(sum(coresorted{a}.spont(goodspontslice(b)).ons,1)));
                    end
                    for c=1:size(goodtstrainslice,2)%for each good tstrain movie
%                         tsactcells{a}=cat(2,tsactcells{a},find(sum(coresorted{a}.tstrain(c).ons,1)));
                        ttsactcells{a}=cat(2,ttsactcells{a},find(sum(coresorted{a}.tstrain(goodtstrainslice(c)).ons,1)));
                    end
                    tscorecells{a}=coresorted{a}.tscorecells{1};
%                     tsactcells{a}=unique(tsactcells{a});
                    ttsactcells{a}=unique(ttsactcells{a});
                    stsactcells{a}=unique(stsactcells{a});
                    spercactintscore(a)=length(tscorecells{a})/length(stsactcells{a});
                    tpercactintscore(a)=length(tscorecells{a})/length(ttsactcells{a});
                    tsgood(a)=1;
                end
            end
        end    
    end
end
for a=1:size(coresorted,2);
	tcorenum(a)=length(tcorecells{a});
	tactnum(a)=length(tactcells{a});
	scorenum(a)=length(scorecells{a});
	sactnum(a)=length(sactcells{a});
    tscorenum(a)=length(tscorecells{a});
end

a=sum(tcorenum)./sum(tactnum);
b=sum(scorenum)./sum(sactnum);
disp(['Percent of total cells active in each slice that are core in Trig, Spont: ',num2str(100*a),'  ',num2str(100*b)]);

disp(['-------------']);

a=tcorenum./tactnum;
b=scorenum./sactnum;
a=a(~isnan(a));
b=b(~isnan(b));
disp(['Mean of slice percent of cells active in each slice that are core in Trig, Spont: ',num2str(100*mean(a)),'  ',num2str(100*mean(b))]);
disp(['SD of slice percent of cells active in each slice that are core in Trig, Spont: ',num2str(100*std(a)),'  ',num2str(100*std(b))]);
[h,p]=ttest2(a,b);
disp(['p value of this difference = ',num2str(p)]);
disp(['-------------']);

a=sum(sum(ttotalcore))/sum(sum(ttotalall));
b=sum(sum(stotalcore))/sum(sum(stotalall));
disp(['Percent of total cells active that are core in Trig, Spont: ',num2str(100*a),'  ',num2str(100*b)]);

a=sum(sum(tonscore))/sum(sum(tonsall));
b=sum(sum(sonscore))/sum(sum(sonsall));
disp(['Percent of all activity that are core in Trig, Spont: ',num2str(100*a),'  ',num2str(100*b)]);
disp(['-------------']);

a=ttotalcore./ttotalall;
b=stotalcore./stotalall;
a=a(~isnan(a));
b=b(~isnan(b));
disp(['Average percent of cells active in each movie that are core in Trig, Spont: ',num2str(100*mean(a)),'  ',num2str(100*mean(b))]);
disp(['SD of percent of cells active in each movie that are core in Trig, Spont: ',num2str(100*std(a)),'  ',num2str(100*std(b))]);
[h,p]=ttest2(a,b);
disp(['p value of this difference = ',num2str(p)]);
% disp(['Range for Trig, Spont: ',num2str(100*min(a)),' - ',num2str(100*max(a)),' ',num2str(100*min(b)),' - ',num2str(100*max(b))]);

a=tonscore./tonsall;
b=sonscore./sonsall;
a=a(~isnan(a));
b=b(~isnan(b));
disp(['Average percent of all activity per movie that is core in Trig, Spont: ',num2str(100*mean(a)),'  ',num2str(100*mean(b))]);
disp(['SD of percent of all activity per movie that is core in Trig, Spont: ',num2str(100*std(a)),'  ',num2str(100*std(b))]);
[h,p]=ttest2(a,b);
disp(['p value of this difference = ',num2str(p)]);
% disp(['Range for Trig, Spont: ',num2str(100*min(a)),' - ',num2str(100*max(a)),' ',num2str(100*min(b)),' - ',num2str(100*max(b))]);
disp(['-------------']);

disp(['Average percent of Trig cells that are part of the Trig+Spont core: ',num2str(100*mean(tpercactintscore(find(tpercactintscore))))]);
disp(['SD percent of Trig cells that are part of the Trig+Spont core: ',num2str(100*std(tpercactintscore(find(tpercactintscore))))]);
disp(['Average percent of Spont cells that are part of the Trig+Spont core: ',num2str(100*mean(spercactintscore(find(spercactintscore))))]);
disp(['SD percent of Spont cells that are part of the Trig+Spont core: ',num2str(100*std(spercactintscore(find(spercactintscore))))]);
disp(['-------------']);

a=tscorenum./tcorenum;
a(~tsgood)=nan;
a(~tcorenum)=nan;
b=tscorenum./scorenum;
b(~tsgood)=nan;
b(~scorenum)=nan;
a=a(~isnan(a));
b=b(~isnan(b));
disp(['Average percent of Trig core cells that are part of the Trig+Spont core: ',num2str(100*mean(a))])
disp(['Average SD of Trig core cells that are part of the Trig+Spont core: ',num2str(100*std(a))])
disp(['Average percent of Spont core cells that are part of the Trig+Spont core: ',num2str(100*mean(b))])
disp(['Average SD of Spont core cells that are part of the Trig+Spont core: ',num2str(100*std(b))])
disp(['-------------']);
disp(['-------------']);

a=tm3all./tonsall;
b=sm3all./sonsall;
a=a(find(tm3use));
b=b(find(sm3use));
disp(['Average percent of cells active per movie that are in Max-3 frame in Trig, Spont: ',num2str(100*mean(a)),'  ',num2str(100*mean(b))]);
disp(['SD of percent of cells active per movie that are in Max-3 frame in Trig, Spont: ',num2str(100*std(a)),'  ',num2str(100*std(b))]);
[h,p]=ttest2(a,b);
disp(['p value of this difference = ',num2str(p)]);
disp(['Total movies with Max-3 frame in Trig, Spont: ',num2str(sum(sum(tm3use))),' ',num2str(sum(sum(sm3use)))]);

a=tm2all./tonsall;
b=sm2all./sonsall;
a=a(find(tm2use));
b=b(find(sm2use));
disp(['Average percent of cells active per movie that are in Max-2 frame in Trig, Spont: ',num2str(100*mean(a)),'  ',num2str(100*mean(b))]);
disp(['SD of percent of cells active per movie that are in Max-2 frame in Trig, Spont: ',num2str(100*std(a)),'  ',num2str(100*std(b))]);
[h,p]=ttest2(a,b);
disp(['p value of this difference = ',num2str(p)]);
disp(['Total movies with Max-3 frame in Trig, Spont: ',num2str(sum(sum(tm3use))),' ',num2str(sum(sum(sm3use)))]);

a=tm1all./tonsall;
b=sm1all./sonsall;
a=a(find(tm1use));
b=b(find(sm1use));
disp(['Average percent of cells active per movie that are in Max-1 frame in Trig, Spont: ',num2str(100*mean(a)),'  ',num2str(100*mean(b))]);
disp(['SD of percent of cells active per movie that are in Max-1 frame in Trig, Spont: ',num2str(100*std(a)),'  ',num2str(100*std(b))]);
[h,p]=ttest2(a,b);
disp(['p value of this difference = ',num2str(p)]);
disp(['Total movies with Max-2 frame in Trig, Spont: ',num2str(sum(sum(tm2use))),' ',num2str(sum(sum(sm2use)))]);

a=tmaxall./tonsall;
b=smaxall./sonsall;
a=a(find(tonsall));
b=b(find(sonsall));
disp(['Average percent of cells active per movie that are in Max frame in Trig, Spont: ',num2str(100*mean(a)),'  ',num2str(100*mean(b))]);
disp(['SD of percent of cells active per movie that are in Max frame in Trig, Spont: ',num2str(100*std(a)),'  ',num2str(100*std(b))]);
[h,p]=ttest2(a,b);
disp(['p value of this difference = ',num2str(p)]);
disp(['Total movies with Max-1 frame in Trig, Spont: ',num2str(sum(sum(tm1use))),' ',num2str(sum(sum(sm1use)))]);

a=tp1all./tonsall;
b=sp1all./sonsall;
a=a(find(tp1use));
b=b(find(sp1use));
disp(['Average percent of cells active per movie that are in Max+1 frame in Trig, Spont: ',num2str(100*mean(a)),'  ',num2str(100*mean(b))]);
disp(['SD of percent of cells active per movie that are in Max+1 frame in Trig, Spont: ',num2str(100*std(a)),'  ',num2str(100*std(b))]);
[h,p]=ttest2(a,b);
disp(['p value of this difference = ',num2str(p)]);
disp(['Total movies with Max+1 frame in Trig, Spont: ',num2str(sum(sum(tp1use))),' ',num2str(sum(sum(sp1use)))]);

a=tp2all./tonsall;
b=sp2all./sonsall;
a=a(find(tp2use));
b=b(find(sp2use));
disp(['Average percent of cells active per movie that are in Max+2 frame in Trig, Spont: ',num2str(100*mean(a)),'  ',num2str(100*mean(b))]);
disp(['SD of percent of cells active per movie that are in Max+2 frame in Trig, Spont: ',num2str(100*std(a)),'  ',num2str(100*std(b))]);
[h,p]=ttest2(a,b);
disp(['p value of this difference = ',num2str(p)]);
disp(['Total movies with Max+2 frame in Trig, Spont: ',num2str(sum(sum(tp2use))),' ',num2str(sum(sum(sp2use)))]);

a=tp3all./tonsall;
b=sp3all./sonsall;
a=a(find(tp3use));
b=b(find(sp3use));
disp(['Average percent of cells active per movie that are in Max+3 frame in Trig, Spont: ',num2str(100*mean(a)),'  ',num2str(100*mean(b))]);
disp(['SD of percent of cells active per movie that are in Max+3 frame in Trig, Spont: ',num2str(100*std(a)),'  ',num2str(100*std(b))]);
[h,p]=ttest2(a,b);
disp(['p value of this difference = ',num2str(p)]);
disp(['Total movies with Max+3 frame in Trig, Spont: ',num2str(sum(sum(tp3use))),' ',num2str(sum(sum(sp3use)))]);
disp(['-------------']);
disp(['-------------']);


a=tm3core./tonscore;
b=sm3core./sonscore;
a=a(find(tm3use));
b=b(find(sm3use));
a=a(~isnan(a));
b=b(~isnan(b));
disp(['Average percent of core cells per movie that are in Max-3 frame in Trig, Spont: ',num2str(100*mean(a)),'  ',num2str(100*mean(b))]);
disp(['SD of percent of cells active per movie that are in Max-3 frame in Trig, Spont: ',num2str(100*std(a)),'  ',num2str(100*std(b))]);
[h,p]=ttest2(a,b);
disp(['p value of this difference = ',num2str(p)]);
disp(['Total movies with Max-3 frame in Trig, Spont: ',num2str(length(a)),' ',num2str(length(b))]);

a=tm2core./tonscore;
b=sm2core./sonscore;
a=a(find(tm2use));
b=b(find(sm2use));
a=a(~isnan(a));
b=b(~isnan(b));
disp(['Average percent of core cells per movie that are in Max-2 frame in Trig, Spont: ',num2str(100*mean(a)),'  ',num2str(100*mean(b))]);
disp(['SD of percent of cells active per movie that are in Max-2 frame in Trig, Spont: ',num2str(100*std(a)),'  ',num2str(100*std(b))]);
[h,p]=ttest2(a,b);
disp(['p value of this difference = ',num2str(p)]);
disp(['Total movies with Max-2 frame in Trig, Spont: ',num2str(length(a)),' ',num2str(length(b))]);

a=tm1core./tonscore;
b=sm1core./sonscore;
a=a(find(tm1use));
b=b(find(sm1use));
a=a(~isnan(a));
b=b(~isnan(b));
disp(['Average percent of core cells per movie that are in Max-1 frame in Trig, Spont: ',num2str(100*mean(a)),'  ',num2str(100*mean(b))]);
disp(['SD of percent of cells active per movie that are in Max-1 frame in Trig, Spont: ',num2str(100*std(a)),'  ',num2str(100*std(b))]);
[h,p]=ttest2(a,b);
disp(['p value of this difference = ',num2str(p)]);
disp(['Total movies with Max-1 frame in Trig, Spont: ',num2str(length(a)),' ',num2str(length(b))]);

a=tmaxcore./tonscore;
b=smaxcore./sonscore;
a=a(find(tonscore));
b=b(find(sonscore));
a=a(~isnan(a));
b=b(~isnan(b));
disp(['Average percent of core cells per movie that are in Max frame in Trig, Spont: ',num2str(100*mean(a)),'  ',num2str(100*mean(b))]);
disp(['SD of percent of cells active per movie that are in Max frame in Trig, Spont: ',num2str(100*std(a)),'  ',num2str(100*std(b))]);
[h,p]=ttest2(a,b);
disp(['p value of this difference = ',num2str(p)]);
disp(['Total movies with Max frame in Trig, Spont: ',num2str(length(a)),' ',num2str(length(b))]);

a=tp1core./tonscore;
b=sp1core./sonscore;
a=a(find(tp1use));
b=b(find(sp1use));
a=a(~isnan(a));
b=b(~isnan(b));
disp(['Average percent of core cells per movie that are in Max+1 frame in Trig, Spont: ',num2str(100*mean(a)),'  ',num2str(100*mean(b))]);
disp(['SD of percent of cells active per movie that are in Max+1 frame in Trig, Spont: ',num2str(100*std(a)),'  ',num2str(100*std(b))]);
[h,p]=ttest2(a,b);
disp(['p value of this difference = ',num2str(p)]);
disp(['Total movies with Max+1 frame in Trig, Spont: ',num2str(length(a)),' ',num2str(length(b))]);

a=tp2core./tonscore;
b=sp2core./sonscore;
a=a(find(tp2use));
b=b(find(sp2use));
a=a(~isnan(a));
b=b(~isnan(b));
disp(['Average percent of core cells per movie that are in Max+2 frame in Trig, Spont: ',num2str(100*mean(a)),'  ',num2str(100*mean(b))]);
disp(['SD of percent of cells active per movie that are in Max+2 frame in Trig, Spont: ',num2str(100*std(a)),'  ',num2str(100*std(b))]);
[h,p]=ttest2(a,b);
disp(['p value of this difference = ',num2str(p)]);
disp(['Total movies with Max+1 frame in Trig, Spont: ',num2str(length(a)),' ',num2str(length(b))]);

a=tp3core./tonscore;
b=sp3core./sonscore;
a=a(find(tp3use));
b=b(find(sp3use));
a=a(~isnan(a));
b=b(~isnan(b));
disp(['Average percent of core cells per movie that are in Max+3 frame in Trig, Spont: ',num2str(100*mean(a)),'  ',num2str(100*mean(b))]);
disp(['SD of percent of cells active per movie that are in Max+3 frame in Trig, Spont: ',num2str(100*std(a)),'  ',num2str(100*std(b))]);
[h,p]=ttest2(a,b);
disp(['p value of this difference = ',num2str(p)]);
disp(['Total movies with Max+3 frame in Trig, Spont: ',num2str(length(a)),' ',num2str(length(b))]);
disp(['-------------']);
disp(['-------------']);
% 
% 
% a=(tm3core./tonscore)./(tm3all./tonsall);
% b=(sm3core./sonscore)./(sm3all./sonsall);
% a=a(find(tm3use));
% b=b(find(sm3use));
% a=a(~isnan(a));
% b=b(~isnan(b));
% a(find(a==0))=.000001;
% b(find(b==0))=.000001;
% a=log(a);
% b=log(b);
% disp(['Average percent of core cells per movie that are in Max-3 frame in Trig, Spont: ',num2str(exp(mean(a))),'  ',num2str(exp(mean(b)))]);
% disp(['SD of percent of cells active per movie that are in Max-3 frame in Trig, Spont: ',num2str(exp(std(a))),'  ',num2str(exp(std(b)))]);
% [h,p]=ttest2(a,b);
% disp(['p value of this difference = ',num2str(p)]);
% disp(['Total movies with Max-3 frame in Trig, Spont: ',num2str(length(a)),' ',num2str(length(b))]);
% 
% a=(tm2core./tonscore)./(tm2all./tonsall);
% b=(sm2core./sonscore)./(sm2all./sonsall);
% a=a(find(tm2use));
% b=b(find(sm2use));
% a=a(~isnan(a));
% b=b(~isnan(b));
% a(find(a==0))=.000001;
% b(find(b==0))=.000001;
% a=log(a);
% b=log(b);
% disp(['Average percent of core cells per movie that are in Max-2 frame in Trig, Spont: ',num2str(exp(mean(a))),'  ',num2str(exp(mean(b)))]);
% disp(['SD of percent of cells active per movie that are in Max-2 frame in Trig, Spont: ',num2str(exp(std(a))),'  ',num2str(exp(std(b)))]);
% [h,p]=ttest2(a,b);
% disp(['p value of this difference = ',num2str(p)]);
% disp(['Total movies with Max-2 frame in Trig, Spont: ',num2str(length(a)),' ',num2str(length(b))]);
% 
% a=(tm1core./tonscore)./(tm1all./tonsall);
% b=(sm1core./sonscore)./(sm1all./sonsall);
% a=a(find(tm1use));
% b=b(find(sm1use));
% a=a(~isnan(a));
% b=b(~isnan(b));
% a(find(a==0))=.000001;
% b(find(b==0))=.000001;
% a=log(a);
% b=log(b);
% disp(['Average percent of core cells per movie that are in Max-1 frame in Trig, Spont: ',num2str(exp(mean(a))),'  ',num2str(exp(mean(b)))]);
% disp(['SD of percent of cells active per movie that are in Max-1 frame in Trig, Spont: ',num2str(exp(std(a))),'  ',num2str(exp(std(b)))]);
% [h,p]=ttest2(a,b);
% disp(['p value of this difference = ',num2str(p)]);
% disp(['Total movies with Max-1 frame in Trig, Spont: ',num2str(length(a)),' ',num2str(length(b))]);
% 
% a=(tmaxcore./tonscore)./(tmaxall./tonsall);
% b=(smaxcore./sonscore)./(smaxall./sonsall);
% a=a(find(tonscore));
% b=b(find(sonscore));
% a=a(~isnan(a));
% b=b(~isnan(b));
% a(find(a==0))=.000001;
% b(find(b==0))=.000001;
% a=log(a);
% b=log(b);
% disp(['Average percent of core cells per movie that are in Max frame in Trig, Spont: ',num2str(exp(mean(a))),'  ',num2str(exp(mean(b)))]);
% disp(['SD of percent of cells active per movie that are in Max frame in Trig, Spont: ',num2str(exp(std(a))),'  ',num2str(exp(std(b)))]);
% [h,p]=ttest2(a,b);
% disp(['p value of this difference = ',num2str(p)]);
% disp(['Total movies with Max frame in Trig, Spont: ',num2str(length(a)),' ',num2str(length(b))]);
% 
% a=(tp1core./tonscore)./(tp1all./tonsall);
% b=(sp1core./sonscore)./(sp1all./sonsall);
% a=a(find(tp1use));
% b=b(find(sp1use));
% a=a(~isnan(a));
% b=b(~isnan(b));
% a(find(a==0))=.000001;
% b(find(b==0))=.000001;
% a=log(a);
% b=log(b);
% disp(['Average percent of core cells per movie that are in Max+1 frame in Trig, Spont: ',num2str(exp(mean(a))),'  ',num2str(exp(mean(b)))]);
% disp(['SD of percent of cells active per movie that are in Max+1 frame in Trig, Spont: ',num2str(exp(std(a))),'  ',num2str(exp(std(b)))]);
% [h,p]=ttest2(a,b);
% disp(['p value of this difference = ',num2str(p)]);
% disp(['Total movies with Max+1 frame in Trig, Spont: ',num2str(length(a)),' ',num2str(length(b))]);
% 
% a=(tp2core./tonscore)./(tp2all./tonsall);
% b=(sp2core./sonscore)./(sp2all./sonsall);
% a=a(find(tp2use));
% b=b(find(sp2use));
% a=a(~isnan(a));
% b=b(~isnan(b));
% a(find(a==0))=.000001;
% b(find(b==0))=.000001;
% a=log(a);
% b=log(b);
% disp(['Average percent of core cells per movie that are in Max+2 frame in Trig, Spont: ',num2str(exp(mean(a))),'  ',num2str(exp(mean(b)))]);
% disp(['SD of percent of cells active per movie that are in Max+2 frame in Trig, Spont: ',num2str(exp(std(a))),'  ',num2str(exp(std(b)))]);
% [h,p]=ttest2(a,b);
% disp(['p value of this difference = ',num2str(p)]);
% disp(['Total movies with Max+1 frame in Trig, Spont: ',num2str(length(a)),' ',num2str(length(b))]);
a=(sum(tmaxcore(find(tm3use)))./sum(tonscore(find(tm3use))))./(sum(tm3all(find(tm3use)))./sum(tonsall(find(tm3use))));
b=(sum(sm3core(find(sm3use)))./sum(sonscore(find(sm3use))))./(sum(sm3all(find(sm3use)))./sum(sonsall(find(sm3use))));
disp(['Relative representation of core in Max-3 relative to all cells for Trig, Spont: ',num2str(a),'  ',num2str(b)]);

a=(sum(tm2core(find(tm2use)))./sum(tonscore(find(tm2use))))./(sum(tm2all(find(tm2use)))./sum(tonsall(find(tm2use))));
b=(sum(sm2core(find(sm2use)))./sum(sonscore(find(sm2use))))./(sum(sm2all(find(sm2use)))./sum(sonsall(find(sm2use))));
disp(['Relative representation of core in Max-2 frame relative to all cells for Trig, Spont: ',num2str(a),'  ',num2str(b)]);

a=(sum(tm1core(find(tm1use)))./sum(tonscore(find(tm1use))))./(sum(tm1all(find(tm1use)))./sum(tonsall(find(tm1use))));
b=(sum(sm1core(find(sm1use)))./sum(sonscore(find(sm1use))))./(sum(sm1all(find(sm1use)))./sum(sonsall(find(sm1use))));
disp(['Relative representation of core in Max-1 frame relative to all cells for Trig, Spont: ',num2str(a),'  ',num2str(b)]);

a=(sum(tmaxcore(find(tonscore)))./sum(tonscore(find(tonscore))))./(sum(tmaxall(find(tonscore)))./sum(tonsall(find(tonscore))));
b=(sum(smaxcore(find(sonscore)))./sum(sonscore(find(sonscore))))./(sum(smaxall(find(sonscore)))./sum(sonsall(find(sonscore))));
disp(['Relative representation of core in Max frame relative to all cells for Trig, Spont: ',num2str(a),'  ',num2str(b)]);

a=(sum(tp1core(find(tp1use)))./sum(tonscore(find(tp1use))))./(sum(tp1all(find(tp1use)))./sum(tonsall(find(tp1use))));
b=(sum(sp1core(find(sp1use)))./sum(sonscore(find(sp1use))))./(sum(sp1all(find(sp1use)))./sum(sonsall(find(sp1use))));
disp(['Relative representation of core in Max+1 frame relative to all cells for Trig, Spont: ',num2str(a),'  ',num2str(b)]);

a=(sum(tp2core(find(tp2use)))./sum(tonscore(find(tp2use))))./(sum(tp2all(find(tp2use)))./sum(tonsall(find(tp2use))));
b=(sum(sp2core(find(sp2use)))./sum(sonscore(find(sp2use))))./(sum(sp2all(find(sp2use)))./sum(sonsall(find(sp2use))));
disp(['Relative representation of core in Max+2 frame relative to all cells for Trig, Spont: ',num2str(a),'  ',num2str(b)]);

a=(sum(tp3core(find(tp3use)))./sum(tonscore(find(tp3use))))./(sum(tp3all(find(tp3use)))./sum(tonsall(find(tp3use))));
b=(sum(sp3core(find(sp3use)))./sum(sonscore(find(sp3use))))./(sum(sp3all(find(sp3use)))./sum(sonsall(find(sp3use))));
disp(['Relative representation of core in Max+3 frame relative to all cells for Trig, Spont: ',num2str(a),'  ',num2str(b)]);
