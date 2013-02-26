function matnotes = classifyinteraction(matnotes,sidx);

for sidx = sidx
    if sum(matnotes(sidx).alivecells);
        for tidx = 1:size(matnotes(sidx).trial,2);
            if ~isempty(matnotes(sidx).trial(tidx).ephys.in6);
                stimtype = matnotes(sidx).trial(tidx).stim;
                binary = strcmp(stimtype,'wdtrain') | ...
                    strcmp(stimtype,'wdsingle') | ...
                    (strcmp(stimtype,'tstrain') & str2num(matnotes(sidx).name(6))>=5);
                if binary
                    alive = zeros(size(matnotes(sidx).trial(tidx).ephys.cell));
                    for cidx = 1:size(matnotes(sidx).trial(tidx).ephys.cell,2);
                        if matnotes(sidx).trial(tidx).ephys.cell(cidx).alivecell;
                            alive(cidx) = 1;%see if any cells alive
                        end
                    end
                    if sum(alive)%if any cells were alive
                        abfpath = ['C:\Exchange\Data\Axon Data\', matnotes(sidx).trial(tidx).abfname];
                        [data,trash,channels]=abfload(abfpath);
                        for cidx = find(alive);
                            celltrace = strmatch(matnotes(sidx).trial(tidx).ephys.cell(cidx).name,channels);
                            celltrace = data(:,celltrace);
                            in6 = matnotes(sidx).trial(tidx).ephys.in6;
                            
                            %%
                            f = figure('toolbar','figure');
                            title(matnotes(sidx).trial(tidx).ephys.cell(cidx).interactiontype);
                            ax=axes('YLim',[-85 30],'units','normalized','position',[.13 .1 .7750 .8]);
                            line((1:length(celltrace)),celltrace);

                            in6 = matnotes(sidx).trial(tidx).ephys.in6;
                            bursts = separatein6(in6,275,'burst');
                            tonics = separatein6(in6,275,'tonic');

                            strings = {};
                            if ~isempty(matnotes(sidx).trial(tidx).ephys.cell(cidx).interactiontype);
                                strings{1} = 'SAME';
                            end
                            strings{end+1} = 'NONE';
                            for bidx = 1:length(bursts);
                                strings{end+1} = ['Burst',num2str(bidx)];
                                thisburst = bursts{bidx};
                                line(thisburst,celltrace(thisburst),'color','r','marker','o','linestyle','none');
                                line(thisburst,(-80*ones(size(thisburst))),'color','r','marker','o','linestyle','none');
                            end
                            for toidx = 1:length(tonics);
                                strings{end+1} = ['Tonic',num2str(toidx)];
                                thistonic = tonics{toidx};
                                line(thistonic,celltrace(thistonic),'color','g','marker','o','linestyle','none');
                                line(thistonic,(-80*ones(size(thistonic))),'color','g','marker','o','linestyle','none');
                            end
                               
                            popmenu = uicontrol('style','popupmenu',...
                                            'units','normalized',...
                                            'position',[.87 .9 .12 .08],...
                                            'string',strings,...
                                            'callback',@popupcallback);
                            assignin('base','interactiontype',strings{1})
                            disp([num2str(sidx),' ',num2str(tidx)]);
                            uiwait(f);
                            interactiontype = evalin('base','interactiontype');
%% After popupmenu is clicked
                            if strcmp(interactiontype,'SAME')
                                %
                            elseif strcmp(interactiontype,'NONE')
                                matnotes(sidx).trial(tidx).interactionstim(cidx) = 0;
                                matnotes(sidx).trial(tidx).ephys.cell(cidx).interactiontype = '';
                            else ~strcmp(interactiontype,'NONE');
                                matnotes(sidx).trial(tidx).interactionstim(cidx) = 1;
                                matnotes(sidx).trial(tidx).ephys.cell(cidx).interactiontype = interactiontype;
                            end
                        end
                    end
                end
            end
        end
    end
end




function popupcallback(obj,ev);
strs = get(obj,'String');
assignin('base','interactiontype',strs{get(obj,'value')})

