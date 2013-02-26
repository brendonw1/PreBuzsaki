function results = StatsUPvsUPWStim(matnotes,stimnum,varargin)

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
upstimupguide = logical([]);
upupguide = logical([]);
ratiousuprate = [];
diffusuprate = [];
ratiousupdur = [];
diffusupdur = [];
ratiousupamp = [];
diffusupamp = [];

for sidx = 1:size(matnotes,2);
    for cell = 1:4%go through all cells that had spiking ups
        cellnum = 4*(sidx-1)+cell;
        thiscellhasup = 0;
        thiscellhasupstim = 0;
        upstimupnum = 0;
        upupnum = 0;
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
%                 if ~strcmp(matnotes(sidx).trial(tidx).stim,'wdtrain')%if the trial is NOT 'wdtrain'
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
                                            if timeref>=ups(uidx,2) && timeref<=ups(uidx,3);
% %% note: special for burst burst
%                                                 if in6(1)<ups(uidx,1)%for burstburst or tonicburst... make sure stim started before up, (while interaction stim was during up)
                                                    stiminup = 1;%stim in up used later to record stats specifically 
    %                                                 thiscellhasstiminup = 1;
                                                    break
%                                                 end
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
                                                upstimupnum = upstimupnum+1;
                                                dur = ups(uidx,3)-ups(uidx,2);
                                                
%                                                 aps = matnotes(sidx).trial(tidx).ephys.cell(cell).aps;
                                                aps = aps(aps>ups(uidx,2));
                                                aps = aps(aps<ups(uidx,3));

                                                ccn = matnotes(sidx).CellOrder.CellChannels{cell};
                                                chanmatch = strmatch(ccn,channels);
                                                downvals = data([ups(uidx,1),ups(uidx,4)],chanmatch);
                                                upvals = data(ups(uidx,2):ups(uidx,3),chanmatch);
                                                amp = mean(upvals)- mean(downvals);
                                                
                                                upstimupguide(cellnum,upstimupnum) = 1;
                                                upstimdurs(cellnum,upstimupnum) = dur;
                                                upstimamps(cellnum,upstimupnum) = amp;
                                                upstimaps(cellnum,upstimupnum) = length(aps);
                                                
                                                thiscellhasupstim= 1;
                                            end
                                        end
                                    end
%                                 end
                            end
                        end
                    end
%                 end
%% Evaluate UPStates spiking for same cell
                if strcmp(matnotes(sidx).trial(tidx).stim,'tstrain') || strcmp(matnotes(sidx).trial(tidx).stim,'spont')%if the trial is 'spont'
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
                            upupnum = upupnum+1;
                            dur = ups(uidx,3)-ups(uidx,2);

%                                 aps = matnotes(sidx).trial(tidx).ephys.cell(cell).aps;
                            aps = aps(aps>ups(uidx,2));
                            aps = aps(aps<ups(uidx,3));

                            ccn = matnotes(sidx).CellOrder.CellChannels{cell};
                            chanmatch = strmatch(ccn,channels);
                            downvals = data([ups(uidx,1),ups(uidx,4)],chanmatch);
                            upvals = data(ups(uidx,2):ups(uidx,3),chanmatch);
                            amp = mean(upvals)- mean(downvals);
                            
                            upupguide(cellnum,upupnum) = 1;
                            updurs(cellnum,upupnum) = dur;
                            upamps(cellnum,upupnum) = amp;
                            upaps(cellnum,upupnum) = length(aps);
                            thiscellhasup = 1;
                        end
                    end
                end
            end
