function [sliceoverlaps]=pairwiseoverlaps2(sorted,goodperslice);
% function [ttoverlaps,ssoverlaps,tsoverlaps,sliceoverlaps]=pairwiseoverlaps(sorted);
% function [ttoverlaps,ssoverlaps,wwoverlaps,tsoverlaps,twoverlaps,swoverlaps,sliceoverlaps]=pairwiseoverlaps(sorted);
% function [ttoverlaps,ssoverlaps,tsoverlaps,meanslicerepeat]=findallrepeats(sorted,reshuffsorted);

% goodperslice=2;
cellspermovie=5;



warning off MATLAB:conversionToLogical
warning off MATLAB:divideByZero
% names={['tstrain'] ['tssingle'] ['spont'] ['wdsingle'] ['wdtrain']};
% goodnames={['goodt'] ['goodtss'] ['goods'] ['goodwds'] ['goodwdt']};
% suffixes={['t'] ['tss'] ['s'] ['wds'] ['wdt']};
goodt(size(sorted,2),1)=0;
goods(size(sorted,2),1)=0;
goode(size(sorted,2),1)=0;
goodw(size(sorted,2),1)=0;

names={['tstrain'] ['spont'] ['wdtrain']};
suffixes={['t'] ['s'] ['w']};
for n=1:length(names);
    name=names{n};
    goodname=['good',suffixes{n}];
    goodename=['goode',suffixes{n}];
    collname=['coll',suffixes{n}];
    collename=['colle',suffixes{n}];
	for y=1:size(sorted,2);%for each slice
        eval(['tf=~isempty(sorted{y}.',name,');'])
        if tf%j;%if there were tstrain movies for this slice, then...
            eval(['k=size(sorted{y}.',name,',2);'])
            for z=1:k
                echoframes=[];
                eval(['ctf=iscell(sorted{y}.',name,'(z).echo);'])
                if ctf
                    eval(['ctf=~isempty(sorted{y}.',name,'(z).echo{1});'])
                end
                if ctf
                    eval(['echoframes=sorted{y}.',name,'(z).echo{1};'])
                    cutoff=echoframes(1);
                else
                    eval(['cutoff=size(sorted{y}.',name,'(z).ons,1);'])
                end
                eval(['nonechoons=sorted{y}.',name,'(z).ons(1:cutoff,:);'])
                coll=logical(sum(nonechoons,1));%collapse data from all frames into a single chunk of data
                eval([collname,'{y}(z,:)=coll;'])
                if sum(coll,2)>=cellspermovie;%if total number of cells on in this movie is greater than cellspermovie:
                    eval([goodname,'(y,z)=1;'])%record that this movie was big enough... in this form for easy measuring of size
                end
                
                if ~isempty(echoframes);
                    eval(['echoons=sorted{y}.',name,'(z).ons(echoframes,:);'])
                    coll=logical(sum(echoons,1));%collapse data from all frames into a single chunk of data
                    eval([collename,'{y}(z,:)=coll;'])
                    colle{y}(z,:)=coll;
                    if sum(coll,2)>=cellspermovie;%if total number of cells on in this movie is greater than cellspermovie:
                        eval([goodename,'(y,z)=1;'])%record that this movie was big enough... in this form for easy measuring of size
                        goode(y,z)=1;
                    end
                end            
            end
        end
	end
end
for y=1:size(sorted,2);%for each slice
	for z=1:size(sorted{y}.tssingle,2)
		goodp(y,z)=sorted{y}.tssingle(z).plasticity;
		if goodp(y,z);
            collp{y}(z,:)=logical(sum(sorted{y}.tssingle(z).ons,1));
        end
    end
end

for a=1:size(sorted,2);%for each slice
    sliceoverlaps(a).tt=[];
    sliceoverlaps(a).ss=[];
    sliceoverlaps(a).ee=[];
    sliceoverlaps(a).pp=[];
    sliceoverlaps(a).ww=[];
    sliceoverlaps(a).ts=[];
    sliceoverlaps(a).te=[];
    sliceoverlaps(a).se=[];
	sliceoverlaps(a).tp=[];
	sliceoverlaps(a).sp=[];
