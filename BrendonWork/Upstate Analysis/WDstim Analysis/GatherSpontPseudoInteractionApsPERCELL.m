function results = GatherSpontPseudoInteractionApsPERCELL(matnotes,binwidths,varargin);

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
beforetime = -5000;
aftertime = 10000;
% binwidth = 1000;%150ms;
allwidth = aftertime-beforetime;
% beforetime = -4500;
% aftertime = 8200;
% binwidth = 1500;%150ms;
allwidth = aftertime-beforetime;

allaps = [];
events = [];
cellrates = [];
cellcounts = [];
celltotalevents = [];
cellevents = 0;
cellnames = {};
celldi = [];
cellupratebytotal = [];
celluprateconserv = [];

% stimnum = 1;%which individual stim within the burst is locked to

%% gather data

for bwidx = 1:length(binwidths);
    binwidth = binwidths(bwidx);
    for sidx = 1:size(matnotes,2);
        for cell = 1:4%go through all cells that had spiking ups
            %% exclude 2 most active cells
            %        if (sidx == 141 & cell == 2) | (sidx == 159 & cell == 3);
            %            continue
            %        end
            %% exclude 3 most active cells
            %        if (sidx == 141 & cell == 2) | (sidx == 159 & cell == 3) | (sidx == 202 & cell == 1);
            %            continue
            %        end
            %% only 2 most active cells
            %         if ~(sidx == 141 & cell == 2) & ~(sidx == 159 & cell == 3);
            %             continue
            %         end
            %%
            cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};%set up to test for direct input or not
            eval(eval(distring));%eval direct input or not of each cell... makes tempvar for next line
            if tempvar;%if it passes muster
                allbutaps = 0;
                cellaps = [];
                cellevents = 0;
                celluptimetotal = 0;
                celluptimeconserv = 0;
                allcellapsonce = [];
                for tidx = 1:size(matnotes(sidx).trial,2)%go through each trial
        %%
                    if strcmp(matnotes(sidx).trial(tidx).stim,'spont')%if the trial is 'spont'
        %%
                        if isfield(matnotes(sidx).trial(tidx).ephys,'cell');
    %note no interaction stuff here
                            aps = matnotes(sidx).trial(tidx).ephys.cell(cell).aps;
                            ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
                            for uidx = 1:size(ups,1);
                                thisup = ups(uidx,:);
                                upstart = thisup(2);
                                upstop = thisup(3);
                                upwidth = upstop-upstart+1;%true upstate width
                                celluptimetotal = celluptimetotal + upwidth;
%                                 upratebytotal = length(upaps)/(upwidth/10000);%spike rate for this up
%                                 upwidth = min([upwidth-aftertime/2 20000]);%a functional upstate width:
                                    %max 1sec (to acct for decrease in rate
                                    %later in ups)
                                celluptimeconserv = celluptimeconserv + upwidth;
%                                 uprateconserv = length(upaps)/(upwidth/10000);%spike rate in higher spiking period
                                upaps = aps(aps>upstart);
                                upaps = upaps(upaps<upstop);
                                upaps = upaps - upstart;
                                allcellapsonce = cat(2,allcellapsonce,upaps);
                                
%% Systematic Time Refs
%                                 for timeref = 1:100:upwidth
%% Random Time Refs
                                for ind = 1:100;
        %                             timeref = upstart + rand(1)*(upstop-upstart);
        %                             timeref = upstart + rand(1)*10000;
                                    timeref = rand(1)*upwidth;
                                    if ~isempty(upaps);
                                        thisupaps = upaps-timeref;
                                        thisupaps(thisupaps < beforetime) = [];
                                        thisupaps(thisupaps > aftertime) = [];
                                    else
                                        thisupaps = [];
                                    end
                                    cellaps = cat(2,cellaps,thisupaps);
                                    allaps = cat(2,allaps,thisupaps);
                                    events(end+1,:) = [sidx,tidx,cell,uidx];
                                    cellevents = cellevents + 1;
                                end
                            end
                        end
                    end
                end
    %% to record data for general cells
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
                    cellupratebytotal(end+1) = length(allcellapsonce)/(celluptimetotal/10000);
                    celluprateconserv(end+1) = length(allcellapsonce)/(celluptimeconserv/10000);
                elseif allbutaps
                    xs = [1:ceil(allwidth/binwidth)]*binwidth-(binwidth/2);
                    cellrates(end+1,:) = zeros(size(xs));
                    celltotalevents(end+1) = cellevents(end);
                    sln = matnotes(sidx).name(1:end-4);
                    cellnames{end+1} = [sln,' ',cfn];
                    eval(['celldi(end+1) = matnotes(sidx).',cfn,'.DirectInput;'])
                    cellupratebytotal(end+1) = 0;
                    celluprateconserv(end+1) = 0;
                end
            end
        end
    end