%% pairwise comparisons: ratios and differences 
% UPStim vs UPStates
            if thiscellhasup && thiscellhasupstim
                thisupstimguide = upstimupguide(cellnum,:);
                thiscellupstimaps = upstimaps(cellnum,thisupstimguide);
                thiscellupstimdurs = upstimdurs(cellnum,thisupstimguide);
                thiscellupstimamps = upstimamps(cellnum,thisupstimguide);
                thiscellburstbrate = 10000*sum(thiscellupstimaps)/sum(thiscellupstimdurs);
                
                thisupguide = upupguide(cellnum,:);
                thiscellupaps = upaps(cellnum,thisupguide);
                thiscellupdurs = updurs(cellnum,thisupguide);
                thiscellupamps = upamps(cellnum,thisupguide);
                thiscelltstrainrate = 10000*sum(thiscellupaps)/sum(thiscellupdurs);
                
                ratiousuprate(end+1) = thiscellburstbrate/thiscelltstrainrate;
                diffusuprate(end+1) = thiscellburstbrate - thiscelltstrainrate;
                ratiousupdur(end+1) = mean(thiscellupstimdurs) / mean(thiscellupdurs);
                diffusupdur(end+1) = mean(thiscellupstimdurs) - mean(thiscellupdurs);
                ratiousupamp(end+1) = mean(thiscellupstimamps) / mean(thiscellupamps);
                diffusupamp(end+1) = mean(thiscellupstimamps) - mean(thiscellupamps);                                
            end

%% to record data for each cell
%             thiscellupstimdurs = upstimdurs(:,cell);
%             thiscellupstimdurs = thiscellupstimdurs(thiscellupstimdurs~=0);
%             thiscellspontdurs = spontdurs(:,cell);
%             thiscellspontdurs = thiscellspontdurs((thiscellspontdurs~=0));
%             thiscellupdurs = updurs(:,cell);
%             thiscellupdurs = thiscellupdurs(thiscellupdurs~=0);
        end
    end
    disp(sidx)
end
max1 = max([size(upstimupguide,1) size(upupguide,1)]);
max2 = max([size(upstimupguide,2) size(upupguide,2)]);
upstimupguide(max1,max2) = 0;
upupguide(max1,max2) = 0;

upstimcells = find(sum(upstimupguide,2));
upcells = find(sum(upupguide,2));
cellswithall = intersect(upstimcells,upcells);

upstimtotaldurs = sum(upstimdurs(upstimcells,:),2);
upstimtotalaps = sum(upstimaps(upstimcells,:),2);
upstimcellrates = upstimtotalaps./(upstimtotaldurs/10000);
upstimcelldurs = [];
upstimcellamps = [];
for cidx = 1:length(upstimcells);
    thiscell = upstimcells(cidx);
    thisguide = upstimupguide(thiscell,:);
    upstimcelldurs(end+1) = mean(upstimdurs(thiscell,thisguide),2);
    upstimcellamps(end+1) = mean(upstimamps(thiscell,thisguide),2);
end

uptotaldurs = sum(updurs(upcells,:),2);
uptotalaps = sum(upaps(upcells,:),2);
upcellrates = uptotalaps./(uptotaldurs/10000);
upcelldurs = [];
upcellamps = [];
for cidx = 1:length(upcells);
    thiscell = upcells(cidx);
    thisguide = upupguide(thiscell,:);
    upcelldurs(end+1) = mean(updurs(thiscell,thisguide),2);
    upcellamps(end+1) = mean(upamps(thiscell,thisguide),2);
end
%% For figure 1 (Rates Bar Graph)
means(1) = mean(upcellrates);
summedcellrates = 2* mean(upcellrates);
means(2) = summedcellrates;
means(3) = mean(upstimcellrates);
sems(1) = sem(upcellrates,1);
sems(2) = 0;
sems(3) = sem(upstimcellrates,1);
uprateresamples = resampledataset(upcellrates,10000);
upstimrateresamples = resampledataset(upstimcellrates,10000);
% calc prob of getting this diff of means for burstb vs tstrain
bvtrateexpecteddiffs = sort(abs(mean(upstimrateresamples)-mean(uprateresamples)));
bvtp = find(bvtrateexpecteddiffs>abs(mean(upstimcellrates)-mean(upcellrates)));
bvtp = length(bvtp)/10000;
% [h,svtp] = ttest2(spontcellrates,upcellrates);
% [h,wvsp] = ttest2(upstimcellrates,spontcellrates);
% [h,wvtp] = ttest2(upstimcellrates,upcellrates);
sumvtp = sum(mean(uprateresamples)>summedcellrates)/10000;
sumvbp = sum(mean(upstimrateresamples)>summedcellrates)/10000;

