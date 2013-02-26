function overlaps = InteractSpontStimOverlap(moviecell)
%noninteraction vs noninteraction
%interaction vs noninteraction
%interaction vs interaction
%just use mov1

overlaps.spsppercs = [];
overlaps.spspname1 = {};
overlaps.spspname2 = {};
overlaps.sptspercs = [];
overlaps.sptsname1 = {};
overlaps.sptsname2 = {};
overlaps.tstspercs = [];
overlaps.tstsname1 = {};
overlaps.tstsname2 = {};

overlaps.spspzpercs = [];
overlaps.sptszpercs = [];
overlaps.tstszpercs = [];


slices = fieldnames(moviecell);

tsmoviecount = 0;
spmoviecount = 0;
for sidx = 1:length(slices);
    sname = slices{sidx};
    overlaps.slices(sidx).spsppercs = [];
    overlaps.slices(sidx).spspname1 = {};
    overlaps.slices(sidx).spspname2 = {};
    overlaps.slices(sidx).sptspercs = [];
    overlaps.slices(sidx).sptsname1 = {};
    overlaps.slices(sidx).sptsname2 = {};
    overlaps.slices(sidx).tstspercs = [];
    overlaps.slices(sidx).tstsname1 = {};
    overlaps.slices(sidx).tstsname2 = {};
    
    eval(['nummovs = length(moviecell.',sname,');'])
    
    ts = [];
    sp = [];
    for midx = 1:nummovs
        eval(['movinfo = moviecell.',sname,'(midx);'])
        if strcmp(movinfo.Protocol,'s')
            if movinfo.UpYN1 || movinfo.UpYN2 || movinfo.UpYN3
                ts(end+1) = midx; %#ok<AGROW>
                tsmoviecount = tsmoviecount+1;
            end
        elseif strcmp(movinfo.Protocol,'look') || strcmp(movinfo.Protocol,'spont')
            if movinfo.UpYN1 || movinfo.UpYN2 || movinfo.UpYN3
                sp(end+1) = midx; %#ok<AGROW>
                spmoviecount = spmoviecount+1;
            end
        end
    end
    
    if ~isempty(ts) && ~isempty(sp)
        for midxx1 = 1:length(ts)
            midx1 = ts(midxx1);
            eval(['movinfo1 = moviecell.',sname,'(midx1);'])
            for midxx2 = 1:length(sp)
                midx2 = sp(midxx2);
                eval(['movinfo2 = moviecell.',sname,'(midx2);'])
                onsmov1 = [];
                onsmov2 = [];
                if movinfo1.UpYN1
                    onsmov1 = movinfo1.Up.UpCellOns1;
                elseif movinfo1.UpYN2
                    onsmov1 = movinfo1.Up.UpCellOns2;
                elseif movinfo1.UpYN3
                    onsmov1 = movinfo1.Up.UpCellOns3;
                end

                if movinfo2.UpYN1
                    onsmov2 = movinfo2.Up.UpCellOns1;
                elseif movinfo2.UpYN2
                    onsmov2 = movinfo2.Up.UpCellOns2;
                elseif movinfo2.UpYN3
                    onsmov2 = movinfo2.Up.UpCellOns3;
                end

                if ~isempty(onsmov1) && ~isempty(onsmov2)%shouldn't be necessary, but why not
