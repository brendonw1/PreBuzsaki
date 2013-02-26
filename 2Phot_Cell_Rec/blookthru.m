function cells = blookthru(tr,spk,frames)

cells=[];
figure;
set(gcf,'position',[5 250 1275 450])
for a=1:length(frames);
    lookthru=[];
    frame=frames(a);
	f=find(spk(:,frame));
	tr2=tr(f,:);
	pk=frame;
	
	for j = 1:size(tr2,1)
        set(gcf,'name',['Trace ' num2str(j) ' of ' num2str(size(tr2,1))]);
        %h = plot(dfoverf(tr2(j,:))); % change back for DF/F
        h = plot(tr2(j,:));
	%     if ~isempty(pk)
            hold on
            %plot([pk pk],ylim,':r');
            plot([pk-5 pk-5],ylim,':r');%plot red lines to indicate relevant frames
            plot([pk+5 pk+5],ylim,':r');
	%     end
        delete(h);
        %h = plot(dfoverf(tr2(j,:))); % change back for DF/F
        h = plot(tr2(j,:));
        %h = plot(tr2(j,:),'-xk','markeredgecolor',[1 0 0]);
        
        %if you want to plot the baseline
        %hold on
        %plot(baseline(dfoverf(tr2(j,:)),10),'-r');
        
        hold off;
        xlim([1 size(tr2,2)]);
        
        [x(j) y butt] = ginput(1);
        if butt == 1
            lookthru(j) = 1;
        else
            lookthru(j) = 0;
        end
        
        %ylim([mean(tr2(j,:))-50 mean(tr2(j,:))+50]);
        
	end
    cells=cat(1,cells,f(find(lookthru)));
end

delete(gcf);