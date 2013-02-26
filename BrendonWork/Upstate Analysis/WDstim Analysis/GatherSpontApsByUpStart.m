function results = GatherSpontApsByUpStart(matnotes,varargin);

warning off
%% evaluate inputs and setup
directdesc = '. ';
distring = ['''tempvar = 1;'''];%default
for vidx = 1:length(varargin);
    if strcmp(varargin{vidx},'direct');
        direct = varargin{vidx+1};
        switch direct
            case 1
                directdesc = ' in DI Cells. ';
                distring = '[''tempvar = matnotes(sidx).'',cfn,''.DirectInput;'']';
            case 0
                directdesc = ' in non-DI Cells. ';
                distring = '[''tempvar = ~(matnotes(sidx).'',cfn,''.DirectInput);'']';
        end
    end
end

allaps = [];
upends = [];
events = [];

for sidx = 1:size(matnotes,2);
%     temp = find(matnotes(sidx).upstatecells);
%     goodcells = find(matnotes(sidx).spikingcells);
%     goodcells = intersect(temp,goodcells);
    goodcells = 1:4;
%     if ~isempty(goodcells);%if some cells that spiked and had an upstate at least once
        for tidx = 1:size(matnotes(sidx).trial,2)%go through each trial
            if strcmp('spont',matnotes(sidx).trial(tidx).stim);%if that trial was TS train
%                 if matnotes(sidx).trial(tidx).ephysupstate%if there was an upstate in some cell in that trial
%                     if ~isempty(matnotes(sidx).trial(tidx).ephys.in6)%if really stim
%                         in6 = matnotes(sidx).trial(tidx).ephys.in6;%find burst
                        interactcriterion = find(~matnotes(sidx).trial(tidx).interactionstim);
                        trialgoodcells = intersect(goodcells,interactcriterion);
                        for cidx = 1:length(trialgoodcells)%go through all cells that had spiking ups
                            cell = trialgoodcells(cidx);
                            cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};
                            eval(eval(distring));
                            if tempvar;                            
                                if isfield(matnotes(sidx).trial(tidx).ephys,'cell');
                                    ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
        %                                 for uidx = 1:size(ups,1);
                                    if ~isempty(ups);
                                        uidx = 1;
                                        aps = matnotes(sidx).trial(tidx).ephys.cell(cidx).aps;
                                        if ~isempty(aps);
        %                                     aps = aps(aps>ups(uidx,2));
        %                                     if ~isempty(aps);
                                                timeref = ups(uidx,2);
                                                thisupend = ups(uidx,3)-ups(uidx,2);
                                                if thisupend>5000;
                                                    if isempty(upends)
                                                        upends = thisupend;
                                                    else
            %                                                 minupend = min([thisupend upends]);
                                                        upends = cat(2,upends,thisupend);
                                                    end
                                                    aps = aps(aps<ups(uidx,3));
                                                    aps = aps-timeref;
                                                    aps(aps < 0) = [];
                                                    allaps = cat(2,allaps,aps);
                                                    events(end+1,:) = [sidx tidx cell];
                                                end
        %                                     end
                                        end
                                    end
                                end
                            end
%                         end
%                     end
                end
            end
        end
%     end
end
%% data consolidation
trialinfo = diff(events(:,1:2),1);
trialinfo = ~(trialinfo==0);
trialinfo = trialinfo(:,1)+trialinfo(:,2);
trialinfo = logical([1;trialinfo]);
alltrials = events(trialinfo,1:2);

cellinfo = diff(events(:,[1,3]),1);
cellinfo = ~(cellinfo==0);
cellinfo = cellinfo(:,1)+cellinfo(:,2);
cellinfo = logical([1;cellinfo]);
allcells = events(cellinfo,1:3);

allslices = unique(alltrials(:,1));

results.allaps = allaps;
results.events = events;
results.allcells = allcells(:,1:3);
results.alltrials = alltrials;
results.allslices = allslices;

%% fig1
xs = [1:16]*2000;

[an,axout] = hist(allaps,xs);
[un,uxout] = hist(upends,xs);
un = sum(un)-cumsum(un);
apperbin = an./un;
pointsperbin = (axout(2)-axout(1));
binpersec = 10000/pointsperbin;
appersec = apperbin * binpersec;
f = figure;
bar(axout,appersec);
xlim([axout(1)-2*pointsperbin axout(end)+2*pointsperbin]);
datastr = [num2str(size(events,1)),' Events. ',...
        num2str(size(allcells,1)),' Cells. '...
        num2str(size(alltrials,1)),' Trials. '...
        num2str(size(allslices,1)),' Slices. '];
infostr = ['Spont Upstates: Per Upstate Spike Rate',directdesc,...
    ' Locked to UpStart. ',num2str(1000/binpersec),'ms bins'];
title({infostr;datastr})
set(f,'userdata',results);

apperbin = an;
appersec = apperbin * binpersec;
f = figure;
bar(axout,appersec);
xlim([axout(1)-2*pointsperbin axout(end)+2*pointsperbin]);
infostr = ['Spont Upstates: Population Spike Rate',directdesc,...
    'Locked to UpStart. ',num2str(1000/binpersec),'ms bins'];
title({infostr;datastr})
set(f,'userdata',results);