function distances = spikedistforsynchrony(uprecords,numreshuffles,shuffmode,startstopmode,varargin);
% function
% distances=spikedistforsynchrony(spikesreshuffuprecords,goodpercell)
%how to choose... optimize time on whole dataset?  
%optimize on each & see how different each set is... 
warning off
tic
millisecondbinsizes=2.^(11:-1:0);%[2048 1024 512 256 128 64 32 16 8 4 2 1] arbitrary precisions for spike timing, in milliseconds
samplingrate=10000;%points per second
if nargin==5;
    shufflibrary=varargin{1};
end
samplingrate=samplingrate/1000;%sample points per millisecond
Q=(1./millisecondbinsizes)./samplingrate;%penalty per data point for each level of precision
Q(end+1)=0;%this is for finding diffrences only based on different numbers of spikes
Q=sort(Q);
overlappingups=[];
for a=1:size(uprecords,1);%for each slice
	for b=1:size(uprecords,2);%for each recording
        localguide=uprecords(1).guide(a,b,:,:);
        if sum(sum(localguide))>1;%if there were at least two upstates from this file
       	    for c=1:size(uprecords,3);%for each cell, compare each upstate in that cell to each up in each other cell
                for d=1:size(uprecords,4);%for each uptrace in that recording
%                     if strcmpi(uprecords(a,b,c,d).stim,'wdtrain');
                        if ~isempty(uprecords(a,b,c,d).ups);
                            for e=((c+1):size(uprecords,3));%for all other cells
                                for f=(1:size(uprecords,4));%for each up state they had
                                    if ~isempty(uprecords(a,b,e,f).ups);
                                        if overlapping(uprecords(a,b,c,d).ups([1 4]),uprecords(a,b,e,f).ups([1 4]));
                                                %if he upstates overlap in
                                                %time
                                            overlappingups(end+1,:)= [a,b,c,d,e,f];
                                        end
                                    end
                                end
                            end
%                         end
                        end
                end
            end
        end
    end