%                     minavail = min([sum(onsmov1(:)) sum(onsmov2(:))]);
%                     sharedons = onsmov1.*onsmov2;
%                     perc = sum(sharedons)/minavail;
                    perc = getoverlap(onsmov1,onsmov2);
                    if perc == 1
                        1;
                    end
                    overlaps.slices(sidx).sptspercs(end+1) = perc;
                    overlaps.slices(sidx).sptsname1{end+1} = movinfo1.Name;
                    overlaps.slices(sidx).sptsname2{end+1} = movinfo2.Name;

                    overlaps.sptspercs(end+1) = perc;
                    overlaps.sptsname1{end+1} = movinfo1.Name;
                    overlaps.sptsname2{end+1} = movinfo2.Name;
                end
            end
        end
    end

    for midxx1 = 1:length(ts)
        midx1 = ts(midxx1);
        eval(['movinfo1 = moviecell.',sname,'(midx1);'])
        for midxx2 = (midxx1+1):length(ts)
            midx2 = ts(midxx2);
            eval(['movinfo2 = moviecell.',sname,'(midx2);'])
            onsmov1 = [];
            onsmov2 = [];
            if movinfo1.UpYN1
                onsmov1 = movinfo1.Up.UpCellOns1;
            elseif movinfo1.UpYN2
                onsmov1 = movinfo1.Up.UpCellOns2;
            elseif movinfo1.UpYN3
                onsmov1 = movinfo1.Up.UpCellOns3;
            end

            if movinfo2.UpYN1
                onsmov2 = movinfo2.Up.UpCellOns1;
            elseif movinfo2.UpYN2
                onsmov2 = movinfo2.Up.UpCellOns2;
            elseif movinfo2.UpYN3
                onsmov2 = movinfo2.Up.UpCellOns3;
            end

            if ~isempty(onsmov1) && ~isempty(onsmov2)%shouldn't be necessary, but why not
%                     minavail = min([sum(onsmov1(:)) sum(onsmov2(:))]);
%                     sharedons = onsmov1.*onsmov2;
%                     perc = sum(sharedons)/minavail;
                perc = getoverlap(onsmov1,onsmov2);

                overlaps.slices(sidx).tstspercs(end+1) = perc;
                overlaps.slices(sidx).tstsname1{end+1} = movinfo1.Name;
                overlaps.slices(sidx).tstsname2{end+1} = movinfo2.Name;

                overlaps.tstspercs(end+1) = perc;
                overlaps.tstsname1{end+1} = movinfo1.Name;
                overlaps.tstsname2{end+1} = movinfo2.Name;
            end
        end
    end

    for midxx1 = 1:length(sp)
        midx1 = sp(midxx1);
        eval(['movinfo1 = moviecell.',sname,'(midx1);'])
        for midxx2 = (midxx1+1):length(sp)
            midx2 = sp(midxx2);
            eval(['movinfo2 = moviecell.',sname,'(midx2);'])
            onsmov1 = [];
            onsmov2 = [];
            if movinfo1.UpYN1
                onsmov1 = movinfo1.Up.UpCellOns1;
            elseif movinfo1.UpYN2
                onsmov1 = movinfo1.Up.UpCellOns2;
            elseif movinfo1.UpYN3
                onsmov1 = movinfo1.Up.UpCellOns3;
            end

            if movinfo2.UpYN1
                onsmov2 = movinfo2.Up.UpCellOns1;
            elseif movinfo2.UpYN2
                onsmov2 = movinfo2.Up.UpCellOns2;
            elseif movinfo2.UpYN3
                onsmov2 = movinfo2.Up.UpCellOns3;
            end

            if ~isempty(onsmov1) && ~isempty(onsmov2)%shouldn't be necessary, but why not
%                     minavail = min([sum(onsmov1(:)) sum(onsmov2(:))]);
%                     sharedons = onsmov1.*onsmov2;
%                     perc = sum(sharedons)/minavail;
                perc = getoverlap(onsmov1,onsmov2);

                overlaps.slices(sidx).spsppercs(end+1) = perc;
                overlaps.slices(sidx).spspname1{end+1} = movinfo1.Name;
                overlaps.slices(sidx).spspname2{end+1} = movinfo2.Name;

                overlaps.spsppercs(end+1) = perc;
                overlaps.spspname1{end+1} = movinfo1.Name;
                overlaps.spspname2{end+1} = movinfo2.Name;
            end
        end

    end
end

overlaps.tsmoviecount = tsmoviecount;
overlaps.spmoviecount = spmoviecount;

%% plot tstrain-tstrain vs spont-spontspont
figure('name','Overlaps of Movies with tsts vs spsp');
subplot(2,1,1);
[iny,inx] = hist(overlaps.spsppercs);
bar(inx,iny)
[nny,nnx] = hist(overlaps.tstspercs);
[h,p] = kstest2(overlaps.tstspercs,overlaps.spsppercs);
if p >=.05
    kstext = ['Kolmogorov-Smirnov: distributions ARE NOT DIFFERENT.  K-S p = ',num2str(p)];
