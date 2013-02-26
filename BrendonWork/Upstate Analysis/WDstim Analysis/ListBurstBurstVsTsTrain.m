function results = ListBursbBurstVsTsTrain(matnotes,stimnum,varargin);

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
spontupguide = logical([]);
tstrainupguide = logical([]);

results.allcellnumbers = [];
results.allcellnames = {};
results.allcelldescrip = {};
results.diallcellnumbers = [];
results.diallcellnames = {};
results.diallcelldescrip = {};
results.nondiallcellnumbers = [];
results.nondiallcellnames = {};
results.nondiallcelldescrip = {};


results.burstbcellnumbers = [];
results.burstbcellnames = {};
results.burstbcelldescrip = {};
results.tstraincellnumbers = [];
results.tstraincellnames = {};
results.tstraincelldescrip = {};

results.diburstbcellnumbers = [];
results.diburstbcellnames = {};
results.diburstbcelldescrip = {};
results.ditstraincellnumbers = [];
results.ditstraincellnames = {};
results.ditstraincelldescrip = {};

results.nondiburstbcellnumbers = [];
results.nondiburstbcellnames = {};
results.nondiburstbcelldescrip = {};
results.nonditstraincellnumbers = [];
results.nonditstraincellnames = {};
results.nonditstraincelldescrip = {};

for sidx = 1:size(matnotes,2);
    for cell = 1:4%go through all cells that had spiking ups
        cellnum = 4*(sidx-1)+cell;
        thiscellhasburstb = 0;
        thiscellhasspont = 0;
        thiscellhaststrain = 0;
%         burstbupnum = 0;
%         spontupnum = 0;
%         tstrainupnum = 0;
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
%% Looking for Burstburst
%         thiscellhasstiminup = 0;%to allow for later recording data seprarately for cells with stim in ups versus those without
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

% %% for making sure it's in an official upstate                                                 
                                        ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
                                        stiminup = 0;
                                        for uidx = 1:size(ups,1);
                                            if timeref>=ups(uidx,2) & timeref<=ups(uidx,3);
                                                if in6(1)<ups(uidx,1)%for burstburst or tonicburst... make sure stim started before up, (while interaction stim was during up)
                                                    stiminup = 1;%stim in up used later to record stats specifically 
                                                    break
                                                end
                                            end
                                        end
                                        if stiminup                                              
                                            if ~isempty(ups);
                                                thiscellhasburstb = 1;
                                            end
                                        end
                                    end
%                                 end
                            end
                        end
                    end
                end
%% Evaluate Spontaneous spiking for same cell
%                 if strcmp(matnotes(sidx).trial(tidx).stim,'spont')%if the trial is 'spont'
%                     if isfield(matnotes(sidx).trial(tidx).ephys,'cell');
% %note no interaction stuff here
% %                         aps = matnotes(sidx).trial(tidx).ephys.cell(cell).aps;
%                         ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
%                         if ~isempty(ups);
%                             thiscellhasspont = 1;
%                         end
%                     end
%                 end
%% Evaluate TsTrain spiking for same cell
                if strcmp(matnotes(sidx).trial(tidx).stim,'tstrain')%if the trial is 'spont'
                    if isfield(matnotes(sidx).trial(tidx).ephys,'cell');
%note no interaction stuff here
%                         aps = matnotes(sidx).trial(tidx).ephys.cell(cell).aps;
                        ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
                        if ~isempty(ups);
                            thiscellhaststrain = 1;
                        end
                    end
                end
            end
%% to record data for each cell
        end
        if thiscellhasburstb | thiscellhaststrain;
            cellrecorded = 0;
            sln = matnotes(sidx).name(1:end-4);
            eval(['celldi = matnotes(sidx).',cfn,'.DirectInput;'])
            cellinfo = eval(['matnotes(sidx).',cfn]);
            sp = cellinfo.SpikePatternInterpretation;
            mo = cellinfo.MorphologyInterpretation;
            ov = cellinfo.OverallInterpretation;
            
            results.allcellnumbers(end+1,:) = [sidx cell];
            results.allcellnames{end+1,1} = [sln,' ',cfn];
            results.allcelldescrip{end+1,1} = [sln,' ',cfn,' ',num2str(celldi),' ',ov,' ',sp,' ',mo];
            if celldi
                results.diallcellnumbers(end+1,:) = [sidx cell];
                results.diallcellnames{end+1,1} = [sln,' ',cfn];
                results.diallcelldescrip{end+1,1} = [sln,' ',cfn,' ',num2str(celldi),' ',ov,' ',sp,' ',mo];
            else
                results.nondiallcellnumbers(end+1,:) = [sidx cell];
                results.nondiallcellnames{end+1,1} = [sln,' ',cfn];
                results.nondiallcelldescrip{end+1,1} = [sln,' ',cfn,' ',num2str(celldi),' ',ov,' ',sp,' ',mo];
            end
            
            if thiscellhasburstb;
                results.burstbcellnumbers(end+1,:) = [sidx cell];
                results.burstbcellnames{end+1,1} = [sln,' ',cfn];
                results.burstbcelldescrip{end+1,1} = [sln,' ',cfn,' ',num2str(celldi),' ',ov,' ',sp,' ',mo];
                if celldi
                    results.diburstbcellnumbers(end+1,:) = [sidx cell];
                    results.diburstbcellnames{end+1,1} = [sln,' ',cfn];
                    results.diburstbcelldescrip{end+1,1} = [sln,' ',cfn,' ',num2str(celldi),' ',ov,' ',sp,' ',mo];
                else
                    results.nondiburstbcellnumbers(end+1,:) = [sidx cell];
                    results.nondiburstbcellnames{end+1,1} = [sln,' ',cfn];
                    results.nondiburstbcelldescrip{end+1,1} = [sln,' ',cfn,' ',num2str(celldi),' ',ov,' ',sp,' ',mo];
                end
            end
