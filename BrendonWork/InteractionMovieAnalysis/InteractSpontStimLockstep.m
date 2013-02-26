function locksteps = InteractSpontStimLockstep(moviecell)
%noninteraction vs noninteraction
%interaction vs noninteraction
%interaction vs interaction
%just use mov1

locksteps.spsppercs = [];
locksteps.spspname1 = {};
locksteps.spspname2 = {};
locksteps.sptspercs = [];
locksteps.sptsname1 = {};
locksteps.sptsname2 = {};
locksteps.tstspercs = [];
locksteps.tstsname1 = {};
locksteps.tstsname2 = {};

locksteps.spspzpercs = [];
locksteps.sptszpercs = [];
locksteps.tstszpercs = [];


slices = fieldnames(moviecell);

for sidx = 1:length(slices);
    sname = slices{sidx};
    locksteps.slices(sidx).spsppercs = [];
    locksteps.slices(sidx).spspname1 = {};
    locksteps.slices(sidx).spspname2 = {};
    locksteps.slices(sidx).sptspercs = [];
    locksteps.slices(sidx).sptsname1 = {};
    locksteps.slices(sidx).sptsname2 = {};
    locksteps.slices(sidx).tstspercs = [];
    locksteps.slices(sidx).tstsname1 = {};
    locksteps.slices(sidx).tstsname2 = {};
    
    eval(['nummovs = length(moviecell.',sname,');'])
    
    ts = [];
    sp = [];
    for midx = 1:nummovs
        eval(['movinfo = moviecell.',sname,'(midx);'])
        if strcmp(movinfo.Protocol,'s')
            if movinfo.UpYN1 || movinfo.UpYN2 || movinfo.UpYN3
                ts(end+1) = midx; %#ok<AGROW>
            end
        elseif strcmp(movinfo.Protocol,'look') || strcmp(movinfo.Protocol,'spont')
            if movinfo.UpYN1 || movinfo.UpYN2 || movinfo.UpYN3
                sp(end+1) = midx; %#ok<AGROW>
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
                
                [onsmov1,movidx1] = selectmoviefrommovinfo(movinfo1,0);
                [onsmov2,movidx2] = selectmoviefrommovinfo(movinfo2,0);


                if ~isempty(onsmov1) && ~isempty(onsmov2)%shouldn't be necessary, but why not
%                     minavail = min([sum(onsmov1(:)) sum(onsmov2(:))]);
%                     sharedons = onsmov1.*onsmov2;
%                     perc = sum(sharedons)/minavail;
                    perc = getlocksteppercent(onsmov1,onsmov2);
                    
                    locksteps.slices(sidx).sptspercs(end+1) = perc;
                    locksteps.slices(sidx).sptsname1{end+1} = movinfo1.Name;
                    locksteps.slices(sidx).sptsname2{end+1} = movinfo2.Name;

                    locksteps.sptspercs(end+1) = perc;
                    locksteps.sptsname1{end+1} = movinfo1.Name;
                    locksteps.sptsname2{end+1} = movinfo2.Name;
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

            [onsmov1,movidx1] = selectmoviefrommovinfo(movinfo1,0);
            [onsmov2,movidx2] = selectmoviefrommovinfo(movinfo2,0);

            if ~isempty(onsmov1) && ~isempty(onsmov2)%shouldn't be necessary, but why not
%                     minavail = min([sum(onsmov1(:)) sum(onsmov2(:))]);
%                     sharedons = onsmov1.*onsmov2;
%                     perc = sum(sharedons)/minavail;
                perc = getlocksteppercent(onsmov1,onsmov2);

                locksteps.slices(sidx).tstspercs(end+1) = perc;
                locksteps.slices(sidx).tstsname1{end+1} = movinfo1.Name;
                locksteps.slices(sidx).tstsname2{end+1} = movinfo2.Name;

                locksteps.tstspercs(end+1) = perc;
                locksteps.tstsname1{end+1} = movinfo1.Name;
                locksteps.tstsname2{end+1} = movinfo2.Name;
            end
        end
    end

    for midxx1 = 1:length(sp)
        midx1 = sp(midxx1);
        eval(['movinfo1 = moviecell.',sname,'(midx1);'])
        for midxx2 = (midxx1+1):length(sp)
            midx2 = sp(midxx2);
            eval(['movinfo2 = moviecell.',sname,'(midx2);'])
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
            interact1 = movinfo1.Movie1AnyInteract;
            interact2 = movinfo2.Movie1AnyInteract;
            [onsmov1,movindex1] = selectmoviefrommovinfo(movinfo1,0);
            [onsmov2,movindex2] = selectmoviefrommovinfo(movinfo2,0);

            if ~isempty(onsmov1) && ~isempty(onsmov2)%shouldn't be necessary, but why not
