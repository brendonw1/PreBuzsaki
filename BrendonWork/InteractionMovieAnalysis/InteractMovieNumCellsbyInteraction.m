function totals = InteractMovieNumCellsbyInteraction(moviecell)

cumtsactives = [];
cumspactives = [];
cumbbactives = [];
cumwdactives = [];
cumupactives = [];
cumusactives = [];

sliceusupdiffs = [];
slicebbtsdiffs = [];
slicewdspdiffs = [];
slices = fieldnames(moviecell);

for sidx = 1:length(slices);
    sname = slices{sidx};
    eval(['nummovs = length(moviecell.',sname,');'])
    tsactives = [];
    spactives = [];
    bbactives = [];
    wdactives = [];
    upactives = [];
    usactives = [];
    for midx1 = 1:nummovs
        eval(['movinfo = moviecell.',sname,'(midx1);'])
        numactives = sum(logical(sum(movinfo.Ons1,1)));
        if strcmp('s',movinfo.Protocol)
            tsactives(end+1) = numactives;%actives in tstrain movie
            upactives(end+1) = numactives;%pooled with spont
            cumtsactives(end+1) = numactives;%counting all for this conditions
            cumupactives(end+1) = numactives;%counting all for this conditions
        elseif strcmp('look',movinfo.Protocol)
            spactives(end+1) = numactives;%actives in spont movie
            upactives(end+1) = numactives;
            cumspactives(end+1) = numactives;%counting all for this conditions
            cumupactives(end+1) = numactives;%counting all for this conditions
        elseif strcmp('ss',movinfo.Protocol)
            bbactives(end+1) = numactives;%actives in burst burst
            usactives(end+1) = numactives;%pooled with spont stim
            cumbbactives(end+1) = numactives;%counting all for this conditions
            cumusactives(end+1) = numactives;%counting all for this conditions
        elseif strcmp('spontstim',movinfo.Protocol)
            wdactives(end+1) = numactives;%actives in spontstim
            usactives(end+1) = numactives;
            cumwdactives(end+1) = numactives;%counting all for this conditions
            cumusactives(end+1) = numactives;%counting all for this conditions            
        end
    end
    sliceusupdiffs(end+1) = mean(usactives) - mean(upactives);
    slicebbtsdiffs(end+1) = mean(bbactives) - mean(tsactives);
    slicewdspdiffs(end+1) = mean(spactives) - mean(wdactives);
end
1;
%% plot up vs us: upper panel total distribution, lower panel subtractions
%% per slice
figure;hist(cumupactives);hold on;hist(cumusactives,'color','r')

%% plot tstrain vs bb: upper panel total distribution, lower panel
%% subtractions per slice

%% plot spont vs spontstim: upper panel total distribution, lower panel
%% subtractions per slice

