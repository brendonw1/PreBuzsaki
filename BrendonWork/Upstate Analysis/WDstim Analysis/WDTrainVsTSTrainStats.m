function results = WDTrainVsTSTrainStats(matnotes);


allwdcells = [];
alltscells = [];

alltstraindurs =[];
allwddurs =[];
alldurratios = [];
alldurdiffs = [];
alltstrainamps =[];
allwdamps =[];
allampratios = [];
allampdiffs = [];
alltstrainaps =[];
allwdaps =[];
allapsratios = [];
allapsdiffs = [];

for sidx = 1:size(matnotes,2);
    tstrains = [];
    wdtrains = [];
    tstraindurs = [];
    tstrainaps = [];
    tstrainamps = [];
    wddurs = [];
    wdaps = [];
    wdamps = [];
    for tidx = 1:size(matnotes(sidx).trial,2)
        if isfield(matnotes(sidx).trial(tidx),'ephysupstate');
            if matnotes(sidx).trial(tidx).ephysupstate
                if ~isempty(matnotes(sidx).trial(tidx).ephys.abfname);
                    switch matnotes(sidx).trial(tidx).stim
                        case 'tstrain'
                            tstrains(end+1) = tidx;
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
    if ~isempty(tstrains) & ~isempty(wdtrains)%if both were done on this slice
        allgoodtrials = [tstrains wdtrains];
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
                                case 'tstrain'
                                    tstraindurs(tidx,cidx) = dur;
                                    tstrainamps(tidx,cidx) = amp;
                                    if length(aps) == 0;
                                        tstrainaps(tidx,cidx) = Inf;
                                    else
                                        tstrainaps(tidx,cidx) = length(aps);
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
        if ~isempty(tstraindurs) & ~isempty(wddurs)
%% duration calcs
            availdurcells = intersect(find(sum(wddurs,1)),find(sum(tstraindurs,1)));
            for cidx = availdurcells;
                wdtrials = find(wddurs(:,cidx));
                wdaddon = [sidx*ones(size(wdtrials,1),1) wdtrials cidx*ones(size(wdtrials,1),1)];
                allwdcells = cat(1,allwdcells,wdaddon);                
                tstrials = find(tstraindurs(:,cidx));
                tsaddon = [sidx*ones(size(tstrials,1),1) tstrials cidx*ones(size(tstrials,1),1)];
                alltscells = cat(1,alltscells,tsaddon);

                thiscelltstraindurs = tstraindurs(:,cidx);
                thiscelltstraindurs = thiscelltstraindurs(find(thiscelltstraindurs));
                thiscellwddurs = wddurs(:,cidx);
                thiscellwddurs = thiscellwddurs(find(thiscellwddurs));
                
                alltstraindurs = cat(1,alltstraindurs,thiscelltstraindurs);
                allwddurs = cat(1,allwddurs,thiscellwddurs);
                alldurratios(end+1) = mean(thiscellwddurs)/mean(thiscelltstraindurs);
                alldurdiffs(end+1) = mean(thiscellwddurs) - mean(thiscelltstraindurs);
            end
%% amplitude calcs
            availampcells = intersect(find(sum(wdamps,1)),find(sum(tstrainamps,1)));
            for cidx = availampcells;
                thiscelltstrainamps = tstrainamps(:,cidx);
                thiscelltstrainamps = thiscelltstrainamps(find(thiscelltstrainamps));
                thiscellwdamps = wdamps(:,cidx);
                thiscellwdamps = thiscellwdamps(find(thiscellwdamps));
                
                alltstrainamps = cat(1,alltstrainamps,thiscelltstrainamps);
                allwdamps = cat(1,allwdamps,thiscellwdamps);
                allampratios(end+1) = mean(thiscellwdamps)/mean(thiscelltstrainamps);
                allampdiffs(end+1) = mean(thiscellwdamps) - mean(thiscelltstrainamps);
            end
%% Number of aps calcs
            availapscells = intersect(find(sum(wdaps,1)),find(sum(tstrainaps,1)));
            for cidx = availapscells;
                thiscelltstrainaps = tstrainaps(:,cidx);
                thiscelltstrainaps = thiscelltstrainaps(find(thiscelltstrainaps));
                thiscelltstrainaps(thiscelltstrainaps == Inf) = 0;
                thiscellwdaps = wdaps(:,cidx);
                thiscellwdaps = thiscellwdaps(find(thiscellwdaps));
                thiscellwdaps(thiscellwdaps == Inf) = 0;
                
                alltstrainaps = cat(1,alltstrainaps,thiscelltstrainaps);
                allwdaps = cat(1,allwdaps,thiscellwdaps);
                allapsratios(end+1) = mean(thiscellwdaps)/mean(thiscelltstrainaps);
                allapsdiffs(end+1) = mean(thiscellwdaps) - mean(thiscelltstrainaps);
            end
        end
    end
    disp(sidx);
end

%% plot ratios
[h,p,ci,stats] = ttest(log(alldurratios));
figure;
hist(log(alldurratios));
title({'Logs of ratios of WDTrain:TSTrain Up Duration within each cell.',...
    ['Mean = ',num2str(mean(log(alldurratios))),'. SD = ',num2str(std(log(alldurratios))),'.'],...
    ['Different from zero? p = ',num2str(p),'.  (by t-test)']})