%             if thiscellhasspont;
%                 results.spontcellnumbers(end+1,:) = [sidx cell];
%                 results.spontcellnames{end+1,1} = [sln,' ',cfn];
%                 results.spontcelldescrip{end+1,1} = [sln,' ',cfn,' ',num2str(celldi),' ',ov,' ',sp,' ',mo];
%                 if celldi
%                     results.dispontcellnumbers(end+1,:) = [sidx cell];
%                     results.dispontcellnames{end+1,1} = [sln,' ',cfn];
%                     results.dispontcelldescrip{end+1,1} = [sln,' ',cfn,' ',num2str(celldi),' ',ov,' ',sp,' ',mo];
%                 else
%                     results.nondispontcellnumbers(end+1,:) = [sidx cell];
%                     results.nondispontcellnames{end+1,1} = [sln,' ',cfn];
%                     results.nondispontcelldescrip{end+1,1} = [sln,' ',cfn,' ',num2str(celldi),' ',ov,' ',sp,' ',mo];
%                 end
%             end
            if thiscellhaststrain;
                results.tstraincellnumbers(end+1,:) = [sidx cell];
                results.tstraincellnames{end+1,1} = [sln,' ',cfn];
                results.tstraincelldescrip{end+1,1} = [sln,' ',cfn,' ',num2str(celldi),' ',ov,' ',sp,' ',mo];
                if celldi
                    results.ditstraincellnumbers(end+1,:) = [sidx cell];
                    results.ditstraincellnames{end+1,1} = [sln,' ',cfn];
                    results.ditstraincelldescrip{end+1,1} = [sln,' ',cfn,' ',num2str(celldi),' ',ov,' ',sp,' ',mo];
                else
                    results.nonditstraincellnumbers(end+1,:) = [sidx cell];
                    results.nonditstraincellnames{end+1,1} = [sln,' ',cfn];
                    results.nonditstraincelldescrip{end+1,1} = [sln,' ',cfn,' ',num2str(celldi),' ',ov,' ',sp,' ',mo];
                end
            end
        end
    end
end

fields = fieldnames(results);
for fidx = 1:size(fields,1);
    if ~isempty(findstr('descrip',fields{fidx}))
        xlmat = {};
        name = fields{fidx};
        eval(['data = results.',name,';']);
        xlmat{1,1} = name;
        xlmat{1,3} = ['n = ',num2str(size(data,1)),' cells.'];
        xlmat{3,1} = 'Slice #';
        xlmat{3,2} = 'Cell #';
        xlmat{3,3} = 'Slice and cell names';
        xlmat{3,4} = 'Direct Input';
        xlmat{3,5} = 'Core';
        xlmat{3,6} = 'Ephys';
        xlmat{3,7} = 'Morpho';
        xlmat{3,8} = 'Overall';
        xlmat{3,9} = 'Official';
%         fid = fopen([name,'.txt'],'w');
%         fprintf(fid,[name,'.  n = ',num2str(size(data,1)),' cells.\n\n']);
        for didx = 1:size(data,1);
            eval(['sidx = results.',name(1:end-7),'numbers(',num2str(didx),',1);']);
            eval(['cell = results.',name(1:end-7),'numbers(',num2str(didx),',2);']);
            eval(['cname = results.',name(1:end-7),'names{',num2str(didx),'};']);
            cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};%set up to test for direct input or not
            eval(['celldi = matnotes(sidx).',cfn,'.DirectInput;'])
            cellcore = matnotes(sidx).corecells(cell);
            cellinfo = eval(['matnotes(sidx).',cfn]);
            sp = cellinfo.SpikePatternInterpretation;
            mo = cellinfo.MorphologyInterpretation;
            ov = cellinfo.OverallInterpretation;
            
            xlmat{3+didx,1} = sidx;
            xlmat{3+didx,2} = cell;
            xlmat{3+didx,3} = cname;
            xlmat{3+didx,4} = celldi;
            xlmat{3+didx,5} = cellcore;
            xlmat{3+didx,6} = sp;
            xlmat{3+didx,7} = mo;
            xlmat{3+didx,8} = ov;
            xlmat{3+didx,9} = [];
%             fprintf(fid,[data{didx},'\n']);
        end
%         fclose(fid);
        xlswrite(name,xlmat);
    end
end