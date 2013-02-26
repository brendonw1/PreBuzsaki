function results = GatherAllBurstInteractionTSTrainMEMBPERCELL(matnotes,stimnum,beforetime,aftertime,varargin)

warning off
%% evaluate inputs and setup
directdesc = '. ';
distring = '''tempvar = 1;''';%default
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

results.UPresps = [];
results.DOWNresps = [];
results.cellpercentchange = [];
results.cellabsolutechange = [];
results.cellDOWNmaxresptime = [];
results.cellDOWNmembs = [];
results.cellUPmembs = [];
results.cellOverallMeanDiff = [];
results.celltype = {};
ephyspath = 'D:\Exchange\Data\Axon Data\';

% stimnum = 1;%which individual stim within the burst is locked to

%% gather data

for sidx = 1:size(matnotes,2);
%     for cell = 1:4%go through all cells that had spiking ups
%         cell = cell;
    for cell = 1:4%go through all cells that had spiking ups

%% FOR MEMB: exclude 3 most cells with ugly stim transients, bad membrane kinetics
       if (sidx == 288) || (sidx == 297)
           continue
       end
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
        cellUPresp = [];
        cellDOWNresp = [];
        cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};%set up to test for direct input or not
        eval(eval(distring));%eval direct input or not of each cell... makes tempvar for next line
        if tempvar;%if it passes muster
            UPmembs = [];
            cellUPresp = [];
            for tidx = 1:size(matnotes(sidx).trial,2)%go through each trial
%                 if strcmp(matnotes(sidx).trial(tidx).stim,'wdtrain')%if the trial is 'wdtrain'
                    in6 = matnotes(sidx).trial(tidx).ephys.in6;
                    if isfield(matnotes(sidx).trial(tidx).ephys,'cell');
                        interactiontype = matnotes(sidx).trial(tidx).ephys.cell(cell).interactiontype;
                        if ~isempty(strfind(lower(interactiontype),'burst'))%if a burst interaction
                            burstnum = str2double(interactiontype(6));
                            bursts = separatein6(in6,275,'burst');
                            if ~isempty(bursts);
                                burstnum = min([size(bursts,2) burstnum]);
                                aps = matnotes(sidx).trial(tidx).ephys.cell(cell).aps;
                                if length(bursts{burstnum})>=stimnum;
                                    timeref = bursts{burstnum}(stimnum);

%% for making sure it's in an official upstate                                                 
                                    ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
                                    stiminup = 0;
                                    for uidx = 1:size(ups,1);
                                        if timeref>=ups(uidx,2) && timeref<=ups(uidx,3);
                                            stiminup = 1;%stim in up used later to record stats specifically 
                                            break
                                        end
                                    end
                                    if stiminup
%%                 
                                        aps(aps<(timeref+beforetime)) = [];
                                        aps(aps>(timeref+aftertime)) = [];
                                        if isempty(aps)
                                            
                                            [d,si,recChNames] = abfload([ephyspath,matnotes(sidx).trial(tidx).abfname,'.abf']);%get data using abfload
                                            channame = matnotes(sidx).CellOrder.CellChannels(cell);%get channel name
                                            channum = strmatch(channame,recChNames);
                                            if sidx == 153;
                                                1;
                                            end
                                            d = d(:,channum);%keep only channel
                                            aps = findaps2(d);
                                            aps(aps<(timeref+beforetime)) = [];
                                            aps(aps>(timeref+aftertime)) = [];
                                            if isempty(aps)
                                                UPmembs(end+1,:) = d((timeref+beforetime):(timeref+aftertime))';%keep only timepoints of interest
                                            end    
                                        end
                                    end
                                end
                            end
                        end
                    end
%                 end
            end
