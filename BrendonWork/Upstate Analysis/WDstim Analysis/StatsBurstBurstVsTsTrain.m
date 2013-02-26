function results = StatsBurstBurstVsTsTrain(matnotes,stimnum,varargin)

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
burstbupguide = logical([]);
tstrainupguide = logical([]);
ratiobbtsrate = [];
diffbbtsrate = [];
ratiobbtsdur = [];
diffbbtsdur = [];
ratiobbtsamp = [];
diffbbtsamp = [];


for sidx = 1:size(matnotes,2);
    for cell = 1:4%go through all cells that had spiking ups
        cellnum = 4*(sidx-1)+cell;
        thiscellhaststrain = 0;
        thiscellhasburstb = 0;
        burstbupnum = 0;
        spontupnum = 0;
        tstrainupnum = 0;
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
        thiscellhasstiminup = 0;%to allow for later recording data seprarately for cells with stim in ups versus those without
        cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};%set up to test for direct input or not
        eval(eval(distring));%eval direct input or not of each cell... makes tempvar for next line        
        if tempvar;%if it passes muster
            for tidx = 1:size(matnotes(sidx).trial,2)%go through each trial
                if ~strcmp(matnotes(sidx).trial(tidx).stim,'wdtrain')%if the trial is NOT 'wdtrain'
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
%% note: special for burst burst
                                                if in6(1)<ups(uidx,1)%for burstburst or tonicburst... make sure stim started before up, (while interaction stim was during up)
                                                    stiminup = 1;%stim in up used later to record stats specifically 
    %                                                 thiscellhasstiminup = 1;
                                                    break
                                                end
                                            end
                                        end