[h,p,ci,stats] = ttest(log(allampratios));
figure;
hist(log(allampratios));
title({'Logs of ratios of WDTrain:TSTrain Up Amplitude within each cell.',...
    ['Mean = ',num2str(mean(log(allampratios))),'. SD = ',num2str(std(log(allampratios))),'.'],...
    ['Different from zero? p = ',num2str(p),'.  (by t-test)']})

figure;
tempvar = allapsratios(allapsratios ~= 0);
tempvar = tempvar(tempvar ~= Inf);
tempvar = tempvar(~isnan(tempvar));
[h,p,ci,stats] = ttest(log(tempvar));
hist(log(tempvar));
title({'Logs of ratios of WDTrain:TSTrain Up Number of APs within each cell.',...
    ['Mean = ',num2str(mean(log(tempvar))),'. SD = ',num2str(std(log(tempvar))),'.'],...
    ['Different from zero? p = ',num2str(p),'.  (by t-test)']})

%% plot diffs
[h,p,ci,stats] = ttest(alldurdiffs);
figure;
hist(alldurdiffs);
title({'WDTrain-TSTrain Up Duration within each cell.',...
    ['Mean = ',num2str(mean(alldurdiffs)),'. SD = ',num2str(std(alldurdiffs)),'.'],...
    ['Different from zero? p = ',num2str(p),'.  (by t-test)']})

[h,p,ci,stats] = ttest(allampdiffs);
figure;
hist(allampdiffs);
title({'WDTrain-TSTrain Up Amplitude within each cell.',...
    ['Mean = ',num2str(mean(allampdiffs)),'. SD = ',num2str(std(allampdiffs)),'.'],...
    ['Different from zero? p = ',num2str(p),'.  (by t-test)']})

[h,p,ci,stats] = ttest(allapsdiffs);
figure;
hist(allapsdiffs);
title({'WDTrain-TSTrain Up Number of Aps within each cell.',...
    ['Mean = ',num2str(mean(allapsdiffs)),'. SD = ',num2str(std(allapsdiffs)),'.'],...
    ['Different from zero? p = ',num2str(p),'.  (by t-test)']})



%% plot non-per-cell (ie pop) averages and sd's
[h,p,ci]=ttest2(allwddurs,alltstraindurs);
figure;
errorbargraph([mean(allwddurs) mean(alltstraindurs)],[std(allwddurs) std(alltstraindurs)])
title1 = 'WDTrain(L)   vs   TSTrain(R) Durations.';
title2 = [num2str(length(alldurratios)),' cells.  ', num2str(length(allwddurs)),' WD UPs.  ',...
    num2str(length(alltstraindurs)),' TSTrain UPs.  '];
title3 = [num2str(mean(allwddurs)),'+/-',num2str(std(allwddurs)),'.    ',...
    num2str(mean(alltstraindurs)),'+/-',num2str(std(alltstraindurs))];
title4 = ['Diff between WD Durations and TSTrain Durations by ttest2: p = ',num2str(p)];
title({title1;title2;title3;title4})

[h,p,ci]=ttest2(allwdamps,alltstrainamps);
figure;
errorbargraph([mean(allwdamps) mean(alltstrainamps)],[std(allwdamps) std(alltstrainamps)])
title1 = 'WDTrain(L)   vs   TSTrain(R) Amplitudes.';
title2 = [num2str(length(allampratios)),' cells.  ', num2str(length(allwdamps)),' WD UPs.  ',...
    num2str(length(alltstrainamps)),' TSTrain UPs.  '];
title3 = [num2str(mean(allwdamps)),'+/-',num2str(std(allwdamps)),'.    ',...
    num2str(mean(alltstrainamps)),'+/-',num2str(std(alltstrainamps))];
title4 = ['Diff between WD Amplitudes and TSTrain Amplitudes by ttest2: p = ',num2str(p)];
title({title1;title2;title3;title4})

[h,p,ci]=ttest2(allwdaps,alltstrainaps);
figure;
errorbargraph([mean(allwdaps) mean(alltstrainaps)],[std(allwdaps) std(alltstrainaps)])
title1 = 'WDTrain(L)   vs   TSTrain(R) # of APs.';
title2 = [num2str(length(allapsratios)),' cells.  ', num2str(length(allwdaps)),' WD UPs.  ',...
    num2str(length(alltstrainaps)),' TSTrain UPs.  '];
title3 = [num2str(mean(allwdaps)),'+/-',num2str(std(allwdaps)),'.    ',...
    num2str(mean(alltstrainaps)),'+/-',num2str(std(alltstrainaps))];
title4 = ['Diff between WD #APs and TSTrain #APs by ttest2: p = ',num2str(p)];
title({title1;title2;title3;title4})


%% output prep

results.alltstraindurs = alltstraindurs;
results.allwddurs = allwddurs;
results.alldurratios = alldurratios;
results.alldurdiffs = alldurdiffs;

results.alltstrainamps = alltstrainamps;
results.allwdamps = allwdamps;
results.allampratios = allampratios;
results.allampdiffs = allampdiffs;

results.alltstrainaps = alltstrainaps;
results.allwdaps = allwdaps;
results.allapsratios = allapsratios;
results.allapsdiffs = allapsdiffs;

results.allwdcells = allwdcells;
results.alltscells = alltscells;
