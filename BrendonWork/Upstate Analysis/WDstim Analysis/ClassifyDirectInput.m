function matnotes = ClassifyInDirectInput(matnotes,sidx);

dicells = {};
for sidx = sidx
    goodcells = find(matnotes(sidx).alivecells);
    for cidx = 1:length(goodcells);
        membs = [];
        cell = goodcells(cidx);
        for tidx = 1:size(matnotes(sidx).trial,2);
            if isfield(matnotes(sidx).trial(tidx).ephys,'cell');
                if matnotes(sidx).trial(tidx).ephys.cell(cell).alivecell;
                    stimtype = matnotes(sidx).trial(tidx).stim;
                    binary = strcmp(stimtype,'wdtrain') | ...
                        strcmp(stimtype,'wdsingle') | ...
                        strcmp(stimtype,'tstrain') | ...
                        strcmp(stimtype,'tssingle');
                    if binary
                        if ~isempty(matnotes(sidx).trial(tidx).ephys.in6);
%                             abfpath = ['E:\Abeles Data Folder\Axon Data\', matnotes(sidx).trial(tidx).abfname];
%                             [data,trash,channels]=abfload(abfpath);
                            abfpath1 = matnotes(sidx).trial(tidx).ephys.abfname;
                            try
                                abfpath = ['D:\Exchange\Data\Axon Data\',abfpath1];
                                [data,trash,channels]=abfload(abfpath);
                            catch
                                abfpath = ['E:\Brendon From Snap\BW Exchange\Data\Axon Data\',abfpath1];
                                [data,trash,channels]=abfload(abfpath);                            
                            end

                            celltrace = strmatch(matnotes(sidx).trial(tidx).ephys.cell(cidx).name,channels);
                            celltrace = data(:,celltrace);
                            in6 = matnotes(sidx).trial(tidx).ephys.in6(1);
                            membs = cat(2,membs,celltrace((in6-500):(in6+2000)));
                        end
                    end
                end
            end
        end
        if ~isempty(membs);
            membs = fliplr(membs);%plot first traces on top of later traces (easier to single stim)
            f = figure('toolbar','figure','units','normalized','position',[.3 .05 .4 .45]);
%             ax=axes('units','normalized','position',[.13 .1 .7750 .8]);
            plot(membs);
            line([500 500],[-85 40],'color','r')
            ylim([-85 -40])
            title([num2str(sidx),' ',matnotes(sidx).name(1:end-4),' ',num2str(cell)]);
            di = questdlg('Direct Input Cell?');
            if strcmp(di,'Yes');
                cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};
                eval(['matnotes(sidx).',cfn,'.DirectInput=1;']);
                close(f);
%                 dicells{end+1} = [];
                disp([matnotes(sidx).name(1:end-4),' ',cfn]);
            elseif strcmp(di,'No');
                cfn = matnotes(sidx).CellOrder.CellFieldNames{cell};
                eval(['matnotes(sidx).',cfn,'.DirectInput=0;']);
                close(f);
            else
                close(f);
                return
            end
        end
    end
end