%                     minavail = min([sum(onsmov1(:)) sum(onsmov2(:))]);
%                     sharedons = onsmov1.*onsmov2;
%                     perc = sum(sharedons)/minavail;
                perc = getlocksteppercent(onsmov1,onsmov2);

                locksteps.slices(sidx).spsppercs(end+1) = perc;
                locksteps.slices(sidx).spspname1{end+1} = movinfo1.Name;
                locksteps.slices(sidx).spspname2{end+1} = movinfo2.Name;

                locksteps.spsppercs(end+1) = perc;
                locksteps.spspname1{end+1} = movinfo1.Name;
                locksteps.spspname2{end+1} = movinfo2.Name;
            end
        end
    end

end

%% plot tstrain-tstrain vs spont-spontspont
figure('name','Locksteps of Movies with tsts vs spsp');
subplot(2,1,1);
[iny,inx] = hist(locksteps.spsppercs);
bar(inx,iny)
[nny,nnx] = hist(locksteps.tstspercs);
[h,p] = kstest2(locksteps.tstspercs,locksteps.spsppercs);
if p >=.05
    kstext = ['Kolmogorov-Smirnov: distributions ARE NOT DIFFERENT.  K-S p = ',num2str(p)];
else
    kstext = ['Kolmogorov-Smirnov: distributions ARE DIFFERENT.  K-S p = ',num2str(p)];
end

hold on
bar(nnx,nny,'r')
title({'Red: Pairs of TsTrain movies.  Blue: Pairs of Spont movies';...
    ['TsTrain-TsTrain: ',num2str(mean(locksteps.tstspercs)),'\pm',num2str(std(locksteps.tstspercs)),'.  Spont-Spont: ',num2str(mean(locksteps.spsppercs)),'\pm',num2str(std(locksteps.spsppercs)),'.'];...
    kstext})
xlabel('% lockstep')
ylabel('Number of pairs')
subplot(2,1,2)
resampnn = resampledataset(locksteps.tstspercs,10000);
resampin = resampledataset(locksteps.spsppercs,10000);
resampdiffs = mean(resampnn,1)-mean(resampin,1);
resampdiffs = sort(resampdiffs);
realdiff = mean(locksteps.tstspercs,2) - mean(locksteps.spsppercs,2);
hist(resampdiffs);
hold on;
plot(realdiff,1,'color','r','marker','*');
xlabel('Difference in % lockstep: tsts-spsp')
ylabel('Number of reshuffles')
title({'Histogram of differences between 10000 random resamples of nn and in datasets. Vs observed';...
    ['Observed difference = ',num2str(realdiff),'.  ',num2str(sum(realdiff>=resampdiffs)/100),' percentile.'];...
    ['Resampled differences = ',num2str(mean(resampdiffs)),'\pm',num2str(std(resampdiffs)),'.'];...
    ['5th percentile = ',num2str(resampdiffs(500)),'   95th percentile = ',num2str(resampdiffs(9500))]})

%% plot tstrain-tstrain vs spont-tstrain differences
figure('name','Locksteps of Movies with tsts vs tssp');
subplot(2,1,1);
[iny,inx] = hist(locksteps.sptspercs);
bar(inx,iny)
[nny,nnx] = hist(locksteps.tstspercs);
[h,p] = kstest2(locksteps.tstspercs,locksteps.sptspercs);
if p >=.05
    kstext = ['Kolmogorov-Smirnov: distributions ARE NOT DIFFERENT.  K-S p = ',num2str(p)];
else
    kstext = ['Kolmogorov-Smirnov: distributions ARE DIFFERENT.  K-S p = ',num2str(p)];
end

