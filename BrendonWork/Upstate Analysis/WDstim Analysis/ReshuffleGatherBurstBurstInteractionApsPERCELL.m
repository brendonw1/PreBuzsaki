function results = ReshuffleGatherBurstBurstInteractionApsPERCELL(matnotes,stimnum,binwidth,numreshuffs,varargin);
%don't see why to do this by rate, if per cell evaluation... since rate is
%a cell-wise calculation

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
% 
beforetime = -4500;
aftertime = 9000;
% binwidth = 1500;%150ms; %input in this version
allwidth = aftertime-beforetime;

%below is for counting significance of number of spikes in either first bin
%or max bin
stimwidth = 1500;%how long we gave thalamic stims (6 stims: each has 25ms after)
numcountbins = ceil(stimwidth/binwidth);%how many bins will fit in this stim window
countbinstarts = 0:binwidth:(binwidth*(numcountbins-1));%start times of bins
countbinstops = binwidth:binwidth:(binwidth*numcountbins);%stop times of bins
numfirstbinaps = [];
nummaxbinaps = [];

% allaps = [];
% events = [];
% cellrates = [];
% cellcounts = [];
% celltotalevents = [];
% cellevents = 0;
% cellnames = {};
% celldi = [];

yallaps = [];
yevents = [];
ycellrates = [];
ycellcounts = [];
ycelltotalevents = [];
ycellevents = 0;
ycellnames = {};
ycelldi = [];

directory = uigetdir;

% stimnum = 1;%which individual stim within the burst is locked to

%% gather data

for sidx = 1:size(matnotes,2);
%     for cidx = 1:4%go through all cells that had spiking ups
%         cell = cidx;
    for cell = 1:4%go through all cells that had spiking ups

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
        ThisCellHasTSBurstInter = 0;%to allow for later recording data seprarately for cells with stim in ups versus those without
        cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};%set up to test for direct input or not
        eval(eval(distring));%eval direct input or not of each cell... makes tempvar for next line
        if tempvar;%if it passes muster
%             allbutaps = 0;
%             cellaps = [];
%             cellevents = 0;

            yallbutaps = 0;
            ycellaps = [];
            ycellevents = 0;

            for tidx = 1:size(matnotes(sidx).trial,2)%go through each trial
    %%
                if ~strcmp(matnotes(sidx).trial(tidx).stim,'wdtrain')%if the trial is 'wdtrain'
    %%
                    in6 = matnotes(sidx).trial(tidx).ephys.in6;
                    if isfield(matnotes(sidx).trial(tidx).ephys,'cell');
                        interactiontype = matnotes(sidx).trial(tidx).ephys.cell(cell).interactiontype;
                        if ~isempty(strfind(lower(interactiontype),'burst'))%if a burst interaction
                            burstnum = str2num(interactiontype(6));
                            bursts = separatein6(in6,275,'burst');
                            if ~isempty(bursts);
                                burstnum = min([size(bursts,2) burstnum]);
                                aps = matnotes(sidx).trial(tidx).ephys.cell(cell).aps;
    %                             if ~isempty(aps);
                                    if length(bursts{burstnum})>=stimnum;
                                        timeref = bursts{burstnum}(stimnum);

%% for making sure it's in an official upstate                                                 
                                        ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
                                        stiminup = 0;
                                        for uidx = 1:size(ups,1);
                                            if timeref>=ups(uidx,2) & timeref<=ups(uidx,3);
                                                stiminup = 1;%stim in up used later to record stats specifically 
                                                if in6(1)<ups(uidx,1)%for burstburst or tonicburst... make sure stim started before up, (while interaction stim was during up)
                                                    stiminup = 1;%stim in up used later to record stats specifically 
                                                    ThisCellHasTSBurstInter = 1;
                                                    break
                                                end
                                            end
                                        end
%                                         if stiminup
%%                                            
                                            if ~isempty(aps);
                                                aps = aps-timeref;
                                                aps(aps < beforetime) = [];
                                                aps(aps > aftertime) = [];
