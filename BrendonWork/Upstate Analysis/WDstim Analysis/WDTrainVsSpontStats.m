function results = WDTrainVsSpontStats(matnotes);


allwdcells = [];
allspontcells = [];

allspontdurs =[];
allwddurs =[];
alldurratios = [];
alldurdiffs = [];
allspontamps =[];
allwdamps =[];
allampratios = [];
allampdiffs = [];
allspontaps =[];
allwdaps =[];
allapsratios = [];
allapsdiffs = [];

for sidx = 1:size(matnotes,2);
    sponts = [];
    wdtrains = [];
    spontdurs = [];
    spontaps = [];
    spontamps = [];
    wddurs = [];
    wdaps = [];
    wdamps = [];
    for tidx = 1:size(matnotes(sidx).trial,2)
        if isfield(matnotes(sidx).trial(tidx),'ephysupstate');
            if matnotes(sidx).trial(tidx).ephysupstate
                if ~isempty(matnotes(sidx).trial(tidx).ephys.abfname);
                    switch matnotes(sidx).trial(tidx).stim
                        case 'spont'
                            sponts(end+1) = tidx;
                        case 'wdtrain'
                            if isfield(matnotes(sidx).trial(tidx).ephys,'cell')
                                tempidxvar = 0;
                                for cidx = 1:4;
                                    if ~isempty(matnotes(sidx).trial(tidx).ephys.cell(cidx).interactiontype);
                                        interactiontype = matnotes(sidx).trial(tidx).ephys.cell(cidx).interactiontype;
                                        if ~isempty(strfind(lower(interactiontype),'burst'))
                                            tempidxvar = 1;
                                        end
                                    end
                                end
                                if tempidxvar
                                    wdtrains(end+1) = tidx;
                                end
                            end
                    end
                end
            end
        end
    end
    if ~isempty(sponts) & ~isempty(wdtrains)%if both were done on this slice
        allgoodtrials = [sponts wdtrains];
        for tidx = allgoodtrials
            if isfield(matnotes(sidx).trial(tidx).ephys,'cell')
                abfpath = matnotes(sidx).trial(tidx).ephys.abfname;
