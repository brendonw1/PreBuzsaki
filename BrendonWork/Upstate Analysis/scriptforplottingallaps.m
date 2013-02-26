%% can or can-not have this
stimtype='tstrain';
% stimtype='wdtrain';
%%

beforedur=0;
afterdur=10000;
aps=[];
trialcount=0;
for a=1:length(matnotes);%for each slice
    cells=find(matnotes(a).alivecells);
    for c=1:length(cells);
%         anyspikes=0;
%         postypes=zeros(1,length(stimtypes));%intiate
        for b=1:length(matnotes(a).trial);%for each trial
            if isfield(matnotes(a).trial(b).ephys,'cell');
                if ~isempty(matnotes(a).trial(b).stim);
%% for looking at only a certain kind of stim...take out to ignore stim type
                    if strcmpi(matnotes(a).trial(b).stim,stimtype);
%% end certain stim

%% if want to have only upstate events
                        if ~isempty(matnotes(1).trial(10).ephys.cell(cells(c)));
%% end "upstate only"

%% for setting a specific lag (in6, up detection, etc)
                            if ~isempty(matnotes(a).trial(b).ephys.in6)
                                trains=separatetrains(matnotes(a).trial(b).ephys.in6,5000);
                                lag=trains{1}(1);
%% end lag set
                                disp([a b])
                                [data,sampling,channels]=abfload(matnotes(a).trial(b).abfname);
                                match=strmatch(matnotes(a).trial(b).ephys.cell(c).name,channels);
                                data=data(:,match);
                                if median(data)<-55 & median(data)>-85
                                    temp=findaps2(data);
                                    temp=temp-lag;
                                    temp(find(temp)<1)=[];
                                    aps(end+1:end+length(temp))=temp;
                                    trialcount=trialcount+1;
                                end
                            end
                        end
                    end
                 end
            end
        end
    end
end

aps(find(aps<1))=[];%in case missed above... I noticed a problem for some reason
[y,x]=hist(aps(find(aps<=afterdur)),10);
y=y/trialcount;%per-cell rate
figure;bar(x,y)


% %takes all upstate traces in uptraces, finds all aps and plots their
% %timepoints (found relative to UP state onset) as a histogram
% %does not include time points further out than the stortest recorded UP
% %state.  
% 
% len=[];
% for a=1:size(uptraces.traces,1);
% 	for b=1:size(uptraces.traces,2);
% 		for c=1:size(uptraces.traces,3);
% 			for d=1:size(uptraces.traces,4);
%                 len(end+1)=length(uptraces(a,b,c,d).traces);
%             end
%         end
%     end
% end
% 
% len=len(find(len));
% 
% allaps=[];
% for a=1:size(uptraces.traces,1);
% 	for b=1:size(uptraces.traces,2);
% 		for c=1:size(uptraces.traces,3);
% 			for d=1:size(uptraces.traces,4);
% 				if ~isempty(uptraces(a,b,c,d).traces);
%                     temp=uptraces(a,b,c,d).traces;
%                     lag=(uptraces(a,b,c,d).ups(2)-uptraces(a,b,c,d).ups(1));%for starting from the start time not from the beginning of the rise
%                     aps=findaps(temp);
%                     if ~isempty(aps{1});
% 						allaps((end+1):(end+length(aps{1})))=aps{1}-lag;
%                     end
%                 end
%             end
%         end
%     end
% end
% 
% figure;
% hist(allaps(find(allaps<min(len))),100)
% 
% title('Distribution of timing of action potentials relative to the start of upstates')
% 
% %observations... looks almost evenly distributed throughout function.
% %Perhaps slight falloff towards end.  Predictable by subthreshold alone...
% %ie no burst or other properties used.  Maybe I should average the
% %subthresh potentials and see if the shape mimics this... perhaps normalize
% %them all.  Maybe examine cells that fire most at very start... what are
% %those cells?  Should do more advanced binning, look for a function, maybe
% %slightly more informative.  (synchrony, ie cost function across cells)