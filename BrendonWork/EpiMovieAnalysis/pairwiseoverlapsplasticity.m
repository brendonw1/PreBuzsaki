function [sliceoverlaps]=pairwiseoverlapsplasticity(sorted,goodperslice);
% function [ttoverlaps,ssoverlaps,tsoverlaps,sliceoverlaps]=pairwiseoverlaps(sorted);
% function [ttoverlaps,ssoverlaps,wwoverlaps,tsoverlaps,twoverlaps,swoverlaps,sliceoverlaps]=pairwiseoverlaps(sorted);
% function [ttoverlaps,ssoverlaps,tsoverlaps,meanslicerepeat]=findallrepeats(sorted,reshuffsorted);

% goodperslice=2;
cellspermovie=5;

warning off MATLAB:conversionToLogical
warning off MATLAB:divideByZero
goodp(size(sorted,2),1)=0;
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
	for d=1:size(sorted{c}.tssingle,2)
		goodp(c,d)=sorted{c}.tssingle(d).plasticity;
		if goodp(c,d);
            collp{c}(d,:)=logical(sum(sorted{c}.tssingle(d).ons,1));
        end
    end
end

for a=1:size(sorted,2);%for each slice
	sliceoverlaps(a).tp=[];
	sliceoverlaps(a).sp=[];
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
end

tpmeanpairo=[];
tpsdpairo=[];
spmeanpairo=[];
spsdpairo=[];
tpnc=[];
spnc=[];

for a=1:size(sorted,2);
    if size(sliceoverlaps(a).sp,2)>1;
        spnc(end+1)=a;%find slices with more than one pairwise comparison... sd's can only be on these
    end
    if size(sliceoverlaps(a).tp,2)>1;
        tpnc(end+1)=a;%find slices with more than one pairwise comparison... sd's can only be on these
    end
end
for a=1:size(sorted,2);
    if ~isempty(sliceoverlaps(a).tp);
        tpmeanpairo(end+1)=mean(sliceoverlaps(a).tp);
    end
    if ~isempty(sliceoverlaps(a).sp);
        spmeanpairo(end+1)=mean(sliceoverlaps(a).sp);
    end
end

for a=1:length(spnc);
    spsdpairo(end+1)=std(sliceoverlaps(spnc(a)).sp);
end
for a=1:length(tpnc);
    tpsdpairo(end+1)=std(sliceoverlaps(tpnc(a)).tp);
end

for a=1:size(sliceoverlaps,2)
	spcount(a)=~isempty(sliceoverlaps(a).sp);
	tpcount(a)=~isempty(sliceoverlaps(a).tp);
end

disp('-------------------------');
disp('-------------------------');
disp('THE FOLLOWING NUMBERS ARE IN REGARDS TO WHAT PERCENT OF ACTIVE CELLS REPEAT IN PAIRWISE COMPARISONS');
disp(['Number of TP, SP slices compared pairwise: ',num2str(sum(tpcount)),'  ',num2str(sum(spcount))]);
disp(['Mean Average Pairwise TP, SP Repeats: ',num2str(mean(tpmeanpairo)),'  ',num2str(mean(spmeanpairo))])
disp(['SD of Average Pairwise TP, SP Repeats: ',num2str(std(tpmeanpairo)),'  ',num2str(std(spmeanpairo))])
disp(['Mean SD Pairwise TP, SP Repeats: ',num2str(mean(tpsdpairo)),'  ',num2str(mean(spsdpairo))])
disp(['SD of SD Pairwise TP, SP Repeats: ',num2str(std(tpsdpairo)),'  ',num2str(std(spsdpairo))])
[h,p]=ttest2(tpmeanpairo,spmeanpairo);
disp(['P value of TP to SP means 2 tailed T-test: ',num2str(p)]);
