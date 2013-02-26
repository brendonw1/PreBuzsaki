function overlaps = SpontInteractMovieOverlap(moviecell,numreshuffs)
%noninteraction vs noninteraction
%interaction vs noninteraction
%interaction vs interaction
%just use mov1
zperc = zeros(1,numreshuffs); %#ok<NASGU>

overlaps.intintpercs = [];
overlaps.intintname1 = {};
overlaps.intintname2 = {};
overlaps.intnonpercs = [];
overlaps.intnonname1 = {};
overlaps.intnonname2 = {};
overlaps.nonnonpercs = [];
overlaps.nonnonname1 = {};
overlaps.nonnonname2 = {};

overlaps.intintzpercs = [];
overlaps.intnonzpercs = [];
overlaps.nonnonzpercs = [];


slices = fieldnames(moviecell);

for sidx = 1:length(slices);
    sname = slices{sidx};
    overlaps.slices(sidx).intintpercs = [];
    overlaps.slices(sidx).intintname1 = {};
    overlaps.slices(sidx).intintname2 = {};
    overlaps.slices(sidx).intnonpercs = [];
    overlaps.slices(sidx).intnonname1 = {};
    overlaps.slices(sidx).intnonname2 = {};
    overlaps.slices(sidx).nonnonpercs = [];
    overlaps.slices(sidx).nonnonname1 = {};
    overlaps.slices(sidx).nonnonname2 = {};
    
    eval(['nummovs = length(moviecell.',sname,');'])
    for midx1 = 1:nummovs
        eval(['movinfo1 = moviecell.',sname,'(midx1);'])
        for midx2 = midx1+1:nummovs
            eval(['movinfo2 = moviecell.',sname,'(midx2);'])
            if movinfo1.UpYN1 && movinfo2.UpYN2
                
                onsmov1 = movinfo1.Up.UpCellOns1;
                onsmov2 = movinfo2.Up.UpCellOns1;
                
%                 minavail = min([sum(onsmov1(:)) sum(onsmov2(:))]);
%                 sharedons = onsmov1.*onsmov2;
%                 perc = sum(sharedons)/minavail;
                perc = getoverlap(onsmov1,onsmov2);
                
                interact1 = movinfo1.Movie1AnyInteract;
                interact2 = movinfo2.Movie1AnyInteract;
                if isempty(interact1);interact1 = 0;end
                if isempty(interact2);interact2 = 0;end

                if interact1+interact2 == 2 &&...
                        strcmp('spontstim',movinfo1.Protocol) && strcmp('spontstim',movinfo2.Protocol);
                    overlaps.slices(sidx).intintpercs(end+1) = perc;
                    overlaps.slices(sidx).intintname1{end+1} = movinfo1.Name;
                    overlaps.slices(sidx).intintname2{end+1} = movinfo2.Name;

                    overlaps.intintpercs(end+1) = perc;
                    overlaps.intintname1{end+1} = movinfo1.Name;
                    overlaps.intintname2{end+1} = movinfo2.Name;
                    
                elseif interact1+interact2 == 1 &&... 
                        (strcmp('look',movinfo1.Protocol) && strcmp('spontstim',movinfo2.Protocol) ||...
                        strcmp('spontstim',movinfo1.Protocol) && strcmp('look',movinfo2.Protocol))
                    overlaps.slices(sidx).intnonpercs(end+1) = perc;
                    overlaps.slices(sidx).intnonname1{end+1} = movinfo1.Name;
                    overlaps.slices(sidx).intnonname2{end+1} = movinfo2.Name;

                    overlaps.intnonpercs(end+1) = perc;
                    overlaps.intnonname1{end+1} = movinfo1.Name;
                    overlaps.intnonname2{end+1} = movinfo2.Name;

                elseif interact1+interact2 == 0 &&...
                        strcmp('look',movinfo1.Protocol) && strcmp('look',movinfo2.Protocol)
                    overlaps.slices(sidx).nonnonpercs(end+1) = perc;
                    overlaps.slices(sidx).nonnonname1{end+1} = movinfo1.Name;
                    overlaps.slices(sidx).nonnonname2{end+1} = movinfo2.Name;

                    overlaps.nonnonpercs(end+1) = perc;
                    overlaps.nonnonname1{end+1} = movinfo1.Name;
                    overlaps.nonnonname2{end+1} = movinfo2.Name;
                end
            end
        end
    end
end

%% plot nn vs in differences
figure('name','Overlaps of spontstim & spont vs spont & spont');
subplot(2,1,1);
[iny,inx] = hist(overlaps.intnonpercs);
bar(inx,iny)
[nny,nnx] = hist(overlaps.nonnonpercs);
[h,p] = kstest2(overlaps.nonnonpercs,overlaps.intnonpercs);
if p >=.05
    kstext = ['Kolmogorov-Smirnov: distributions ARE NOT DIFFERENT.  K-S p = ',num2str(p)];
