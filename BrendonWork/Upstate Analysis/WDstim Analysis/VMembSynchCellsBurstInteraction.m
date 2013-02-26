function VMembSynchCellsBurstInteraction(matnotes,stimnum,varargin);

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
beforetime = -1500;
aftertime = 4100;
% stimnum = 1;%which individual stim within the burst is locked to

%% gather data
for sidx = 1:size(matnotes,2);
    pregoodcells = find(matnotes(sidx).spikingcells);
    goodcells = [];
    for cidx = 1:length(pregoodcells)%go through all cells that had spiking ups
        cell = pregoodcells(cidx);
        cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};
        eval(eval(distring));%make tempvar
        if tempvar;
            goodcells(end+1) = cell;
        end
    end
    if length(goodcells>1);
        membs = [];
        for cidx = 1:length(goodcells)%go through all cells that had spiking ups
            cell = goodcells(cidx);            
            for tidx = 1:size(matnotes(sidx).trial,2)%go through each trial
                if isfield(matnotes(sidx).trial(tidx).ephys,'cell');
                    in6 = matnotes(sidx).trial(tidx).ephys.in6;
                    interactiontype = matnotes(sidx).trial(tidx).ephys.cell(cell).interactiontype;
                    if ~isempty(strfind(lower(interactiontype),'burst'))%if a burst interaction
                        burstnum = str2num(interactiontype(6));
                        bursts = separatein6(in6,275,'burst');
                        if ~isempty(bursts);
                            burstnum = min([size(bursts,2) burstnum]);
                            if length(bursts{burstnum})>=stimnum;
                                timeref = bursts{burstnum}(stimnum);
                                abfpath = matnotes(sidx).trial(tidx).ephys.abfname;
                                abfpath = ['C:\Exchange\Data\Axon Data\',abfpath];
                                [data,trash,channels]=abfload(abfpath);
                                ccn = matnotes(sidx).CellOrder.CellChannels{cell};
                                chanmatch = strmatch(ccn,channels);
                                tempmemb = data(:,chanmatch);
                                membs(:,tidx,cidx) = tempmemb(timeref+beforetime:timeref+aftertime);
                                
                            end
                        end
                    end
                end
            end
%% plot
            if ~isempty(membs)
                goodtrials = {};
                goodt = [];
                for t=1:size(membs,2);
                    gc = [];
                    for c=1:size(membs,3);
                        if sum(membs(:,t,c))~=0
                            gc(end+1) = c; 
                        end
                    end
                    if sum(gc)>1;
                        goodtrials{t} = find(gc);%list of good cells for that trial
                    end
                end
                for t = 1:length(goodtrials)
                    if ~isempty(goodtrials{t})
                        goodt(end+1) = t;
                    end
                end
                if ~isempty(goodt);
                    figure;
                    cl=hsv(length(goodt)+1);
                    for ti = 1:length(goodt);
                        t = goodt(ti);
                        for c = 1:length(goodtrials{t})
                            tm = membs(:,t,c);
                            hold on;
                            col = cl(ti,:);
                            plot(tm,'color',col)
                        end
                    end
                end
            end
%%
        end
    end
end