%% Evaluate TsTrain spiking for same cell
            if ~isempty(UPmembs)
                DOWNmembs = [];
                cellDOWNresp = [];
                for tidx = 1:size(matnotes(sidx).trial,2)%go through each trial
                    if strcmp(matnotes(sidx).trial(tidx).stim,'tstrain')
                        if ~isempty(matnotes(sidx).trial(tidx).ephys.in6)%if really stim
                            in6 = matnotes(sidx).trial(tidx).ephys.in6;%find burst
                            interactioncriterion = find(~matnotes(sidx).trial(tidx).interactionstim);%1 if no interaction
                            if interactioncriterion%if no interaction
                                ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
                                if ~isempty(ups);
                                    uidx = 1;%just go for the first up
                                    timeref = in6(1);
                                    if ups(uidx,2)>timeref && ups(uidx,2)<(timeref+aftertime)
                                        aps = matnotes(sidx).trial(tidx).ephys.cell(cell).aps;
                                        
                                        aps(aps<(timeref+beforetime)) = [];
                                        aps(aps>(timeref+aftertime)) = [];
                                        if isempty(aps)
                                            [d,si,recChNames] = abfload([ephyspath,matnotes(sidx).trial(tidx).abfname,'.abf']);%get data using abfload
                                            channame = matnotes(sidx).CellOrder.CellChannels(cell);%get channel name
                                            channum = strmatch(channame,recChNames);
                                            d = d(:,channum);%keep only channel
                                            DOWNmembs(end+1,:) = d((timeref+beforetime):(timeref+aftertime))';%keep only timepoints of interest
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if ~isempty(DOWNmembs)
                    DOWNmembs = mean(DOWNmembs,1);
                    [DOWNmaxresp, DOWNmaxresptime] = max(DOWNmembs(-beforetime+1:end));
                    DOWNbaseline = mean(DOWNmembs(1:-beforetime));
                    cellDOWNresp(end+1) = DOWNmaxresp - DOWNbaseline;

                    UPmembs = mean(UPmembs,1);
                    UPmaxresp = UPmembs(DOWNmaxresptime);
                    UPbaseline = mean(UPmembs(1:-beforetime));
                    cellUPresp = UPmaxresp - UPbaseline;
                    
                    UPresp = UPmembs(-beforetime+1:end)-UPbaseline;
                    DOWNresp = DOWNmembs(-beforetime+1:end)-DOWNbaseline;
                    
                    pointwisediff = mean(UPresp - DOWNresp)/mean(DOWNresp);
                    meandiff = mean(pointwisediff);
                end
            end

%%
        end
  
        if ~isempty(cellDOWNresp)   
            results.UPresps(end+1) = cellUPresp;
            results.DOWNresps(end+1) = cellDOWNresp;
            results.cellpercentchange(end+1) = (cellUPresp - cellDOWNresp)/cellDOWNresp;
            results.cellabsolutechange(end+1) = cellUPresp - cellDOWNresp;
            results.cellDOWNmaxresptime(end+1) = DOWNmaxresptime;
            results.cellDOWNmembs(end+1,:) = DOWNmembs;
            results.cellUPmembs(end+1,:) = UPmembs;
            results.cellOverallMeanDiff(end+1) = meandiff;
            eval(['results.celltype{end+1} = matnotes(sidx).',cfn,'.OverallInterpretation;'])
            disp(sidx)
        end
    end
end

figure;
bar(results.cellpercentchange)
title({['Measurements at time of max deflection of DOWNstate: Percent drop in UP state'];...
    ['Mean: ', num2str(mean(results.cellpercentchange)),'.  SD: ',num2str(std(results.cellpercentchange)),...
    '.  Range: ',num2str(max(results.cellpercentchange)),' to ',num2str(min(results.cellpercentchange))]})

figure;bar(results.cellOverallMeanDiff)
title({['Measurements of mean drop in UP state across all post-stim points'];...
    ['Mean: ', num2str(mean(results.cellOverallMeanDiff)),'.  SD: ',num2str(std(results.cellOverallMeanDiff)),...
    '.  Range: ',num2str(max(results.cellOverallMeanDiff)),' to ',num2str(min(results.cellOverallMeanDiff))]})
