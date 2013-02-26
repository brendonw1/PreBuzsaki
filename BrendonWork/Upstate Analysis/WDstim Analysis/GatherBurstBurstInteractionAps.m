function results = GatherBurstBurstInteractionAps(matnotes,stimnum,varargin);

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

beforetime = -4500;
aftertime = 8200;
binwidth = 1500;%150ms;
allwidth = aftertime-beforetime;
allaps = [];
events = [];
% stimnum = 1;%which individual stim within the burst is locked to

%% gather data
for sidx = 1:size(matnotes,2);
    goodcells = 1:4;
    for tidx = 1:size(matnotes(sidx).trial,2)%go through each trial
        if ~strcmp(matnotes(sidx).trial(tidx).stim,'wdtrain')
            in6 = matnotes(sidx).trial(tidx).ephys.in6;
            interactcriterion = find(matnotes(sidx).trial(tidx).interactionstim);
            trialgoodcells = intersect(goodcells,interactcriterion);
            for cidx = 1:length(trialgoodcells)%go through all cells that had spiking ups
                cell = trialgoodcells(cidx);
%% exclude 2 most active cells
%        if (sidx == 141 & cell == 2) | (sidx == 159 & cell == 3);
%            continue
%        end
%% exclude 3: 2 cells most active in Spont Stim and 1 cell most active in stim stim 
%        if (sidx == 141 & cell == 2) | (sidx == 159 & cell == 3) | (sidx == 263 & cell == 3);
%            continue
%        end
%% exclude 3 most active WDTrain cells
%        if (sidx == 141 & cell == 2) | (sidx == 159 & cell == 3) | (sidx == 202 & cell == 1);
%            continue
%        end
%% only 2 most active cells
%         if ~(sidx == 141 & cell == 2) & ~(sidx == 159 & cell == 3);
%             continue
%         end
%%
                cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};
                eval(eval(distring));
                if tempvar;
                    if isfield(matnotes(sidx).trial(tidx).ephys,'cell');
                        interactiontype = matnotes(sidx).trial(tidx).ephys.cell(cell).interactiontype;
                        if ~isempty(strfind(lower(interactiontype),'burst'))%if a burst interaction
                            burstnum = str2num(interactiontype(6));
                            bursts = separatein6(in6,275,'burst');
                            if ~isempty(bursts);
                                burstnum = min([size(bursts,2) burstnum]);
%                                 aps = matnotes(sidx).trial(tidx).ephys.cell(cell).aps;
%                                 if ~isempty(aps);
                                    if length(bursts{burstnum})>=stimnum;
                                        timeref = bursts{burstnum}(stimnum);

%% for making sure it's in an official upstate                                                 
%                                         ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
%                                         stiminup = 0;
%                                         for uidx = 1:size(ups,2);
%                                             if timeref>=ups(2) & timeref<=ups(3);
%                                                 stiminup = 1;
%                                                 break
%                                             end
%                                         end
%                                         if stiminup
%%                                            
                                            if ~isempty(aps);
                                                aps = aps-timeref;
                                                aps(aps < beforetime) = [];
                                                aps(aps > aftertime) = [];
                                                allaps = cat(2,allaps,aps);
                                            end
                                            if ~isempty (matnotes(sidx).trial(tidx).ephys.cell(cell).upstates);
                                                ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
                                                bef = find(ups(:,2)<timeref);
                                                aft = find(ups(:,3)>timeref);
                                                befaft = intersect(bef,aft);
                                                if ~isempty(befaft);
                                                    upyn = 1;
                                                end
                                            else
                                                upyn = 0;
                                            end
                                            events(end+1,:) = [sidx,tidx,cell,upyn];
                                        end
%                                     end
                                end
%                             end
                        end
                    end
                end
            end
        end
    end
end
%% data consolidation
trialinfo = diff(events(:,1:2),1);
trialinfo = ~(trialinfo==0);
trialinfo = trialinfo(:,1)+trialinfo(:,2);
trialinfo = logical([1;trialinfo]);
alltrials = events(trialinfo,1:2);