hold on
bar(nnx,nny,'r')
title({'Red: Pairs of TsTrain movies.  Blue: Spont-TsTrain pairs of movies';...
    ['TsTrain-TsTrain: ',num2str(mean(locksteps.tstspercs)),'\pm',num2str(std(locksteps.tstspercs)),'.  Spont-TsTrain: ',num2str(mean(locksteps.sptspercs)),'\pm',num2str(std(locksteps.sptspercs)),'.'];...
    kstext})
xlabel('% lockstep')
ylabel('Number of pairs')
subplot(2,1,2)
resampnn = resampledataset(locksteps.tstspercs,10000);
resampin = resampledataset(locksteps.sptspercs,10000);
resampdiffs = mean(resampnn,1)-mean(resampin,1);
resampdiffs = sort(resampdiffs);
realdiff = mean(locksteps.tstspercs,2) - mean(locksteps.sptspercs,2);
hist(resampdiffs);
hold on;
plot(realdiff,1,'color','r','marker','*');
xlabel('Difference in % lockstep: tsts-spts')
ylabel('Number of reshuffles')
title({'Histogram of differences between 10000 random resamples of nn and in datasets. Vs observed';...
    ['Observed difference = ',num2str(realdiff),'.  ',num2str(sum(realdiff>=resampdiffs)/100),' percentile.'];...
    ['Resampled differences = ',num2str(mean(resampdiffs)),'\pm',num2str(std(resampdiffs)),'.'];...
    ['5th percentile = ',num2str(resampdiffs(500)),'   95th percentile = ',num2str(resampdiffs(9500))]})

%% plot spont-spont vs spont-tstrain differences
figure('name','Locksteps of Movies with spsp vs tssp');
subplot(2,1,1);
[iny,inx] = hist(locksteps.sptspercs);
bar(inx,iny)
[nny,nnx] = hist(locksteps.spsppercs);
[h,p] = kstest2(locksteps.spsppercs,locksteps.sptspercs);
if p >=.05
    kstext = ['Kolmogorov-Smirnov: distributions ARE NOT DIFFERENT.  K-S p = ',num2str(p)];
else
    kstext = ['Kolmogorov-Smirnov: distributions ARE DIFFERENT.  K-S p = ',num2str(p)];
end

hold on
bar(nnx,nny,'r')
title({'Red: Pairs of TsTrain movies.  Blue: Pairs of Spont movies';...
    ['Spont-Spont: ',num2str(mean(locksteps.spsppercs)),'\pm',num2str(std(locksteps.spsppercs)),'.  Spont-TsTrain: ',num2str(mean(locksteps.sptspercs)),'\pm',num2str(std(locksteps.sptspercs)),'.'];...
    kstext})