else
    kstext = ['Kolmogorov-Smirnov: distributions ARE DIFFERENT.  K-S p = ',num2str(p)];
end

hold on
bar(nnx,nny,'r')
title({'Red: Pairs of TsTrain movies.  Blue: Pairs of Spont movies';...
    ['TsTrain-TsTrain: ',num2str(mean(overlaps.tstspercs)),'\pm',num2str(std(overlaps.tstspercs)),'.  Spont-Spont: ',num2str(mean(overlaps.spsppercs)),'\pm',num2str(std(overlaps.spsppercs)),'.'];...
    kstext})
xlabel('% overlap')
ylabel('Number of pairs')
subplot(2,1,2)
resampnn = resampledataset(overlaps.tstspercs,10000);
resampin = resampledataset(overlaps.spsppercs,10000);
resampdiffs = mean(resampnn,1)-mean(resampin,1);
resampdiffs = sort(resampdiffs);
realdiff = mean(overlaps.tstspercs,2) - mean(overlaps.spsppercs,2);
hist(resampdiffs);
hold on;
plot(realdiff,1,'color','r','marker','*');
xlabel('Difference in % overlap: tsts-spsp')
ylabel('Number of reshuffles')
title({'Histogram of differences between 10000 random resamples of nn and in datasets. Vs observed';...
    ['Observed difference = ',num2str(realdiff),'.  ',num2str(sum(realdiff>=resampdiffs)/100),' percentile.'];...
    ['Resampled differences = ',num2str(mean(resampdiffs)),'\pm',num2str(std(resampdiffs)),'.'];...
    ['5th percentile = ',num2str(resampdiffs(500)),'   95th percentile = ',num2str(resampdiffs(9500))]})

%% plot tstrain-tstrain vs spont-tstrain differences
figure('name','Overlaps of Movies with tsts vs tssp');
subplot(2,1,1);
[iny,inx] = hist(overlaps.sptspercs);
bar(inx,iny)
[nny,nnx] = hist(overlaps.tstspercs);
[h,p] = kstest2(overlaps.tstspercs,overlaps.sptspercs);
if p >=.05
    kstext = ['Kolmogorov-Smirnov: distributions ARE NOT DIFFERENT.  K-S p = ',num2str(p)];
else
    kstext = ['Kolmogorov-Smirnov: distributions ARE DIFFERENT.  K-S p = ',num2str(p)];
end

hold on
bar(nnx,nny,'r')
title({'Red: Pairs of TsTrain movies.  Blue: Spont-TsTrain pairs of movies';...
    ['TsTrain-TsTrain: ',num2str(mean(overlaps.tstspercs)),'\pm',num2str(std(overlaps.tstspercs)),'.  Spont-TsTrain: ',num2str(mean(overlaps.sptspercs)),'\pm',num2str(std(overlaps.sptspercs)),'.'];...
    kstext})
xlabel('% overlap')
ylabel('Number of pairs')
subplot(2,1,2)
resampnn = resampledataset(overlaps.tstspercs,10000);
resampin = resampledataset(overlaps.sptspercs,10000);
resampdiffs = mean(resampnn,1)-mean(resampin,1);
resampdiffs = sort(resampdiffs);
realdiff = mean(overlaps.tstspercs,2) - mean(overlaps.sptspercs,2);
hist(resampdiffs);
hold on;
plot(realdiff,1,'color','r','marker','*');
xlabel('Difference in % overlap: tsts-spts')
ylabel('Number of reshuffles')
title({'Histogram of differences between 10000 random resamples of nn and in datasets. Vs observed';...
    ['Observed difference = ',num2str(realdiff),'.  ',num2str(sum(realdiff>=resampdiffs)/100),' percentile.'];...
    ['Resampled differences = ',num2str(mean(resampdiffs)),'\pm',num2str(std(resampdiffs)),'.'];...
    ['5th percentile = ',num2str(resampdiffs(500)),'   95th percentile = ',num2str(resampdiffs(9500))]})