%     sliceoverlaps(a).tw=[];
%     sliceoverlaps(a).sw=[];
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
    n=sum(goode(a,:),2);
    if n>=goodperslice;%if there is more than one movie with more than cellspermovie cells coming on from slice "a"
        g=find(goode(a,:));
        for b=1:length(g);%for each good movie 
            for c=b+1:length(g);%for each not yet compared movie
                eeoverlaps{a,g(b),g(c)}=colle{a}(g(b),:).*colle{a}(g(c),:);%find best repeats between those two
                denom=min([sum(colle{a}(g(b),:)) sum(colle{a}(g(c),:))]);
                sliceoverlaps(a).ee(end+1)=sum(eeoverlaps{a,g(b),g(c)})/denom;
            end
        end
    end
    n=sum(goodp(a,:),2);
    if n>=goodperslice;%if there is more than one movie with more than cellspermovie cells coming on from slice "a"
        g=find(goodp(a,:));
        for b=1:length(g);%for each good movie 
            for c=b+1:length(g);%for each not yet compared movie
                ppoverlaps{a,g(b),g(c)}=collp{a}(g(b),:).*collp{a}(g(c),:);%find best repeats between those two
                denom=min([sum(collp{a}(g(b),:)) sum(collp{a}(g(c),:))]);
                sliceoverlaps(a).pp(end+1)=sum(ppoverlaps{a,g(b),g(c)})/denom;
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
    if sum(goodt(a,:),2)>=1 & sum(goode(a,:),2)>=1;%if both spont and stim in this slice have at least one good movie
        gt=find(goodt(a,:));
        ge=find(goode(a,:));
        for b=1:length(gt);
            for c=1:length(ge);
                teoverlaps{a,gt(b),ge(c)}=collt{a}(gt(b),:).*colle{a}(ge(c),:);%find best repeats between those two
                denom=min([sum(collt{a}(gt(b),:)) sum(colle{a}(ge(c),:))]);
                sliceoverlaps(a).te(end+1)=sum(teoverlaps{a,gt(b),ge(c)})/denom;
            end
        end
    end
    if sum(goods(a,:),2)>=1 & sum(goode(a,:),2)>=1;%if both spont and stim in this slice have at least one good movie
        gs=find(goods(a,:));
        ge=find(goode(a,:));
        for b=1:length(gs);
            for c=1:length(ge);
                seoverlaps{a,gs(b),ge(c)}=colls{a}(gs(b),:).*colle{a}(ge(c),:);%find best repeats between those two
                denom=min([sum(colls{a}(gs(b),:)) sum(colle{a}(ge(c),:))]);
                sliceoverlaps(a).se(end+1)=sum(seoverlaps{a,gs(b),ge(c)})/denom;
            end
        end
    end
	if sum(goodp(a,:),2)>=1 & sum(goodt(a,:),2)>=1;%if both spont and stim in this slice have at least one good movie
		gp=find(goodp(a,:));
		gt=find(goodt(a,:));
		for b=1:length(gt);
			for c=1:length(gp);
				tpoverlaps{a,gt(b),gp(c)}=collt{a}(gt(b),:).*collp{a}(gp(c),:);%find best repeats between those two
				denom=min([sum(collt{a}(gt(b),:)) sum(collp{a}(gp(c),:))]);
				sliceoverlaps(a).tp(end+1)=sum(tpoverlaps{a,gt(b),gp(c)})/denom;
	        end
        end
    end
	if sum(goodp(a,:),2)>=1 & sum(goods(a,:),2)>=1;%if both spont and stim in this slice have at least one good movie
		gp=find(goodp(a,:));
		gs=find(goods(a,:));
		for b=1:length(gs);
			for c=1:length(gp);
				spoverlaps{a,gs(b),gp(c)}=colls{a}(gs(b),:).*collp{a}(gp(c),:);%find best repeats between those two
				denom=min([sum(colls{a}(gs(b),:)) sum(collp{a}(gp(c),:))]);
				sliceoverlaps(a).sp(end+1)=sum(spoverlaps{a,gs(b),gp(c)})/denom;
            end
        end
    end
