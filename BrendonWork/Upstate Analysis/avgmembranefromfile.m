beforedur=500;
afterdur=2000;
udtraces=struct;

for sidx = 1:size(matnotes,2);
%     temp = find(matnotes(sidx).upstatecells);
    goodcells = find(matnotes(sidx).spikingcells);
%     goodcells = intersect(temp,goodcells);
    if ~isempty(goodcells);
        u = {};
        d = {};
        for tidx = 1:size(matnotes(sidx).trial,2)
            if matnotes(sidx).trial(tidx).ephysupstate
                abfpath = ['C:\Exchange\Data\Axon Data\',matnotes(sidx).trial(tidx).abfname,'.abf'];
                [data,trash,channels] = abfload(abfpath);
                if ~isempty(matnotes(sidx).trial(tidx).ephys.in6)
                    bursts = separatein6(matnotes(sidx).trial(tidx).ephys.in6,300,'burst');
                    for bidx = 1:size(bursts,2);%for each burst
                        %see if it started in the up or the down state
                        for cidx = 1:length(goodcells)
                            cell = goodcells(cidx);
                            ups = matnotes(sidx).trial(tidx).ephys.cell(cell).upstates;
                            isup = 0;
%                             for uidx = 1:size(ups,1);
                            uidx = 1;
                            
                            if strcmp(matnotes(sidx).trial(tidx).stim,'wdtrain');
                                isup = 1;
                            elseif strcmp(matnotes(sidx).trial(tidx).stim,'tstrain') & bidx == 2;
                                isup = 1;
                            elseif ~isempty(ups)
                                if bursts{bidx}(1)>ups(uidx,2) & bursts{bidx}(1)<ups(uidx,3);
                                    isup = 1;
                                elseif strcmp(matnotes(sidx).trial(tidx).stim,'tstrain') & bidx == 1;
                                    isup = -1;
                                elseif bursts{bidx}(1)<ups(uidx,2) & (ups(uidx,2)-bursts{bidx}(1)>200)
                                    isup = -1;
                                end
                            elseif isempty(ups)
                                alive = matnotes(sidx).trial(tidx).ephys.cell(cell).alivecell;
                                spiking = ~isempty(matnotes(sidx).trial(tidx).ephys.cell(cell).aps);
                                if alive & spiking...%if cell was alive spiked
                                    for ccidx = 1:length(goodcells)%see if ups in any simult. recorded cell
                                        ccell = goodcells(ccidx);
                                        cups = matnotes(sidx).trial(tidx).ephys.cell(ccell).upstates;
                                        if ~isempty(cups) & isup == 0;
                                            for cuidx = 1:size(cups,1);
                                                if bursts{bidx}(1)>cups(cuidx,2) & bursts{bidx}(1)<cups(cuidx,3);
                                                    isup = 1;
                                                elseif strcmp(matnotes(sidx).trial(tidx).stim,'tstrain') & bidx == 1;
                                                    isup = -1;
                                                elseif bursts{bidx}(1)<cups(cuidx,2) & (cups(cuidx,2)-bursts{bidx}(1)>200)
                                                    isup = -1;
                                                end
                                            end
                                        end
                                    end
                                 end
                             end                            

                            if isup==1;
                                channum = strmatch(matnotes(sidx).trial(tidx).ephys.cell(cell).name,channels);
                                times(1) = max([1,bursts{bidx}(1)-beforedur]);
                                times(2) = min([bursts{bidx}(1)+afterdur size(data,1)]);
                                if length(u)<cidx;
                                    u{cidx}=[];
                                end
                                meanmemb = data(times(1):times(2),channum);
                                if ~isempty(meanmemb)
                                    u{cidx}(end+1,:) = meanmemb;
                                end
                            elseif isup == -1;
                                channum = strmatch(matnotes(sidx).trial(tidx).ephys.cell(cell).name,channels);
                                times(1) = max([1,bursts{bidx}(1)-beforedur]);
                                times(2) = min([bursts{bidx}(1)+afterdur size(data,1)]);
                                if length(d)<cidx;
                                    d{cidx}=[];
                                end
                                meanmemb = data(times(1):times(2),channum);
                                if ~isempty(meanmemb)
                                    d{cidx}(end+1,:) = meanmemb;
                                end
                            end
%                             end
                        end
                    end
                end
            end
        end
        udtraces(end+1).name = matnotes(sidx).name(1:end-4);
        udtraces(end).slicenum = sidx;
        udtraces(end).u = u;
        udtraces(end).d = d;
    end
    disp(sidx);
end

for sidx = 1:size(udtraces,2);
    if ~isempty(udtraces(sidx).d) & ~isempty(udtraces(sidx).u)
        dyes = [];
        uyes = [];
        for cidx = 1:size(udtraces(sidx).d,2);
            dyes(cidx) = ~isempty(udtraces(sidx).d{cidx});
        end
        for cidx = 1:size(udtraces(sidx).u,2);
            uyes(cidx) = ~isempty(udtraces(sidx).u{cidx});
        end
        dyes = find(dyes);
        uyes = find(uyes);
        yes = intersect(dyes,uyes);
        for yidx = 1:length(yes);
            cellidx = yes(yidx);
            figure;
            subplot(2,1,1);
            plot(udtraces(sidx).d{cellidx}')
            xlim([0,(beforedur+afterdur+1)])
            ylim([-85 0]);
            cellname = matnotes(udtraces(sidx).slicenum).CellOrder.CellChannels{cellidx};
            title([udtraces(sidx).name,' Cell ',cellname]);
            subplot(2,1,2);
            plot(udtraces(sidx).u{cellidx}')
            xlim([0,(beforedur+afterdur+1)])
            ylim([-85 0]);
        end
    end
end