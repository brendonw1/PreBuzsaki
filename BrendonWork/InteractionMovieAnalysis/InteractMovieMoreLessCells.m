function gainedlost = InteractMovieMoreLessCells(moviecell)

gainedlost.noninttots = [];
gainedlost.inttots = [];
gainedlost.snoninttots = [];
gainedlost.sinttots = [];
gainedlost.tnoninttots = [];
gainedlost.tinttots = [];

slices = fieldnames(moviecell);

for sidx = 1:length(slices);
    inttots = [];
    noninttots = [];
    sinttots = [];
    snoninttots = [];
    tinttots = [];
    tnoninttots = [];
    
    sname = slices{sidx};
    eval(['nummovs = length(moviecell.',sname,');'])
    
    for midx = 1:nummovs
        eval(['movinfo = moviecell.',sname,'(midx);'])
        
        onsmov = [];
        if movinfo.UpYN1
            onsmov = movinfo.Up.UpCellOns1;
        elseif movinfo.UpYN2
            onsmov = movinfo.Up.UpCellOns2;
        elseif movinfo.UpYN3
            onsmov = movinfo.Up.UpCellOns3;
        end

        interact = movinfo.Movie1AnyInteract;
        if isempty(interact);interact = 0;end
        
        %grab all nonint and int for each slice
        %1 = mean size of non int
        %divide all values by that so both int and nonint individual
        %measures vary
        %come up with mean +/- sd for each slice
        
        if ~isempty(onsmov);
            if interact
                inttots(end+1) = sum(onsmov);
                if strcmp(movinfo.Protocol,'ss')
                    tinttots(end+1) = sum(onsmov);
                elseif strcmp(movinfo.Protocol,'spontstim');
                    sinttots(end+1) = sum(onsmov);
                end                        
            else
                noninttots(end+1) = sum(onsmov);           
                if strcmp(movinfo.Protocol,'s')
                    tnoninttots(end+1) = sum(onsmov);
                elseif strcmp(movinfo.Protocol,'look');
                    snoninttots(end+1) = sum(onsmov);
                end
            end
        end
    end
    if ~isempty(inttots) && ~isempty(noninttots);
        norm = mean(noninttots);
        inttots = inttots/norm;
        noninttots = noninttots/norm;

        gainedlost.inttots = cat(2,gainedlost.inttots,inttots);
        gainedlost.noninttots = cat(2,gainedlost.noninttots,noninttots);

        gainedlost.slices(sidx).inttots = inttots;
        gainedlost.slices(sidx).noninttots = noninttots;
    end
    if ~isempty(sinttots) && ~isempty(snoninttots);
        norm = mean(snoninttots);
        sinttots = sinttots/norm;
        snoninttots = snoninttots/norm;

        gainedlost.sinttots = cat(2,gainedlost.sinttots,sinttots);
        gainedlost.snoninttots = cat(2,gainedlost.snoninttots,snoninttots);
    end
    if ~isempty(tinttots) && ~isempty(tnoninttots);
        norm = mean(tnoninttots);
        tinttots = tinttots/norm;
        tnoninttots = tnoninttots/norm;

        gainedlost.tinttots = cat(2,gainedlost.tinttots,tinttots);
        gainedlost.tnoninttots = cat(2,gainedlost.tnoninttots,tnoninttots);
    end
        

%         figure;
%         subplot(2,1,1)
%         [iny,inx] = hist(inttots);
%         bar(inx,iny,'r');
%         hold on;
%         [niny,ninx] = hist(noninttots);
%         bar(ninx,niny);
%         title({'Blue: Non-Interaction movies.  Red: Interaction movies.';...
%         ['Nonint: ',num2str(mean(noninttots)),'\pm',num2str(std(noninttots)),...
%         '.  Int: ',num2str(mean(inttots)),'\pm',num2str(std(inttots)),'.']})
%         xlabel('% of mean nonint number of cells')
%         ylabel('Number of movies')
% 
%         subplot(2,1,2)
%         resampn = resampledataset(noninttots,10000);
%         resampi = resampledataset(inttots,10000);
%         resampdiffs = mean(resampn,1)-mean(resampi,1);
%         resampdiffs = sort(resampdiffs);
%         realdiff = mean(noninttots,2) - mean(inttots,2);
%         hist(resampdiffs);
%         hold on;
%         plot(realdiff,1,'color','r','marker','*');
%         xlabel('Percent of cells: Nonint-Int')
%         ylabel('Number of reshuffles')
%         title({'Histogram of differences between 10000 random resamples of NonInt and Int datasets. Vs observed';...
%             ['Observed difference = ',num2str(realdiff),'.  ',num2str(sum(realdiff>=resampdiffs)/100),' percentile.'];...
%             ['Resampled differences = ',num2str(mean(resampdiffs)),'\pm',num2str(std(resampdiffs)),'.'];...
%             ['5th percentile = ',num2str(resampdiffs(500)),'   95th percentile = ',num2str(resampdiffs(9500))]})
    
end