xlabel('% lockstep')
ylabel('Number of pairs')
subplot(2,1,2)
resampnn = resampledataset(locksteps.spsppercs,10000);
resampin = resampledataset(locksteps.sptspercs,10000);
resampdiffs = mean(resampnn,1)-mean(resampin,1);
resampdiffs = sort(resampdiffs);
realdiff = mean(locksteps.spsppercs,2) - mean(locksteps.sptspercs,2);
hist(resampdiffs);
hold on;
plot(realdiff,1,'color','r','marker','*');
xlabel('Difference in % lockstep: spsp-spts')
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
%             locksteps.slices(sidx).spspzpercs = [];
%             locksteps.slices(sidx).sptszpercs = [];
%             locksteps.slices(sidx).tstszpercs = [];
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
% %                 onsmov1 = [];
% %                 onsmov2 = [];
% %                 if movinfo1.UpYN1
% %                     onsmov1 = movinfo1.Up.UpCellOns1;
% %                 elseif movinfo1.UpYN2
% %                     onsmov1 = movinfo1.Up.UpCellOns2;
% %                 elseif movinfo1.UpYN3
% %                     onsmov1 = movinfo1.Up.UpCellOns3;
% %                 end
% % 
% %                 if movinfo2.UpYN1
% %                     onsmov2 = movinfo2.Up.UpCellOns1;
% %                 elseif movinfo2.UpYN2
% %                     onsmov2 = movinfo2.Up.UpCellOns2;
% %                 elseif movinfo2.UpYN3
% %                     onsmov2 = movinfo2.Up.UpCellOns3;
% %                 end
% 
%                 [onsmov1,movindex1] = selectmoviefrommovinfo(movinfo1,0);
%                 [onsmov2,movindex2] = selectmoviefrommovinfo(movinfo2,0);
% 
%                 if ~isempty(onsmov1) && ~isempty(onsmov2)
% 
%                     zons1 = reshufflewhichcells2(onsmov1);
%                     zons2 = reshufflewhichcells2(onsmov2);
%                     
% %                     minavail = min([sum(onsmov1(:)) sum(onsmov2(:))]);
% %                     zshared = zons1.*zons2;
% %                     zperc = sum(zshared(:))/minavail;
%                     zperc = getlocksteppercent(zons1,zons2);
%                                         
%                     if isempty(interact1);interact1 = 0;end
%                     if isempty(interact2);interact2 = 0;end
% 
%                     if interact1+interact2 == 2;
%                         locksteps.slices(sidx).spspzpercs(siicounter,z) = zperc;
%                         locksteps.spspzpercs(iicounter,z) = zperc;
%                         siicounter = siicounter + 1;
%                         iicounter = iicounter + 1;
%                         
%                     elseif interact1+interact2 == 1;
%                         locksteps.slices(sidx).sptszpercs(sincounter,z) = zperc;
%                         locksteps.sptszpercs(incounter,z) = zperc;
%                         sincounter = sincounter + 1;
%                         incounter = incounter + 1;
%                         
%                     elseif interact1+interact2 == 0;
%                         locksteps.slices(sidx).tstszpercs(snncounter,z) = zperc;
%                         locksteps.tstszpercs(nncounter,z) = zperc;
%                         snncounter = snncounter + 1;
%                         nncounter = nncounter + 1;
% 
%                     end
%                 end
%             end
%         end
%     end
% end
% figure('name','Locksteps in Observed vs Which-Cell-Reshuffled Datasets');
% subplot(3,1,1);
% nnzpercs = sort(mean(locksteps.tstszpercs,1));
% hist(nnzpercs);
% hold on
% plot(mean(locksteps.tstspercs),1,'color','r','marker','*')
% nnpercentile = sum(nnzpercs<mean(locksteps.tstspercs))/numreshuffs*100;
% xlabel('Percent lockstep')
% ylabel('Number of datasets')
% title(['TS-TS Lockstep.  ',num2str(nnpercentile),'th percentile.'])
% 
% subplot(3,1,2);
% inzpercs = sort(mean(locksteps.sptszpercs,1));
% hist(inzpercs);
% hold on
% plot(mean(locksteps.sptspercs),1,'color','r','marker','*')
% inpercentile = sum(inzpercs<mean(locksteps.sptspercs))/numreshuffs*100;
% xlabel('Percent lockstep')
% ylabel('Number of datasets')
% title(['SP-TS Lockstep.  ',num2str(inpercentile),'th percentile.'])
% 
% subplot(3,1,3);
% iizpercs = sort(mean(locksteps.spspzpercs,1));
% hist(iizpercs);
% hold on
% plot(mean(locksteps.spsppercs),1,'color','r','marker','*')
% iipercentile = sum(iizpercs<mean(locksteps.spsppercs))/numreshuffs*100;
% xlabel('Percent lockstep')
% ylabel('Number of datasets')
% title(['SP-SP Lockstep.  ',num2str(iipercentile),'th percentile.'])
% 
% 
% %% within slice analysis... to see if in is not different from nn in each
% %% slice by resampling
% spercentiles = zeros(1,length(locksteps.slices));
% for sidx = 1:length(locksteps.slices);
%     sresampnn = resampledataset(locksteps.slices(sidx).tstspercs,10000);
%     sresampin = resampledataset(locksteps.slices(sidx).sptspercs,10000);
%     sresampdiffs = mean(sresampnn,1) - mean(sresampin,1);
%     sresampdiffs = sort(sresampdiffs);
%     srealdiff = mean(locksteps.slices(sidx).tstspercs,2) - mean(locksteps.slices(sidx).sptspercs,2);
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
% title([num2str(numsignifdiffs),' out of ',num2str(numslices),' slices
% showed significant difference in lockstep between TSvTS and SPvSP.'])