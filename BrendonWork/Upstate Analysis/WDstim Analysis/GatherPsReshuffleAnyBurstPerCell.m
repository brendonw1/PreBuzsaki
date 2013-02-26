function results = GatherPsReshuffleAnyBurstPerCell(matnotes,stimnum,binwidths,numreshuffs,varargin);
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
% binwidth = 1500;%150ms;
allwidth = aftertime-beforetime;

firstps = [];
maxps = [];

for bwidx = 1:length(binwidths);
    disp(bwidx)
    cellcounter = 0;
    binwidth = binwidths(bwidx);
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
    for sidx = 1:size(matnotes,2);
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
            thiscellhasstiminup = 0;%to allow for later recording data seprarately for cells with stim in ups versus those without
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
%         %%
%                     if strcmp(matnotes(sidx).trial(tidx).stim,'wdtrain')%if the trial is 'wdtrain'
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
                                                    thiscellhasstiminup = 1;
                                                    break
                                                end
                                            end
    %                                         if stiminup
    %%                                            
                                                if ~isempty(aps);
                                                    aps = aps-timeref;
                                                    aps(aps < beforetime) = [];
                                                    aps(aps > aftertime) = [];
                                                end
                                                if ~isempty(aps);
    %                                                 cellaps = cat(2,cellaps,aps);
    %                                                 allaps =
    %                                                 cat(2,allaps,aps);
                                                    if stiminup%for recording cells that had official up with stim (See mfile cell above)
                                                        ycellaps = cat(2,ycellaps,aps);
                                                        yallaps = cat(2,yallaps,aps);
                                                    end
                                                elseif isempty(aps);
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
%                     end
                end
%% to record data for cells that had stims
                if thiscellhasstiminup
                    cellcounter = cellcounter+1;
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

                    thesereshuffs = znumfirstbinaps(end,:);
                    p = sum(numfirstbinaps(end)<=thesereshuffs)/numreshuffs;
                    firstps(bwidx,cellcounter) = p;
                    thesereshuffs = znummaxbinaps(end,:);
                    p = sum(nummaxbinaps(end)<=thesereshuffs)/numreshuffs;
                    maxps(bwidx,cellcounter) = p;
                end
            end
        end
    end
end

results.firstps = firstps;
results.maxps = maxps;
figure;
hist(mean(results.firstps),100)
title({['Mean P value across First bins for each cell.  ',num2str(size(firstps,2)),' cells.  ',num2str(numreshuffs),' reshuffles.'];...
    ['Bins = ',num2str(binwidths),'ms']});
figure;
hist(mean(results.maxps),100)
title({['Mean P value across Max bins for each cell.  ',num2str(size(firstps,2)),' cells.  ',num2str(numreshuffs),' reshuffles.'];...
    ['Bins = ',num2str(binwidths),'ms']});
figure;
hist(max(results.firstps),100)
title({['Max P value across First bins for each cell.  ',num2str(size(firstps,2)),' cells.  ',num2str(numreshuffs),' reshuffles.'];...
    ['Bins = ',num2str(binwidths),'ms']});
figure;
hist(max(results.maxps),100)
title({['Max P value across Max bins for each cell.  ',num2str(size(firstps,2)),' cells.  ',num2str(numreshuffs),' reshuffles.'];...
    ['Bins = ',num2str(binwidths),'ms']});