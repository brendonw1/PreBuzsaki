function peristim = InteractMoviePSTH(moviecell)

cumbefore = zeros(1,10);
cumduring = 0;
cumafter = zeros(1,10);
totalmovies = 0;
totalcellmovies = 0;
totalcellsprobed = 0;

slices = fieldnames(moviecell);

for sidx = 1:length(slices);
    sname = slices{sidx};
    eval(['nummovs = length(moviecell.',sname,');'])
    
    peristim.slices(sidx).beforeons = {};
    peristim.slices(sidx).duringons = {};
    peristim.slices(sidx).afterons = {};
    peristim.slices(sidx).beforecounts = [];
    peristim.slices(sidx).duringcounts = [];
    peristim.slices(sidx).aftercounts = [];

    for midx = 1:nummovs
        eval(['movinfo = moviecell.',sname,'(midx);'])
        interact = movinfo.Movie1AnyInteract;
        upyn = movinfo.UpYNover;
        if isempty(interact);interact = 0;end        
        if isempty(upyn);upyn = 0;end
        if interact && upyn
            ons = movinfo.OnsOversampled;
            intframe = movinfo.MovieOversampledInteractFrame;
            
            beforestart = max([1 intframe-10]);%getting 10 frames before the stim, or the first frame
            beforeons = ons(beforestart:intframe-1,:);%grab frames before interacting stim
            peristim.slices(sidx).beforeons{end+1} = beforeons;%store
            tbc = sum(beforeons,2)';%just count number of cells
            beforecounts = zeros(1,10);%embedding counts in a 1x10 vector
            beforecounts((end-size(tbc,2)+1):end) = tbc;%regardless of length of counts
            peristim.slices(sidx).beforecounts(end+1,:) = beforecounts;
            
            duringons = ons(intframe,:);
            peristim.slices(sidx).duringons{end+1} = duringons;
            duringcounts = sum(duringons,2)';
            peristim.slices(sidx).duringcounts(end+1,:) = duringcounts;
            
            afterend = min([size(ons,1) intframe+10]);
            afterons = ons(intframe+1:afterend,:);
            peristim.slices(sidx).afterons{end+1} = afterons;
            tac = sum(afterons,2)';
            aftercounts = zeros(1,10);
            aftercounts((end-size(tac,2)+1):end) = tac;
            peristim.slices(sidx).aftercounts(end+1,:) = aftercounts;
            
            
            cumbefore = cumbefore + beforecounts;
            cumduring = cumduring + duringcounts;
            cumafter = cumafter + aftercounts;
            
            totalmovies = totalmovies + 1;
            totalcellmovies = totalcellmovies + size(ons,2);
    
        end
    end
    totalcellsprobed = totalcellsprobed + size(ons,2);    
end

peristim.cumbefore = cumbefore;
peristim.cumduring = cumduring;
peristim.cumafter = cumafter;
peristim.totalmovies = totalmovies;
peristim.totalcellmovies = totalcellmovies;
peristim.totalcellsprobed = totalcellsprobed;

figure;
bar([-10:10],[cumbefore cumduring cumafter]);
hold on
plot(0,cumduring,'marker','*','color','r')
xlabel('Frame number.  100ms/Frame.  Frame 0 = Stim')
ylabel('Number of Spikes from all cells in all trials')
xlim([-11 11])
title('Peri-stimulus time histogram of detected spikes in calcium imaging')