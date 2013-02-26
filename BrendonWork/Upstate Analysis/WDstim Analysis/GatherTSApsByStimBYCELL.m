function results = GatherTSApsByStimBYCELL(matnotes,varargin);

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

stimnum = 1;
beforetime = -3000;
aftertime = 6000;
binwidth = 1000;%150ms;
allwidth = aftertime-beforetime;
allaps = [];
upends = [];
events = [];

cellrates = [];
cellcounts = [];
celltotalevents = [];
cellevents = 0;
cellnames = {};
celldi = [];
% stimnum = 1;%which individual stim within the burst is locked to

for sidx = 1:size(matnotes,2);
    for cidx = 1:4%go through all cells that had spiking ups
        cell = cidx;
%% exclude 2 most active cells
%         if sidx == 141 | (sidx == 159 & cell == 3);
%             continue
%         end
%%
        cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};
        eval(eval(distring));
        if tempvar;
            allbutaps = 0;
            cellaps = [];
            cellevents = 0;
            for tidx = 1:size(matnotes(sidx).trial,2)%go through each trial
    %%
                if strcmp(matnotes(sidx).trial(tidx).stim,'tstrain')
    %%
                    if ~isempty(matnotes(sidx).trial(tidx).ephys.in6)%if really stim
                        in6 = matnotes(sidx).trial(tidx).ephys.in6;%find burst
                        interactioncriterion = find(~matnotes(sidx).trial(tidx).interactionstim);%1 if no interaction
                        if interactioncriterion%if no interaction
                            ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
                            if ~isempty(ups);
                                uidx = 1;%just go for the first up
                                aps = matnotes(sidx).trial(tidx).ephys.cell(cidx).aps;
                                if ~isempty(aps);
                                    aps = aps(aps>ups(uidx,2));
                                    if ~isempty(aps);
                                        timeref = in6(1);
                                        thisupend = ups(uidx,3)-timeref;
                                        if thisupend>5000;%if at least 500ms duration
                                            if isempty(upends)%this just to keep track of longest ending upstate
                                                upends = thisupend;
                                            else
    %                                                 minupend = min([thisupend upends]);
                                                upends = cat(2,upends,thisupend);
                                            end
                                            aps = aps(aps<ups(uidx,3));
                                            if ~isempty(aps)
                                                aps = aps-timeref;
                                                aps(aps < beforetime) = [];
                                                aps(aps > aftertime) = [];
                                                cellaps = cat(2,cellaps,aps);
                                                allaps = cat(2,allaps,aps);
                                            else
                                                allbutaps = 1;
                                            end
                                            events(end+1,:) = [sidx,tidx,cell];
                                            cellevents = cellevents + 1;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if ~isempty(cellaps);
                cellaps2 = cellaps-beforetime;

                xs = [1:ceil(allwidth/binwidth)]*binwidth-(binwidth/2);
                naps = hist(cellaps2,xs);
                cellcounts (end+1,:) = naps;
                naps = naps*(10000/binwidth);
                cellrates (end+1,:) = naps/cellevents(end);
                celltotalevents(end+1) = cellevents(end);
    %             cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};
                sln = matnotes(sidx).name(1:end-4);
                cellnames{end+1} = [sln,' ',cfn];
                eval(['celldi(end+1) = matnotes(sidx).',cfn,'.DirectInput;'])
            elseif allbutaps
                xs = [1:ceil(allwidth/binwidth)]*binwidth-(binwidth/2);
                cellrates(end+1,:) = zeros(size(xs));
                celltotalevents(end+1) = cellevents(end);
                sln = matnotes(sidx).name(1:end-4);
                cellnames{end+1} = [sln,' ',cfn];
                eval(['celldi(end+1) = matnotes(sidx).',cfn,'.DirectInput;'])
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
results.cellrates = cellrates;

%% fig1
cr2 = [mean(cellrates(:,1:3),2),cellrates(:,4)];
p = wilcoxon(cr2(:,1),cr2(:,2));%two tailed test
p = p/2;%one tailed: question is only whether increase

meanrates = mean(cellrates,1);
f=figure;
bar(xs,meanrates,1)
ylabel('Avg Firing Rate Per Cell(Hz)')
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
xlabel('Time relative to stimulus onset')
datastr = [num2str(size(events,1)),' Events. ',...
        num2str(size(allcells,1)),' Cells. '...
        num2str(size(alltrials,1)),' Trials. '...
        num2str(size(allslices,1)),' Slices. '];
infostr = ['Spikes timelocked to Stim #',num2str(stimnum),...
    ' of Burst stimuli during ongoing upstates',directdesc,...
    num2str(binwidth/10),'ms bins.'];
signifstr = ['Did spiking increase after stim (1-tailed t): p = ',num2str(p),', by Wilcoxon'];
title({infostr;datastr;signifstr})
set(f,'userdata',results);


% xs = [1:16]*1500;
% 
% [an,axout] = hist(allaps,xs);
% [un,uxout] = hist(upends,xs);
% un = sum(un)-cumsum(un);
% apperbin = an./un;
% pointsperbin = (axout(2)-axout(1));
% binpersec = 10000/pointsperbin;
% appersec = apperbin * binpersec;
% f=figure;
% bar(axout,appersec);
% xlim([axout(1)-2*pointsperbin axout(end)+2*pointsperbin]);
% datastr = [num2str(size(events,1)),' Events. ',...
%         num2str(size(allcells,1)),' Cells. '...
%         num2str(size(alltrials,1)),' Trials. '...
%         num2str(size(allslices,1)),' Slices. '];
% infostr = ['Trig Upstates: Per Upstate Spike Rate',directdesc,...
%     ' Locked to Stim. ',num2str(1000/binpersec),'ms bins'];
% title({infostr;datastr})
% set(f,'userdata',results);
% 
% apperbin = an;
% appersec = apperbin * binpersec;
% f=figure;
% bar(axout,appersec);
% xlim([axout(1)-2*pointsperbin axout(end)+2*pointsperbin]);
% infostr = ['Trig Upstates: Population Spike Rate',directdesc,...
%     'Locked to Stim. ',num2str(1000/binpersec),'ms bins'];
% title({infostr;datastr})
% set(f,'userdata',results);