function locksteps = InteractMovieLockstep(moviecell,numreshuffs)
%noninteraction vs noninteraction
%interaction vs noninteraction
%interaction vs interaction
%just use mov1
zperc = zeros(1,numreshuffs); %#ok<NASGU>

locksteps.intintpercs = [];
locksteps.intintname1 = {};
locksteps.intintname2 = {};
locksteps.intnonpercs = [];
locksteps.intnonname1 = {};
locksteps.intnonname2 = {};
locksteps.nonnonpercs = [];
locksteps.nonnonname1 = {};
locksteps.nonnonname2 = {};

locksteps.intintzpercs = [];
locksteps.intnonzpercs = [];
locksteps.nonnonzpercs = [];


slices = fieldnames(moviecell);

for sidx = 1:length(slices);
    sname = slices{sidx};
    locksteps.slices(sidx).intintpercs = [];
    locksteps.slices(sidx).intintname1 = {};
    locksteps.slices(sidx).intintname2 = {};
    locksteps.slices(sidx).intnonpercs = [];
    locksteps.slices(sidx).intnonname1 = {};
    locksteps.slices(sidx).intnonname2 = {};
    locksteps.slices(sidx).nonnonpercs = [];
    locksteps.slices(sidx).nonnonname1 = {};
    locksteps.slices(sidx).nonnonname2 = {};
    
    eval(['nummovs = length(moviecell.',sname,');'])
    for midx1 = 1:nummovs
        eval(['movinfo1 = moviecell.',sname,'(midx1);'])
        for midx2 = midx1+1:nummovs
            eval(['movinfo2 = moviecell.',sname,'(midx2);'])
            if movinfo1.UpYN1 && movinfo2.UpYN2
                
                % select movies to use
                interact1 = movinfo1.Movie1AnyInteract;
                interact2 = movinfo2.Movie1AnyInteract;
                if isempty(interact1);interact1 = 0;end
                if isempty(interact2);interact2 = 0;end

                [onsmov1,movidx1] = selectmoviefrommovinfo(movinfo1,interact1);
                [onsmov2,movidx2] = selectmoviefrommovinfo(movinfo2,interact2);
                
                %denom is the total ACTIVATIONS in the SHARED CELLS
%                 sharedactivecells = find(logical(sum(onsmov1,1).*sum(onsmov2,1)));
%                 nonsharedcells = setdiff(1:size(onsmov1,2),sharedactivecells);
%                 onsmov1(:,nonsharedcells) = 0;
%                 onsmov2(:,nonsharedcells) = 0;
%                 minavail = min([sum(onsmov1(:)) sum(onsmov2(:))]);
% 
%                 [lock1,lock2] = findbestrepeats(onsmov1,onsmov2); %#ok<NASGU>
%                 perc = sum(lock1(:))/minavail;
                perc = getlocksteppercent(onsmov1,onsmov2);

                if isempty(interact1);interact1 = 0;end
                if isempty(interact2);interact2 = 0;end
                
                if interact1+interact2 == 2 &&...
                        strcmp('spontstim',movinfo1.Protocol) && strcmp('spontstim',movinfo2.Protocol)
                    locksteps.slices(sidx).intintpercs(end+1) = perc;
                    locksteps.slices(sidx).intintname1{end+1} = movinfo1.Name;
                    locksteps.slices(sidx).intintname2{end+1} = movinfo2.Name;

                    locksteps.intintpercs(end+1) = perc;
                    locksteps.intintname1{end+1} = movinfo1.Name;
                    locksteps.intintname2{end+1} = movinfo2.Name;

                elseif interact1+interact2 == 1 &&... 
                        (strcmp('look',movinfo1.Protocol) && strcmp('spontstim',movinfo2.Protocol) ||...
                        strcmp('spontstim',movinfo1.Protocol) && strcmp('look',movinfo2.Protocol))
                    locksteps.slices(sidx).intnonpercs(end+1) = perc;
                    locksteps.slices(sidx).intnonname1{end+1} = movinfo1.Name;
                    locksteps.slices(sidx).intnonname2{end+1} = movinfo2.Name;

                    locksteps.intnonpercs(end+1) = perc;
                    locksteps.intnonname1{end+1} = movinfo1.Name;
                    locksteps.intnonname2{end+1} = movinfo2.Name;
                    
                elseif interact1+interact2 == 0 &&...
                        strcmp('look',movinfo1.Protocol) && strcmp('look',movinfo2.Protocol)
                    locksteps.slices(sidx).nonnonpercs(end+1) = perc;
                    locksteps.slices(sidx).nonnonname1{end+1} = movinfo1.Name;
                    locksteps.slices(sidx).nonnonname2{end+1} = movinfo2.Name;

                    locksteps.nonnonpercs(end+1) = perc;
                    locksteps.nonnonname1{end+1} = movinfo1.Name;
                    locksteps.nonnonname2{end+1} = movinfo2.Name;
                end
            end
        end
    end