%%
                                        if stiminup
                                            if sum(loadedfile - [sidx tidx]);%if abf not loaded, load it
                                                abfpath1 = matnotes(sidx).trial(tidx).ephys.abfname;
                                %                 abfpath = ['C:\Exchange\Data\Axon Data\',abfpath];
                                %                 abfpath = ['E:\Abeles Data Folder\Axon Data\',abfpath];
                    %                             abfpath = ['D:\Exchange\Data\Axon Data\',abfpath];
                    %                             [data,trash,channels]=abfload(abfpath);
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
                                                burstbupnum = burstbupnum+1;
                                                dur = ups(uidx,3)-ups(uidx,2);
                                                
%                                                 aps = matnotes(sidx).trial(tidx).ephys.cell(cell).aps;
                                                aps = aps(aps>ups(uidx,2));
                                                aps = aps(aps<ups(uidx,3));

                                                ccn = matnotes(sidx).CellOrder.CellChannels{cell};
                                                chanmatch = strmatch(ccn,channels);
                                                downvals = data([ups(uidx,1),ups(uidx,4)],chanmatch);
                                                upvals = data(ups(uidx,2):ups(uidx,3),chanmatch);
                                                amp = mean(upvals)- mean(downvals);
                                                
                                                burstbupguide(cellnum,burstbupnum) = 1;
                                                burstbdurs(cellnum,burstbupnum) = dur;
                                                burstbamps(cellnum,burstbupnum) = amp;
                                                burstbaps(cellnum,burstbupnum) = length(aps);
                                                
                                                thiscellhasburstb= 1;
                                            end
                                        end
                                    end
%                                 end
                            end
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
%                             abfpath = ['D:\Exchange\Data\Axon Data\',abfpath];
%                             [data,trash,channels]=abfload(abfpath);
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
% BurstB vs TsTrain
            if thiscellhaststrain & thiscellhasburstb
                thisburstbguide = burstbupguide(cellnum,:);
                thiscellburstbaps = burstbaps(cellnum,thisburstbguide);
                thiscellburstbdurs = burstbdurs(cellnum,thisburstbguide);
                thiscellburstbamps = burstbamps(cellnum,thisburstbguide);
                thiscellburstbrate = 10000*sum(thiscellburstbaps)/sum(thiscellburstbdurs);
                
                thiststrainguide = tstrainupguide(cellnum,:);
                thiscelltstrainaps = tstrainaps(cellnum,thiststrainguide);
                thiscelltstraindurs = tstraindurs(cellnum,thiststrainguide);
                thiscelltstrainamps = tstrainamps(cellnum,thiststrainguide);
                thiscelltstrainrate = 10000*sum(thiscelltstrainaps)/sum(thiscelltstraindurs);
                
                ratiobbtsrate(end+1) = thiscellburstbrate/thiscelltstrainrate;
                diffbbtsrate(end+1) = thiscellburstbrate - thiscelltstrainrate;
                ratiobbtsdur(end+1) = mean(thiscellburstbdurs) / mean(thiscelltstraindurs);
                diffbbtsdur(end+1) = mean(thiscellburstbdurs) - mean(thiscelltstraindurs);
                ratiobbtsamp(end+1) = mean(thiscellburstbamps) / mean(thiscelltstrainamps);
                diffbbtsamp(end+1) = mean(thiscellburstbamps) - mean(thiscelltstrainamps);                                
            end

%% to record data for each cell
%             thiscellburstbdurs = burstbdurs(:,cell);
%             thiscellburstbdurs = thiscellburstbdurs(thiscellburstbdurs~=0);
%             thiscellspontdurs = spontdurs(:,cell);
%             thiscellspontdurs = thiscellspontdurs((thiscellspontdurs~=0));
%             thiscelltstraindurs = tstraindurs(:,cell);
%             thiscelltstraindurs = thiscelltstraindurs(thiscelltstraindurs~=0);
        end
    end
    disp(sidx)
end
max1 = max([size(burstbupguide,1) size(tstrainupguide,1)]);
max2 = max([size(burstbupguide,2) size(tstrainupguide,2)]);
burstbupguide(max1,max2) = 0;
tstrainupguide(max1,max2) = 0;

burstbcells = find(sum(burstbupguide,2));
tstraincells = find(sum(tstrainupguide,2));
cellswithall = intersect(burstbcells,tstraincells);

burstbtotaldurs = sum(burstbdurs(burstbcells,:),2);
burstbtotalaps = sum(burstbaps(burstbcells,:),2);
burstbcellrates = burstbtotalaps./(burstbtotaldurs/10000);
burstbcelldurs = [];
burstbcellamps = [];
for cidx = 1:length(burstbcells);
    thiscell = burstbcells(cidx);
    thisguide = burstbupguide(thiscell,:);
    burstbcelldurs(end+1) = mean(burstbdurs(thiscell,thisguide),2);
    burstbcellamps(end+1) = mean(burstbamps(thiscell,thisguide),2);
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
means(1) = mean(tstraincellrates);
summedcellrates = 2* mean(tstraincellrates);
means(2) = summedcellrates;
means(3) = mean(burstbcellrates);
sems(1) = sem(tstraincellrates,1);
sems(2) = 0;
sems(3) = sem(burstbcellrates,1);
tstrainrateresamples = resampledataset(tstraincellrates,10000);
burstbrateresamples = resampledataset(burstbcellrates,10000);
% calc prob of getting this diff of means for burstb vs tstrain
bvtrateexpecteddiffs = sort(abs(mean(burstbrateresamples)-mean(tstrainrateresamples)));
bvtp = find(bvtrateexpecteddiffs>abs(mean(burstbcellrates)-mean(tstraincellrates)));
bvtp = length(bvtp)/10000;
% [h,svtp] = ttest2(spontcellrates,tstraincellrates);
% [h,wvsp] = ttest2(burstbcellrates,spontcellrates);
% [h,wvtp] = ttest2(burstbcellrates,tstraincellrates);
sumvtp = sum(mean(tstrainrateresamples)>summedcellrates)/10000;
sumvbp = sum(mean(burstbrateresamples)>summedcellrates)/10000;

errorbargraph(means,sems);
ylabel('Spike Rate across UP States (AP/sec)')
title({['Spike RATES.  10000 Reshuffles.'];
    ['1) TsTrain 2) 2xTsTrain(Exp) 3) StimInteraction (Obs).'];...
    ['p of IntVsTs = ',num2str(bvtp),'.'];...
    ['p of SumVsTs = ',num2str(sumvtp),'. p of SumVsInt = ',num2str(sumvbp),'.']});



%% For figure 2 (Duratoins Bar Graph)
means(1) = mean(tstraincelldurs);
summedcelldurs = 2* mean(tstraincelldurs);
means(2) = summedcelldurs;
means(3) = mean(burstbcelldurs);
sems(1) = sem(tstraincelldurs,2);
sems(2) = 0;
sems(3) = sem(burstbcelldurs,2);
tstraindurresamples = resampledataset(tstraincelldurs,10000);
burstbdurresamples = resampledataset(burstbcelldurs,10000);
% calc prob of getting this diff of means for burstb vs tstrain
bvtdurexpecteddiffs = sort(abs(mean(burstbdurresamples)-mean(tstraindurresamples)));
bvtp = find(bvtdurexpecteddiffs>abs(mean(burstbcelldurs)-mean(tstraincelldurs)));
bvtp = length(bvtp)/10000;
% [h,svtp] = ttest2(spontcelldurs,tstraincelldurs);
% [h,wvsp] = ttest2(burstbcelldurs,spontcelldurs);
% [h,wvtp] = ttest2(burstbcelldurs,tstraincelldurs);
sumvtp = sum(mean(tstraindurresamples)>summedcelldurs)/10000;
sumvbp = sum(mean(burstbdurresamples)>summedcelldurs)/10000;

errorbargraph(means,sems);
ylabel('Duration of UP States (num samples)')
title({['UP State Duration.  10000 Reshuffles.'];
    ['1) TsTrain 2)2xTsTrain(Exp) 3) StimInteraction (Obs).'];...
    ['p of IntVsTs = ',num2str(bvtp),'.'];...
    ['p of SumVsTs = ',num2str(sumvtp),'. p of SumVsInt = ',num2str(sumvbp),'.']});


%% For figure 3 (Amplitudes Bar Graph)

means(1) = mean(tstraincellamps);
summedcellamps = 2*mean(tstraincellamps);
means(2) = summedcellamps;
means(3) = mean(burstbcellamps);
sems(1) = sem(tstraincellamps,2);
sems(2) = 0;
sems(3) = sem(burstbcellamps,2);
tstrainampresamples = resampledataset(tstraincellamps,10000);
burstbampresamples = resampledataset(burstbcellamps,10000);
% calc prob of getting this diff of means for burstb vs tstrain
bvtampexpecteddiffs = sort(abs(mean(burstbampresamples)-mean(tstrainampresamples)));
bvtp = find(bvtampexpecteddiffs>abs(mean(burstbcellamps)-mean(tstraincellamps)));
bvtp = length(bvtp)/10000;
% [h,svtp] = ttest2(spontcellamps,tstraincellamps);
% [h,wvsp] = ttest2(burstbcellamps,spontcellamps);
% [h,wvtp] = ttest2(burstbcellamps,tstraincellamps);
sumvtp = sum(mean(tstrainampresamples)>summedcellamps)/10000;
sumvbp = sum(mean(burstbampresamples)>summedcellamps)/10000;

errorbargraph(means,sems);
ylabel('Amplitude UP States (mV)')
title({['UP State AMPLITUDE.  10000 Reshuffles.'];
    ['1) TsTrain 2) 2xTsTrain(Exp) 3) StimInteraction (Obs).'];...
    ['p of IntVsTs = ',num2str(bvtp),'.'];...
    ['p of SumVsTs = ',num2str(sumvtp),'. p of SumVsInt = ',num2str(sumvbp),'.']});

%% Numbers output figure;

%ratios too messy
%getting rid of ratios with 0 numerator or denominator
% ratiobbtsrate2 = ratiobbtsrate(~isnan(ratiobbtsrate));
% ratiobbtsrate2 = log(ratiobbtsrate2(ratiobbtsrate2<Inf));
% ratiobbtsdur2 = ratiobbtsdur(~isnan(ratiobbtsdur));
% ratiobbtsdur2 = log(ratiobbtsdur2(ratiobbtsdur2<Inf));
% ratiobbtsamp2 = ratiobbtsamp(~isnan(ratiobbtsamp));
% ratiobbtsamp2 = log(ratiobbtsamp2(ratiobbtsamp2<Inf));
%p's for diffs
[h,diffbbtsrateP]=ttest(diffbbtsrate);%are diffs different from 0 mean
[h,diffbbtsdurP]=ttest(diffbbtsdur);
[h,diffbbtsampP]=ttest(diffbbtsamp);
% %p's for ratios
% [h,ratiobbtsrateP]=ttest(ratiobbtsrate2);%are ratios ratioerent from 0 mean
% [h,ratiobbtsdurP]=ttest(ratiobbtsdur2);
% [h,ratiobbtsampP]=ttest(ratiobbtsamp2);

figure;
axes('position',[0 0 1 1],'color',[.8 .8 .8]);
axis off
displaytext = {'GENERAL MEASURES FOR EACH CONDITION';...
    ['BurstB.  (n=',num2str(length(burstbcellrates)),' cells)'];...
    ['BurstB Rate: Mean=',num2str(mean(burstbcellrates)),'APs/Sec.  SD=',num2str(std(burstbcellrates)),'.  SEM=',num2str(sem(burstbcellrates)),'.'];...
    ['BurstB Duration: Mean=',num2str(mean(burstbcelldurs)),' samples.  SD=',num2str(std(burstbcelldurs)),'.  SEM=',num2str(sem(burstbcelldurs')),'.'];...
    ['BurstB Amplitude: Mean=',num2str(mean(burstbcellamps)),'mV.  SD=',num2str(std(burstbcellamps)),'.  SEM=',num2str(sem(burstbcellrates)),'.'];...
    ' ';...
    ['TsTrain.  (n=',num2str(length(tstraincellrates)),' cells)'];...
    ['TsTrain Rate: Mean=',num2str(mean(tstraincellrates)),'APs/Sec.  SD=',num2str(std(tstraincellrates)),'.  SEM=',num2str(sem(tstraincellrates)),'.'];...
    ['TsTrain Duration: Mean=',num2str(mean(tstraincelldurs)),' samples.  SD=',num2str(std(tstraincelldurs)),'.  SEM=',num2str(sem(tstraincelldurs')),'.'];...
    ['TsTrain Amplitude: Mean=',num2str(mean(tstraincellamps)),'mV.  SD=',num2str(std(tstraincellamps)),'.  SEM=',num2str(sem(tstraincellrates)),'.'];...
    ' ';...
    ' ';...
    'COMPARATIVE MEASURES ACROSS PAIRS OF CONDITIONS: DIFFERENCES';...
    ['BurstB vs TsTrain. (n = ',num2str(length(diffbbtsrate)),')'];...
    ['BurstB-TsTrain Rate Diff: Mean=',num2str(mean(diffbbtsrate)),'APs/Sec.  SD=',num2str(std(diffbbtsrate)),'.  SEM=',num2str(sem(diffbbtsrate')),'.'];...
    ['p = ',num2str(diffbbtsrateP),' by one tailed ttest (testing whether gaussian with mean = 0)'];...
    ['BurstB-TsTrain Dur Diff: Mean=',num2str(mean(diffbbtsdur)),' sample  SD=',num2str(std(diffbbtsdur)),'.  SEM=',num2str(sem(diffbbtsdur')),'.'];...
    ['p = ',num2str(diffbbtsdurP),' by one tailed ttest (testing whether gaussian with mean = 0)'];...
    ['BurstB-TsTrain Amp Diff: Mean=',num2str(mean(diffbbtsamp)),'mV.  SD=',num2str(std(diffbbtsamp)),'.  SEM=',num2str(sem(diffbbtsamp')),'.'];...
    ['p = ',num2str(diffbbtsampP),' by one tailed ttest (testing whether gaussian with mean = 0)'];...
    };

text(0,.5,displaytext);


% cellswithall = intersect(intersect(burstbcells,spontcells),tstraincells);
% tstraintotaldurs = sum(tstraindurs(cellswithall,:),2);
% tstraintotalaps = sum(tstrainaps(cellswithall,:),2);
% tstrainrates = tstraintotalaps./(tstraintotaldurs/10000);
% burstbtotaldurs = sum(burstbdurs(cellswithall,:),2);
% burstbtotalaps = sum(burstbaps(cellswithall,:),2);
% burstbrates = burstbtotalaps./(burstbtotaldurs/10000);
% sponttotaldurs = sum(spontdurs(cellswithall,:),2);
% sponttotalaps = sum(spontaps(cellswithall,:),2);
% spontrates = sponttotalaps./(sponttotaldurs/10000);
% 
% spontrates = spontrates./spontrates;
% burstbrates = burstbrates./spontrates;
% tstrainrates = tstrainrates./spontrates;
% rates = [mean(spontrates(~isnan(spontrates))),mean(burstbrates(~isnan(burstbrates))),mean(tstrainrates(~isnan(tstrainrates)))];
% figure;bar([1 2 3],rates,.6);
% 1;
% % wilcoxan
% % set(f,'userdata',results);