figure;
subplot(2,1,1)
[iny,inx] = hist(gainedlost.inttots);
bar(inx,iny,'r');
hold on;
[niny,ninx] = hist(gainedlost.noninttots);
bar(ninx,niny);
title({'Blue: Non-Interaction movies.  Red: Interaction movies.';...
['Nonint: ',num2str(mean(gainedlost.noninttots)),'\pm',num2str(std(gainedlost.noninttots)),...
'.  Int: ',num2str(mean(gainedlost.inttots)),'\pm',num2str(std(gainedlost.inttots)),'.']})
xlabel('% of mean nonint number of cells')
ylabel('Number of movies')

subplot(2,1,2)
resampn = resampledataset(gainedlost.noninttots,10000);
resampi = resampledataset(gainedlost.inttots,10000);
resampdiffs = mean(resampn,1)-mean(resampi,1);
resampdiffs = sort(resampdiffs);
realdiff = mean(gainedlost.noninttots,2) - mean(gainedlost.inttots,2);
hist(resampdiffs);
hold on;
plot(realdiff,1,'color','r','marker','*');
xlabel('Percent of cells: Nonint-Int')
ylabel('Number of reshuffles')
title({'Histogram of differences between 10000 random resamples of NonInt and Int datasets. Vs observed';...
    ['Observed difference = ',num2str(realdiff),'.  ',num2str(sum(realdiff>=resampdiffs)/100),' percentile.'];...
    ['Resampled differences = ',num2str(mean(resampdiffs)),'\pm',num2str(std(resampdiffs)),'.'];...
    ['5th percentile = ',num2str(resampdiffs(500)),'   95th percentile = ',num2str(resampdiffs(9500))]})



figure;
subplot(2,1,1)
[iny,inx] = hist(gainedlost.sinttots);
bar(inx,iny,'r');
hold on;
[niny,ninx] = hist(gainedlost.snoninttots);
bar(ninx,niny);
title({'Blue: Spont movies.  Red: Spont+Stim movies.';...
['Nonint: ',num2str(mean(gainedlost.snoninttots)),'\pm',num2str(std(gainedlost.snoninttots)),...
'.  Int: ',num2str(mean(gainedlost.sinttots)),'\pm',num2str(std(gainedlost.sinttots)),'.']})
xlabel('% of mean spont number of cells')
ylabel('Number of movies')

subplot(2,1,2)
resampn = resampledataset(gainedlost.noninttots,10000);
resampi = resampledataset(gainedlost.inttots,10000);
resampdiffs = mean(resampn,1)-mean(resampi,1);
resampdiffs = sort(resampdiffs);
realdiff = mean(gainedlost.noninttots,2) - mean(gainedlost.inttots,2);
hist(resampdiffs);
hold on;
plot(realdiff,1,'color','r','marker','*');
xlabel('Percent of cells: Spont - Spont+Stim')
ylabel('Number of reshuffles')
title({'Histogram of differences between 10000 random resamples of Spont and Spont+Stim datasets. Vs observed';...
    ['Observed difference = ',num2str(realdiff),'.  ',num2str(sum(realdiff>=resampdiffs)/100),' percentile.'];...
    ['Resampled differences = ',num2str(mean(resampdiffs)),'\pm',num2str(std(resampdiffs)),'.'];...
    ['5th percentile = ',num2str(resampdiffs(500)),'   95th percentile = ',num2str(resampdiffs(9500))]})



figure;
subplot(2,1,1)
[iny,inx] = hist(gainedlost.tinttots);
bar(inx,iny,'r');
hold on;
[niny,ninx] = hist(gainedlost.tnoninttots);
bar(ninx,niny);
title({'Blue: Stim movies.  Red: Stim+Stim movies.';...
['Nonint: ',num2str(mean(gainedlost.tnoninttots)),'\pm',num2str(std(gainedlost.tnoninttots)),...
'.  Int: ',num2str(mean(gainedlost.tinttots)),'\pm',num2str(std(gainedlost.tinttots)),'.']})
xlabel('% of mean stim number of cells')
ylabel('Number of movies')

subplot(2,1,2)
resampn = resampledataset(gainedlost.tnoninttots,10000);
resampi = resampledataset(gainedlost.tinttots,10000);
resampdiffs = mean(resampn,1)-mean(resampi,1);
resampdiffs = sort(resampdiffs);
realdiff = mean(gainedlost.tnoninttots,2) - mean(gainedlost.tinttots,2);
hist(resampdiffs);
hold on;
plot(realdiff,1,'color','r','marker','*');
xlabel('Percent of cells: Stim - Stim+Stim')
ylabel('Number of reshuffles')
title({'Histogram of differences between 10000 random resamples of Stim and Stim+Stim datasets. Vs observed';...
    ['Observed difference = ',num2str(realdiff),'.  ',num2str(sum(realdiff>=resampdiffs)/100),' percentile.'];...
    ['Resampled differences = ',num2str(mean(resampdiffs)),'\pm',num2str(std(resampdiffs)),'.'];...
    ['5th percentile = ',num2str(resampdiffs(500)),'   95th percentile = ',num2str(resampdiffs(9500))]})
