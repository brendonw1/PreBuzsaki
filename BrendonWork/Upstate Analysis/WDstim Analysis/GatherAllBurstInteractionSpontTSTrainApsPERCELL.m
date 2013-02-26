function results = GatherAllBurstInteractionSpontTSTrainApsPERCELL(matnotes,stimnum,binwidth,beforetime,aftertime,varargin);

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
% beforetime = -5000;
% aftertime = 5000;
% binwidth = 2500;%150ms;
allwidth = aftertime-beforetime;
% beforetime = -4500;
% aftertime = 8200;
% binwidth = 1500;%150ms;
% allwidth = aftertime-beforetime;


yallaps = [];
yevents = [];
ycellrates = [];
ycellcounts = [];
ycelltotalevents = [];
ycellevents = 0;
ycellnames = {};
ycelldi = [];

sallaps = [];
sevents = [];
scellrates = [];
scellcounts = [];
scelltotalevents = [];
scellevents = 0;
scellnames = {};
scelldi = [];
scellupratebytotal = [];
scelluprateconserv = [];

tallaps = [];
tevents = [];
tcellrates = [];
tcellcounts = [];
tcelltotalevents = [];
tcellevents = 0;
tcellnames = {};
tcelldi = [];
upends = [];

numcellswithall = 0;
aycellrates = [];
ascellrates = [];
atcellrates = [];
NO2 = 0;
% stimnum = 1;%which individual stim within the burst is locked to

%% gather data

for sidx = 1:size(matnotes,2);
%     for cell = 1:4%go through all cells that had spiking ups
%         cell = cell;
    for cell = 1:4%go through all cells that had spiking ups
        yallbutaps = 0;
        ycellaps = [];
        ycellevents = 0;
%% exclude 2 most active cells
%        if (sidx == 141 & cell == 2) | (sidx == 159 & cell == 3);
%            NO2 = 1;
%            continue
%        end
%% exclude 3 most active cells
%        if (sidx == 141 & cell == 2) | (sidx == 159 & cell == 3) | (sidx == 263 & cell == 3);
%            continue
%        end
%% only 2 most active cells
%         if ~(sidx == 141 & cell == 2) & ~(sidx == 159 & cell == 3);
%             continue
%         end
%%
        thiscellhasstiminup = 0;%to allow for later recording data seprarately for cells with stim in ups versus those without
        cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};%set up to test for direct input or not
        eval(eval(distring));%eval direct input or not of each cell... makes tempvar for next line
        if tempvar;%if it passes muster
            for tidx = 1:size(matnotes(sidx).trial,2)%go through each trial
%                 if strcmp(matnotes(sidx).trial(tidx).stim,'wdtrain')%if the trial is 'wdtrain'
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
                                                thiscellhasstiminup = 1;
                                                break
                                            end
                                        end
                                        if stiminup
%%                 
                                            if ~isempty(aps);
                                                aps = aps-timeref;
                                                aps(aps < beforetime) = [];
                                                aps(aps > aftertime) = [];
                                            end
                                            if ~isempty(aps); %need new start b/c aps could have been emptied above
                                                ycellaps = cat(2,ycellaps,aps);
                                                yallaps = cat(2,yallaps,aps);
                                            elseif isempty(aps);
                                                yallbutaps = 1;
                                            end
%                                             if ~isempty (matnotes(sidx).trial(tidx).ephys.cell(cell).upstates);
%                                                 ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
%                                                 bef = find(ups(:,2)<timeref);
%                                                 aft = find(ups(:,3)>timeref);
%                                                 befaft = intersect(bef,aft);
%                                                 if ~isempty(befaft);
%                                                     upyn = 1;
%                                                 end
%                                             else
%                                                 upyn = 0;
%                                             end
                                            
%                                             if stiminup%for recording
%                                             cells that had official up with stim (See mfile cell above)
                                                yevents(end+1,:) = [sidx,tidx,cell];
                                                ycellevents = ycellevents + 1;
%                                             end
                                        end
                                    end
    %                             end
                            end
                        end
                    end
%                 end
            end
%% to record data for cells that had stims in official ups only
            if thiscellhasstiminup
                if ~isempty(ycellaps);
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
                elseif yallbutaps
                    yxs = [1:ceil(allwidth/binwidth)]*binwidth-(binwidth/2);
                    ycellrates(end+1,:) = zeros(size(yxs));
                    ycelltotalevents(end+1) = ycellevents(end);
                    ysln = matnotes(sidx).name(1:end-4);
                    ycellnames{end+1} = [ysln,' ',cfn];
                    eval(['ycelldi(end+1) = matnotes(sidx).',cfn,'.DirectInput;'])
                end
            end
