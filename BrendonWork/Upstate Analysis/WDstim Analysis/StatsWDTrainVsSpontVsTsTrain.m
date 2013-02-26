function results = StatsWDTrainVsSpontVsTsTrain(matnotes,stimnum,varargin);

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

results = [];
loadedfile = [0 0];
wdtrainupguide = logical([]);
spontupguide = logical([]);
tstrainupguide = logical([]);

ratiosptsrate = [];
diffsptsrate = [];
ratiosptsdur = [];
diffsptsdur = [];
ratiosptsamp = [];
diffsptsamp = [];
%
ratiowdtsrate = [];
diffwdtsrate = [];
ratiowdtsdur = [];
diffwdtsdur = [];
ratiowdtsamp = [];
diffwdtsamp = [];
%
ratiowdsprate = [];
diffwdsprate = [];
ratiowdspdur = [];
diffwdspdur = [];
ratiowdspamp = [];
diffwdspamp = [];

for sidx = 1:size(matnotes,2);
    for cell = 1:4%go through all cells that had spiking ups
        cellnum = 4*(sidx-1)+cell;
        thiscellhaswdtrain = 0;
        thiscellhasspont = 0;
        thiscellhaststrain = 0;
        wdtrainupnum = 0;
        spontupnum = 0;
        tstrainupnum = 0;