%% plot spont-spont vs spont-tstrain differences
figure('name','Overlaps of Movies with spsp vs tssp');
subplot(2,1,1);
[iny,inx] = hist(overlaps.sptspercs);
bar(inx,iny)
[nny,nnx] = hist(overlaps.spsppercs);
[h,p] = kstest2(overlaps.spsppercs,overlaps.sptspercs);
if p >=.05
    kstext = ['Kolmogorov-Smirnov: distributions ARE NOT DIFFERENT.  K-S p = ',num2str(p)];
else
    kstext = ['Kolmogorov-Smirnov: distributions ARE DIFFERENT.  K-S p = ',num2str(p)];
end

hold on
bar(nnx,nny,'r')
title({'Red: Pairs of TsTrain movies.  Blue: Pairs of Spont movies';...
    ['Spont-Spont: ',num2str(mean(overlaps.spsppercs)),'\pm',num2str(std(overlaps.spsppercs)),'.  Spont-TsTrain: ',num2str(mean(overlaps.sptspercs)),'\pm',num2str(std(overlaps.sptspercs)),'.'];...
    kstext})
xlabel('% overlap')
ylabel('Number of pairs')
subplot(2,1,2)
resampnn = resampledataset(overlaps.spsppercs,10000);
resampin = resampledataset(overlaps.sptspercs,10000);
resampdiffs = mean(resampnn,1)-mean(resampin,1);
resampdiffs = sort(resampdiffs);
realdiff = mean(overlaps.spsppercs,2) - mean(overlaps.sptspercs,2);
hist(resampdiffs);
hold on;
plot(realdiff,1,'color','r','marker','*');
xlabel('Difference in % overlap: spsp-spts')
ylabel('Number of reshuffles')
title({'Histogram of differences between 10000 random resamples of nn and in datasets. Vs observed';...
    ['Observed difference = ',num2str(realdiff),'.  ',num2str(sum(realdiff>=resampdiffs)/100),' percentile.'];...
    ['Resampled differences = ',num2str(mean(resampdiffs)),'\pm',num2str(std(resampdiffs)),'.'];...
    ['5th percentile = ',num2str(resampdiffs(500)),'   95th percentile = ',num2str(resampdiffs(9500))]})
