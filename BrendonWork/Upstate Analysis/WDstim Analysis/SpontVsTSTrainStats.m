function SpontVsTSTrainStats(matnotes)


alltstraindurs =[];
allspontdurs =[];
alldurratios = [];
alldurdiffs = [];
alltstrainamps =[];
allspontamps =[];
allampratios = [];
allampdiffs = [];
alltstrainaps =[];
allupdelays = [];
allspontaps =[];
allapsratios = [];
allapsdiffs = [];

for sidx = 1:size(matnotes,2);
    tstrains = [];
    wdtrains = [];
    sponts = [];
    tstraindurs = [];
    tstrainaps = [];
    tstrainamps = [];
    spontdurs = [];
    spontaps = [];
    spontamps = [];
    for tidx = 1:size(matnotes(sidx).trial,2)%for each trial
        if isfield(matnotes(sidx).trial(tidx),'ephysupstate');
            if matnotes(sidx).trial(tidx).ephysupstate;%see if there was an upstate (in any cell)
                if ~isempty(matnotes(sidx).trial(tidx).ephys.abfname);%(assume there is a recording)
                    switch matnotes(sidx).trial(tidx).stim;%depending on what sort of train it is
                        case 'tstrain'
                            tstrains(end+1) = tidx;
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
%     if ~isempty(tstrains) && ~isempty(wdtrains) && ~isempty(sponts)%if all three in this slice
    if ~isempty(tstrains) && ~isempty(sponts)%if spont and stim in this slice
        allgoodtrials = [tstrains sponts];
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
                                    if isempty(aps);
                                        tstrainaps(tidx,cidx) = Inf;
                                    else
                                        tstrainaps(tidx,cidx) = length(aps);
                                    end
                                    
                                    stimtime = matnotes(sidx).trial(tidx).ephys.in6(1);
                                    uptime = ups(uidx,2);
                                    updelay = uptime - stimtime;
                                    if updelay > 0%if up was (likely) caused by stim...
                                        allupdelays(end+1) = updelay;
                                    end                                    
                                    
                                case 'spont'
                                    spontdurs(tidx,cidx) = dur;
                                    spontamps(tidx,cidx) = amp;
                                    if isempty(aps);
                                        spontaps(tidx,cidx) = Inf;
                                    else
                                        spontaps(tidx,cidx) = length(aps);
                                    end
                            end
                         end
                    end
                end
            end
        end
        if ~isempty(tstraindurs) && ~isempty(spontdurs)
%% duration calcs
            availdurcells = intersect(find(sum(spontdurs,1)),find(sum(tstraindurs,1)));
            for cidx = availdurcells;
                thiscelltstraindurs = tstraindurs(:,cidx);
                thiscelltstraindurs = thiscelltstraindurs(thiscelltstraindurs~=0);
                thiscellspontdurs = spontdurs(:,cidx);
                thiscellspontdurs = thiscellspontdurs((thiscellspontdurs~=0));
                
                alltstraindurs = cat(1,alltstraindurs,thiscelltstraindurs);
                allspontdurs = cat(1,allspontdurs,thiscellspontdurs);
                alldurratios(end+1) = mean(thiscellspontdurs)/mean(thiscelltstraindurs);
                alldurdiffs(end+1) = mean(thiscellspontdurs) - mean(thiscelltstraindurs);
            end
%% amplitude calcs
            availampcells = intersect(find(sum(spontamps,1)),find(sum(tstrainamps,1)));
            for cidx = availampcells;
                thiscelltstrainamps = tstrainamps(:,cidx);
                thiscelltstrainamps = thiscelltstrainamps(thiscelltstrainamps~=0);
                thiscellspontamps = spontamps(:,cidx);
                thiscellspontamps = thiscellspontamps(thiscellspontamps~=0);
                
                alltstrainamps = cat(1,alltstrainamps,thiscelltstrainamps);
                allspontamps = cat(1,allspontamps,thiscellspontamps);
                allampratios(end+1) = mean(thiscellspontamps)/mean(thiscelltstrainamps);
                allampdiffs(end+1) = mean(thiscellspontamps) - mean(thiscelltstrainamps);
            end
%% Number of aps calcs
            availapscells = intersect(find(sum(spontaps,1)),find(sum(tstrainaps,1)));
            for cidx = availapscells;
                thiscelltstrainaps = tstrainaps(:,cidx);
                thiscelltstrainaps = thiscelltstrainaps(thiscelltstrainaps~=0);
                thiscelltstrainaps(thiscelltstrainaps == Inf) = 0;
                thiscellspontaps = spontaps(:,cidx);
                thiscellspontaps = thiscellspontaps(thiscellspontaps~=0);
                thiscellspontaps(thiscellspontaps == Inf) = 0;
                
                alltstrainaps = cat(1,alltstrainaps,thiscelltstrainaps);
                allspontaps = cat(1,allspontaps,thiscellspontaps);
                allapsratios(end+1) = mean(thiscellspontaps)/mean(thiscelltstrainaps);
                allapsdiffs(end+1) = mean(thiscellspontaps) - mean(thiscelltstrainaps);
            end
        end
    end
    disp(sidx);