%% exclude 2 most active cells
%        if (sidx == 141 & cell == 2) | (sidx == 159 & cell == 3);
%            NO2 = 1;
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
        thiscellhasstiminup = 0;%to allow for later recording data seprarately for cells with stim in ups versus those without
        cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};%set up to test for direct input or not
        eval(eval(distring));%eval direct input or not of each cell... makes tempvar for next line        
        if tempvar;%if it passes muster
            for tidx = 1:size(matnotes(sidx).trial,2)%go through each trial
                if strcmp(matnotes(sidx).trial(tidx).stim,'wdtrain')%if the trial is 'wdtrain'
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
%                                                 thiscellhasstiminup = 1;
                                                break
                                            end
                                        end
                                        if stiminup
                                            if sum(loadedfile - [sidx tidx]);%if abf not loaded, load it
                                                abfpath1 = matnotes(sidx).trial(tidx).ephys.abfname;
                                %                 abfpath = ['C:\Exchange\Data\Axon Data\',abfpath];
                                %                 abfpath = ['E:\Abeles Data Folder\Axon Data\',abfpath];
                                                try
                                                    abfpath = ['D:\Exchange\Data\Axon Data\',abfpath1];
                                                    [data,trash,channels]=abfload(abfpath);
                                                catch
                                                    abfpath = ['E:\Brendon From Snap\BW Exchange\Data\Axon Data\',abfpath1];
                                                    [data,trash,channels]=abfload(abfpath);                            
                                                end
                                                loadedfile = [sidx tidx];
                                            end
                                            
                                            for uidx = 1:size(ups,1);
                                                wdtrainupnum = wdtrainupnum+1;
                                                dur = ups(uidx,3)-ups(uidx,2);
                                                
%                                                 aps = matnotes(sidx).trial(tidx).ephys.cell(cell).aps;
                                                aps = aps(aps>ups(uidx,2));
                                                aps = aps(aps<ups(uidx,3));

                                                ccn = matnotes(sidx).CellOrder.CellChannels{cell};
                                                chanmatch = strmatch(ccn,channels);
                                                downvals = data([ups(uidx,1),ups(uidx,4)],chanmatch);
                                                upvals = data(ups(uidx,2):ups(uidx,3),chanmatch);
                                                amp = mean(upvals)- mean(downvals);
                                                
                                                wdtrainupguide(cellnum,wdtrainupnum) = 1;
                                                wdtraindurs(cellnum,wdtrainupnum) = dur;
                                                wdtrainamps(cellnum,wdtrainupnum) = amp;
                                                wdtrainaps(cellnum,wdtrainupnum) = length(aps);
                                                
                                                thiscellhaswdtrain = 1;
                                            end
                                        end
                                    end
%                                 end
                            end
                        end
                    end
                end
%% Evaluate Spontaneous spiking for same cell
                if strcmp(matnotes(sidx).trial(tidx).stim,'spont')%if the trial is 'spont'
                    if isfield(matnotes(sidx).trial(tidx).ephys,'cell');
%note no interaction stuff here
                        aps = matnotes(sidx).trial(tidx).ephys.cell(cell).aps;
                        ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
                        if sum(loadedfile - [sidx tidx]);%if abf not loaded, load it
                            abfpath1 = matnotes(sidx).trial(tidx).ephys.abfname;
            %                 abfpath = ['C:\Exchange\Data\Axon Data\',abfpath];
            %                 abfpath = ['E:\Abeles Data Folder\Axon Data\',abfpath];
                            try
                                abfpath = ['D:\Exchange\Data\Axon Data\',abfpath1];
                                [data,trash,channels]=abfload(abfpath);
                            catch
                                abfpath = ['E:\Brendon From Snap\BW Exchange\Data\Axon Data\',abfpath1];
                                [data,trash,channels]=abfload(abfpath);                            
                            end
                            loadedfile = [sidx tidx];
                        end

                        for uidx = 1:size(ups,1);
                            spontupnum = spontupnum+1;
                            dur = ups(uidx,3)-ups(uidx,2);

%                                 aps = matnotes(sidx).trial(tidx).ephys.cell(cell).aps;
                            aps = aps(aps>ups(uidx,2));
                            aps = aps(aps<ups(uidx,3));

                            ccn = matnotes(sidx).CellOrder.CellChannels{cell};
                            chanmatch = strmatch(ccn,channels);
                            downvals = data([ups(uidx,1),ups(uidx,4)],chanmatch);
                            upvals = data(ups(uidx,2):ups(uidx,3),chanmatch);
                            amp = mean(upvals)- mean(downvals);

                            spontupguide(cellnum,spontupnum) = 1;
                            spontdurs(cellnum,spontupnum) = dur;
                            spontamps(cellnum,spontupnum) = amp;
                            spontaps(cellnum,spontupnum) = length(aps);

                            thiscellhasspont = 1;
                        end
                    end
                end
%% Evaluate TsTrain spiking for same cell
                if strcmp(matnotes(sidx).trial(tidx).stim,'tstrain')%if the trial is 'spont'
                    if isfield(matnotes(sidx).trial(tidx).ephys,'cell');
%note no interaction stuff here
                        aps = matnotes(sidx).trial(tidx).ephys.cell(cell).aps;
                        ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
                        if sum(loadedfile - [sidx tidx]);%if abf not loaded, load it
                            abfpath1 = matnotes(sidx).trial(tidx).ephys.abfname;
            %                 abfpath = ['C:\Exchange\Data\Axon Data\',abfpath];
            %                 abfpath = ['E:\Abeles Data Folder\Axon Data\',abfpath];
                            try
                                abfpath = ['D:\Exchange\Data\Axon Data\',abfpath1];
                                [data,trash,channels]=abfload(abfpath);
                            catch
                                abfpath = ['E:\Brendon From Snap\BW Exchange\Data\Axon Data\',abfpath1];
                                [data,trash,channels]=abfload(abfpath);                            
                            end
                            loadedfile = [sidx tidx];
                        end

                        for uidx = 1:size(ups,1);
                            tstrainupnum = tstrainupnum+1;
                            dur = ups(uidx,3)-ups(uidx,2);

%                                 aps = matnotes(sidx).trial(tidx).ephys.cell(cell).aps;
                            aps = aps(aps>ups(uidx,2));
                            aps = aps(aps<ups(uidx,3));

                            ccn = matnotes(sidx).CellOrder.CellChannels{cell};
                            chanmatch = strmatch(ccn,channels);
                            downvals = data([ups(uidx,1),ups(uidx,4)],chanmatch);
                            upvals = data(ups(uidx,2):ups(uidx,3),chanmatch);
                            amp = mean(upvals)- mean(downvals);
                            
                            tstrainupguide(cellnum,tstrainupnum) = 1;
                            tstraindurs(cellnum,tstrainupnum) = dur;
                            tstrainamps(cellnum,tstrainupnum) = amp;
                            tstrainaps(cellnum,tstrainupnum) = length(aps);
                            
                            thiscellhaststrain = 1;
                        end
                    end
                end
            end
%% pairwise comparisons: ratios and differences 
% Spont vs TsTrain
            if thiscellhaststrain & thiscellhasspont
                thisspontguide = spontupguide(cellnum,:);
                thiscellspontaps = spontaps(cellnum,thisspontguide);
                thiscellspontdurs = spontdurs(cellnum,thisspontguide);
                thiscellspontamps = spontamps(cellnum,thisspontguide);
                thiscellspontrate = 10000*sum(thiscellspontaps)/sum(thiscellspontdurs);
                
                thiststrainguide = tstrainupguide(cellnum,:);
                thiscelltstrainaps = tstrainaps(cellnum,thiststrainguide);
                thiscelltstraindurs = tstraindurs(cellnum,thiststrainguide);
                thiscelltstrainamps = tstrainamps(cellnum,thiststrainguide);
                thiscelltstrainrate = 10000*sum(thiscelltstrainaps)/sum(thiscelltstraindurs);
                
                ratiosptsrate(end+1) = thiscellspontrate/thiscelltstrainrate;
                diffsptsrate(end+1) = thiscellspontrate - thiscelltstrainrate;
                ratiosptsdur(end+1) = mean(thiscellspontdurs) / mean(thiscelltstraindurs);
                diffsptsdur(end+1) = mean(thiscellspontdurs) - mean(thiscelltstraindurs);
                ratiosptsamp(end+1) = mean(thiscellspontamps) / mean(thiscelltstrainamps);
                diffsptsamp(end+1) = mean(thiscellspontamps) - mean(thiscelltstrainamps);                                
            end
% WDTrain vs Spont
            if thiscellhaststrain & thiscellhaswdtrain
                thiswdtrainguide = wdtrainupguide(cellnum,:);
                thiscellwdtrainaps = wdtrainaps(cellnum,thiswdtrainguide);
                thiscellwdtraindurs = wdtraindurs(cellnum,thiswdtrainguide);
                thiscellwdtrainamps = wdtrainamps(cellnum,thiswdtrainguide);
                thiscellwdtrainrate = 10000*sum(thiscellwdtrainaps)/sum(thiscellwdtraindurs);
                
                thiststrainguide = tstrainupguide(cellnum,:);
                thiscelltstrainaps = tstrainaps(cellnum,thiststrainguide);
                thiscelltstraindurs = tstraindurs(cellnum,thiststrainguide);
                thiscelltstrainamps = tstrainamps(cellnum,thiststrainguide);
                thiscelltstrainrate = 10000*sum(thiscelltstrainaps)/sum(thiscelltstraindurs);
                
                ratiowdtsrate(end+1) = thiscellwdtrainrate/thiscelltstrainrate;
                diffwdtsrate(end+1) = thiscellwdtrainrate - thiscelltstrainrate;
                ratiowdtsdur(end+1) = mean(thiscellwdtraindurs) / mean(thiscelltstraindurs);
                diffwdtsdur(end+1) = mean(thiscellwdtraindurs) - mean(thiscelltstraindurs);
                ratiowdtsamp(end+1) = mean(thiscellwdtrainamps) / mean(thiscelltstrainamps);
                diffwdtsamp(end+1) = mean(thiscellwdtrainamps) - mean(thiscelltstrainamps);                                
            end
% WDTrain vs Spont
            if thiscellhasspont & thiscellhaswdtrain
                thiswdtrainguide = wdtrainupguide(cellnum,:);
                thiscellwdtrainaps = wdtrainaps(cellnum,thiswdtrainguide);
                thiscellwdtraindurs = wdtraindurs(cellnum,thiswdtrainguide);
                thiscellwdtrainamps = wdtrainamps(cellnum,thiswdtrainguide);
                thiscellwdtrainrate = 10000*sum(thiscellwdtrainaps)/sum(thiscellwdtraindurs);
                
                thisspontguide = spontupguide(cellnum,:);
                thiscellspontaps = spontaps(cellnum,thisspontguide);
                thiscellspontdurs = spontdurs(cellnum,thisspontguide);
                thiscellspontamps = spontamps(cellnum,thisspontguide);
                thiscellspontrate = 10000*sum(thiscellspontaps)/sum(thiscellspontdurs);
                
                ratiowdsprate(end+1) = thiscellwdtrainrate/thiscellspontrate;
                diffwdsprate(end+1) = thiscellwdtrainrate - thiscellspontrate;
                ratiowdspdur(end+1) = mean(thiscellwdtraindurs) / mean(thiscellspontdurs);
                diffwdspdur(end+1) = mean(thiscellwdtraindurs) - mean(thiscellspontdurs);
                ratiowdspamp(end+1) = mean(thiscellwdtrainamps) / mean(thiscellspontamps);
                diffwdspamp(end+1) = mean(thiscellwdtrainamps) - mean(thiscellspontamps);                                
            end
        end
    end
    disp(sidx)
end
max1 = max([size(wdtrainupguide,1) size(spontupguide,1) size(tstrainupguide,1)]);
max2 = max([size(wdtrainupguide,2) size(spontupguide,2) size(tstrainupguide,2)]);
wdtrainupguide(max1,max2) = 0;
spontupguide(max1,max2) = 0;
tstrainupguide(max1,max2) = 0;

wdtraincells = find(sum(wdtrainupguide,2));
spontcells = find(sum(spontupguide,2));
tstraincells = find(sum(tstrainupguide,2));
cellswithall = intersect(intersect(wdtraincells,spontcells),tstraincells);

wdtraintotaldurs = sum(wdtraindurs(wdtraincells,:),2);
wdtraintotalaps = sum(wdtrainaps(wdtraincells,:),2);
wdtraincellrates = wdtraintotalaps./(wdtraintotaldurs/10000);
wdtraincelldurs = [];
wdtraincellamps = [];
for cidx = 1:length(wdtraincells);
    thiscell = wdtraincells(cidx);
    thisguide = wdtrainupguide(thiscell,:);
    wdtraincelldurs(end+1) = mean(wdtraindurs(thiscell,thisguide),2);
    wdtraincellamps(end+1) = mean(wdtrainamps(thiscell,thisguide),2);
end
    
sponttotaldurs = sum(spontdurs(spontcells,:),2);
sponttotalaps = sum(spontaps(spontcells,:),2);
spontcellrates = sponttotalaps./(sponttotaldurs/10000);
spontcelldurs = [];
spontcellamps = [];
for cidx = 1:length(spontcells);
    thiscell = spontcells(cidx);
    thisguide = spontupguide(thiscell,:);
    spontcelldurs(end+1) = mean(spontdurs(thiscell,thisguide),2);
    spontcellamps(end+1) = mean(spontamps(thiscell,thisguide),2);
end

tstraintotaldurs = sum(tstraindurs(tstraincells,:),2);
tstraintotalaps = sum(tstrainaps(tstraincells,:),2);
tstraincellrates = tstraintotalaps./(tstraintotaldurs/10000);
tstraincelldurs = [];
tstraincellamps = [];
for cidx = 1:length(tstraincells);
    thiscell = tstraincells(cidx);
    thisguide = tstrainupguide(thiscell,:);
    tstraincelldurs(end+1) = mean(tstraindurs(thiscell,thisguide),2);
    tstraincellamps(end+1) = mean(tstrainamps(thiscell,thisguide),2);
end
%% For figure 1 (Rates Bar Graph)
means(1) = mean(spontcellrates);
means(2) = mean(tstraincellrates);
summedcellrates = mean(spontcellrates) + mean(tstraincellrates);
means(3) = summedcellrates;
means(4) = mean(wdtraincellrates);
sems(1) = sem(spontcellrates,1);
sems(2) = sem(tstraincellrates,1);
sems(3) = 0;
sems(4) = sem(wdtraincellrates,1);
spontrateresamples = resampledataset(spontcellrates,10000);
tstrainrateresamples = resampledataset(tstraincellrates,10000);
wdtrainrateresamples = resampledataset(wdtraincellrates,10000);
% calc prob of getting this diff of means for spont vs ts
svtrateexpecteddiffs = sort(abs(mean(spontrateresamples)-mean(tstrainrateresamples)));
svtp = find(svtrateexpecteddiffs>abs(mean(spontcellrates)-mean(tstraincellrates)));
svtp = length(svtp)/10000;
% calc prob of getting this diff of means for wdtrain vs spont
wvsrateexpecteddiffs = sort(abs(mean(wdtrainrateresamples)-mean(spontrateresamples)));
wvsp = find(wvsrateexpecteddiffs>abs(mean(wdtraincellrates)-mean(spontcellrates)));
wvsp = length(wvsp)/10000;
% calc prob of getting this diff of means for wdtrain vs tstrain
wvtrateexpecteddiffs = sort(abs(mean(wdtrainrateresamples)-mean(tstrainrateresamples)));
wvtp = find(wvtrateexpecteddiffs>abs(mean(wdtraincellrates)-mean(tstraincellrates)));
wvtp = length(wvtp)/10000;
% [h,svtp] = ttest2(spontcellrates,tstraincellrates);
% [h,wvsp] = ttest2(wdtraincellrates,spontcellrates);
% [h,wvtp] = ttest2(wdtraincellrates,tstraincellrates);
sumvsp = sum(mean(spontrateresamples)>summedcellrates)/10000;
sumvtp = sum(mean(tstrainrateresamples)>summedcellrates)/10000;
sumvwp = sum(mean(wdtrainrateresamples)>summedcellrates)/10000;

errorbargraph(means,sems);
ylabel('Spike Rate across UP States')
title({['Spike RATES.  10000 Reshuffles.'];
    ['1) Spont 2) TsTrain 3) Spont+TsTrain(Exp) 4) SpontInteraction (Obs).'];...
    ['p of SpVsTs = ',num2str(svtp),'. p of IntVsSp = ',num2str(wvsp),'.  p of IntVsTs = ',num2str(wvtp),'.'];...
    ['p of SumVsSp = ',num2str(sumvsp),'.  p of SumVsTs = ',num2str(sumvtp),'. p of SumVsInt = ',num2str(sumvwp),'.']});



%% For figure 2 (Durations Bar Graph)
means(1) = mean(spontcelldurs);
means(2) = mean(tstraincelldurs);
summedcelldurs = mean(spontcelldurs) + mean(tstraincelldurs);
means(3) = summedcelldurs;
means(4) = mean(wdtraincelldurs);
sems(1) = sem(spontcelldurs,2);
sems(2) = sem(tstraincelldurs,2);
sems(3) = 0;
sems(4) = sem(wdtraincelldurs,2);
spontdurresamples = resampledataset(spontcelldurs,10000);
tstraindurresamples = resampledataset(tstraincelldurs,10000);
wdtraindurresamples = resampledataset(wdtraincelldurs,10000);
% calc prob of getting this diff of means for spont vs ts
svtdurexpecteddiffs = sort(abs(mean(spontdurresamples)-mean(tstraindurresamples)));
svtp = find(svtdurexpecteddiffs>abs(mean(spontcelldurs)-mean(tstraincelldurs)));
svtp = length(svtp)/10000;
% calc prob of getting this diff of means for wdtrain vs spont
wvsdurexpecteddiffs = sort(abs(mean(wdtraindurresamples)-mean(spontdurresamples)));
wvsp = find(wvsdurexpecteddiffs>abs(mean(wdtraincelldurs)-mean(spontcelldurs)));
wvsp = length(wvsp)/10000;
% calc prob of getting this diff of means for wdtrain vs tstrain
wvtdurexpecteddiffs = sort(abs(mean(wdtraindurresamples)-mean(tstraindurresamples)));
wvtp = find(wvtdurexpecteddiffs>abs(mean(wdtraincelldurs)-mean(tstraincelldurs)));
wvtp = length(wvtp)/10000;
% [h,svtp] = ttest2(spontcelldurs,tstraincelldurs);
% [h,wvsp] = ttest2(wdtraincelldurs,spontcelldurs);
% [h,wvtp] = ttest2(wdtraincelldurs,tstraincelldurs);
sumvsp = sum(mean(spontdurresamples)>summedcelldurs)/10000;
sumvtp = sum(mean(tstraindurresamples)>summedcelldurs)/10000;
sumvwp = sum(mean(wdtraindurresamples)>summedcelldurs)/10000;

errorbargraph(means,sems);
ylabel('Duration across UP States (num samples)')
title({['Duration.  10000 Reshuffles.'];
    ['1) Spont 2) TsTrain 3) Spont+TsTrain(Exp) 4) SpontInteraction (Obs).'];...
    ['p of SpVsTs = ',num2str(svtp),'. p of IntVsSp = ',num2str(wvsp),'.  p of IntVsTs = ',num2str(wvtp),'.'];...
    ['p of SumVsSp = ',num2str(sumvsp),'.  p of SumVsTs = ',num2str(sumvtp),'. p of SumVsInt = ',num2str(sumvwp),'.']});


%% For figure 3 (Amplitudes Bar Graph)

means(1) = mean(spontcellamps);
means(2) = mean(tstraincellamps);
summedcellamps = mean(spontcellamps) + mean(tstraincellamps);
means(3) = summedcellamps;
means(4) = mean(wdtraincellamps);
sems(1) = sem(spontcellamps,2);
sems(2) = sem(tstraincellamps,2);
sems(3) = 0;
sems(4) = sem(wdtraincellamps,2);
spontampresamples = resampledataset(spontcellamps,10000);
tstrainampresamples = resampledataset(tstraincellamps,10000);
wdtrainampresamples = resampledataset(wdtraincellamps,10000);
% calc prob of getting this diff of means for spont vs ts
svtampexpecteddiffs = sort(abs(mean(spontampresamples)-mean(tstrainampresamples)));
svtp = find(svtampexpecteddiffs>abs(mean(spontcellamps)-mean(tstraincellamps)));
svtp = length(svtp)/10000;
% calc prob of getting this diff of means for wdtrain vs spont
wvsampexpecteddiffs = sort(abs(mean(wdtrainampresamples)-mean(spontampresamples)));
wvsp = find(wvsampexpecteddiffs>abs(mean(wdtraincellamps)-mean(spontcellamps)));
wvsp = length(wvsp)/10000;
% calc prob of getting this diff of means for wdtrain vs tstrain
wvtampexpecteddiffs = sort(abs(mean(wdtrainampresamples)-mean(tstrainampresamples)));
wvtp = find(wvtampexpecteddiffs>abs(mean(wdtraincellamps)-mean(tstraincellamps)));
wvtp = length(wvtp)/10000;
% [h,svtp] = ttest2(spontcellamps,tstraincellamps);
% [h,wvsp] = ttest2(wdtraincellamps,spontcellamps);
% [h,wvtp] = ttest2(wdtraincellamps,tstraincellamps);
sumvsp = sum(mean(spontampresamples)>summedcellamps)/10000;
sumvtp = sum(mean(tstrainampresamples)>summedcellamps)/10000;
sumvwp = sum(mean(wdtrainampresamples)>summedcellamps)/10000;

errorbargraph(means,sems);
ylabel('Amplitude across UP States (mV)')
title({['Amplitude.  10000 Reshuffles.'];
    ['1) Spont 2) TsTrain 3) Spont+TsTrain(Exp) 4) SpontInteraction (Obs).'];...
    ['p of SpVsTs = ',num2str(svtp),'. p of IntVsSp = ',num2str(wvsp),'.  p of IntVsTs = ',num2str(wvtp),'.'];...
    ['p of SumVsSp = ',num2str(sumvsp),'.  p of SumVsTs = ',num2str(sumvtp),'. p of SumVsInt = ',num2str(sumvwp),'.']});

%% Numbers output figure;

%ratios too messy
%getting rid of ratios with 0 numerator or denominator
% ratiowdsprate2 = ratiowdsprate(~isnan(ratiowdsprate));
% ratiowdsprate2 = log(ratiowdsprate2(abs(ratiowdsprate2)<Inf));
% ratiowdspdur2 = ratiowdspdur(~isnan(ratiowdspdur));
% ratiowdspdur2 = log(ratiowdspdur2(abs(ratiowdspdur2)<Inf));
% ratiowdspamp2 = ratiowdspamp(~isnan(ratiowdspamp));
% ratiowdspamp2 = log(ratiowdspamp2(abs(ratiowdspamp2)<Inf));
% %
% ratiowdtsrate2 = ratiowdtsrate(~isnan(ratiowdtsrate));
% ratiowdtsrate2 = log(ratiowdtsrate2(ratiowdtsrate2<Inf));
% ratiowdtsdur2 = ratiowdtsdur(~isnan(ratiowdtsdur));
% ratiowdtsdur2 = log(ratiowdtsdur2(ratiowdtsdur2<Inf));
% ratiowdtsamp2 = ratiowdtsamp(~isnan(ratiowdtsamp));
% ratiowdtsamp2 = log(ratiowdtsamp2(ratiowdtsamp2<Inf));
% %
% ratiosptsrate2 = ratiosptsrate(~isnan(ratiosptsrate));
% ratiosptsrate2 = log(ratiosptsrate2(ratiosptsrate2<Inf));
% ratiosptsdur2 = ratiosptsdur(~isnan(ratiosptsdur));
% ratiosptsdur2 = log(ratiosptsdur2(ratiosptsdur2<Inf));
% ratiosptsamp2 = ratiosptsamp(~isnan(ratiosptsamp));
% ratiosptsamp2 = log(ratiosptsamp2(ratiosptsamp2<Inf));

%p's for diffs
[h,diffwdsprateP]=ttest(diffwdsprate);%are diffs different from 0 mean
[h,diffwdspdurP]=ttest(diffwdspdur);
[h,diffwdspampP]=ttest(diffwdspamp);
[h,diffwdtsrateP]=ttest(diffwdtsrate);%are diffs different from 0 mean
[h,diffwdtsdurP]=ttest(diffwdtsdur);
[h,diffwdtsampP]=ttest(diffwdtsamp);
[h,diffsptsrateP]=ttest(diffsptsrate);%are diffs different from 0 mean
[h,diffsptsdurP]=ttest(diffsptsdur);
[h,diffsptsampP]=ttest(diffsptsamp);
% %p's for ratios
% [h,ratiowdsprateP]=ttest(ratiowdsprate2);%are ratios ratioerent from 0 mean
% [h,ratiowdspdurP]=ttest(ratiowdspdur2);
% [h,ratiowdspampP]=ttest(ratiowdspamp2);
% [h,ratiowdtsrateP]=ttest(ratiowdtsrate2);%are ratios ratioerent from 0 mean
% [h,ratiowdtsdurP]=ttest(ratiowdtsdur2);
% [h,ratiowdtsampP]=ttest(ratiowdtsamp2);
% [h,ratiosptsrateP]=ttest(ratiosptsrate2);%are ratios ratioerent from 0
% mean
% [h,ratiosptsdurP]=ttest(ratiosptsdur2);
% [h,ratiosptsampP]=ttest(ratiosptsamp2);

figure('units','pixels','position',[500   300   600   750]);
axes('position',[0 0 1 1],'color',[.8 .8 .8]);
axis off
displaytext = {'GENERAL MEASURES FOR EACH CONDITION';...
    ['WdTrain.  (n=',num2str(length(wdtraincellrates)),' cells)'];...
    ['WdTrain Rate: Mean=',num2str(mean(wdtraincellrates)),'APs/Sec.  SD=',num2str(std(wdtraincellrates)),'.  SEM=',num2str(sem(wdtraincellrates)),'.'];...
    ['WdTrain Duration: Mean=',num2str(mean(wdtraincelldurs)),' samples.  SD=',num2str(std(wdtraincelldurs)),'.  SEM=',num2str(sem(wdtraincelldurs')),'.'];...
    ['WdTrain Amplitude: Mean=',num2str(mean(wdtraincellamps)),'mV.  SD=',num2str(std(wdtraincellamps)),'.  SEM=',num2str(sem(wdtraincellrates)),'.'];...
    ' ';...
    ['Spont.  (n=',num2str(length(spontcellrates)),' cells)'];...
    ['Spont Rate: Mean=',num2str(mean(spontcellrates)),'APs/Sec.  SD=',num2str(std(spontcellrates)),'.  SEM=',num2str(sem(spontcellrates)),'.'];...
    ['Spont Duration: Mean=',num2str(mean(spontcelldurs)),' samples.  SD=',num2str(std(spontcelldurs)),'.  SEM=',num2str(sem(spontcelldurs')),'.'];...
    ['Spont Amplitude: Mean=',num2str(mean(spontcellamps)),'mV.  SD=',num2str(std(spontcellamps)),'.  SEM=',num2str(sem(spontcellrates)),'.'];...
    ' ';...
    ['TsTrain.  (n=',num2str(length(tstraincellrates)),' cells)'];...
    ['TsTrain Rate: Mean=',num2str(mean(tstraincellrates)),'APs/Sec.  SD=',num2str(std(tstraincellrates)),'.  SEM=',num2str(sem(tstraincellrates)),'.'];...
    ['TsTrain Duration: Mean=',num2str(mean(tstraincelldurs)),' samples.  SD=',num2str(std(tstraincelldurs)),'.  SEM=',num2str(sem(tstraincelldurs')),'.'];...
    ['TsTrain Amplitude: Mean=',num2str(mean(tstraincellamps)),'mV.  SD=',num2str(std(tstraincellamps)),'.  SEM=',num2str(sem(tstraincellrates)),'.'];...
    ' ';...
    ' ';...
    'COMPARATIVE MEASURES ACROSS PAIRS OF CONDITIONS: DIFFERENCES';...
    ['WdTrain vs Spont. (n = ',num2str(length(diffwdsprate)),')'];...
    ['WdTrain-Spont Rate Diff: Mean=',num2str(mean(diffwdsprate)),'APs/Sec.  SD=',num2str(std(diffwdsprate)),'.  SEM=',num2str(sem(diffwdsprate')),'.'];...
    ['p = ',num2str(diffwdsprateP),' by one tailed ttest (testing whether gaussian with mean = 0)'];...
    ['WdTrain-Spont Dur Diff: Mean=',num2str(mean(diffwdspdur)),' sample  SD=',num2str(std(diffwdspdur)),'.  SEM=',num2str(sem(diffwdspdur')),'.'];...
    ['p = ',num2str(diffwdspdurP),' by one tailed ttest (testing whether gaussian with mean = 0)'];...
    ['WdTrain-Spont Amp Diff: Mean=',num2str(mean(diffwdspamp)),'mV.  SD=',num2str(std(diffwdspamp)),'.  SEM=',num2str(sem(diffwdspamp')),'.'];...
    ['p = ',num2str(diffwdspampP),' by one tailed ttest (testing whether gaussian with mean = 0)'];...
    ' ';...
    ['WdTrain vs TsTrain. (n = ',num2str(length(diffwdtsrate)),')'];...
    ['WdTrain-TsTrain Rate Diff: Mean=',num2str(mean(diffwdtsrate)),'APs/Sec.  SD=',num2str(std(diffwdtsrate)),'.  SEM=',num2str(sem(diffwdtsrate')),'.'];...
    ['p = ',num2str(diffwdtsrateP),' by one tailed ttest (testing whether gaussian with mean = 0)'];...
    ['WdTrain-TsTrain Dur Diff: Mean=',num2str(mean(diffwdtsdur)),' sample  SD=',num2str(std(diffwdtsdur)),'.  SEM=',num2str(sem(diffwdtsdur')),'.'];...
    ['p = ',num2str(diffwdtsdurP),' by one tailed ttest (testing whether gaussian with mean = 0)'];...
    ['WdTrain-TsTrain Amp Diff: Mean=',num2str(mean(diffwdtsamp)),'mV.  SD=',num2str(std(diffwdtsamp)),'.  SEM=',num2str(sem(diffwdtsamp')),'.'];...
    ['p = ',num2str(diffwdtsampP),' by one tailed ttest (testing whether gaussian with mean = 0)'];...
    ' ';...
    ['Spont vs TsTrain. (n = ',num2str(length(diffsptsrate)),')'];...
    ['Spont-TsTrain Rate Diff: Mean=',num2str(mean(diffsptsrate)),'APs/Sec.  SD=',num2str(std(diffsptsrate)),'.  SEM=',num2str(sem(diffsptsrate')),'.'];...
    ['p = ',num2str(diffsptsrateP),' by one tailed ttest (testing whether gaussian with mean = 0)'];...
    ['Spont-TsTrain Dur Diff: Mean=',num2str(mean(diffsptsdur)),' sample  SD=',num2str(std(diffsptsdur)),'.  SEM=',num2str(sem(diffsptsdur')),'.'];...
    ['p = ',num2str(diffsptsdurP),' by one tailed ttest (testing whether gaussian with mean = 0)'];...
    ['Spont-TsTrain Amp Diff: Mean=',num2str(mean(diffsptsamp)),'mV.  SD=',num2str(std(diffsptsamp)),'.  SEM=',num2str(sem(diffsptsamp')),'.'];...
    ['p = ',num2str(diffsptsampP),' by one tailed ttest (testing whether gaussian with mean = 0)'];...
    ' ';...
    ' ';...
%     'COMPARATIVE MEASURES ACROSS PAIRS OF CONDITIONS: LOG OF RATIOS';...
%     ['WdTrain vs Spont. (n = ',num2str(length(ratiowdtsrate)),')'];...
%     ['WdTrain-Spont Rate Ratio: Mean=',num2str(mean(ratiowdsprate2)),'APs/Sec.  SD=',num2str(std(ratiowdsprate2)),'.  SEM=',num2str(sem(ratiowdsprate2')),'.'];...
%     ['p = ',num2str(ratiowdsprateP),' by one tailed ttest (testing whether gaussian with mean = 0).  n=',num2str(length(ratiowdsprate2)),'.'];...
%     ['WdTrain-Spont Dur Ratio: Mean=',num2str(mean(ratiowdspdur2)),' sample  SD=',num2str(std(ratiowdspdur2)),'.  SEM=',num2str(sem(ratiowdspdur2')),'.'];...
%     ['p = ',num2str(ratiowdspdurP),' by one tailed ttest (testing whether gaussian with mean = 0).  n=',num2str(length(ratiowdspdur2)),'.'];...
%     ['WdTrain-Spont Rate Ratio: Mean=',num2str(mean(ratiowdspamp2)),'mV.  SD=',num2str(std(ratiowdspamp2)),'.  SEM=',num2str(sem(ratiowdspamp2')),'.'];...
%     ['p = ',num2str(ratiowdspampP),' by one tailed ttest (testing whether gaussian with mean = 0).  n=',num2str(length(ratiowdsprate2)),'.'];...
%     ' ';...
%     ['WdTrain vs TsTrain. (n = ',num2str(length(ratiowdtsrate)),')'];...
%     ['WdTrain-TsTrain Rate Ratio: Mean=',num2str(mean(ratiowdtsrate2)),'APs/Sec.  SD=',num2str(std(ratiowdtsrate2)),'.  SEM=',num2str(sem(ratiowdtsrate2')),'.'];...
%     ['p = ',num2str(ratiowdtsrateP),' by one tailed ttest (testing whether gaussian with mean = 0).  n=',num2str(length(ratiowdtsrate2)),'.'];...
%     ['WdTrain-TsTrain Dur Ratio: Mean=',num2str(mean(ratiowdtsdur2)),' sample  SD=',num2str(std(ratiowdtsdur2)),'.  SEM=',num2str(sem(ratiowdtsdur2')),'.'];...
%     ['p = ',num2str(ratiowdtsdurP),' by one tailed ttest (testing whether gaussian with mean = 0).  n=',num2str(length(ratiowdtsdur2)),'.'];...
%     ['WdTrain-TsTrain Rate Ratio: Mean=',num2str(mean(ratiowdtsamp2)),'mV.  SD=',num2str(std(ratiowdtsamp2)),'.  SEM=',num2str(sem(ratiowdtsamp2')),'.'];...
%     ['p = ',num2str(ratiowdtsampP),' by one tailed ttest (testing whether gaussian with mean = 0).  n=',num2str(length(ratiowdtsamp2)),'.'];...
%     ' ';...
%     ['Spont vs TsTrain. (n = ',num2str(length(ratiosptsrate)),')'];...
%     ['Spont-TsTrain Rate Ratio: Mean=',num2str(mean(ratiosptsrate2)),'APs/Sec.  SD=',num2str(std(ratiosptsrate2)),'.  SEM=',num2str(sem(ratiosptsrate2')),'.'];...
%     ['p = ',num2str(ratiosptsrateP),' by one tailed ttest (testing whether gaussian with mean = 0).  n=',num2str(length(ratiosptsrate2)),'.'];...
%     ['Spont-TsTrain Dur Ratio: Mean=',num2str(mean(ratiosptsdur2)),' sample  SD=',num2str(std(ratiosptsdur2)),'.  SEM=',num2str(sem(ratiosptsdur2')),'.'];...
%     ['p = ',num2str(ratiosptsdurP),' by one tailed ttest (testing whether gaussian with mean = 0).  n=',num2str(length(ratiosptsdur2)),'.'];...
%     ['Spont-TsTrain Rate Ratio: Mean=',num2str(mean(ratiosptsamp2)),'mV.  SD=',num2str(std(ratiosptsamp2)),'.  SEM=',num2str(sem(ratiosptsamp2)),'.'];...
%     ['p = ',num2str(ratiosptsampP),' by one tailed ttest (testing whether gaussian with mean = 0).  n=',num2str(length(ratiosptsamp2)),'.'];...
    };

text(0,.5,displaytext);

% cellswithall = intersect(intersect(wdtraincells,spontcells),tstraincells);
% tstraintotaldurs = sum(tstraindurs(cellswithall,:),2);
% tstraintotalaps = sum(tstrainaps(cellswithall,:),2);
% tstrainrates = tstraintotalaps./(tstraintotaldurs/10000);
% wdtraintotaldurs = sum(wdtraindurs(cellswithall,:),2);
% wdtraintotalaps = sum(wdtrainaps(cellswithall,:),2);
% wdtrainrates = wdtraintotalaps./(wdtraintotaldurs/10000);
% sponttotaldurs = sum(spontdurs(cellswithall,:),2);
% sponttotalaps = sum(spontaps(cellswithall,:),2);
% spontrates = sponttotalaps./(sponttotaldurs/10000);
% 
% spontrates = spontrates./spontrates;
% wdtrainrates = wdtrainrates./spontrates;
% tstrainrates = tstrainrates./spontrates;
% rates = [mean(spontrates(~isnan(spontrates))),mean(wdtrainrates(~isnan(wdtrainrates))),mean(tstrainrates(~isnan(tstrainrates)))];
% figure;bar([1 2 3],rates,.6);
% 1;
% % wilcoxan
% % set(f,'userdata',results);