end

%% plot nn vs in differences
figure('name','locksteps of of spontstim & spont vs spont & spont');
subplot(2,1,1);
[iny,inx] = hist(locksteps.intnonpercs);
bar(inx,iny)
[nny,nnx] = hist(locksteps.nonnonpercs);
hold on
bar(nnx,nny,'r')
[h,p] = kstest2(locksteps.nonnonpercs,locksteps.intnonpercs);
if p >=.05
    kstext = ['Kolmogorov-Smirnov: distributions ARE NOT DIFFERENT.  K-S p = ',num2str(p)];
else
    kstext = ['Kolmogorov-Smirnov: distributions ARE DIFFERENT.  K-S p = ',num2str(p)];
end

title({'Red: Pairs of spont movies.  Blue: Spontstim - Spont pairs';...
    ['Spont-Spont: ',num2str(mean(locksteps.nonnonpercs)),'\pm',num2str(std(locksteps.nonnonpercs)),'.  Spontstim-Spont: ',num2str(mean(locksteps.intnonpercs)),'\pm',num2str(std(locksteps.intnonpercs)),'.'];...
    kstext})
xlabel('% lockstep')
ylabel('Number of pairs')
subplot(2,1,2)
resampnn = resampledataset(locksteps.nonnonpercs,10000);
resampin = resampledataset(locksteps.intnonpercs,10000);
resampdiffs = mean(resampnn,1)-mean(resampin,1);
resampdiffs = sort(resampdiffs);
realdiff = mean(locksteps.nonnonpercs,2) - mean(locksteps.intnonpercs,2);
hist(resampdiffs);

hold on;
plot(realdiff,1,'color','r','marker','*');
xlabel('Difference in % lockstep: SvS-SvSS')
ylabel('Number of reshuffles')
title({'Histogram of differences between 10000 random resamples of nn and in datasets. Vs observed';...
    ['Observed difference = ',num2str(realdiff),'.  ',num2str(sum(realdiff>=resampdiffs)/100),' percentile.'];...
    ['Resampled differences = ',num2str(mean(resampdiffs)),'\pm',num2str(std(resampdiffs)),'.'];...
    ['5th percentile = ',num2str(resampdiffs(500)),'   95th percentile = ',num2str(resampdiffs(9500))]})

%% plot ii vs in differences
figure('name','Overlaps of Movies with interaction with non-interaction vs non-int&non-int');
subplot(2,1,1);
[iny,inx] = hist(locksteps.intnonpercs);
bar(inx,iny)
[iiy,iix] = hist(locksteps.intintpercs);
[h,p] = kstest2(locksteps.intintpercs,locksteps.intnonpercs);
if p >=.05
    kstext = ['Kolmogorov-Smirnov: distributions ARE NOT DIFFERENT.  K-S p = ',num2str(p)];
else
    kstext = ['Kolmogorov-Smirnov: distributions ARE DIFFERENT.  K-S p = ',num2str(p)];
end

hold on
bar(iix,iiy,'r')
title({'Red: Pairs of non-interaction movies.  Blue: Interaction - Non-Interaction pairs';...
    ['Int-Int: ',num2str(mean(locksteps.intintpercs)),'\pm',num2str(std(locksteps.intintpercs)),'.  Int-NonInt: ',num2str(mean(locksteps.intnonpercs)),'\pm',num2str(std(locksteps.intnonpercs)),'.'];...
    kstext})
