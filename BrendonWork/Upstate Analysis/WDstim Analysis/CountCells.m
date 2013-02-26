function CountCellsBurst(matnotes,stimnum,binafterstim,varargin);
%count numbers of cells satisfying various criteria.  Output these numbers.
warning off
%% evaluate inputs and setup
directdesc = 'All Cells. ';
distring = ['''tempvar = 1;'''];%default
for vidx = 1:length(varargin);
    if strcmp(varargin{vidx},'direct');
        direct = varargin{vidx+1};
        switch direct
            case 1
                directdesc = 'DI Cells. ';
                distring = '[''tempvar = matnotes(sidx).'',cfn,''.DirectInput;'']';
            case 0
                directdesc = 'non-DI Cells. ';
                distring = '[''tempvar = ~(matnotes(sidx).'',cfn,''.DirectInput);'']';
        end
    end
end

events = [];
% stimnum = 1;%which individual stim within the burst is locked to

%% gather data
aliveanddirectornot = 0;
upstatesdirectornot = 0;
spikingupstatesdirectornotcore = 0;
spikingupstatesdirectornotnoncore = 0;
spikingintimebincore= 0;
spikingintimebinnoncore= 0;
spikingintimebincells = struct;
cellsonlyintimebin = 0;
burstsinburstburst = 0;
inbininburstburst = 0;

for sidx = 1:size(matnotes,2);%for each slice
     for cidx = 1:size(matnotes(sidx).CellOrder.CellChannels,2);%for each cell
         %go through all cells that had spiking ups
        cell = cidx;
        if matnotes(sidx).alivecells(cell);
            cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};
            eval(eval(distring));%make tempvar... ie direcinput-or-not status
            if tempvar;
                aliveanddirectornot = aliveanddirectornot + 1;%record alive
                if matnotes(sidx).upstatecells(cell);%if cell ever had an upstate
                    upstatesdirectornot = upstatesdirectornot + 1;%record upstates
                    if matnotes(sidx).spikingcells(cell);
                        if matnotes(sidx).corecells(cell)
                            spikingupstatesdirectornotcore = spikingupstatesdirectornotcore+1;%record spiking ups
                        else
                            spikingupstatesdirectornotnoncore = spikingupstatesdirectornotnoncore+1;%record spiking ups
                        end
                        thiscellintimebin = 0;
                        cellonlyfiresintimebin = 1;
                        for tidx = 1:size(matnotes(sidx).trial,2);%for each trial
%%
                            if strcmp(matnotes(sidx).trial(tidx).stim,'wdtrain')
%%
                                spikingtrial = 0;
                                thistrialinbin = 0;
                                if isfield(matnotes(sidx).trial(tidx).ephys,'cell');
                                    aps = matnotes(sidx).trial(tidx).ephys.cell(cell).aps;
                                    if ~isempty(aps);%if this cell spikes this trial
                                        spikingtrial = 1;
                                        interactiontype = matnotes(sidx).trial(tidx).ephys.cell(cell).interactiontype;
                                        if ~isempty(strfind(lower(interactiontype),'burst'))%if a burst interaction
                                            in6 = matnotes(sidx).trial(tidx).ephys.in6;
                                            burstnum = str2num(interactiontype(6));
                                            bursts = separatein6(in6,275,'burst');
                                            burstsinburstburst = burstsinburstburst + 1;
                                            if ~isempty(bursts);
                                                burstnum = min([size(bursts,2) burstnum]);
                                                matnotes(sidx).trial(tidx);
                                                matnotes(sidx).trial(tidx).ephys;
                                                if length(bursts{burstnum})>=stimnum;
                                                    timeref = bursts{burstnum}(stimnum);
%% for making sure it's in an official upstate
%                                                     ups = matnotes(sidx).trial(tidx).ephys.cell(cidx).upstates;
%                                                     stiminup = 0;
%                                                     for uidx = 1:size(ups,2);
%                                                         if timeref>=ups(2) & timeref<=ups(3);
%                                                             stiminup = 1;
%                                                             break
%                                                         end
%                                                     end
%                                                     if stiminup
%%                                                    
                                                        aps = aps - timeref;
                                                        aps(aps<0)=[];
                                                        binstop = binafterstim*10;
                                                        if ~isempty(find(aps<binstop))
                                                            thiscellintimebin = thiscellintimebin + 1;
                                                            thistrialinbin = 1;
                                                        end
%                                                     end
                                                end
                                            end
                                        end
                                    end
                                end
                                if spikingtrial == 1 & thistrialinbin == 0;
                                    cellonlyfiresintimebin = 0;
                                end
                            else%if not wdtrain
                                cellonlyfiresintimebin = 0;
                            end
                        end
                        if thiscellintimebin>0
                            if matnotes(sidx).corecells(cell)
                                spikingintimebincore = spikingintimebincore + 1;%record spiking in this time bin
                            else
                                spikingintimebinnoncore = spikingintimebinnoncore + 1;%record spiking in this time bin
                            end
                            %get and store info about which cells were
                            %involved
                            thiscell = matnotes(sidx).CellOrder.CellFieldNames{cell};
                            eval(['spikingintimebincells(end+1).type = matnotes(sidx).',thiscell,'.OverallInterpretation;']);
                            spikingintimebincells(end).cellname = [matnotes(sidx).name(1:end-4),' ',thiscell(1:end-4)];
                            spikingintimebincells(end).matnotesaddress = [sidx cidx];
                            %%
                            inbininburstburst = inbininburstburst + 1;
                        end
                        if cellonlyfiresintimebin
                            cellsonlyintimebin = cellsonlyintimebin + 1;
                        end
                    end
                end
            end
        end
    end