allslices = unique(alltrials(:,1));

allcells = [];
for sidx = 1:length(allslices);
    thissliceevents = find(events(:,1)==allslices(sidx));
    thissliceevents = events(thissliceevents,:);
    thisslicecells = unique(thissliceevents(:,3));
    for cidx = 1:length(thisslicecells)
        allcells(end+1,:) = [allslices(sidx) thisslicecells(cidx)];
    end
end

results.allaps = allaps;
results.events = events;
results.allcells = allcells;
results.alltrials = alltrials;
results.allslices = allslices;

%% fig2
binwidth = 1500;%150ms;
allwidth = aftertime-beforetime;
allaps2 = allaps-beforetime;
xs = [1:ceil(allwidth/binwidth)]*binwidth-(binwidth/2);
naps = hist(allaps2,xs);
f = figure;
%
naps = naps*(10000/binwidth)/size(events,1);
ylabel('Firing Rate (Hz)')
%%
% ylabel('Number of Spikes')
%%
hold on
bar(xs,naps,1);
xlim([0 allwidth+.5*binwidth]);
tickwidth = beforetime/-2;
set(gca,'xtick',[0:tickwidth:allwidth]);
set(gca,'xticklabel',[(beforetime:tickwidth:aftertime)/10]);
yl = get(gca,'ylim');
line([-beforetime -beforetime],[0 yl(2)],'color','r');
stimtimes = 250*(1-stimnum:1:6-stimnum);
for stidx = 1:length(stimtimes);
    line([-beforetime+stimtimes(stidx) -beforetime+stimtimes(stidx)],[0 yl(2)/12],'color','g');
end
plot(allaps2,zeros(size(allaps2)),'color','m','marker','.','linestyle','none')

xlabel('Time relative to stimulus onset')
datastr = [num2str(size(events,1)),' Events. ',...
        num2str(size(allcells,1)),' Cells. '...
        num2str(size(alltrials,1)),' Trials. '...
        num2str(size(allslices,1)),' Slices. '...
        num2str(length(find(events(:,4)))),' Upstates.'];
infostr = ['Spikes timelocked to Stim #',num2str(stimnum),...
    ' of Burst stimuli during ongoing upstates',directdesc,...
    num2str(binwidth/10),'ms bins.'];
title({infostr;datastr})
set(f,'userdata',results);

%% fig 2
gauspts = 750;
gaussd = 100;
apline = zeros(1,allwidth);
apline(allaps2) = 1;
ca = conv(gaussian(-gauspts:gauspts,0,gaussd),apline);
f = figure;
%%
ca = ca*(10000/binwidth)/size(events,1);
ylabel('Firing Rate (Hz)')
%%
% ylabel('Number of Spikes')
%%
hold on
plot(ca);
xlim([gauspts+1 allwidth+gauspts]);
yl = get(gca,'ylim');
line([-beforetime+gauspts -beforetime+gauspts],[0 yl(2)],'color','r');
stimtimes = 250*(1-stimnum:1:6-stimnum)+gauspts;
for stidx = 1:length(stimtimes);
    line([-beforetime+stimtimes(stidx) -beforetime+stimtimes(stidx)],[0 yl(2)/12],'color','g');
end
set(gca,'xtick',[gauspts:tickwidth:allwidth+gauspts]);
set(gca,'xticklabel',[(beforetime:tickwidth:aftertime)/10]);
plot(allaps2+gauspts,zeros(size(allaps2)),'color','m','marker','.','linestyle','none')
xlabel('Time relative to stimulus onset')
infostr = ['Spikes timelocked to Stim #',num2str(stimnum),...
    ' of Burst stimuli during ongoing upstates',directdesc,...
    num2str(gaussd/10),'ms SD for gaussian.' ];
title({infostr;datastr})
set(f,'userdata',results);