%                                                 cellaps = cat(2,cellaps,aps);
%                                                 allaps = cat(2,allaps,aps);
                                                if stiminup%for recording cells that had official up with stim (See mfile cell above)
                                                    ycellaps = cat(2,ycellaps,aps);
                                                    yallaps = cat(2,yallaps,aps);
                                                end
                                            end
                                            if isempty(aps);
                                                allbutaps = 1;
                                                if stiminup%for recording cells that had official up with stim (See mfile cell above)
                                                    yallbutaps = 1;
                                                end
                                            end
                                            if ~isempty (matnotes(sidx).trial(tidx).ephys.cell(cell).upstates);
                                                ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
                                                bef = find(ups(:,2)<timeref);
                                                aft = find(ups(:,3)>timeref);
                                                befaft = intersect(bef,aft);
                                                if ~isempty(befaft);
                                                    upyn = 1;
                                                end
                                                whichup = befaft;
                                            else
                                                upyn = 0;
                                            end
                                            
%                                             events(end+1,:) = [sidx,tidx,cell,upyn];
%                                             cellevents = cellevents + 1;
                                            if stiminup%for recording cells that had official up with stim (See mfile cell above)
                                                yevents(end+1,:) = [sidx,tidx,cell,upyn,whichup];
                                                ycellevents = ycellevents + 1;
                                            end
%                                         end
                                    end
    %                             end
                            end
                        end
                    end
                end
            end
%% to record data for general cells
%             if ~isempty(cellaps);
%                 cellaps2 = cellaps-beforetime;
% 
%                 xs = [1:ceil(allwidth/binwidth)]*binwidth-(binwidth/2);
%                 naps = hist(cellaps2,xs);
%                 cellcounts (end+1,:) = naps;
%                 naps = naps*(10000/binwidth);
%                 cellrates (end+1,:) = naps/cellevents(end);
%                 celltotalevents(end+1) = cellevents(end);
%     %             cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};
%                 sln = matnotes(sidx).name(1:end-4);
%                 cellnames{end+1} = [sln,' ',cfn];
%                 eval(['celldi(end+1) = matnotes(sidx).',cfn,'.DirectInput;'])
%             elseif allbutaps
%                 xs = [1:ceil(allwidth/binwidth)]*binwidth-(binwidth/2);
%                 cellrates(end+1,:) = zeros(size(xs));
%                 celltotalevents(end+1) = cellevents(end);
%                 sln = matnotes(sidx).name(1:end-4);
%                 cellnames{end+1} = [sln,' ',cfn];
%                 eval(['celldi(end+1) = matnotes(sidx).',cfn,'.DirectInput;'])
%             end
%% to record data for cells that had stims
            if ThisCellHasTSBurstInter
                if yallbutaps
                    yxs = [1:ceil(allwidth/binwidth)]*binwidth-(binwidth/2);
                    ycellrates(end+1,:) = zeros(size(yxs));
                    ycelltotalevents(end+1) = ycellevents(end);
                    ysln = matnotes(sidx).name(1:end-4);
                    ycellnames{end+1} = [ysln,' ',cfn];
                    eval(['ycelldi(end+1) = matnotes(sidx).',cfn,'.DirectInput;'])
                elseif ~isempty(ycellaps);
                    ycellaps2 = ycellaps-beforetime;

                    yxs = [1:ceil(allwidth/binwidth)]*binwidth-(binwidth/2);
                    ynaps = hist(ycellaps2,yxs);
                    ycellcounts (end+1,:) = ynaps;
                    ynaps = ynaps*(10000/binwidth);
                    ycellrates (end+1,:) = ynaps/ycellevents(end);
                    ycelltotalevents(end+1) = ycellevents(end);
        %             cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};
                    ysln = matnotes(sidx).name(1:end-4);
                    ycellnames{end+1} = [ysln,' ',cfn];
                    eval(['ycelldi(end+1) = matnotes(sidx).',cfn,'.DirectInput;'])
                end
                
                %for counting aps in the important time bins
                tempbinaps=[];
                for bidx = 1:numcountbins;
                    tempaps = ycellaps(find(ycellaps>countbinstarts(bidx)));
                    tempaps(tempaps>countbinstops(bidx))=[];
                    tempbinaps(bidx) = length(tempaps);
                end
                numfirstbinaps(end+1) = tempbinaps(1);
                [trash,thiscellmaxbin] = max(tempbinaps);
                nummaxbinaps(end+1) = tempbinaps(thiscellmaxbin);