%                 abfpath = ['C:\Exchange\Data\Axon Data\',abfpath];
%                 abfpath = ['E:\Abeles Data Folder\Axon Data\',abfpath];
                abfpath = ['D:\Exchange\Data\Axon Data\',abfpath];

                [data,trash,channels]=abfload(abfpath);
                for cidx = 1:4;
                    if ~isempty(matnotes(sidx).trial(tidx).ephys.cell(cidx).upstates)
                        ups = matnotes(sidx).trial(tidx).ephys.cell(cidx).upstates;
                        for uidx = size(ups,1);%use the last upstate
                            dur = ups(uidx,3)-ups(uidx,2);
                            aps = matnotes(sidx).trial(tidx).ephys.cell(cidx).aps;
                            aps = aps(aps>ups(uidx,2));
                            aps = aps(aps<ups(uidx,3));
                            
                            ccn = matnotes(sidx).CellOrder.CellChannels{cidx};
                            chanmatch = strmatch(ccn,channels);
                            downvals = data([ups(uidx,1),ups(uidx,4)],chanmatch);
                            upvals = data(ups(uidx,2):ups(uidx,3),chanmatch);
                            
                            amp = mean(upvals)- mean(downvals);
                            switch matnotes(sidx).trial(tidx).stim
                                case 'spont'
                                    spontdurs(tidx,cidx) = dur;
                                    spontamps(tidx,cidx) = amp;
                                    if length(aps) == 0;
                                        spontaps(tidx,cidx) = Inf;
                                    else
                                        spontaps(tidx,cidx) = length(aps);
                                    end
                                case 'wdtrain'
                                    wddurs(tidx,cidx) = dur;
                                    wdamps(tidx,cidx) = amp;
                                    if length(aps) == 0;
                                        wdaps(tidx,cidx) = Inf;
                                    else
                                        wdaps(tidx,cidx) = length(aps);
                                    end
                            end
                         end
                    end
                end
            end
        end
        if ~isempty(spontdurs) & ~isempty(wddurs)
%% duration calcs
            availdurcells = intersect(find(sum(wddurs,1)),find(sum(spontdurs,1)));
            for cidx = availdurcells;
                wdtrials = find(wddurs(:,cidx));
                wdaddon = [sidx*ones(size(wdtrials,1),1) wdtrials cidx*ones(size(wdtrials,1),1)];
                allwdcells = cat(1,allwdcells,wdaddon);                
                sponttrials = find(spontdurs(:,cidx));
                spontaddon = [sidx*ones(size(sponttrials,1),1) sponttrials cidx*ones(size(sponttrials,1),1)];
                allspontcells = cat(1,allspontcells,spontaddon);

                thiscellspontdurs = spontdurs(:,cidx);
                thiscellspontdurs = thiscellspontdurs(find(thiscellspontdurs));
                thiscellwddurs = wddurs(:,cidx);
                thiscellwddurs = thiscellwddurs(find(thiscellwddurs));
                
                allspontdurs = cat(1,allspontdurs,thiscellspontdurs);
                allwddurs = cat(1,allwddurs,thiscellwddurs);
                alldurratios(end+1) = mean(thiscellwddurs)/mean(thiscellspontdurs);
                alldurdiffs(end+1) = mean(thiscellwddurs) - mean(thiscellspontdurs);
            end
%% amplitude calcs
            availampcells = intersect(find(sum(wdamps,1)),find(sum(spontamps,1)));
            for cidx = availampcells;
                thiscellspontamps = spontamps(:,cidx);
                thiscellspontamps = thiscellspontamps(find(thiscellspontamps));
                thiscellwdamps = wdamps(:,cidx);
                thiscellwdamps = thiscellwdamps(find(thiscellwdamps));
                
                allspontamps = cat(1,allspontamps,thiscellspontamps);
                allwdamps = cat(1,allwdamps,thiscellwdamps);
                allampratios(end+1) = mean(thiscellwdamps)/mean(thiscellspontamps);
                allampdiffs(end+1) = mean(thiscellwdamps) - mean(thiscellspontamps);
            end
%% Number of aps calcs
            availapscells = intersect(find(sum(wdaps,1)),find(sum(spontaps,1)));
            for cidx = availapscells;
                thiscellspontaps = spontaps(:,cidx);
                thiscellspontaps = thiscellspontaps(find(thiscellspontaps));
                thiscellspontaps(thiscellspontaps == Inf) = 0;
                thiscellwdaps = wdaps(:,cidx);
                thiscellwdaps = thiscellwdaps(find(thiscellwdaps));
                thiscellwdaps(thiscellwdaps == Inf) = 0;
                
                allspontaps = cat(1,allspontaps,thiscellspontaps);
                allwdaps = cat(1,allwdaps,thiscellwdaps);
                allapsratios(end+1) = mean(thiscellwdaps)/mean(thiscellspontaps);
                allapsdiffs(end+1) = mean(thiscellwdaps) - mean(thiscellspontaps);
            end
        end
    end
    disp(sidx);
end

%% plot ratios
[h,p,ci,stats] = ttest(log(alldurratios));
figure;
hist(log(alldurratios));
title({'Logs of ratios of WDTrain:Spont Up Duration within each cell.',...
    ['Mean = ',num2str(mean(log(alldurratios))),'. SD = ',num2str(std(log(alldurratios))),'.'],...
    ['Different from zero? p = ',num2str(p),'.  (by t-test)']})

[h,p,ci,stats] = ttest(log(allampratios));
figure;
hist(log(allampratios));
title({'Logs of ratios of WDTrain:Spont Up Amplitude within each cell.',...
    ['Mean = ',num2str(mean(log(allampratios))),'. SD = ',num2str(std(log(allampratios))),'.'],...
    ['Different from zero? p = ',num2str(p),'.  (by t-test)']})

figure;
tempvar = allapsratios(allapsratios ~= 0);
tempvar = tempvar(tempvar ~= Inf);
tempvar = tempvar(~isnan(tempvar));
[h,p,ci,stats] = ttest(log(tempvar));
hist(log(tempvar));
title({'Logs of ratios of WDTrain:Spont Up Number of APs within each cell.',...
    ['Mean = ',num2str(mean(log(tempvar))),'. SD = ',num2str(std(log(tempvar))),'.'],...
    ['Different from zero? p = ',num2str(p),'.  (by t-test)']})

%% plot diffs
[h,p,ci,stats] = ttest(alldurdiffs);
figure;
hist(alldurdiffs);
title({'WDTrain-Spont Up Duration within each cell.',...
    ['Mean = ',num2str(mean(alldurdiffs)),'. SD = ',num2str(std(alldurdiffs)),'.'],...
    ['Different from zero? p = ',num2str(p),'.  (by t-test)']})

[h,p,ci,stats] = ttest(allampdiffs);
figure;
hist(allampdiffs);
title({'WDTrain-Spont Up Amplitude within each cell.',...
    ['Mean = ',num2str(mean(allampdiffs)),'. SD = ',num2str(std(allampdiffs)),'.'],...
    ['Different from zero? p = ',num2str(p),'.  (by t-test)']})

[h,p,ci,stats] = ttest(allapsdiffs);
figure;
hist(allapsdiffs);
title({'WDTrain-Spont Up Number of Aps within each cell.',...
    ['Mean = ',num2str(mean(allapsdiffs)),'. SD = ',num2str(std(allapsdiffs)),'.'],...
    ['Different from zero? p = ',num2str(p),'.  (by t-test)']})



%% plot non-per-cell (ie pop) averages and sd's
[h,p,ci]=ttest2(allwddurs,allspontdurs);
figure;
errorbargraph([mean(allwddurs) mean(allspontdurs)],[std(allwddurs) std(allspontdurs)])
title1 = 'WDTrain(L)   vs   Spont(R) Durations.';
title2 = [num2str(length(alldurratios)),' cells.  ', num2str(length(allwddurs)),' WD UPs.  ',...
    num2str(length(allspontdurs)),' Spont UPs.  '];
title3 = [num2str(mean(allwddurs)),'+/-',num2str(std(allwddurs)),'.    ',...
    num2str(mean(allspontdurs)),'+/-',num2str(std(allspontdurs))];
title4 = ['Diff between WD Durations and Spont Durations by ttest2: p = ',num2str(p)];
title({title1;title2;title3;title4})

[h,p,ci]=ttest2(allwdamps,allspontamps);
figure;
errorbargraph([mean(allwdamps) mean(allspontamps)],[std(allwdamps) std(allspontamps)])
title1 = 'WDTrain(L)   vs   Spont(R) Amplitudes.';
title2 = [num2str(length(allampratios)),' cells.  ', num2str(length(allwdamps)),' WD UPs.  ',...
    num2str(length(allspontamps)),' Spont UPs.  '];
title3 = [num2str(mean(allwdamps)),'+/-',num2str(std(allwdamps)),'.    ',...
    num2str(mean(allspontamps)),'+/-',num2str(std(allspontamps))];
title4 = ['Diff between WD Amplitudes and Spont Amplitudes by ttest2: p = ',num2str(p)];
title({title1;title2;title3;title4})

[h,p,ci]=ttest2(allwdaps,allspontaps);
figure;
errorbargraph([mean(allwdaps) mean(allspontaps)],[std(allwdaps) std(allspontaps)])
title1 = 'WDTrain(L)   vs   Spont(R) # of APs.';
title2 = [num2str(length(allapsratios)),' cells.  ', num2str(length(allwdaps)),' WD UPs.  ',...
    num2str(length(allspontaps)),' Spont UPs.  '];
title3 = [num2str(mean(allwdaps)),'+/-',num2str(std(allwdaps)),'.    ',...
    num2str(mean(allspontaps)),'+/-',num2str(std(allspontaps))];
title4 = ['Diff between WD #APs and Spont #APs by ttest2: p = ',num2str(p)];
title({title1;title2;title3;title4})


%% output prep

results.allspontdurs = allspontdurs;
results.allwddurs = allwddurs;
results.alldurratios = alldurratios;
results.alldurdiffs = alldurdiffs;

results.allspontamps = allspontamps;
results.allwdamps = allwdamps;
results.allampratios = allampratios;
results.allampdiffs = allampdiffs;

results.allspontaps = allspontaps;
results.allwdaps = allwdaps;
results.allapsratios = allapsratios;
results.allapsdiffs = allapsdiffs;

results.allwdcells = allwdcells;
results.allspontcells = allspontcells;