errorbargraph(means,sems);
ylabel('Spike Rate across UP States (AP/sec)')
title({['Spike RATES.  10000 Reshuffles.'];
    ['1) UP States 2) 2xUP States(Exp) 3) UP Stim (Obs).'];...
    ['p of IntVsUP = ',num2str(bvtp),'.'];...
    ['p of SumVsUP = ',num2str(sumvtp),'. p of SumVsInt = ',num2str(sumvbp),'.']});



%% For figure 2 (Duratoins Bar Graph)
means(1) = mean(upcelldurs);
summedcelldurs = 2* mean(upcelldurs);
means(2) = summedcelldurs;
means(3) = mean(upstimcelldurs);
sems(1) = sem(upcelldurs,2);
sems(2) = 0;
sems(3) = sem(upstimcelldurs,2);
updurresamples = resampledataset(upcelldurs,10000);
upstimdurresamples = resampledataset(upstimcelldurs,10000);
% calc prob of getting this diff of means for burstb vs tstrain
bvtdurexpecteddiffs = sort(abs(mean(upstimdurresamples)-mean(updurresamples)));
bvtp = find(bvtdurexpecteddiffs>abs(mean(upstimcelldurs)-mean(upcelldurs)));
bvtp = length(bvtp)/10000;
% [h,svtp] = ttest2(spontcelldurs,upcelldurs);
% [h,wvsp] = ttest2(upstimcelldurs,spontcelldurs);
% [h,wvtp] = ttest2(upstimcelldurs,upcelldurs);
sumvtp = sum(mean(updurresamples)>summedcelldurs)/10000;
sumvbp = sum(mean(upstimdurresamples)>summedcelldurs)/10000;

errorbargraph(means,sems);
ylabel('Duration of UP States (num samples)')
title({['UP State Duration.  10000 Reshuffles.'];
    ['1) UP states 2)2xUP States(Exp) 3) StimInteraction (Obs).'];...
    ['p of IntVsUP = ',num2str(bvtp),'.'];...
    ['p of SumVsUP = ',num2str(sumvtp),'. p of SumVsInt = ',num2str(sumvbp),'.']});


%% For figure 3 (Amplitudes Bar Graph)

means(1) = mean(upcellamps);
summedcellamps = 2*mean(upcellamps);
means(2) = summedcellamps;
means(3) = mean(upstimcellamps);
sems(1) = sem(upcellamps,2);
sems(2) = 0;
sems(3) = sem(upstimcellamps,2);
upampresamples = resampledataset(upcellamps,10000);
upstimampresamples = resampledataset(upstimcellamps,10000);
% calc prob of getting this diff of means for burstb vs tstrain
bvtampexpecteddiffs = sort(abs(mean(upstimampresamples)-mean(upampresamples)));
bvtp = find(bvtampexpecteddiffs>abs(mean(upstimcellamps)-mean(upcellamps)));
bvtp = length(bvtp)/10000;
% [h,svtp] = ttest2(spontcellamps,upcellamps);
% [h,wvsp] = ttest2(upstimcellamps,spontcellamps);
% [h,wvtp] = ttest2(upstimcellamps,upcellamps);
sumvtp = sum(mean(upampresamples)>summedcellamps)/10000;
sumvbp = sum(mean(upstimampresamples)>summedcellamps)/10000;

errorbargraph(means,sems);
ylabel('Amplitude UP States (mV)')
title({['UP State AMPLITUDE.  10000 Reshuffles.'];
    ['1) UPStates 2) 2xUPStates(Exp) 3) StimInteraction (Obs).'];...
    ['p of IntVsUP = ',num2str(bvtp),'.'];...
    ['p of SumVsUP = ',num2str(sumvtp),'. p of SumVsInt = ',num2str(sumvbp),'.']});

%% Numbers output figure;

