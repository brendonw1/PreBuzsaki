function [allaps,len]=plottingallaps(uptraces,abfnotes,reltowhat);
%takes all upstate traces in uptraces, finds all aps and plots their
%timepoints (found relative to UP state onset) as a histogram
%does not include time points further out than the stortest recorded UP
%state.  Reltowhat tells whether one should display spikes relative to the
%stimulus ('in6'), the start of the upstate rise ('rise'), the start point
%of the upstate ('startup')

allaps.total=[];
allaps.t=[];
allaps.s=[];
allaps.wd=[];
len.total=[];
len.t=[];
len.s=[];
len.wd=[];
stims.total=[];
% stims.t=[];
% stims.s=[];
stims.wd=[];
for a=1:size(uptraces.traces,1);
	for b=1:size(uptraces.traces,2);
		for c=1:size(uptraces.traces,3);
			for d=1:size(uptraces.traces,4);
				if ~isempty(uptraces.traces{a,b,c,d});
                    temp=uptraces.traces{a,b,c,d};
                    if strcmp(reltowhat,'in6');
                        if ~isempty(uptraces.in6{a,b,c,d});
                             if uptraces.in6{a,b,c,d}(1)<uptraces.ups{a,b,c,d}(1)   
                                lag=(uptraces.in6{a,b,c,d}(1)-uptraces.ups{a,b,c,d}(1));%for starting from the start time not from the beginning of the rise
                                aps=findaps(temp);
                                if ~isempty(aps{1});
									allaps.total((end+1):(end+length(aps{1})))=aps{1}-lag;
                                    len.total(end+1)=uptraces.ups{a,b,c,d}(4)-uptraces.in6{a,b,c,d}(1);
                                    if strcmp(abfnotes{a}.stim{b},'tstrain');%if the upstate was stimulated from the thalamus
                                        allaps.t((end+1):(end+length(aps{1})))=aps{1}-lag;
                                        len.t(end+1)=uptraces.ups{a,b,c,d}(4)-uptraces.in6{a,b,c,d}(1);
                                    elseif strcmp(abfnotes{a}.stim{b},'spont');%if the upstate was stimulated from the thalamus
                                        allaps.s((end+1):(end+length(aps{1})))=aps{1}-lag;
                                        len.s(end+1)=uptraces.ups{a,b,c,d}(4)-uptraces.in6{a,b,c,d}(1);
                                    elseif strcmp(abfnotes{a}.stim{b},'wdtrain');%if the upstate was stimulated from the thalamus
                                        allaps.wd((end+1):(end+length(aps{1})))=aps{1}-lag;
                                        len.wd(end+1)=uptraces.ups{a,b,c,d}(4)-uptraces.in6{a,b,c,d}(1);
                                    end
                                end
                            end
                        end
                    elseif strcmp(reltowhat,'startup');
                        lag=(uptraces.ups{a,b,c,d}(2)-uptraces.ups{a,b,c,d}(1));%for starting from the start time not from the beginning of the rise
                        aps=findaps(temp);
                        if ~isempty(aps{1});
							allaps.total((end+1):(end+length(aps{1})))=aps{1}-lag;
                            len.total(end+1)=uptraces.ups{a,b,c,d}(4)-uptraces.ups{a,b,c,d}(2);
                            stims.total(end+1)=uptraces.in6{a,b,c,d}(1);
                            if strcmp(abfnotes{a}.stim{b},'tstrain');%if the upstate was stimulated from the thalamus
                                allaps.t((end+1):(end+length(aps{1})))=aps{1}-lag;
                                len.t(end+1)=uptraces.ups{a,b,c,d}(4)-uptraces.ups{a,b,c,d}(2);
%                                 stims.t(end+1)=uptraces.in6{a,b,c,d}(1)-lag;
                            elseif strcmp(abfnotes{a}.stim{b},'spont');%if the upstate was stimulated from the thalamus
                                allaps.s((end+1):(end+length(aps{1})))=aps{1}-lag;
                                len.s(end+1)=uptraces.ups{a,b,c,d}(4)-uptraces.ups{a,b,c,d}(2);
%                                 stims.s(end+1)=uptraces.in6{a,b,c,d}(1)-lag;                                
                            elseif strcmp(abfnotes{a}.stim{b},'wdtrain');%if the upstate was stimulated from the thalamus
                                allaps.wd((end+1):(end+length(aps{1})))=aps{1}-lag;
                                len.wd(end+1)=uptraces.ups{a,b,c,d}(4)-uptraces.ups{a,b,c,d}(2);
                                stims.wd(end+1)=uptraces.in6{a,b,c,d}(1)-(uptraces.ups{a,b,c,d}+lag);
                            end
                        end
                    elseif strcmp(reltowhat,'rise');
                        lag=0;
                        aps=findaps(temp);
                        if ~isempty(aps{1});
						    allaps.total((end+1):(end+length(aps{1})))=aps{1}-lag;
                            len.total(end+1)=uptraces.ups{a,b,c,d}(4)-uptraces.ups{a,b,c,d}(1);
                            if strcmp(abfnotes{a}.stim{b},'tstrain');%if the upstate was stimulated from the thalamus
                                allaps.t((end+1):(end+length(aps{1})))=aps{1}-lag;
                                len.t(end+1)=uptraces.ups{a,b,c,d}(4)-uptraces.ups{a,b,c,d}(1);