%% reshuffle aps timerefs from all wd stims from this cell
                for z = 1:numreshuffs;
                    zaps = [];
                    upslist = yevents(find(yevents(:,1)==sidx),:);%list of wd ups for this slice...
                    upslist = upslist(find(upslist(:,3)==cell),:);%list of wd ups for this cell
                    for zeidx = 1:size(upslist,1);
                        zsidx = upslist(zeidx,1);
                        ztidx = upslist(zeidx,2);
                        zcell = upslist(zeidx,3);
                        zup = upslist(zeidx,5);
                        aps = matnotes(zsidx).trial(ztidx).ephys.cell(zcell).aps;
                        if ~isempty(aps);
                            thisup = matnotes(zsidx).trial(ztidx).ephys.cell(zcell).upstates(zup,:);

                            upstart = thisup(2);
                            upstop = thisup(3);
%                             timeref = upstart + rand(1)*(upstop-upstart);
%                             timeref = upstart + rand(1)*10000;
                            timeref = upstart + rand(1)*min([10000 (upstop-upstart)]);
                            aps = aps-timeref;

                            zaps = cat(2,zaps,aps);
                        end
                    end
                    tempbinaps=[];
                    for bidx = 1:numcountbins;
                        tempaps = zaps(find(zaps>countbinstarts(bidx)));
                        tempaps(tempaps>countbinstops(bidx))=[];
                        tempbinaps(bidx) = length(tempaps);
                    end
                    znumfirstbinaps(length(numfirstbinaps),z) = tempbinaps(1);
