function shuffaps = ReshuffleBurstInteractionAps(matnotes,stimnum,numshuffs,aftertime,varargin);

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

events = [];
beforetime = -0;
% aftertime = 1500;%from input in this version
% numshuffs = 1000;
% stimnum = 1;%which individual stim within the burst is locked to

%% gather data
for z = 1:numshuffs;
    allaps = [];
    for sidx = 1:size(matnotes,2);
        goodcells = 1:4;
        for tidx = 1:size(matnotes(sidx).trial,2)%go through each trial
            if strcmp(matnotes(sidx).trial(tidx).stim,'wdtrain')
                in6 = matnotes(sidx).trial(tidx).ephys.in6;
                interactcriterion = find(matnotes(sidx).trial(tidx).interactionstim);
                trialgoodcells = intersect(goodcells,interactcriterion);
                for cidx = 1:length(trialgoodcells)%go through all cells that had spiking ups
                    cell = trialgoodcells(cidx);
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
                    
                    cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};
                    eval(eval(distring));%create tempvar
                    if tempvar;
                        if isfield(matnotes(sidx).trial(tidx).ephys,'cell');
                            interactiontype = matnotes(sidx).trial(tidx).ephys.cell(cell).interactiontype;
                            if ~isempty(strfind(lower(interactiontype),'burst'))%if a burst interaction
                                burstnum = str2num(interactiontype(6));
                                bursts = separatein6(in6,275,'burst');
                                if ~isempty(bursts);
                                    burstnum = min([size(bursts,2) burstnum]);
                                    aps = matnotes(sidx).trial(tidx).ephys.cell(cell).aps;
%                                     if ~isempty(aps);
                                        if length(bursts{burstnum})>=stimnum;
                                            if ~isempty (matnotes(sidx).trial(tidx).ephys.cell(cell).upstates);
                                                burststart = bursts{burstnum}(stimnum);
                                                ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
                                                bef = find(ups(:,2)<burststart);
                                                aft = find(ups(:,3)>burststart);
                                                befaft = intersect(bef,aft);                                        
                                                if ~isempty(befaft);%if we aer in the right upstate
                                                    upstart = ups(befaft,2);
                                                    upstop = ups(befaft,3);
%                                                     timeref = upstart + rand(1)*(upstop-upstart);
                                                    timeref = upstart + rand(1)*10000;

%                                                     timeref = bursts{burstnum}(stimnum);
%                                                     timeref = timeref+3000;
%% for making sure it's in an official upstate         
%                                                     stiminup = 0;
%                                                     for uidx = 1:size(ups,2);
%                                                         if timeref>=ups(2) & timeref<=ups(3);
%                                                             stiminup = 1;
%                                                             break
%                                                         end
%                                                     end
%                                                     if stiminup
%%                                                    
                                                        aps = aps-timeref;
                                                        aps(aps < beforetime) = [];
                                                        aps(aps > aftertime) = [];
                                                        allaps = cat(2,allaps,aps);
%                                                     end
                                                end
                                            end
%                                         end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    shuffaps(z) = length(allaps);
    disp(z);
end

figure;hist(shuffaps);
title([num2str(numshuffs),' reshuffles of dataset.  How many spikes in the dataset fall within ',num2str(aftertime/10),'ms of burst stim']);