%                                 stims.t(end+1)=uptraces.in6{a,b,c,d}(1)-lag;
                            elseif strcmp(abfnotes{a}.stim{b},'spont');%if the upstate was stimulated from the thalamus
                                allaps.s((end+1):(end+length(aps{1})))=aps{1}-lag;
                                len.s(end+1)=uptraces.ups{a,b,c,d}(4)-uptraces.ups{a,b,c,d}(1);
%                                 stims.s(end+1)=uptraces.in6{a,b,c,d}(1)-lag;
                            elseif strcmp(abfnotes{a}.stim{b},'wdtrain');%if the upstate was stimulated from the thalamus
                                allaps.wd((end+1):(end+length(aps{1})))=aps{1}-lag;
                                len.wd(end+1)=uptraces.ups{a,b,c,d}(4)-uptraces.ups{a,b,c,d}(1);
                                stims.wd(end+1)=uptraces.in6{a,b,c,d}(1)-(uptraces.ups{a,b,c,d}+lag);
                            end
                        end
                    end
                end
            end
        end
    end
end



figure;
[i,j]=hist(allaps.total(find(allaps.total<min(len.total))),50);
[p,S]=polyfit(j,i,1);%fit trend to a line
t2=polyval(p,j)%
plot(j,i)
ylim([0 max(i)])
hold on
plot(j,t2,'r')
xlabel('Number of time points')
% plot(

if strcmp(reltowhat,'in6');
    title('Distribution of timing of action potentials relative to the start of thalamic stimuli')
elseif strcmp(reltowhat,'startup');
    title('Distribution of timing of action potentials relative to the start of plateau of upstate')
elseif strcmp(reltowhat,'rise');
    title('Distribution of timing of action potentials relative to the start of rise to upstate')    
end



figure;
[i,j]=hist(allaps.t(find(allaps.t<min(len.t))),50);
[p,S]=polyfit(j,i,1);%fit trend to a line
t2=polyval(p,j)%
plot(j,i)
ylim([0 max(i)])
hold on
plot(j,t2,'r')
xlabel('Number of time points')

if strcmp(reltowhat,'in6');
    title('TStrain action potentials relative to the start of thalamic stimuli')
elseif strcmp(reltowhat,'startup');
    title('TStrain action potentials relative to the start of plateau of upstate')
elseif strcmp(reltowhat,'rise');
    title('TStrain action potentials relative to the start of rise to upstate')    
end


figure;
[i,j]=hist(allaps.s(find(allaps.s<min(len.s))),50);
[p,S]=polyfit(j,i,1);%fit trend to a line
t2=polyval(p,j)%
plot(j,i)
ylim([0 max(i)])
hold on
plot(j,t2,'r')
xlabel('Number of time points')

if strcmp(reltowhat,'in6');
    title('Spont action potentials relative to the start of thalamic stimuli')
elseif strcmp(reltowhat,'startup');
    title('Spont action potentials relative to the start of plateau of upstate')
elseif strcmp(reltowhat,'rise');
    title('Spont action potentials relative to the start of rise to upstate')    
end


figure;
[i,j]=hist(allaps.wd(find(allaps.wd<min(len.wd))),50);
[p,S]=polyfit(j,i,1);%fit trend to a line
t2=polyval(p,j)%
plot(j,i)
ylim([0 max(i)])
hold on
plot(j,t2,'r')
plot(stims.wd)

xlabel('Number of time points')

if strcmp(reltowhat,'in6');
    title('WDTrain action potentials relative to the start of thalamic stimuli')
elseif strcmp(reltowhat,'startup');
    title('WDTrain action potentials relative to the start of plateau of upstate')
elseif strcmp(reltowhat,'rise');
    title('WDTrain action potentials relative to the start of rise to upstate')    
end


%observations... looks almost evenly distributed throughout function.
%Perhaps slight falloff towards end.  Predictable by subthreshold alone...
%ie no burst or other properties used.  Maybe I should average the
%subthresh potentials and see if the shape mimics this... perhaps normalize
%them all.  Maybe examine cells that fire most at very start... what are
%those cells?  Should do more advanced binning, look for a function, maybe
%slightly more informative.  (synchrony, ie cost function across cells)