xlabel('% lockstep')
ylabel('Number of pairs')
subplot(2,1,2)
resampii = resampledataset(locksteps.intintpercs,10000);
resampin = resampledataset(locksteps.intnonpercs,10000);
resampdiffs = mean(resampii,1)-mean(resampin,1);
resampdiffs = sort(resampdiffs);
realdiff = mean(locksteps.nonnonpercs,2) - mean(locksteps.intnonpercs,2);
hist(resampdiffs);
hold on;
plot(realdiff,1,'color','r','marker','*');
xlabel('Difference in % lockstep: ii-in')
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
            locksteps.slices(sidx).intintzpercs = [];
            locksteps.slices(sidx).intnonzpercs = [];
            locksteps.slices(sidx).nonnonzpercs = [];
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
                    
                    % select movies to use
                    interact1 = movinfo1.Movie1AnyInteract;
                    interact2 = movinfo2.Movie1AnyInteract;
                    if isempty(interact1);interact1 = 0;end
                    if isempty(interact2);interact2 = 0;end
                    
                    onsmov1 = selectmoviefrommovinfo(movinfo1,interact1);
                    onsmov2 = selectmoviefrommovinfo(movinfo2,interact2);

                    zons1 = reshuffleisis(onsmov1);
                    zons2 = reshuffleisis(onsmov2);

                    %denom is the total ACTIVATIONS in the SHARED CELLS
%                     sharedactivecells = find(logical(sum(zons1,1).*sum(zons2,1)));
%                     nonsharedcells = setdiff(1:size(zons1,2),sharedactivecells);
%                     zons1(:,nonsharedcells) = 0;
%                     zons2(:,nonsharedcells) = 0;
%                     minavail = min([sum(zons1(:)) sum(zons2(:))]);
% 
%                     [zlock1,zlock2] = findbestrepeats(zons1,zons2); %#ok<NASGU>
%                     zperc = sum(zlock1(:))/minavail;
                    zperc = getlocksteppercent(zons1,zons2);
                    
                    if isempty(interact1);interact1 = 0;end
                    if isempty(interact2);interact2 = 0;end

                    if interact1+interact2 == 2 &&...
                        strcmp('spontstim',movinfo1.Protocol) && strcmp('spontstim',movinfo2.Protocol)
                        locksteps.slices(sidx).intintzpercs(siicounter,z) = zperc;
                        locksteps.intintzpercs(iicounter,z) = zperc;
                        siicounter = siicounter + 1;
                        iicounter = iicounter + 1;
                        
                    elseif interact1+interact2 == 1 &&... 
                        (strcmp('look',movinfo1.Protocol) && strcmp('spontstim',movinfo2.Protocol) ||...
                        strcmp('spontstim',movinfo1.Protocol) && strcmp('look',movinfo2.Protocol))
                        locksteps.slices(sidx).intnonzpercs(sincounter,z) = zperc;
                        locksteps.intnonzpercs(incounter,z) = zperc;
                        sincounter = sincounter + 1;
                        incounter = incounter + 1;
                        
                    elseif interact1+interact2 == 0 &&...
                        strcmp('look',movinfo1.Protocol) && strcmp('look',movinfo2.Protocol)
                        locksteps.slices(sidx).nonnonzpercs(snncounter,z) = zperc;
                        locksteps.nonnonzpercs(nncounter,z) = zperc;
                        snncounter = snncounter + 1;
                        nncounter = nncounter + 1;

                    end
                end
            end
        end
    end
    disp(z)
end
figure('name','locksteps in Observed vs ISI-Reshuffled Datasets');
subplot(3,1,1);
nnzpercs = sort(mean(locksteps.nonnonzpercs,1));
hist(nnzpercs);
hold on
plot(mean(locksteps.nonnonpercs),1,'color','r','marker','*')
nnpercentile = sum(nnzpercs<mean(locksteps.nonnonpercs))/numreshuffs*100;
xlabel('Percent lockstep')
ylabel('Number of datasets')
title(['Spont-Spont lockstep.  ',num2str(nnpercentile),'th percentile.'])