end                     
distances.allrawspikedistances=[];
distances.reshuffallrawspikedistances=cell([1,numreshuffles]);
distances.bestrawspikedistances=[];
distances.reshuffbestrawspikedistances=cell([1,numreshuffles]);
% figure
waithandle = waitbar(0,'Analyzing');%for user
for a=1:size(overlappingups,1);%for each pair of overlapping upstates
    localup1=[overlappingups(a,1:4)];%easier to work with indices for first upstate
    localup2=[overlappingups(a,[1 2 5 6])];%easier to work with indices for second upstate
    
    if ~strcmp(startstopmode,'combo') & ~strcmp(startstopmode,'individual')
        error('invalid startstopmode input')
    end
    switch startstopmode
        case 'combo'
            start1=min([uprecords(localup1(1),localup1(2),localup1(3),localup1(4)).ups(2) uprecords(localup2(1),localup2(2),localup2(3),localup2(4)).ups(2)]);
                %data point where first upstate started to rise
            stop1=max([uprecords(localup1(1),localup1(2),localup1(3),localup1(4)).ups(3) uprecords(localup2(1),localup2(2),localup2(3),localup2(4)).ups(3)]);
                %data point where second upstate started to fall
            start2=start1;
            stop2=stop1;
        case 'individual'
            start1=uprecords(localup1(1),localup1(2),localup1(3),localup1(4)).ups(2);
            stop1=uprecords(localup1(1),localup1(2),localup1(3),localup1(4)).ups(3);
            start2=uprecords(localup2(1),localup2(2),localup2(3),localup2(4)).ups(2);
            stop2=uprecords(localup2(1),localup2(2),localup2(3),localup2(4)).ups(3);
    end
            
    [data,samplerate,channels]=abfload(uprecords(localup1(1),localup1(2),localup1(3),localup1(4)).abfname);
        %obviously both ups will be in the same file...so only need to load
        %once
	match=strmatch(uprecords(localup1(1),localup1(2),localup1(3),localup1(4)).cellchannel,channels);
    up1=data(start1:stop1,match);%now have just trace of the first upstate... but coordinated in time with the other upstate
    match=strmatch(uprecords(localup2(1),localup2(2),localup2(3),localup2(4)).cellchannel,channels);
    up2=data(start2:stop2,match);%now have just trace of the second upstate... but coordinated in time with the other upstate
    clear data %memory management
    aps1=findaps2(up1)+start1-1;%get AP peak times for each upstate
    aps2=findaps2(up2)+start2-1;
    
    if isempty(aps1) | isempty(aps2);
        continue;
    end
    
    [meshaps1,meshaps2]=meshgrid(aps1,aps2);%setup for a simple subtraction...
    table=abs(meshaps1-meshaps2);%to get all distances between all spikes
    distances.allrawspikedistances=cat(1,distances.allrawspikedistances,table(:));%vectorize and store in a big vector 
    
    matches=findbestmatchingspikes(aps1,aps2);%find spikes that are nearest each other
    if ~isempty(matches)
        temp=aps1(matches(:,1))-aps2(matches(:,2));%get the distances between those
        distances.bestrawspikedistances=cat(1,distances.bestrawspikedistances,temp');%record them
    end        
    
    for b=1:length(Q);%go through each level of precision                            
        distances.comparisons(a,b)=spkd(aps1,aps2,Q(b));%Victor metric analysis of whole spike train
    end
%%
    switch length(varargin);
        case 0%if no library of reshuffled isis was input... create isis
            if strcmp(shuffmode,'gaussianjitterspikes');
                for z=1:numreshuffles;
                    for b=1:length(Q);%go through each level of precision                            
                       
                        sigma=1/(Q(b));
                        if sigma==Inf;
                            sigma=stop-start+1;
                        end
                        eval(['reshuffaps1=',shuffmode,'(aps1,start1,stop1,sigma);']);
                        eval(['reshuffaps2=',shuffmode,'(aps2,start2,stop2,sigma);']);
%                         [meshaps1,meshaps2]=meshgrid(reshuffaps1,reshuffa
%                         ps2);%setup for a simple subtraction...
%                         table=abs(meshaps1-meshaps2);%to get all
%                         distances between all spikes
%                         table=table(:);
%                         distances.reshuffallrawspikedistances{z}(end+1:en
%                         d+length(table))=table;%vectorize and store in a big vector                        
% 
%                         matches=findbestmatchingspikes(reshuffaps1,reshuf
%                         faps2);%find spikes that are nearest each other
%                         if ~isempty(matches)
%                             temp=reshuffaps1(matches(:,1))-reshuffaps2(a
%                             tches(:,2));%get the distances between those
%                             distances.reshuffbestrawspikedistances{z}(end
%                             +1:end+length(temp))=temp';%record the
%                         end
                        distances.reshuffcomparisons(a,b,z)=spkd(reshuffaps1,reshuffaps2,Q(b));
                    end
                end
            else
                for z=1:numreshuffles;
                    %%add feature to reshuffle each only according to it's
                    %%own upstate.
                    
                    
                    eval(['reshuffaps1=',shuffmode,'(aps1,start1,stop2);']);
                    eval(['reshuffaps2=',shuffmode,'(aps2,start1,stop2);']);
                    [meshaps1,meshaps2]=meshgrid(reshuffaps1,reshuffaps2);%setup for a simple subtraction...
                    table=abs(meshaps1-meshaps2);%to get all distances between all spikes
                    table=table(:);
                    distances.reshuffallrawspikedistances{z}(end+1:end+length(table))=table;%vectorize and store in a big vector                        
                    matches=findbestmatchingspikes(reshuffaps1,reshuffaps2);%find spikes that are nearest each other
                    if ~isempty(matches)
                        temp=reshuffaps1(matches(:,1))-reshuffaps2(matches(:,2));%get the distances between those
                        distances.reshuffbestrawspikedistances{z}(end+1:end+length(temp))=temp';%record them
                    end
                   
                    for b=1:length(Q);%go through each level of precision                            
                        distances.reshuffcomparisons(a,b,z)=spkd(reshuffaps1,reshuffaps2,Q(b));
                    end
                end
            end
        case 1%if a library of reshuffledisis was input
            
    end
    
    localrand=squeeze(sort(distances.reshuffcomparisons(a,:,:),3))';%sorted matrix of distances for reshuffled spikes
    signif=find(sum(localrand-repmat(distances.comparisons(a,:),[size(localrand,1) 1])>0,1)/numreshuffles>=.9);
        %find where at least 95% the reshuffled data had distances greater
        %than the real data
%%
%for plotting each upstate in a upper panel
    start=max(start1,start2);
    stop=min(stop1,stop2);
    figure;
    hold on
    subplot(2,1,1);
    plot(start1:stop1,up1,'b');
    hold on
    plot(start2:stop2,up2,'r');
    xlim([start stop])
    if ~isempty(uprecords(localup1(1),localup1(2),localup1(3),localup1(4)).core);
        corestatus1='core';
    else
        corestatus1='noncore';
    end
    if ~isempty(uprecords(localup2(1),localup2(2),localup2(3),localup2(4)).core);
        corestatus2='core';
    else
        corestatus2='noncore';
    end
    abf=uprecords(localup1(1),localup1(2),localup1(3),localup1(4)).abfname;
    
    title(['File ',abf,'. '...
            uprecords(localup1(1),localup1(2),localup1(3),localup1(4)).stim, ' UP state. ',...
            ' Blue Cell is ',uprecords(localup1(1),localup1(2),localup1(3),localup1(4)).celltype,...
            ' and ',corestatus1,...
            '.  Red Cell is ',uprecords(localup2(1),localup2(2),localup2(3),localup2(4)).celltype,...
            ' and ',corestatus2,' ',...
            num2str(numreshuffles),' ',startstopmode,'-type ''',shuffmode,'''-type reshuffles']);
        
%%
%for plotting spiketrain distance metrics for real vs reshuffled data for a
%number of "Q's", or 1/(bin sizes)
    subplot(2,1,2);
    plot(distances.comparisons(a,:),'g')
    hold on;
    means=mean(distances.reshuffcomparisons(a,:,:),3);
    devs=std(distances.reshuffcomparisons(a,:,:),1,3);
    errorbar(means,devs)
    plot(signif,means(signif),'*','color','r')
    set(gca,'XTickLabel',millisecondbinsizes);
    temp=[abf,'_Cell',num2str(localup1(3)),'_vs_Cell',num2str(localup2(3))]; 
    saveas(gcf,['C:\Exchange\J&B Project\Paper2 Analysis\Synchrony\',date,'SynchronyAnalysis\',temp])
    waithandle = waitbar(a/size(overlappingups,1),waithandle);
end
close(waithandle)
%%
%to store the raw spike distance data in a more organized way
for z=1:numreshuffles;
    temp1(:,z)=distances.reshuffallrawspikedistances{z};
    temp2(:,z)=distances.reshuffbestrawspikedistances{z};
end
distances.reshuffallrawspikedistances=temp1;
distances.reshuffbestrawspikedistances=temp2;
%%
%to plot an overall real vs reshuffled spike distances curve over different
%Qs
figure;plot(mean(distances.comparisons,1),'g');
set(gca,'XTickLabel',Q*(samplingrate/1000));
hold on
errorbar(mean(mean(distances.reshuffcomparisons,3),1),mean(std(distances.reshuffcomparisons,1,3),1))
temp='Combined_Comparisons';
saveas(gcf,['C:\Exchange\J&B Project\Paper2 Analysis\Synchrony\',date,'SynchronyAnalysis\',temp])
% save(['C:\Exchange\J&B Project\Paper2
% Analysis\Synchrony\',date,'SynchronyAnalysis\distances'],distances)
%%
%for plotting binned synchrony measures... see how many raw spike distances
%are within a certain time window for real and reashuffled data.  Plot hist
%of reshuffled and where the real rests.
sz=millisecondbinsizes*samplingrate;
for b=1:length(sz);
    for a=1:size(distances.reshuffallrawspikedistances,2);
        t=find(distances.reshuffallrawspikedistances(:,a)<sz(b));
        shuffnums(a)=length(t);
    end;
    figure;
    hist(shuffnums);
    realnum=length(find(distances.allrawspikedistances<sz(b)));
    hold on
    shuffnums=sort(shuffnums);
    if realnum>shuffnums(round(.95*length(shuffnums)));
        plot(realnum,1,'*','color','r');
        title(['Significant ',num2str(sz(b)/10),'ms Synchrony All Upstates vs ',num2str(numreshuffles),' ',startstopmode,'-type ''',shuffmode,'''-type reshuffles']);
    else
        plot(realnum,1,'*','color',[0 1 1]);
        title(['Non-Significant ',num2str(sz(b)/10),'ms Synchrony All Upstates vs ',num2str(numreshuffles),' ',startstopmode,'-type ''',shuffmode,'''-type reshuffles']);
    end
end
toc