%     if sum(goodt(a,:),2)>=1 & sum(goodw(a,:),2)>=1;%if both spont and stim in this slice have at least one good movie
%         gt=find(goodt(a,:));
%         gw=find(goodw(a,:));
%         for b=1:length(gt);
%             for c=1:length(gw);
%                 twoverlaps{a,gt(b),gw(c)}=collt{a}(gt(b),:).*collw{a}(gw(c),:);%find best repeats between those two
%                 denom=min([sum(collt{a}(gt(b),:)) sum(collw{a}(gw(c),:))]);
%                 sliceoverlaps(a).tw(end+1)=sum(twoverlaps{a,gt(b),gw(c)})/denom;
%             end
%         end
%     end
%     if sum(goods(a,:),2)>=1 & sum(goodw(a,:),2)>=1;%if both spont and stim in this slice have at least one good movie
%         gs=find(goods(a,:));
%         gw=find(goodw(a,:));
%         for b=1:length(gs);
%             for c=1:length(gw);
%                 swoverlaps{a,gs(b),gw(c)}=colls{a}(gs(b),:).*collw{a}(gw(c),:);%find best repeats between those two
%                 denom=min([sum(colls{a}(gs(b),:)) sum(collw{a}(gw(c),:))]);
%                 sliceoverlaps(a).sw(end+1)=sum(swoverlaps{a,gs(b),gw(c)})/denom;
%             end
%         end
%     end
end

ttmeanpairo=[];
ttsdpairo=[];
ssmeanpairo=[];
sssdpairo=[];
eemeanpairo=[];
eesdpairo=[];
ppmeanpairo=[];
ppsdpairo=[];
wwmeanpairo=[];
wwsdpairo=[];
tsmeanpairo=[];
tssdpairo=[];
temeanpairo=[];
tesdpairo=[];
semeanpairo=[];
sesdpairo=[];
tpmeanpairo=[];
tpsdpairo=[];
spmeanpairo=[];
spsdpairo=[];
tnc=[];
snc=[];
enc=[];
pnc=[];
wnc=[];
tsnc=[];
tenc=[];
senc=[];
tpnc=[];
spnc=[];

for a=1:size(sorted,2);
    if size(sliceoverlaps(a).ss,2)>1;
        snc(end+1)=a;%find slices with more than one pairwise comparison... sd's can only be on these
    end
    if size(sliceoverlaps(a).tt,2)>1;
        tnc(end+1)=a;%find slices with more than one pairwise comparison... sd's can only be on these
    end
    if size(sliceoverlaps(a).ee,2)>1;
        enc(end+1)=a;%find slices with more than one pairwise comparison... sd's can only be on these
    end
    if size(sliceoverlaps(a).pp,2)>1;
        pnc(end+1)=a;%find slices with more than one pairwise comparison... sd's can only be on these
    end
    if size(sliceoverlaps(a).ww,2)>1;
        wnc(end+1)=a;%find slices with more than one pairwise comparison... sd's can only be on these
    end
    if size(sliceoverlaps(a).ts,2)>1;
        tsnc(end+1)=a;%find slices with more than one pairwise comparison... sd's can only be on these
    end
    if size(sliceoverlaps(a).te,2)>1;
        tenc(end+1)=a;%find slices with more than one pairwise comparison... sd's can only be on these
    end
    if size(sliceoverlaps(a).se,2)>1;
        senc(end+1)=a;%find slices with more than one pairwise comparison... sd's can only be on these
    end
        if size(sliceoverlaps(a).sp,2)>1;
        spnc(end+1)=a;%find slices with more than one pairwise comparison... sd's can only be on these
    end
    if size(sliceoverlaps(a).tp,2)>1;
        tpnc(end+1)=a;%find slices with more than one pairwise comparison... sd's can only be on these
    end