else
    kstext = ['Kolmogorov-Smirnov: distributions ARE DIFFERENT.  K-S p = ',num2str(p)];
end

hold on
bar(nnx,nny,'r')
title({'Red: Pairs of spont movies.  Blue: Spontstim - Spont pairs';...
    ['Spont-Spont: ',num2str(mean(overlaps.nonnonpercs)),'\pm',num2str(std(overlaps.nonnonpercs)),'.  Spontstim-Spont: ',num2str(mean(overlaps.intnonpercs)),'\pm',num2str(std(overlaps.intnonpercs)),'.'];...
    kstext})
xlabel('% overlap')
ylabel('Number of pairs')
subplot(2,1,2)
resampnn = resampledataset(overlaps.nonnonpercs,10000);
resampin = resampledataset(overlaps.intnonpercs,10000);
resampdiffs = mean(resampnn,1)-mean(resampin,1);
resampdiffs = sort(resampdiffs);
realdiff = mean(overlaps.nonnonpercs,2) - mean(overlaps.intnonpercs,2);
hist(resampdiffs);

hold on;
plot(realdiff,1,'color','r','marker','*');
xlabel('Difference in % overlap: SvS-SvSS')
ylabel('Number of reshuffles')
title({'Histogram of differences between 10000 random resamples of SvS and SvSS datasets. Vs observed';...
    ['Observed difference = ',num2str(realdiff),'.  ',num2str(sum(realdiff>=resampdiffs)/100),' percentile.'];...
    ['Resampled differences = ',num2str(mean(resampdiffs)),'\pm',num2str(std(resampdiffs)),'.'];...
    ['5th percentile = ',num2str(resampdiffs(500)),'   95th percentile = ',num2str(resampdiffs(9500))]})

%% plot ii vs in differences
figure('name','Overlaps of Movies with interaction with non-interaction vs non-int&non-int');
subplot(2,1,1);
[iny,inx] = hist(overlaps.intnonpercs);
bar(inx,iny)
[iiy,iix] = hist(overlaps.intintpercs);
[h,p] = kstest2(overlaps.intintpercs,overlaps.intnonpercs);
if p >=.05
    kstext = ['Kolmogorov-Smirnov: distributions ARE NOT DIFFERENT.  K-S p = ',num2str(p)];
else
    kstext = ['Kolmogorov-Smirnov: distributions ARE DIFFERENT.  K-S p = ',num2str(p)];
end

hold on
bar(iix,iiy,'r')
title({'Red: Pairs of non-interaction movies.  Blue: Interaction - Non-Interaction pairs';...
    ['Int-Int: ',num2str(mean(overlaps.intintpercs)),'\pm',num2str(std(overlaps.intintpercs)),'.  Int-NonInt: ',num2str(mean(overlaps.intnonpercs)),'\pm',num2str(std(overlaps.intnonpercs)),'.'];...
    kstext})
xlabel('% overlap')
ylabel('Number of pairs')
subplot(2,1,2)
resampii = resampledataset(overlaps.intintpercs,10000);
resampin = resampledataset(overlaps.intnonpercs,10000);
resampdiffs = mean(resampii,1)-mean(resampin,1);
resampdiffs = sort(resampdiffs);
realdiff = mean(overlaps.nonnonpercs,2) - mean(overlaps.intnonpercs,2);
hist(resampdiffs);
hold on;
plot(realdiff,1,'color','r','marker','*');
xlabel('Difference in % overlap: ii-in')
ylabel('Number of reshuffles')
title({'Histogram of differences between 10000 random resamples of ii and in datasets. Vs observed';...
    ['Observed difference = ',num2str(realdiff),'.  ',num2str(sum(realdiff>=resampdiffs)/100),' percentile.'];...
    ['Resampled differences = ',num2str(mean(resampdiffs)),'\pm',num2str(std(resampdiffs)),'.'];...
    ['5th percentile = ',num2str(resampdiffs(500)),'   95th percentile = ',num2str(resampdiffs(9500))]})


%% reshuffle which cells were on


for z = 1:numreshuffs;
    iicounter = 1;
    incounter = 1;
    nncounter = 1;
    for sidx = 1:length(slices);
        sname = slices{sidx};
        if z == 1;
            overlaps.slices(sidx).intintzpercs = [];
            overlaps.slices(sidx).intnonzpercs = [];
            overlaps.slices(sidx).nonnonzpercs = [];
        end
        siicounter = 1;
        sincounter = 1;
        snncounter = 1;
        
        eval(['nummovs = length(moviecell.',sname,');'])
        for midx1 = 1:nummovs
            eval(['movinfo1 = moviecell.',sname,'(midx1);'])
            for midx2 = midx1+1:nummovs
                eval(['movinfo2 = moviecell.',sname,'(midx2);'])
                if movinfo1.UpYN1 && movinfo2.UpYN2
                    onsmov1 = movinfo1.Up.UpCellOns1;
                    onsmov2 = movinfo2.Up.UpCellOns1;
                    
                    zons1 = reshufflewhichcells2(onsmov1);
                    zons2 = reshufflewhichcells2(onsmov2);
