function results = GatherTonicInteractionAps(matnotes,tonicnum,varargin);

warning off
%% evaluate inputs and setup
directdesc = ' ';
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
events = [];
beforetime = -3000;
aftertime = 8200;
stimnum = 1;%which individual stim within the burst is locked to
% tonicnum = 2;

%% gather data
for sidx = 1:size(matnotes,2);
    goodcells = 1:4;
    for tidx = 1:size(matnotes(sidx).trial,2)%go through each trial
        in6 = matnotes(sidx).trial(tidx).ephys.in6;
        interactcriterion = find(matnotes(sidx).trial(tidx).interactionstim);
        trialgoodcells = intersect(goodcells,interactcriterion);
        for cidx = 1:length(trialgoodcells)%go through all cells that had spiking ups
            cell = trialgoodcells(cidx);
            cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};
            eval(eval(distring));
            if tempvar;
                if isfield(matnotes(sidx).trial(tidx).ephys,'cell');
                    interactiontype = matnotes(sidx).trial(tidx).ephys.cell(cell).interactiontype;
                    if ~isempty(strfind(lower(interactiontype),'tonic1'))%if a burst interaction
    %                     tonicnum = str2num(interactiontype(6))
                        bursts = separatein6(in6,275);
                        szs = [];
                        for bidx = 1:size(bursts,2);
                            szs(bidx) = size(bursts{bidx},1);%get sizes of each burst
                        end
                        tonics = find(szs==1);
                        if ~isempty(tonics)& length(tonics)>=tonicnum;
                            ttonicnum = tonics(tonicnum);
                            aps = matnotes(sidx).trial(tidx).ephys.cell(cidx).aps;
                            if ~isempty(aps);
                                timeref = bursts{ttonicnum}(stimnum);
                                aps = aps-timeref;
                                aps(aps < beforetime) = [];
                                aps(aps > aftertime) = [];
                                allaps = cat(2,allaps,aps);
                                if ~isempty (matnotes(sidx).trial(tidx).ephys.cell(cell).upstates);
                                    ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
                                    bef = find(ups(:,2)<timeref);
                                    aft = find(ups(:,3)>timeref);
                                    befaft = intersect(bef,aft);
                                    if ~isempty(befaft);
                                        upyn = 1;
                                    end
                                end
                                events(end+1,:) = [sidx,tidx,cell,upyn];
                            end
                        end
                    end
                end
            end
        end
    end
end

%% data consolidation
trialinfo = diff(events(:,1:2));
trialinfo = ~(trialinfo==0);
trialinfo = trialinfo(:,1)+trialinfo(:,2);
trialinfo = logical([1;trialinfo]);
alltrials = events(trialinfo,1:2);

cellinfo = diff(events(:,[1,3]));
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


%% fig 1
binwidth = 500;%15ms;
allwidth = aftertime-beforetime;
allaps2 = allaps-beforetime;
xs = [1:ceil(allwidth/binwidth)]*binwidth-(binwidth/2);
naps = hist(allaps2,xs);
f = figure;
bar(xs,naps,1);
xlim([0 allwidth]);
tickwidth = beforetime/-2;
set(gca,'xtick',[0:tickwidth:allwidth]);
set(gca,'xticklabel',[beforetime:tickwidth:aftertime]);
hold on;
yl = get(gca,'ylim');
line([-beforetime -beforetime],[0 yl(2)],'color','r');
hold on;
plot(allaps2,zeros(size(allaps2)),'color','m','marker','.','linestyle','none')
set(gca,'yticklabel',(str2num(get(gca,'yticklabel'))*(10000/binwidth)/size(events,1)));
ylabel('Firing Rate (Hz)')
xlabel('Time relative to stimulus onset')
datastr = [num2str(size(events,1)),' Events. ',...
        num2str(size(allcells,1)),' Cells. '...
        num2str(size(alltrials,1)),' Trials. '...
        num2str(size(allslices,1)),' Slices. '...
        num2str(length(find(events(:,4)))),' Upstates.'];
infostr = ['Spikes timelocked to Stim #',num2str(stimnum),...
    ' of Tonic stimuli during ongoing upstates',directdesc,...
    num2str(binwidth/10),'ms bins.'];
title({infostr;datastr})
set(f,'userdata',results);

%% fig 2
gauspts = 500;
gaussd = 50;
apline = zeros(1,allwidth);
apline(allaps2) = 1;
ca = conv(gaussian(-gauspts:gauspts,0,gaussd),apline);
f = figure;
plot(ca);
xlim([gauspts+1 allwidth+gauspts]);
hold on;
yl = get(gca,'ylim');
line([-beforetime+gauspts -beforetime+gauspts],[0 yl(2)],'color','r');
set(gca,'xtick',[gauspts:tickwidth:allwidth+gauspts]);
set(gca,'xticklabel',[(beforetime:tickwidth:aftertime)/10]);
plot(allaps2+gauspts,zeros(size(allaps2)),'color','m','marker','.','linestyle','none')
set(gca,'yticklabel',(str2num(get(gca,'yticklabel'))*(10000/binwidth)/size(events,1)));
ylabel('Firing Rate (Hz)')
xlabel('Time relative to stimulus onset')
infostr = ['Spikes timelocked to Stim #',num2str(tonicnum),...
    ' of Tonic stimuli during ongoing upstates',directdesc,...
    num2str(gaussd/10),'ms SD for gaussian.' ];
title({infostr;datastr})
set(f,'userdata',results);