%% Evaluate Spontaneous spiking for same cell
            sallbutaps = 0;
            scellaps = [];
            scellevents = 0;
            scelluptimetotal = 0;
            scelluptimeconserv = 0;
            sallcellapsonce = [];
            for tidx = 1:size(matnotes(sidx).trial,2)%go through each trial
                if strcmp(matnotes(sidx).trial(tidx).stim,'spont')%if the trial is 'spont'
                    if isfield(matnotes(sidx).trial(tidx).ephys,'cell');
%note no interaction stuff here
                        aps = matnotes(sidx).trial(tidx).ephys.cell(cell).aps;
                        ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
                        for uidx = 1:size(ups,1);
                            thisup = ups(uidx,:);
                            upstart = thisup(2);
                            upstop = thisup(3);
                            upwidth = upstop-upstart+1;%true upstate width
                            scelluptimetotal = scelluptimetotal + upwidth;
%                                 upratebytotal = length(upaps)/(upwidth/10000);%spike rate for this up
                            upwidth = min([upwidth-aftertime/2 10000]);%a functional upstate width:
                              %max 1sec (to acct for decrease in rate
                              %later in ups)
                            scelluptimeconserv = scelluptimeconserv + upwidth;
%                                 uprateconserv = length(upaps)/(upwidth/10000);%spike rate in higher spiking period
                            upaps = aps(aps>upstart);
                            upaps = upaps(upaps<upstop);
                            upaps = upaps - upstart;
                            conservaps = upaps(upaps<upwidth);
                            sallcellapsonce = cat(2,sallcellapsonce,conservaps);

    %% Systematic Time Refs
                            for timeref = 1:100:upwidth
    %% Random Time Refs
%                             for ind = 1:100;
%         %                         timeref = upstart + rand(1)*(upstop-upstart);
%         %                         timeref = upstart + rand(1)*10000;
%                                 timeref = rand(1)*upwidth;
    %%
                                if ~isempty(upaps);
                                    thisupaps = upaps-timeref;
                                    thisupaps(thisupaps < beforetime) = [];
                                    thisupaps(thisupaps > aftertime) = [];
                                else
                                    thisupaps = [];
                                end
                                scellaps = cat(2,scellaps,thisupaps);
                                sallaps = cat(2,sallaps,thisupaps);
                                sevents(end+1,:) = [sidx,tidx,cell,uidx];
                                scellevents = scellevents + 1;
                            end
                        end
                    end
                end
            end
            if ~isempty(scellaps);
                scellaps2 = scellaps-beforetime;

                xs = [1:ceil(allwidth/binwidth)]*binwidth-(binwidth/2);
                naps = hist(scellaps2,xs);
                scellcounts (end+1,:) = naps;
                naps = naps*(10000/binwidth);
                scellrates (end+1,:) = naps/scellevents(end);
                scelltotalevents(end+1) = scellevents(end);
    %             cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};
                sln = matnotes(sidx).name(1:end-4);
                scellnames{end+1} = [sln,' ',cfn];
                eval(['scelldi(end+1) = matnotes(sidx).',cfn,'.DirectInput;'])
                scellupratebytotal(end+1) = length(sallcellapsonce)/(scelluptimetotal/10000);
                scelluprateconserv(end+1) = length(sallcellapsonce)/(scelluptimeconserv/10000);
            elseif sallbutaps
                xs = [1:ceil(allwidth/binwidth)]*binwidth-(binwidth/2);
                scellrates(end+1,:) = zeros(size(xs));
                scelltotalevents(end+1) = scellevents(end);
                sln = matnotes(sidx).name(1:end-4);
                scellnames{end+1} = [sln,' ',cfn];
                eval(['scelldi(end+1) = matnotes(sidx).',cfn,'.DirectInput;'])
                scellupratebytotal(end+1) = 0;
                scelluprateconserv(end+1) = 0;
            end