%                     minavail = min([sum(onsmov1(:)) sum(onsmov2(:))]);
%                     zshared = zons1.*zons2;
%                     zperc = sum(zshared(:))/minavail;
                    zperc = getoverlap(zons1,zons2);

                    interact1 = movinfo1.Movie1AnyInteract;
                    interact2 = movinfo2.Movie1AnyInteract;
                    if isempty(interact1);interact1 = 0;end
                    if isempty(interact2);interact2 = 0;end

                    if interact1+interact2 == 2 &&...
                        strcmp('spontstim',movinfo1.Protocol) && strcmp('spontstim',movinfo2.Protocol)
                        overlaps.slices(sidx).intintzpercs(siicounter,z) = zperc;
                        overlaps.intintzpercs(iicounter,z) = zperc;
                        siicounter = siicounter + 1;
                        iicounter = iicounter + 1;
                        
                    elseif interact1+interact2 == 1 &&... 
                        (strcmp('look',movinfo1.Protocol) && strcmp('spontstim',movinfo2.Protocol) ||...
                        strcmp('spontstim',movinfo1.Protocol) && strcmp('look',movinfo2.Protocol))
                        overlaps.slices(sidx).intnonzpercs(sincounter,z) = zperc;
                        overlaps.intnonzpercs(incounter,z) = zperc;
                        sincounter = sincounter + 1;
                        incounter = incounter + 1;
                        
                    elseif interact1+interact2 == 0 &&...
                        strcmp('look',movinfo1.Protocol) && strcmp('look',movinfo2.Protocol)
                        overlaps.slices(sidx).nonnonzpercs(snncounter,z) = zperc;
                        overlaps.nonnonzpercs(nncounter,z) = zperc;
                        snncounter = snncounter + 1;
                        nncounter = nncounter + 1;

                    end
                end
            end
        end
    end
end
figure('name','Overlaps in Observed vs Which-Cell-Reshuffled Datasets');
subplot(3,1,1);
nnzpercs = sort(mean(overlaps.nonnonzpercs,1));
hist(nnzpercs);
hold on
plot(mean(overlaps.nonnonpercs),1,'color','r','marker','*')
nnpercentile = sum(nnzpercs<mean(overlaps.nonnonpercs))/numreshuffs*100;
xlabel('Percent overlap')
ylabel('Number of datasets')
title(['Spont-Spont.  ',num2str(nnpercentile),'th percentile.'])

subplot(3,1,2);
inzpercs = sort(mean(overlaps.intnonzpercs,1));
hist(inzpercs);
hold on
plot(mean(overlaps.intnonpercs),1,'color','r','marker','*')
inpercentile = sum(inzpercs<mean(overlaps.intnonpercs))/numreshuffs*100;
xlabel('Percent overlap')
ylabel('Number of datasets')
title(['SpontStim-Spont Overlap.  ',num2str(inpercentile),'th percentile.'])

subplot(3,1,3);
iizpercs = sort(mean(overlaps.intintzpercs,1));
hist(iizpercs);
hold on
plot(mean(overlaps.intintpercs),1,'color','r','marker','*')
iipercentile = sum(iizpercs<mean(overlaps.intintpercs))/numreshuffs*100;
xlabel('Percent overlap')
ylabel('Number of datasets')
title(['SpontStim-SpontStim Overlap.  ',num2str(iipercentile),'th percentile.'])


%% within slice analysis... to see if in is not different from nn in each
%% slice by resampling
spercentiles = [];
for sidx = 1:length(overlaps.slices);
    if ~isempty(overlaps.slices(sidx).nonnonpercs) && ~isempty(overlaps.slices(sidx).intnonpercs)
        sresampnn = resampledataset(overlaps.slices(sidx).nonnonpercs,10000);
        sresampin = resampledataset(overlaps.slices(sidx).intnonpercs,10000);
        sresampdiffs = mean(sresampnn,1) - mean(sresampin,1);
        sresampdiffs = sort(sresampdiffs);
        srealdiff = mean(overlaps.slices(sidx).nonnonpercs,2) - mean(overlaps.slices(sidx).intnonpercs,2);

        spercentiles(end+1) = sum(sresampdiffs<srealdiff)/100;
    end
end
figure('name','Percentiles of differences in each slice vs diffs of resampled datasets')
plot(spercentiles,ones(size(spercentiles)),'.')
hold on
plot([5 5],[0 2],'r');
plot([95 95],[0 2],'r');
xlabel('Percentile of real difference among resampled datasets')
ylabel('Each dot represents 1 slice')
numsignifdiffs = sum((spercentiles>=95) + (spercentiles<=5));
numslices = sidx;
title([num2str(numsignifdiffs),' out of ',num2str(length(spercentiles)),' slices showed significant difference in overlap between SvS and SvSS.'])

%within-movie analysis