% %% reshuffle which cells were on
% 
% 
% for z = 1:numreshuffs;
% iicounter = 1;
% incounter = 1;
% nncounter = 1;
%     for sidx = 1:length(slices);
%         sname = slices{sidx};
%         if z == 1;
%             overlaps.slices(sidx).spspzpercs = [];
%             overlaps.slices(sidx).sptszpercs = [];
%             overlaps.slices(sidx).tstszpercs = [];
%         end
%         siicounter = 1;
%         sincounter = 1;
%         snncounter = 1;
%         
%         eval(['nummovs = length(moviecell.',sname,');'])
%         for midx1 = 1:nummovs
%             eval(['movinfo1 = moviecell.',sname,'(midx1);'])
%             for midx2 = midx1+1:nummovs
%                 eval(['movinfo2 = moviecell.',sname,'(midx2);'])
%                     
%                 onsmov1 = [];
%                 onsmov2 = [];
%                 if movinfo1.UpYN1
%                     onsmov1 = movinfo1.Up.UpCellOns1;
%                 elseif movinfo1.UpYN2
%                     onsmov1 = movinfo1.Up.UpCellOns2;
%                 elseif movinfo1.UpYN3
%                     onsmov1 = movinfo1.Up.UpCellOns3;
%                 end
% 
%                 if movinfo2.UpYN1
%                     onsmov2 = movinfo2.Up.UpCellOns1;
%                 elseif movinfo2.UpYN2
%                     onsmov2 = movinfo2.Up.UpCellOns2;
%                 elseif movinfo2.UpYN3
%                     onsmov2 = movinfo2.Up.UpCellOns3;
%                 end
% 
%                 if ~isempty(onsmov1) && ~isempty(onsmov2)
% 
%                     zons1 = reshufflewhichcells2(onsmov1);
%                     zons2 = reshufflewhichcells2(onsmov2);
%                     
% %                     minavail = min([sum(onsmov1(:)) sum(onsmov2(:))]);
% %                     zshared = zons1.*zons2;
% %                     zperc = sum(zshared(:))/minavail;
%                     zperc = getoverlap(zons1,zons2);
%                                         
%                     interact1 = movinfo1.Movie1AnyInteract;
%                     interact2 = movinfo2.Movie1AnyInteract;
%                     if isempty(interact1);interact1 = 0;end
%                     if isempty(interact2);interact2 = 0;end
% 
%                     if interact1+interact2 == 2;
%                         overlaps.slices(sidx).spspzpercs(siicounter,z) = zperc;
%                         overlaps.spspzpercs(iicounter,z) = zperc;
%                         siicounter = siicounter + 1;
%                         iicounter = iicounter + 1;
%                         
%                     elseif interact1+interact2 == 1;
%                         overlaps.slices(sidx).sptszpercs(sincounter,z) = zperc;
%                         overlaps.sptszpercs(incounter,z) = zperc;
%                         sincounter = sincounter + 1;
%                         incounter = incounter + 1;
%                         
%                     elseif interact1+interact2 == 0;
%                         overlaps.slices(sidx).tstszpercs(snncounter,z) = zperc;
%                         overlaps.tstszpercs(nncounter,z) = zperc;
%                         snncounter = snncounter + 1;
%                         nncounter = nncounter + 1;
% 
%                     end
%                 end
%             end
%         end
%     end
% end
% figure('name','Overlaps in Observed vs Which-Cell-Reshuffled Datasets');
% subplot(3,1,1);
% nnzpercs = sort(mean(overlaps.tstszpercs,1));
% hist(nnzpercs);
% hold on
% plot(mean(overlaps.tstspercs),1,'color','r','marker','*')
% nnpercentile = sum(nnzpercs<mean(overlaps.tstspercs))/numreshuffs*100;
% xlabel('Percent overlap')
% ylabel('Number of datasets')
% title(['TS-TS Overlap.  ',num2str(nnpercentile),'th percentile.'])
% 
% subplot(3,1,2);
% inzpercs = sort(mean(overlaps.sptszpercs,1));
% hist(inzpercs);
% hold on
% plot(mean(overlaps.sptspercs),1,'color','r','marker','*')
% inpercentile = sum(inzpercs<mean(overlaps.sptspercs))/numreshuffs*100;
% xlabel('Percent overlap')
% ylabel('Number of datasets')
% title(['SP-TS Overlap.  ',num2str(inpercentile),'th percentile.'])
% 
% subplot(3,1,3);
% iizpercs = sort(mean(overlaps.spspzpercs,1));
% hist(iizpercs);
% hold on
% plot(mean(overlaps.spsppercs),1,'color','r','marker','*')
% iipercentile = sum(iizpercs<mean(overlaps.spsppercs))/numreshuffs*100;
% xlabel('Percent overlap')
% ylabel('Number of datasets')
% title(['SP-SP Overlap.  ',num2str(iipercentile),'th percentile.'])
% 
% 
% %% within slice analysis... to see if in is not different from nn in each
% %% slice by resampling
% spercentiles = zeros(1,length(overlaps.slices));
% for sidx = 1:length(overlaps.slices);
%     sresampnn = resampledataset(overlaps.slices(sidx).tstspercs,10000);
%     sresampin = resampledataset(overlaps.slices(sidx).sptspercs,10000);
%     sresampdiffs = mean(sresampnn,1) - mean(sresampin,1);
%     sresampdiffs = sort(sresampdiffs);
%     srealdiff = mean(overlaps.slices(sidx).tstspercs,2) - mean(overlaps.slices(sidx).sptspercs,2);
% 
%     spercentiles(sidx) = sum(sresampdiffs<srealdiff)/100;
% end
% figure('name','Percentiles of differences in each slice vs diffs of resampled datasets')
% plot(spercentiles,ones(size(spercentiles)),'.')
% hold on
% plot([5 5],[0 2],'r');
% plot([95 95],[0 2],'r');
% xlabel('Percentile of real difference among resampled datasets')
% ylabel('Each dot represents 1 slice')
% numsignifdiffs = sum((spercentiles>=95) + (spercentiles<=5));
% numslices = sidx;
% title([num2str(numsignifdiffs),' out of ',num2str(numslices),' slices showed significant difference in overlap between TSvTS and SPvSP.'])