end
for a=1:size(sorted,2);
    if ~isempty(sliceoverlaps(a).tt);
        ttmeanpairo(end+1)=mean(sliceoverlaps(a).tt);
    end
    if ~isempty(sliceoverlaps(a).ss);
        ssmeanpairo(end+1)=mean(sliceoverlaps(a).ss);
    end
    if ~isempty(sliceoverlaps(a).ee);
        eemeanpairo(end+1)=mean(sliceoverlaps(a).ee);
    end
    if ~isempty(sliceoverlaps(a).pp);
        ppmeanpairo(end+1)=mean(sliceoverlaps(a).pp);
    end
    if ~isempty(sliceoverlaps(a).ww);
        wwmeanpairo(end+1)=mean(sliceoverlaps(a).ww);
    end
    if ~isempty(sliceoverlaps(a).ts);
        tsmeanpairo(end+1)=mean(sliceoverlaps(a).ts);
    end
    if ~isempty(sliceoverlaps(a).te);
        temeanpairo(end+1)=mean(sliceoverlaps(a).te);
    end
    if ~isempty(sliceoverlaps(a).se);
        semeanpairo(end+1)=mean(sliceoverlaps(a).se);
    end
    if ~isempty(sliceoverlaps(a).tp);
        tpmeanpairo(end+1)=mean(sliceoverlaps(a).tp);
    end
    if ~isempty(sliceoverlaps(a).sp);
        spmeanpairo(end+1)=mean(sliceoverlaps(a).sp);
    end
end

for a=1:length(snc);
    sssdpairo(end+1)=std(sliceoverlaps(snc(a)).ss);
end
for a=1:length(tnc);
    ttsdpairo(end+1)=std(sliceoverlaps(tnc(a)).tt);
end
for a=1:length(enc);
    eesdpairo(end+1)=std(sliceoverlaps(enc(a)).ee);
end
for a=1:length(pnc);
    ppsdpairo(end+1)=std(sliceoverlaps(pnc(a)).pp);
end
for a=1:length(wnc);
    wwsdpairo(end+1)=std(sliceoverlaps(wnc(a)).ww);
end
for a=1:length(tsnc);
    tssdpairo(end+1)=std(sliceoverlaps(tsnc(a)).ts);
end
for a=1:length(tenc);
    tesdpairo(end+1)=std(sliceoverlaps(tenc(a)).te);
end
for a=1:length(senc);
    sesdpairo(end+1)=std(sliceoverlaps(senc(a)).se);
end
for a=1:length(spnc);
    spsdpairo(end+1)=std(sliceoverlaps(spnc(a)).sp);
end
for a=1:length(tpnc);
    tpsdpairo(end+1)=std(sliceoverlaps(tpnc(a)).tp);
end

for a=1:size(sliceoverlaps,2)
	sscount(a)=~isempty(sliceoverlaps(a).ss);
	ttcount(a)=~isempty(sliceoverlaps(a).tt);
	eecount(a)=~isempty(sliceoverlaps(a).ee);
	ppcount(a)=~isempty(sliceoverlaps(a).pp);
	wwcount(a)=~isempty(sliceoverlaps(a).ww);
  	tscount(a)=~isempty(sliceoverlaps(a).ts);
  	tecount(a)=~isempty(sliceoverlaps(a).te);
  	secount(a)=~isempty(sliceoverlaps(a).se);
	spcount(a)=~isempty(sliceoverlaps(a).sp);
	tpcount(a)=~isempty(sliceoverlaps(a).tp);
end

