function plotdistances(distances,uptraces);

millisecondbinsizes=2.^(11:-1:0);%[2048 1024 512 256 128 64 32 16 8 4 2 1] arbitrary precisions for spike timing, in milliseconds
samplingrate=10000;%points per second

samplingrate=samplingrate/1000;%points per millisecond
Q=(1./millisecondbinsizes)./samplingrate;
Q(end+1)=0;%this is for finding diffrences only based on different numbers of spikes
Q=sort(Q);

overlappingups=[];
for a=1:size(uptraces,1);%for each slice
	for b=1:size(uptraces,2);%for each recording
        localguide=uptraces(1).guide(a,b,:,:);
        if sum(sum(localguide))>1;%if there were at least two upstates from this file
       	    for c=1:size(uptraces,3);%for each cell, compare each upstate in that cell to each up in each other cell
                for d=1:size(uptraces,4);%for each uptrace in that recording
                    if ~isempty(uptraces(a,b,c,d).ups);
                        for e=((c+1):size(uptraces,3));%for all other cells
                            for f=(1:size(uptraces,4));%for each up state they had
                                if ~isempty(uptraces(a,b,e,f).ups);
                                    if overlapping(uptraces(a,b,c,d).ups([1 4]),uptraces(a,b,e,f).ups([1 4]));
                                        overlappingups(end+1,:)= [a,b,c,d,e,f];
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end                        
                        
% for a=1:size(overlappingups,1);%for each pair of overlapping upstates
for a=[3 5 19 46 55 28 36 43 45 87 95];%for each pair of overlapping upstates
%     disp(a)
    localup1=[overlappingups(a,1:4)];%easier to work with indices for first upstate
    localup2=[overlappingups(a,[1 2 5 6])];%easier to work with indices for second upstate
    start=min([uptraces(localup1(1),localup1(2),localup1(3),localup1(4)).ups(2) uptraces(localup2(1),localup2(2),localup2(3),localup2(4)).ups(2)]);%data point where first upstate started to rise
    stop=max([uptraces(localup1(1),localup1(2),localup1(3),localup1(4)).ups(3) uptraces(localup2(1),localup2(2),localup2(3),localup2(4)).ups(3)]);%data point where second upstate started to fall
    load(uptraces(localup1(1),localup1(2),localup1(3),localup1(4)).abfname);%obviously both ups will be in the same file... so only need to load once
    switch uptraces(localup1(1),localup1(2),localup1(3),localup1(4)).cellchannel
		case 'IN 5'
			match=channelmatch(header,1);
		case 'IN 10'
			match=channelmatch(header,2);
		case 'IN 14'
			match=channelmatch(header,3);
	end
    up1=data(start:stop,match);%now have just trace of the first upstate... but coordinated in time with the other upstate
    switch uptraces(localup2(1),localup2(2),localup2(3),localup2(4)).cellchannel
		case 'IN 5'
			match=channelmatch(header,1);
		case 'IN 10'
			match=channelmatch(header,2);
		case 'IN 14'
			match=channelmatch(header,3);
	end
    up2=data(start:stop,match);%now have just trace of the second upstate... but coordinated in time with the other upstate
    localrand=squeeze(sort(distances.reshuffcomparisons(a,:,:),3))';%sorted matrix of distances for reshuffled spikes
    signif=find(sum(localrand-repmat(distances.comparisons(a,:),[size(localrand,1) 1])>0,1)/size(localrand,1)>=.9);%find where at least 95% the reshuffled data had distances greater than the real data

    figure(a);
    subplot(2,1,1);
    plot(up1,'b');
    hold on
    plot(up2,'r');
    if ~isempty(uptraces(localup1(1),localup1(2),localup1(3),localup1(4)).core);
        corestatus1='core';
    else
        corestatus1='noncore';
    end
    if ~isempty(uptraces(localup2(1),localup2(2),localup2(3),localup2(4)).core);
        corestatus2='core';
    else
        corestatus2='noncore';
    end
    title(['File ',uptraces(localup1(1),localup1(2),localup1(3),localup1(4)).abfname,'. '...
            uptraces(localup1(1),localup1(2),localup1(3),localup1(4)).stim, ' UP state. ',...
            ' Blue Cell is ',uptraces(localup1(1),localup1(2),localup1(3),localup1(4)).celltype,...
            ' and ',corestatus1,...
            '.  Red Cell is ',uptraces(localup2(1),localup2(2),localup2(3),localup2(4)).celltype,...
            ' and ',corestatus2])
    
    subplot(2,1,2);
    plot(distances.comparisons(a,:),'g')
    hold on;
    means=mean(distances.reshuffcomparisons(a,:,:),3);
    devs=std(distances.reshuffcomparisons(a,:,:),1,3);
    errorbar(means,devs)
    plot(signif,means(signif),'*','color','r')
    set(gca,'XTickLabel',Q*(samplingrate/1000));
end
                        
figure;plot(mean(distances.comparisons,1),'g');
set(gca,'XTickLabel',Q*(samplingrate/1000));
hold on
errorbar(mean(mean(distances.reshuffcomparisons,3),1),mean(std(distances.reshuffcomparisons,1,3),1))
