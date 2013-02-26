function [numtrys,binaps,binstarts,binstops] = GatherBurstInteractionApsBySlidingBin(matnotes,stimnum,varargin);
%for every bin of a certain width (200ms) evaluate the efficacy per stim of
%

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
binstep = 2500;
binwidth = 10000;
maxbinpoint = 28000;
% numsteps = ceil((maxbinpoint-binwidth)/binstep)+1;

earlieststop = ceil(binwidth/2);
lateststart = maxbinpoint - ceil(binwidth/2);
binstarts = 1+[(zeros(1,(binwidth-earlieststop)/binstep)),(0:binstep:lateststart)];
binstops = [(earlieststop:binstep:maxbinpoint), (maxbinpoint*ones(1,(maxbinpoint-lateststart)/binstep))];

numtrys = zeros(1,length(binstarts));
binaps = zeros(1,length(binstarts));

beforetime = 1;
aftertime = 1500;

%% gather data
for stepidx = 1:length(binstarts);
    disp(stepidx);
    binstart = binstarts(stepidx);
    binstop = binstops(stepidx);
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
                        if ~isempty(strfind(lower(interactiontype),'burst'))%if a burst interaction
                            burstnum = str2num(interactiontype(6));
                            bursts = separatein6(in6,275,'burst');
                            if ~isempty(bursts);
                                burstnum = min([size(bursts,2) burstnum]);
                                aps = matnotes(sidx).trial(tidx).ephys.cell(cidx).aps;
                                timeref = bursts{burstnum}(stimnum);
                                delay = [];
                                if ~isempty (matnotes(sidx).trial(tidx).ephys.cell(cell).upstates);
                                    ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
                                    bef = find(ups(:,2)<timeref);
                                    aft = find(ups(:,3)>timeref);
                                    befaft = intersect(bef,aft);                                        
                                    if ~isempty(befaft);
                                        delay = timeref - ups(befaft,2);
                                        if delay>=binstart & delay <= binstop;
                                            numtrys(stepidx) = numtrys(stepidx)+1;
                                            if ~isempty(aps);
                                                aps = aps-timeref;
                                                aps(aps < beforetime) = [];
                                                aps(aps > aftertime) = [];
                                                if  ~isempty(aps)
                                                    binaps(stepidx) = binaps(stepidx)+1;
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
        end
    end
end
figure;
plot(binaps./numtrys)
titlestr = ['Percent of trials where burst stimuli induce spiking within ',num2str(aftertime/10),'ms of stim initiation'];
infostr = ['Moving Average: ',num2str(binwidth/10),'ms bins every ',num2str(binstep/10),'ms'];
title({titlestr;infostr});
set(gca,'xtick',(1:length(binstarts)))
xtlstr = {};
for bidx = 1:length(binstarts)
    xtlstr{end+1} = [num2str(round(binstarts(bidx)/10)),'-',num2str(round(binstops(bidx)/10))];
end
set(gca,'xticklabel',xtlstr)
ylim([0 1]);