end

%% Count numbers of cells with qualified burst interactions
burstinteractionslices = 0;
burstinteractioncells = 0;
diburstinteractioncells = 0;
nondiburstinteractioncells = 0;
dicellnames = {};
for sidx = 1:size(matnotes,2);
    goodcells = zeros(1,4); 
    gooddicells = zeros(1,4);
    goodnondicells = zeros(1,4);
    for tidx = 1:size(matnotes(sidx).trial,2)%for each trial
%% for making sure it's really wdstim
        if strcmp(matnotes(sidx).trial(tidx).stim,'wdtrain')%if an official wdtrain cell
%%
            if isfield(matnotes(sidx).trial(tidx).ephys,'cell')%if cells recorded
                for cidx = 1:4;%for each cell
                    if ~isempty(matnotes(sidx).trial(tidx).ephys.cell(cidx).interactiontype);%get interactiontype
                        interactiontype = matnotes(sidx).trial(tidx).ephys.cell(cidx).interactiontype;
%%
                        if ~isempty(strfind(lower(interactiontype),'burst'))%if it was some sort of burst
                            in6 = matnotes(sidx).trial(tidx).ephys.in6;
                            burstnum = str2num(interactiontype(6));
                            bursts = separatein6(in6,275,'burst');
                            if ~isempty(bursts);%if really bursts (unnecessary now)
                                burstnum = min([size(bursts,2) burstnum]);%extract the specified one
                                if length(bursts{burstnum})>=stimnum;
                                    timeref = bursts{burstnum}(stimnum);
%% for making sure it's in an official upstate                                                 
%                                     ups = matnotes(sidx).trial(tidx).ephys.cell(cidx).upstates;
%                                     stiminup = 0;
%                                     for uidx = 1:size(ups,2);
%                                         if timeref>=ups(2) & timeref<=ups(3);
%                                             stiminup = 1;
%                                             break
%                                         end
%                                     end
%                                     if stiminup%if burst was in a real upstate
%%
                                        goodcells(cidx) = 1;%record this cell had an interaction...
                                        cname = matnotes(sidx).CellOrder.CellFieldNames{cidx};
                                        eval(['dirin = matnotes(sidx).',cname,'.DirectInput;']);
                                        if dirin == 1
                                            gooddicells(cidx) = 1;%... and was direct-input
                                            dicellnames{end+1} = [matnotes(sidx).name(1:end-4),' '];
                                            dicellnames{end} = [dicellnames{end},matnotes(sidx).CellOrder.CellChannels{cidx}];
                                        elseif dirin == 0
                                            goodnondicells(cidx) = 1;%... or not
                                        end
                                    end
                                end
%                             end
                        end
                    end
                end
            end
        end
    end
    burstinteractioncells = burstinteractioncells + sum(goodcells);
    diburstinteractioncells = diburstinteractioncells + sum(gooddicells);
    nondiburstinteractioncells = nondiburstinteractioncells + sum(goodnondicells);
    if sum(goodcells) > 0
        burstinteractionslices = burstinteractionslices + 1;
    end
end

%% Output
figure;axes;
title(directdesc)
text(1,-1,['Cells alive = ',num2str(aliveanddirectornot)]);
text(1,-2,['Cells with ups = ',num2str(upstatesdirectornot)]);
text(1,-3,['Core cells spiking = ',num2str(spikingupstatesdirectornotcore)]);
text(1,-4,['Non-Core cells spiking = ',num2str(spikingupstatesdirectornotnoncore)]);
text(1,-5,['Core cells spiking within ',num2str(binafterstim),'ms after burst interaction = ',num2str(spikingintimebincore)]);
text(1,-6,['Non-Core cells spiking within ',num2str(binafterstim),'ms after burst interaction = ',num2str(spikingintimebinnoncore)]);
text(1,-7,['Cells firing only within timebin and never else = ',num2str(cellsonlyintimebin)]);

%superghetto oh well
if strcmp(directdesc,'DI Cells. ')
    text(1,-9,['Number of Direct Input cells w/ burst interaction = ',num2str(diburstinteractioncells)]);
elseif strcmp(directdesc,'non-DI Cells. ')
    text(1,-9,['Number of Non-Direct Input cells w/ burst interaction = ',num2str(nondiburstinteractioncells)]);
elseif strcmp(directdesc,'All Cells. ')
    text(1,-9,['Number of All cells w/ burst interaction = ',num2str(burstinteractioncells)]);
end
text(1,-10,['Number of Slices w/ burst interaction = ',num2str(burstinteractionslices)]);

axis([0 7 -11 0])

%%

spikingintimebincells(1)=[];
figure;
title(['Among ',directdesc,'Which cells fired in the ',num2str(binafterstim),' ms time bin'])
for idx = 1:length(spikingintimebincells)
    thiscellprofile = [spikingintimebincells(idx).type,...
        '               ',spikingintimebincells(idx).cellname,...
        '               ',...
        num2str(spikingintimebincells(idx).matnotesaddress)];
    text(1,-idx,thiscellprofile);
end
axis([0 10 -idx-1 0])

%%
figure;
keepernames = {};
for idx = 1:length(dicellnames);
    if isempty(strmatch(dicellnames{idx},keepernames))
        keepernames{end+1} = dicellnames{idx};
    end
end
title(keepernames)
axis off
text(.2,.5,'Direct Input Cells with Interaction')