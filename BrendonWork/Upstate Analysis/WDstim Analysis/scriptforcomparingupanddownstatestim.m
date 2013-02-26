%assumes "bycell" uptraces
for a=1:size(uptraces,1);
    a
    meanmembw=avgmembranepotentials(uptraces(a,:));
    if size(meanmembw,1)>0;
        meanmembts=avgmembranefromfile(uptraces(a,:),'tstrain');
        meanmembss=avgmembranefromfile(uptraces(a,:),'tssingle');
        figure(a);
        subplot(3,1,1);
        plot(meanmembw');
        title('WD Train')
        hold on;
        plot([500 500],[-80 20],'--','color','k');
        if size(meanmembts,1)>0;
            subplot(3,1,2);
            plot(meanmembts');
            title('Train Stim')
            hold on;
            plot([500 500],[-80 20],'--','color','k');
        end
        if size(meanmembss,1)>0;
            subplot(3,1,3);
            plot(meanmembss');
            title('Single Stim')
            hold on;
            plot([500 500],[-80 20],'--','color','k');
        end
    end
end

        