%% Evaluate TsTrain spiking for same cell
            tallbutaps = 0;
            tcellaps = [];
            tcellevents = 0;
            for tidx = 1:size(matnotes(sidx).trial,2)%go through each trial
                if strcmp(matnotes(sidx).trial(tidx).stim,'tstrain')
                    if ~isempty(matnotes(sidx).trial(tidx).ephys.in6)%if really stim
                        in6 = matnotes(sidx).trial(tidx).ephys.in6;%find burst
                        interactioncriterion = find(~matnotes(sidx).trial(tidx).interactionstim);%1 if no interaction
                        if interactioncriterion%if no interaction
                            ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
                            if ~isempty(ups);
                                uidx = 1;%just go for the first up
                                aps = matnotes(sidx).trial(tidx).ephys.cell(cell).aps;
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
                                                tcellaps = cat(2,tcellaps,aps);
                                                tallaps = cat(2,tallaps,aps);
                                            else
                                                tallbutaps = 1;
                                            end
                                            tevents(end+1,:) = [sidx,tidx,cell];
                                            tcellevents = tcellevents + 1;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if ~isempty(tcellaps);
                tcellaps2 = tcellaps-beforetime;

                xs = [1:ceil(allwidth/binwidth)]*binwidth-(binwidth/2);
                naps = hist(tcellaps2,xs);
                tcellcounts (end+1,:) = naps;
                naps = naps*(10000/binwidth);
                tcellrates (end+1,:) = naps/tcellevents(end);
                tcelltotalevents(end+1) = tcellevents(end);
    %             cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};
                sln = matnotes(sidx).name(1:end-4);
                tcellnames{end+1} = [sln,' ',cfn];
                eval(['tcelldi(end+1) = matnotes(sidx).',cfn,'.DirectInput;'])
            elseif tallbutaps
                xs = [1:ceil(allwidth/binwidth)]*binwidth-(binwidth/2);
                tcellrates(end+1,:) = zeros(size(xs));
                tcelltotalevents(end+1) = tcellevents(end);
                sln = matnotes(sidx).name(1:end-4);
                tcellnames{end+1} = [sln,' ',cfn];
                eval(['tcelldi(end+1) = matnotes(sidx).',cfn,'.DirectInput;'])
            end
%% store num spikes and rate for each cell that had all 3
            if ycellevents & scellevents & tcellevents
                numcellswithall = numcellswithall+1;
                aycellrates(end+1,:) = ycellrates(end,:);
                ascellrates(end+1,:) = scellrates(end,:);
                atcellrates(end+1,:) = tcellrates(end,:);
                %store combo cell data for ouput
            end

%%
        end
    end
end

%figure;
%fig1 (bargraph of per cell observed vs expected)
poststimbin = (-beforetime/binwidth)+1;
sponts = ascellrates(:,poststimbin);
tstrains = atcellrates(:,poststimbin);
summedts = sponts+tstrains;
interacts = aycellrates(:,poststimbin);
errorbargraph([mean(sponts) mean(tstrains) mean(summedts) mean(interacts)],[std(sponts) std(tstrains) std(summedts) std(interacts)],.6);
if NO2
    title ({['Spike Rates in ',num2str(binwidth/10),'ms post stim (Error bars = SD over cells) NO 2 CELLS'];'Spont, TsTrain, Sum T+S, Interaction'})
else
    title ({['Spike Rates in ',num2str(binwidth/10),'ms post stim (Error bars = SD over cells)'];'Spont, TsTrain, Sum T+S, Interaction'})
end

%fig2 (fitted slope vs slope=1 for observed vs expected per cell)
figure;
overallmax = ceil(max([interacts;summedts]));
plot(summedts,interacts,'.')
hold on;
plot([0 overallmax],[0 overallmax],'color','r')
p = polyfit(summedts,interacts,1);
polyx = 0:.1:overallmax;
y = polyval(p,polyx);
plot(polyx,y);
ylabel('Interaction Rate')
xlabel('Summed T+S Rate')
ylim([0 overallmax])
xlim([0 overallmax])
if NO2
    title({['Expected vs Observed spiking of Spont+TS.  ',num2str(binwidth/10),'ms Bins.  NO 2 CELLS'];'Red Line: Slope = 1'})
else
    title({['Expected vs Observed spiking of Spont+TS.  ',num2str(binwidth/10),'ms Bins.'];'Red Line: Slope = 1'})
end


spontbins = mean(scellrates,1);
tstrainbins = mean(tcellrates,1);
interactionbins = mean(ycellrates,1);
summedbins = tstrainbins+spontbins;
bardisplay(1) = spontbins(poststimbin);
bardisplay(2) = tstrainbins(poststimbin);
bardisplay(3) = summedbins(poststimbin);
bardisplay(4) = interactionbins(poststimbin);
% barerrors(1) = std(scellrates(:,poststimbin));
% barerrors(2) = std(tcellrates(:,poststimbin));
% barerrors(3) = 0;
% barerrors(4) = std(ycellrates(:,poststimbin));