%ratios too messy
%getting rid of ratios with 0 numerator or denominator
% ratiousuprate2 = ratiousuprate(~isnan(ratiousuprate));
% ratiousuprate2 = log(ratiousuprate2(ratiousuprate2<Inf));
% ratiousupdur2 = ratiousupdur(~isnan(ratiousupdur));
% ratiousupdur2 = log(ratiousupdur2(ratiousupdur2<Inf));
% ratiousupamp2 = ratiousupamp(~isnan(ratiousupamp));
% ratiousupamp2 = log(ratiousupamp2(ratiousupamp2<Inf));
%p's for diffs
[h,diffusuprateP]=ttest(diffusuprate);%are diffs different from 0 mean
[h,diffusupdurP]=ttest(diffusupdur);
[h,diffusupampP]=ttest(diffusupamp);
% %p's for ratios
% [h,ratiousuprateP]=ttest(ratiousuprate2);%are ratios ratioerent from 0 mean
% [h,ratiousupdurP]=ttest(ratiousupdur2);
% [h,ratiousupampP]=ttest(ratiousupamp2);

figure;
axes('position',[0 0 1 1],'color',[.8 .8 .8]);
axis off
displaytext = {'GENERAL MEASURES FOR EACH CONDITION';...
    ['UPStim.  (n=',num2str(length(upstimcellrates)),' cells)'];...
    ['UPStim Rate: Mean=',num2str(mean(upstimcellrates)),'APs/Sec.  SD=',num2str(std(upstimcellrates)),'.  SEM=',num2str(sem(upstimcellrates)),'.'];...
    ['UPStim Duration: Mean=',num2str(mean(upstimcelldurs)),' samples.  SD=',num2str(std(upstimcelldurs)),'.  SEM=',num2str(sem(upstimcelldurs')),'.'];...
    ['UPStim Amplitude: Mean=',num2str(mean(upstimcellamps)),'mV.  SD=',num2str(std(upstimcellamps)),'.  SEM=',num2str(sem(upstimcellrates)),'.'];...
    ' ';...
    ['UPStates.  (n=',num2str(length(upcellrates)),' cells)'];...
    ['UPStates Rate: Mean=',num2str(mean(upcellrates)),'APs/Sec.  SD=',num2str(std(upcellrates)),'.  SEM=',num2str(sem(upcellrates)),'.'];...
    ['UPStates Duration: Mean=',num2str(mean(upcelldurs)),' samples.  SD=',num2str(std(upcelldurs)),'.  SEM=',num2str(sem(upcelldurs')),'.'];...
    ['UPStates Amplitude: Mean=',num2str(mean(upcellamps)),'mV.  SD=',num2str(std(upcellamps)),'.  SEM=',num2str(sem(upcellrates)),'.'];...
    ' ';...
    ' ';...
    'COMPARATIVE MEASURES ACROSS PAIRS OF CONDITIONS: DIFFERENCES';...
    ['UPStim vs UPStates. (n = ',num2str(length(diffusuprate)),')'];...
    ['UPStim-UPStates Rate Diff: Mean=',num2str(mean(diffusuprate)),'APs/Sec.  SD=',num2str(std(diffusuprate)),'.  SEM=',num2str(sem(diffusuprate')),'.'];...
    ['p = ',num2str(diffusuprateP),' by one tailed ttest (testing whether gaussian with mean = 0)'];...
    ['UPStim-UPStates Dur Diff: Mean=',num2str(mean(diffusupdur)),' sample  SD=',num2str(std(diffusupdur)),'.  SEM=',num2str(sem(diffusupdur')),'.'];...
    ['p = ',num2str(diffusupdurP),' by one tailed ttest (testing whether gaussian with mean = 0)'];...
    ['UPStim-UPStates Amp Diff: Mean=',num2str(mean(diffusupamp)),'mV.  SD=',num2str(std(diffusupamp)),'.  SEM=',num2str(sem(diffusupamp')),'.'];...
    ['p = ',num2str(diffusupampP),' by one tailed ttest (testing whether gaussian with mean = 0)'];...
    };

text(0,.5,displaytext);
1;

% cellswithall = intersect(intersect(upstimcells,spontcells),upcells);
% uptotaldurs = sum(updurs(cellswithall,:),2);
% uptotalaps = sum(upaps(cellswithall,:),2);
% tstrainrates = uptotalaps./(uptotaldurs/10000);
% upstimtotaldurs = sum(upstimdurs(cellswithall,:),2);
% upstimtotalaps = sum(upstimaps(cellswithall,:),2);
% burstbrates = upstimtotalaps./(upstimtotaldurs/10000);
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