end

%% plot delays to stimulated upstates
aud2 = [-allupdelays allupdelays];
figure;
hist(allupdelays,50);
title({'Delay from start of thalamic stim to full upstate depolarization';
    ['Mean = ',num2str(mean(allupdelays)/10),'. SD = ',num2str(std(allupdelays)/10),'. Range: ',num2str(max(allupdelays)),' ',num2str(min(allupdelays)),'.'];
    ['SD of flip about zero = ',num2str(std(aud2)/10),'.' ]});


%% plot ratios
[h,p,ci,stats] = ttest(log(alldurratios));
figure;
hist(log(alldurratios));
title({'Logs of ratios of Spont:TSTrain Up Duration within each cell.',...
    ['Mean = ',num2str(mean(log(alldurratios))),'. SD = ',num2str(std(log(alldurratios))),'.'],...
    ['Different from zero? p = ',num2str(p),'.  (by t-test)']})

[h,p,ci,stats] = ttest(log(allampratios));
figure;
hist(log(allampratios));
title({'Logs of ratios of Spont:TSTrain Up Amplitude within each cell.',...
    ['Mean = ',num2str(mean(log(allampratios))),'. SD = ',num2str(std(log(allampratios))),'.'],...
    ['Different from zero? p = ',num2str(p),'.  (by t-test)']})

figure;
tempvar = allapsratios(allapsratios ~= 0);
tempvar = tempvar(tempvar ~= Inf);
tempvar = tempvar(~isnan(tempvar));
[h,p,ci,stats] = ttest(log(tempvar));
hist(log(tempvar));
title({'Logs of ratios of Spont:TSTrain Up Number of APs within each cell.',...
    ['Mean = ',num2str(mean(log(tempvar))),'. SD = ',num2str(std(log(tempvar))),'.'],...
    ['Different from zero? p = ',num2str(p),'.  (by t-test)']})

%% plot diffs
[h,p,ci,stats] = ttest(alldurdiffs);
figure;
hist(alldurdiffs);
title({'Spont-TSTrain Up Duration within each cell.',...
    ['Mean = ',num2str(mean(alldurdiffs)),'. SD = ',num2str(std(alldurdiffs)),'.'],...
    ['Different from zero? p = ',num2str(p),'.  (by t-test)']})

[h,p,ci,stats] = ttest(allampdiffs);
figure;
hist(allampdiffs);
title({'Spont-TSTrain Up Amplitude within each cell.',...
    ['Mean = ',num2str(mean(allampdiffs)),'. SD = ',num2str(std(allampdiffs)),'.'],...
    ['Different from zero? p = ',num2str(p),'.  (by t-test)']})

[h,p,ci,stats] = ttest(allapsdiffs);
figure;
hist(allapsdiffs);
title({'Spont-TSTrain Up Number of Aps within each cell.',...
    ['Mean = ',num2str(mean(allapsdiffs)),'. SD = ',num2str(std(allapsdiffs)),'.'],...
    ['Different from zero? p = ',num2str(p),'.  (by t-test)']})



%% plot non-per-cell (ie pop) averages and sd's
figure;
errorbargraph([mean(allspontdurs) mean(alltstraindurs)],[std(allspontdurs) std(alltstraindurs)])
title1 = 'Spont(L)   vs   TSTrain(R) Durations.';
title2 = [num2str(length(alldurratios)),' cells.  ', num2str(length(allspontdurs)),' Spont UPs.  ',...
    num2str(length(alltstraindurs)),' TSTrain UPs.  '];
title3 = [num2str(mean(allspontdurs)),'+/-',num2str(std(allspontdurs)),'.    ',...
    num2str(mean(alltstraindurs)),'+/-',num2str(std(alltstraindurs))];
title({title1;title2;title3})

figure;
errorbargraph([mean(allspontamps) mean(alltstrainamps)],[std(allspontamps) std(alltstrainamps)])
title1 = 'Spont(L)   vs   TSTrain(R) Amplitudes.';
title2 = [num2str(length(allampratios)),' cells.  ', num2str(length(allspontamps)),' Spont UPs.  ',...
    num2str(length(alltstrainamps)),' TSTrain UPs.  '];
title3 = [num2str(mean(allspontamps)),'+/-',num2str(std(allspontamps)),'.    ',...
    num2str(mean(alltstrainamps)),'+/-',num2str(std(alltstrainamps))];
title({title1;title2;title3})

figure;
errorbargraph([mean(allspontaps) mean(alltstrainaps)],[std(allspontaps) std(alltstrainaps)])
title1 = 'Spont(L)   vs   TSTrain(R) # of APs.';
title2 = [num2str(length(allapsratios)),' cells.  ', num2str(length(allspontaps)),' Spont UPs.  ',...
    num2str(length(alltstrainaps)),' TSTrain UPs.  '];
title3 = [num2str(mean(allspontaps)),'+/-',num2str(std(allspontaps)),'.    ',...
    num2str(mean(alltstrainaps)),'+/-',num2str(std(alltstrainaps))];
title({title1;title2;title3})