%                         [trash,index] = max(tempbinaps);
%                         znummaxbinaps(length(numfirstbinaps),z) = tempbinaps(index);
                    znummaxbinaps(length(numfirstbinaps),z) = tempbinaps(thiscellmaxbin);


                end

            %% for plotting firstbin comparison data for this cell
                thesereshuffs = znumfirstbinaps(end,:);
                f=figure;
                hist(thesereshuffs);
                hold on
                plot(numfirstbinaps(end),0,'*','color','r');
                p = sum(numfirstbinaps(end)<=thesereshuffs)/numreshuffs;

                teststr = ['#APs in FIRST bin for cell (red *) vs Reshuffles (bars).  ',num2str(binwidth/10),'ms bins.'];
                cellinfostr = [ycellnames{end},'.  ',...
                    'Slice ',num2str(sidx),' Cell ',num2str(cell),'.  ',num2str(size(upslist,1)),' trials.'];
                numbersstr = ['Cell: ',num2str(numfirstbinaps(end)),' spikes in first bin.  ',...
                    'Reshuffled distribution: mean = ',num2str(mean(thesereshuffs)),', sd = ',num2str(std(thesereshuffs)),'.'];
                signifstr = ['p = ',num2str(p),'.  ',num2str(numreshuffs),' reshuffles.'];
                titlestr = {teststr;cellinfostr;numbersstr;signifstr};
                title(titlestr);

                set(f,'userdata',thesereshuffs);
                thisstr = ycellnames{end};
                thisstr(strfind(thisstr,' '))=[];
                thisstr(end-3:end)=[];
                hgsave(f,[directory,'\',thisstr,'FirstBin']);

            %% for plotting maxbin comparison data for this cell
                thesereshuffs = znummaxbinaps(end,:);
                f=figure;
                hist(thesereshuffs);
                hold on
                plot(nummaxbinaps(end),0,'*','color','r');
                p = sum(nummaxbinaps(end)<=thesereshuffs)/numreshuffs;

                teststr = ['#APs in MAX bin for cell (red *) vs Reshuffles (bars).  ',num2str(binwidth/10),'ms bins.'];
                cellinfostr = [ycellnames{end},'.  ',...
                    'Slice ',num2str(sidx),' Cell ',num2str(cell),'.  ',num2str(size(upslist,1)),' trials.'];
                numbersstr = ['Cell: ',num2str(nummaxbinaps(end)),' spikes in first bin.  ',...
                    'Reshuffled distribution: mean = ',num2str(mean(thesereshuffs)),', sd = ',num2str(std(thesereshuffs)),'.'];
                signifstr = ['p = ',num2str(p),'.  ',num2str(numreshuffs),' reshuffles.'];
                titlestr = {teststr;cellinfostr;numbersstr;signifstr};
                title(titlestr);

                set(f,'userdata',thesereshuffs);
                thisstr = ycellnames{end};
                thisstr(strfind(thisstr,' '))=[];
                thisstr(end-3:end)=[];
                hgsave(f,[directory,'\',thisstr,'MaxBin']);
            end
        end
    end
end


%% for plotting firstbin comparison data for whole population
thesereshuffs = sum(znumfirstbinaps,1);
f=figure;
hist(thesereshuffs);
hold on
plot(sum(numfirstbinaps),0,'*','color','r');
p = sum(sum(numfirstbinaps)<=thesereshuffs)/numreshuffs;

teststr = ['#APs in FIRST bin for Population (red *) vs Reshuffles (bars).  ',num2str(binwidth/10),'ms bins.'];
cellinfostr = [num2str(size(ycellnames,2)),' total cells.  ', num2str(size(numfirstbinaps,2)),' cells spiking in these trials'];
numbersstr = ['Pop: ',num2str(sum(numfirstbinaps)),' spikes in first bin.  ',...
    'Reshuffled distribution: mean = ',num2str(mean(thesereshuffs)),', sd = ',num2str(std(thesereshuffs)),'.'];
signifstr = ['p = ',num2str(p),'.  ',num2str(numreshuffs),' reshuffles.'];
titlestr = {teststr;cellinfostr;numbersstr;signifstr};
title(titlestr);

set(f,'userdata',thesereshuffs);
hgsave(f,[directory,'\PopulationFirstBin']);

%% for plotting maxbin comparison data for whole population
thesereshuffs = sum(znummaxbinaps,1);
f=figure;
hist(thesereshuffs);
hold on
plot(sum(nummaxbinaps),0,'*','color','r');
p = sum(sum(nummaxbinaps)<=thesereshuffs)/numreshuffs;

teststr = ['#APs in MAX bin for Population (red *) vs Reshuffles (bars).  ',num2str(binwidth/10),'ms bins.'];
cellinfostr = [num2str(size(ycellnames,2)),' total cells.  ', num2str(size(nummaxbinaps,2)),' cells spiking in these trials'];
numbersstr = ['Pop: ',num2str(sum(nummaxbinaps)),' spikes in first bin.  ',...
    'Reshuffled distribution: mean = ',num2str(mean(thesereshuffs)),', sd = ',num2str(std(thesereshuffs)),'.'];
signifstr = ['p = ',num2str(p),'.  ',num2str(numreshuffs),' reshuffles.'];
titlestr = {teststr;cellinfostr;numbersstr;signifstr};
title(titlestr);

set(f,'userdata',thesereshuffs);
hgsave(f,[directory,'\PopulationMaxBin']);

%% data consolidation for general cells
% trialinfo = diff(events(:,1:2),1);
% trialinfo = ~(trialinfo==0);
% trialinfo = trialinfo(:,1)+trialinfo(:,2);
% trialinfo = logical([1;trialinfo]);
% alltrials = events(trialinfo,1:2);
% 
% allslices = unique(alltrials(:,1));y
% 
% allcells = [];
% for sidx = 1:length(allslices);
%     thissliceevents = find(events(:,1)==allslices(sidx));
%     thissliceevents = events(thissliceevents,:);
%     thisslicecells = unique(thissliceevents(:,3));
%     for cidx = 1:length(thisslicecells)
%         allcells(end+1,:) = [allslices(sidx) thisslicecells(cidx)];
%     end
% end
% 
% results.allaps = allaps;
% results.events = events;
% results.allcells = allcells;
% results.alltrials = alltrials;
% results.allslices = allslices;
% results.cellrates = cellrates;

%% data consolidation for official up stim cells
ytrialinfo = diff(yevents(:,1:2),1);
ytrialinfo = ~(ytrialinfo==0);
ytrialinfo = ytrialinfo(:,1)+ytrialinfo(:,2);
ytrialinfo = logical([1;ytrialinfo]);
yalltrials = yevents(ytrialinfo,1:2);

yallslices = unique(yalltrials(:,1));

yallcells = [];
for sidx = 1:length(yallslices);
    ythissliceevents = find(yevents(:,1)==yallslices(sidx));
    ythissliceevents = yevents(ythissliceevents,:);
    ythisslicecells = unique(ythissliceevents(:,3));
    for cidx = 1:length(ythisslicecells)
        yallcells(end+1,:) = [yallslices(sidx) ythisslicecells(cidx)];
    end
end

results.yallaps = yallaps;
results.yevents = yevents;
results.yallcells = yallcells;
results.yalltrials = yalltrials;
results.yallslices = yallslices;
results.ycellrates = ycellrates;


%% fig1
% 
% if mod(-beforetime,binwidth)
%     error('Must have integer number of bins before stim time')
%     return
% else
%     beforezerobin = -beforetime/binwidth;
% end
% cr2 = [mean(cellrates(:,1:beforezerobin),2),cellrates(:,beforezerobin+1)];
% % cr2 = [mean(cellrates(:,1:beforezerobin),2),mean(cellrates(:,beforezerobin+1:beforezerobin+6),2)];
% wp = wilcoxon(cr2(:,1),cr2(:,2));%two tailed test
% wp = wp/2;%one tailed: question is only whether increase
% 
% meanrates = mean(cellrates,1);
% 
% [h,tp,ci]=ttest2(meanrates(1:beforezerobin),meanrates(beforezerobin+1));
% 
% 
% f=figure('name','All stim');
% bar(xs,meanrates,1)
% ylabel('Avg Firing Rate Per Cell(Hz)')
% xlim([0 allwidth+.5*binwidth]);
% tickwidth = beforetime/-2;
% set(gca,'xtick',[0:tickwidth:allwidth]);
% set(gca,'xticklabel',[(beforetime:tickwidth:aftertime)/10]);
% yl = get(gca,'ylim');
% line([-beforetime -beforetime],[0 yl(2)],'color','r');
% stimtimes = 250*(1-stimnum:1:6-stimnum);
% for stidx = 1:length(stimtimes);
%     line([-beforetime+stimtimes(stidx) -beforetime+stimtimes(stidx)],[0 yl(2)/12],'color','g');
% end
% xlabel('Time relative to stimulus onset')
% results.datastr = [num2str(size(events,1)),' Events. ',...
%         num2str(size(allcells,1)),' Cells. '...
%         num2str(size(alltrials,1)),' Trials. '...
%         num2str(size(allslices,1)),' Slices. '...
%         num2str(length(find(events(:,4)))),' Upstates.'];
% results.infostr = ['Spikes timelocked to Stim #',num2str(stimnum),...
%     ' of Burst stimuli during ongoing upstates',directdesc,...
%     num2str(binwidth/10),'ms bins.'];
% results.wxsignifstr = ['Did spiking increase after stim : p = ',num2str(wp),', by Wilcoxon'];
% results.ttsignifstr = ['Did spiking increase after stim : p = ',num2str(tp),', by 2 Tailed T'];
% ti = {results.datastr;results.infostr;results.wxsignifstr;results.ttsignifstr};
% title(ti)
% set(f,'userdata',results);


%% fig2: only for stims in official upstates 11/02/06
% if mod(-beforetime,binwidth)
%     error('Must have integer number of bins before stim time')
%     return
% else
%     beforezerobin = -beforetime/binwidth;
% end
% cr2 = [mean(ycellrates(:,1:beforezerobin),2),ycellrates(:,beforezerobin+1)];
% % cr2 = [mean(cellrates(:,1:beforezerobin),2),mean(cellrates(:,beforezerobin+1:beforezerobin+6),2)];
% wp = wilcoxon(cr2(:,1),cr2(:,2));%two tailed test
% wp = wp/2;%one tailed: question is only whether increase
% 
% meanrates = mean(ycellrates,1);
% 
% [h,tp,ci]=ttest2(meanrates(1:beforezerobin),meanrates(beforezerobin+1));
% 
% ymeanrates = mean(ycellrates,1);
% f=figure('name','''UP state'' stim');
% bar(yxs,ymeanrates,1)
% ylabel('Avg Firing Rate Per Cell(Hz)')
% xlim([0 allwidth+.5*binwidth]);
% tickwidth = beforetime/-2;
% set(gca,'xtick',[0:tickwidth:allwidth]);
% set(gca,'xticklabel',[(beforetime:tickwidth:aftertime)/10]);
% yl = get(gca,'ylim');
% line([-beforetime -beforetime],[0 yl(2)],'color','r');
% stimtimes = 250*(1-stimnum:1:6-stimnum);
% for stidx = 1:length(stimtimes);
%     line([-beforetime+stimtimes(stidx) -beforetime+stimtimes(stidx)],[0 yl(2)/12],'color','g');
% end
% xlabel('Time relative to stimulus onset')
% results.ydatastr = [num2str(size(yevents,1)),' Events. ',...
%         num2str(size(yallcells,1)),' Cells. '...
%         num2str(size(yalltrials,1)),' Trials. '...
%         num2str(size(yallslices,1)),' Slices. '...
%         num2str(length(find(yevents(:,4)))),' Upstates.'];
% results.yinfostr = ['Spikes timelocked to Stim #',num2str(stimnum),...
%     ' of Burst stimuli during ongoing upstates',directdesc,...
%     num2str(binwidth/10),'ms bins.'];
% results.wxsignifstr = ['Did spiking increase after stim (1-tailed t): p = ',num2str(wp),', by Wilcoxon'];
% results.ttsignifstr = ['Did spiking increase after stim : p = ',num2str(tp),', by 2 Tailed T'];
% ti = {results.ydatastr;results.yinfostr;results.wxsignifstr;results.ttsignifstr};
% title(ti)
% set(f,'userdata',results);


%% fig3
% allaps2 = allaps-beforetime;
% xs = [1:ceil(allwidth/binwidth)]*binwidth-(binwidth/2);
% naps = hist(allaps2,xs);
% f = figure;
% %%
% naps = naps*(10000/binwidth)/size(events,1);
% ylabel('Firing Rate (Hz)')
% %%
% % ylabel('Number of Spikes')
% %%
% hold on
% bar(xs,naps,1);
% xlim([0 allwidth+.5*binwidth]);
% tickwidth = beforetime/-2;
% set(gca,'xtick',[0:tickwidth:allwidth]);
% set(gca,'xticklabel',[(beforetime:tickwidth:aftertime)/10]);
% yl = get(gca,'ylim');
% line([-beforetime -beforetime],[0 yl(2)],'color','r');
% stimtimes = 250*(1-stimnum:1:6-stimnum);
% for stidx = 1:length(stimtimes);
%     line([-beforetime+stimtimes(stidx) -beforetime+stimtimes(stidx)],[0 yl(2)/12],'color','g');
% end
% plot(allaps2,zeros(size(allaps2)),'color','m','marker','.','linestyle','none')
% 
% xlabel('Time relative to stimulus onset')
% datastr = [num2str(size(events,1)),' Events. ',...
%         num2str(size(allcells,1)),' Cells. '...
%         num2str(size(alltrials,1)),' Trials. '...
%         num2str(size(allslices,1)),' Slices. '...
%         num2str(length(find(events(:,4)))),' Upstates.'];
% infostr = ['Spikes timelocked to Stim #',num2str(stimnum),...
%     ' of Burst stimuli during ongoing upstates',directdesc,...
%     num2str(binwidth/10),'ms bins.'];
% title({infostr;datastr})
% set(f,'userdata',results);