end

%% data consolidation for general cells
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
results.cellrates = cellrates;
results.UpSpikeRateAllDuration = cellupratebytotal;
results.UpSpikeRateConserv = celluprateconserv;


%% fig1

if mod(-beforetime,binwidth)
    error('Must have integer number of bins before stim time')
    return
else
    beforezerobin = -beforetime/binwidth;
end
cr2 = [mean(cellrates(:,1:beforezerobin),2),cellrates(:,beforezerobin+1)];
% cr2 = [mean(cellrates(:,1:beforezerobin),2),mean(cellrates(:,beforezerobin+1:beforezerobin+6),2)];
wp = wilcoxon(cr2(:,1),cr2(:,2));%two tailed test
wp = wp/2;%one tailed: question is only whether increase

meanrates = mean(cellrates,1);

[h,tp,ci]=ttest2(meanrates(1:beforezerobin),meanrates(beforezerobin+1));


f=figure('name','All stim');
bar(xs,meanrates,1)
ylabel('Avg Firing Rate Per Cell(Hz)')
xlim([0 allwidth+.5*binwidth]);
tickwidth = beforetime/-2;
set(gca,'xtick',[0:tickwidth:allwidth]);
set(gca,'xticklabel',[(beforetime:tickwidth:aftertime)/10]);
yl = get(gca,'ylim');
line([-beforetime -beforetime],[0 yl(2)],'color','r');
% stimtimes = 250*(1-stimnum:1:6-stimnum);
% for stidx = 1:length(stimtimes);
%     line([-beforetime+stimtimes(stidx) -beforetime+stimtimes(stidx)],[0 yl(2)/12],'color','g');
% end
xlabel('Time relative to stimulus onset')
results.datastr = [num2str(size(events,1)),' Events. ',...
        num2str(size(allcells,1)),' Cells. '...
        num2str(size(alltrials,1)),' Trials. '...
        num2str(size(allslices,1)),' Slices. '...
        num2str(length(find(events(:,4)))),' Upstates.'];
results.infostr = ['Spikes timelocked to every 10ms in spontaneous upstates.  '...
    num2str(binwidth/10),'ms bins.'];
results.wxsignifstr = ['Did spiking increase after stim : p = ',num2str(wp),', by Wilcoxon'];
results.ttsignifstr = ['Did spiking increase after stim : p = ',num2str(tp),', by 2 Tailed T'];
ti = {results.datastr;results.infostr;results.wxsignifstr;results.ttsignifstr};
title(ti)
set(f,'userdata',results);


% %% fig2: only for stims in official upstates 11/02/06
% ycr2 = [mean(ycellrates(:,1:3),2),ycellrates(:,4)];
% yp = wilcoxon(ycr2(:,1),ycr2(:,2));%two tailed test
% yp = yp/2;%one tailed: question is only whether increase
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
% % stimtimes = 250*(1-stimnum:1:6-stimnum);
% % for stidx = 1:length(stimtimes);
% %     line([-beforetime+stimtimes(stidx) -beforetime+stimtimes(stidx)],[0 yl(2)/12],'color','g');
% % end
% xlabel('Time relative to stimulus onset')
% results.ydatastr = [num2str(size(yevents,1)),' Events. ',...
%         num2str(size(yallcells,1)),' Cells. '...
%         num2str(size(yalltrials,1)),' Trials. '...
%         num2str(size(yallslices,1)),' Slices. '...
%         num2str(length(find(yevents(:,4)))),' Upstates.'];
% results.yinfostr = ['Spikes timelocked to Stim #',num2str(stimnum),...
%     ' of Burst stimuli during ongoing upstates',directdesc,...
%     num2str(binwidth/10),'ms bins.'];
% results.ysignifstr = ['Did spiking increase after stim (1-tailed t): p = ',num2str(yp),', by Wilcoxon'];
% ti = {results.ydatastr;results.yinfostr;results.ysignifstr};
% title(ti)
% set(f,'userdata',results);
% 

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