disp('-------------------------');
disp('-------------------------');
disp('THE FOLLOWING NUMBERS ARE IN REGARDS TO WHAT PERCENT OF ACTIVE CELLS REPEAT IN PAIRWISE COMPARISONS');
disp(['Number of TT, SS, EE and TS slices compared pairwise: ',num2str(sum(ttcount)),'  ',num2str(sum(sscount)),'  ',num2str(sum(eecount)),'  ',num2str(sum(ppcount)),'  ',num2str(sum(tscount)),'  ',num2str(sum(tecount)),'  ',num2str(sum(secount)),'  ',num2str(sum(tpcount)),'  ',num2str(sum(spcount))]);
disp(['Mean Average Pairwise TT, SS, EE, PP, TS, TE, SE, TP, SP Repeats: ',num2str(mean(ttmeanpairo)),'  ',num2str(mean(ssmeanpairo)),'  ',num2str(mean(eemeanpairo)),'  ',num2str(mean(ppmeanpairo)),'  ',num2str(mean(tsmeanpairo)),'  ',num2str(mean(temeanpairo)),'  ',num2str(mean(semeanpairo)),'  ',num2str(mean(tpmeanpairo)),'  ',num2str(mean(spmeanpairo))])
disp(['SD of Average Pairwise TT, SS, EE, PP, TS, TE, SE, TP, SP Repeats: ',num2str(std(ttmeanpairo)),'  ',num2str(std(ssmeanpairo)),'  ',num2str(std(eemeanpairo)),'  ',num2str(std(ppmeanpairo)),'  ',num2str(std(tsmeanpairo)),'  ',num2str(std(temeanpairo)),'  ',num2str(std(semeanpairo)),'  ',num2str(std(tpmeanpairo)),'  ',num2str(std(spmeanpairo))])
disp(['Mean SD Pairwise TT, SS, EE, PP, TS, TE, SE, TP, SP Repeats: ',num2str(mean(ttsdpairo)),'  ',num2str(mean(sssdpairo)),'  ',num2str(mean(eesdpairo)),'  ',num2str(mean(ppsdpairo)),'  ',num2str(mean(tssdpairo)),'  ',num2str(mean(tesdpairo)),'  ',num2str(mean(sesdpairo)),'  ',num2str(mean(tpsdpairo)),'  ',num2str(mean(spsdpairo))])
disp(['SD of SD Pairwise TT, SS, EE, PP, TS, TE, SE, TP, SP Repeats: ',num2str(std(ttsdpairo)),'  ',num2str(std(sssdpairo)),'  ',num2str(std(eesdpairo)),'  ',num2str(std(ppsdpairo)),'  ',num2str(std(tssdpairo)),'  ',num2str(std(tesdpairo)),'  ',num2str(std(sesdpairo)),'  ',num2str(std(tpsdpairo)),'  ',num2str(std(spsdpairo))])
[h,p]=ttest2(ttmeanpairo,ssmeanpairo);
disp(['P value of TT to SS means 2 tailed T-test: ',num2str(p)]);
[h,p]=ttest2(ttmeanpairo,eemeanpairo);
disp(['P value of TT to EE means 2 tailed T-test: ',num2str(p)]);
[h,p]=ttest2(ttmeanpairo,ppmeanpairo);
disp(['P value of TT to PP means 2 tailed T-test: ',num2str(p)]);
[h,p]=ttest2(ssmeanpairo,eemeanpairo);
disp(['P value of SS to EE means 2 tailed T-test: ',num2str(p)]);
[h,p]=ttest2(ttmeanpairo,tsmeanpairo);
disp(['P value of TT to TS means 2 tailed T-test: ',num2str(p)]);
[h,p]=ttest2(ssmeanpairo,tsmeanpairo);
disp(['P value of SS to TS means 2 tailed T-test: ',num2str(p)]);
[h,p]=ttest2(ttmeanpairo,temeanpairo);
disp(['P value of TT to TE means 2 tailed T-test: ',num2str(p)]);
[h,p]=ttest2(eemeanpairo,temeanpairo);
disp(['P value of EE to TE means 2 tailed T-test: ',num2str(p)]);
[h,p]=ttest2(ssmeanpairo,semeanpairo);
disp(['P value of SS to SE means 2 tailed T-test: ',num2str(p)]);
[h,p]=ttest2(eemeanpairo,semeanpairo);
disp(['P value of EE to SE means 2 tailed T-test: ',num2str(p)]);
[h,p]=ttest2(ttmeanpairo,tpmeanpairo);
disp(['P value of TT to TP means 2 tailed T-test: ',num2str(p)]);
[h,p]=ttest2(ppmeanpairo,tpmeanpairo);
disp(['P value of PP to TP means 2 tailed T-test: ',num2str(p)]);
[h,p]=ttest2(ssmeanpairo,spmeanpairo);
disp(['P value of SS to SP means 2 tailed T-test: ',num2str(p)]);
[h,p]=ttest2(ppmeanpairo,semeanpairo);
disp(['P value of PP to SP means 2 tailed T-test: ',num2str(p)]);
disp('-------------------------');
disp('-------------------------');
disp('-------------------------');
disp('-------------------------');