%fig 3 (bar graphs of population expected vs observed.  spont = spont after pseudostim)
figure;
bar([.5 1.5 2.5 3.5],bardisplay,.6)
if NO2
    title({['Spike Rates in ',num2str(binwidth/10),'ms bins after stim.  NO 2 CELLS'];'1)=Spont poststim bin  2)=TsTrain 250ms  3)=1+2  4)=Observed interaction 250ms'})
else
    title({['Spike Rates in ',num2str(binwidth/10),'ms bins after stim.  '];'1)=Spont poststim bin  2)=TsTrain 250ms  3)=1+2  4)=Observed interaction 250ms'})
end

%fig (bar graphs of population expected vs observed.  spont = mean across conserv time)
% bardisplay(1) = mean(scelluprateconserv);
% % barerrors (1) = std(scelluprateconserv);
% figure;
% bar([.5 1.5 2.5 3.5],bardisplay,.6)
% if NO2
%     title({['Spike Rates in ',num2str(binwidth/10),'ms bins after stim.  NO 2 CELLS'];'1)=Spont overall mean  2)=TsTrain 250ms  3)=1+2  4)=Observed interaction 250ms'})
% else
%     title({['Spike Rates in ',num2str(binwidth/10),'ms bins after stim.  '];'1)=Spont overall mean  2)=TsTrain 250ms  3)=1+2  4)=Observed interaction 250ms'})
% end

%fig4 (PSTHs)
figure;
subplot(2,2,1);%spont
bar(xs,spontbins,1);
line([-beforetime -beforetime],[0 100],'color','r');ylim([0 6])
title('Spont.  250ms bins')
subplot(2,2,2);%tstrain
bar(xs,tstrainbins,1);
line([-beforetime -beforetime],[0 100],'color','r');ylim([0 6])
title('TsTrain.  250ms bins')
subplot(2,2,3);%summed
bar(xs,summedbins,1);
line([-beforetime -beforetime],[0 100],'color','r');ylim([0 6])
title('T+S.  250ms bins')
subplot(2,2,4);%interaction
bar(xs,interactionbins,1);
line([-beforetime -beforetime],[0 100],'color','r');ylim([0 6])
title('Interaction.  250ms bins')

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
    for cell = 1:length(ythisslicecells)
        yallcells(end+1,:) = [yallslices(sidx) ythisslicecells(cell)];
    end
end

results.yallaps = yallaps;
results.yevents = yevents;
results.yallcells = yallcells;
results.yalltrials = yalltrials;
results.yallslices = yallslices;
results.ycellrates = ycellrates;

%% data consolidation for spont UPs
strialinfo = diff(sevents(:,1:2),1);
strialinfo = ~(strialinfo==0);
strialinfo = strialinfo(:,1)+strialinfo(:,2);
strialinfo = logical([1;strialinfo]);
salltrials = sevents(strialinfo,1:2);

sallslices = unique(salltrials(:,1));

sallcells = [];
for sidx = 1:length(sallslices);
    sthissliceevents = find(sevents(:,1)==sallslices(sidx));
    sthissliceevents = sevents(sthissliceevents,:);
    sthisslicecells = unique(sthissliceevents(:,3));
    for cell = 1:length(sthisslicecells)
        sallcells(end+1,:) = [sallslices(sidx) sthisslicecells(cell)];
    end
end

results.sallaps = sallaps;
results.sevents = sevents;
results.sallcells = sallcells;
results.salltrials = salltrials;
results.sallslices = sallslices;
results.scellrates = scellrates;


%% data consolidation for TS Train UPs
ttrialinfo = diff(tevents(:,1:2),1);
ttrialinfo = ~(ttrialinfo==0);
ttrialinfo = ttrialinfo(:,1)+ttrialinfo(:,2);
ttrialinfo = logical([1;ttrialinfo]);
talltrials = tevents(ttrialinfo,1:2);

tallslices = unique(talltrials(:,1));

tallcells = [];
for sidx = 1:length(tallslices);
    tthissliceevents = find(tevents(:,1)==tallslices(sidx));
    tthissliceevents = tevents(tthissliceevents,:);
    tthisslicecells = unique(tthissliceevents(:,3));
    for cell = 1:length(tthisslicecells)
        tallcells(end+1,:) = [tallslices(sidx) tthisslicecells(cell)];
    end
end

results.tallaps = tallaps;
results.tevents = tevents;
results.tallcells = tallcells;
results.talltrials = talltrials;
results.tallslices = tallslices;
results.tcellrates = tcellrates;


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
% results.ysignifstr = ['Did spiking increase after stim (1-tailed t): p = ',num2str(yp),', by Wilcoxon'];
% ti = {results.ydatastr;results.yinfostr;results.ysignifstr};
% title(ti)
% set(f,'userdata',results);