subplot(3,1,2);
inzpercs = sort(mean(locksteps.intnonzpercs,1));
hist(inzpercs);
hold on
plot(mean(locksteps.intnonpercs),1,'color','r','marker','*')
inpercentile = sum(inzpercs<mean(locksteps.intnonpercs))/numreshuffs*100;
xlabel('Percent lockstep')
ylabel('Number of datasets')
title(['SpontStim-Spont lockstep.  ',num2str(inpercentile),'th percentile.'])

subplot(3,1,3);
iizpercs = sort(mean(locksteps.intintzpercs,1));
hist(iizpercs);
hold on
plot(mean(locksteps.intintpercs),1,'color','r','marker','*')
iipercentile = sum(iizpercs<mean(locksteps.intintpercs))/numreshuffs*100;
xlabel('Percent lockstep')
ylabel('Number of datasets')
title(['SpontStim-SpontStim lockstep.  ',num2str(iipercentile),'th percentile.'])


%% within slice analysis... to see if in is not different from nn in each
%% slice by resampling
spercentiles = [];
for sidx = 1:length(locksteps.slices);
    if ~isempty(locksteps.slices(sidx).nonnonpercs) && ~isempty(locksteps.slices(sidx).intnonpercs)
        sresampnn = resampledataset(locksteps.slices(sidx).nonnonpercs,10000);
        sresampin = resampledataset(locksteps.slices(sidx).intnonpercs,10000);
        sresampdiffs = mean(sresampnn,1) - mean(sresampin,1);
        sresampdiffs = sort(sresampdiffs);
        srealdiff = mean(locksteps.slices(sidx).nonnonpercs,2) - mean(locksteps.slices(sidx).intnonpercs,2);

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
title([num2str(numsignifdiffs),' out of ',num2str(length(spercentiles)),' slices showed significant difference in lockstep between SvS and SvSS.'])



% 
% 
% %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [onsmov,movindex] = selectmoviefrommovinfo(movinfo,interact)
% %for a movie where there was an upstate somewhere and an interacting stim
% %(though maybe not in all of the three sub-movies)
% 
% if ~interact%if no interaction
%     onsmov = movinfo.Ons1(movinfo.Up.UpFrames1,:);%just take the first movie
%     movindex = 1;
% elseif interact
%     movinteract = movinfo.Movie1AnyInteract;
%     if isempty(movinteract);movinteract = 0;end 
%     if movinfo.UpYN1 && movinteract%if movie showed an upstate and had interaction
%         ufs1 = movinfo.Up.UpFrames1;
%         inter1 = movinfo.Movie1InteractFrame;
%         ai1 = sum(ufs1>=inter1);
%         di1 = sum(ufs1==inter1);
%         bi1 = sum(ufs1<=inter1);
%         idx1 = di1 * bi1 * ai1;
%         %generate an distribution index for each movie...
%         %Something like #before frames x #afterframes, but modulated by
%         %whether there is a during-frame
%     else
%         idx1 = 0;
%     end
%     
%     movinteract = movinfo.Movie2AnyInteract;
%     if isempty(movinteract);movinteract = 0;end 
%     if movinfo.UpYN2 && movinteract
%         ufs2 = movinfo.Up.UpFrames2;
%         inter2 = movinfo.Movie1InteractFrame;
%         ai2 = sum(ufs2>=inter2);
%         di2 = sum(ufs2==inter2);
%         bi2 = sum(ufs2<=inter2);
%         idx2 = di2 * bi2 * ai2;
%     else
%         idx2 = 0;
%     end
%     
%     movinteract = movinfo.Movie3AnyInteract;
%     if isempty(movinteract);movinteract = 0;end 
%     if movinfo.UpYN3 && movinteract
%         ufs3 = movinfo.Up.UpFrames3;
%         inter3 = movinfo.Movie3InteractFrame;
%         ai3 = sum(ufs3>=inter3);
%         di3 = sum(ufs3==inter3);
%         bi3 = sum(ufs3<=inter3);
%         idx3 = di3 * bi3 * ai3;
%     else
%         idx3 = 0;
%     end
% 
%     [trash,movindex] = max([idx1 idx2 idx3]);
%     eval(['onsmov = movinfo.Ons',num2str(movindex),'(ufs',num2str(movindex),',:);'])
% end
