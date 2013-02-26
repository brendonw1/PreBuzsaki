function matnotes = CorrectGrayMatter(matnotes);

%if a gray matter stimulus slice, reset all stims in slice to gm-type stims
for sidx = 1:size(matnotes,2);
    gmthisslice = 0;
    for tidx = 1:size(matnotes(sidx).trial,2);
        if strcmpi(matnotes(sidx).trial(tidx).stimprotocol,'gm')
            gmthisslice = 1;
        end
    end
    if gmthisslice == 1;
        for tidx = 1:size(matnotes(sidx).trial,2);
            if strcmpi(matnotes(sidx).trial(tidx).stim,'tstrain')
                    matnotes(sidx).trial(tidx).stim='graytrain';
            elseif strcmpi(matnotes(sidx).trial(tidx).stim,'tssingle')
                    matnotes(sidx).trial(tidx).stim='graysingle';
            elseif strcmpi(matnotes(sidx).trial(tidx).stim,'wdtrain')
                    matnotes(sidx).trial(tidx).stim='wdgraytrain';
            elseif strcmpi(matnotes(sidx).trial(tidx).stim,'wdsingle')
                    matnotes(sidx).trial(tidx).stim='wdgraysingle';
            end
        end
    end
end