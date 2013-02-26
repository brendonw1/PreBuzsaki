function [lookthru, x] = lookthru(tr,pk)

for j = 1:size(tr,1)
    set(gcf,'name',['Trace ' num2str(j) ' of ' num2str(size(tr,1))]);
    %h = plot(dfoverf(tr(j,:))); % change back for DF/F
    h = plot(tr(j,:));
    if ~isempty(pk)
        hold on
        %plot([pk pk],ylim,':r');
        plot([pk-6 pk-6],ylim,':r');
        plot([pk+6 pk+6],ylim,':r');
    end
    delete(h);
    %h = plot(dfoverf(tr(j,:))); % change back for DF/F
    h = plot(tr(j,:));
    %h = plot(tr(j,:),'-xk','markeredgecolor',[1 0 0]);
    
    %if you want to plot the baseline
    %hold on
    %plot(baseline(dfoverf(tr(j,:)),10),'-r');
    
    hold off;
    xlim([1 size(tr,2)]);
    
    [x(j) y butt] = ginput(1);
    if butt == 1
        lookthru(j) = 1;
    else
        lookthru(j) = 0;
    end
    
    %ylim([mean(tr(j,:))-50 mean(tr(j,:))+50]);
    
end
delete(gcf);