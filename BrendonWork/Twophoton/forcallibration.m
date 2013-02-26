importfloat32dir(cd)
framenums=continuousabove(Frames,zeros(size(Frames)),3,5000,10000);
aps=findaps2(Vm);
septrains=separatetrains(aps,10000);
events=struct('framespan',{},'numspikes',{},'type',{});
figure;
for a=1:length(septrains);
    first=find(framenums(:,1)<septrains{a}(1));
    if ~isempty(first);%if frames were being taken
        first=first(end);
        last=find(framenums(:,end)>septrains{a}(end));
        last=last(1);
        numintrain=length(septrains{a});
	%%%%set up for display%%%%
		start=septrains{a}(1)-30000;
		stop=septrains{a}(1)+30000;
        hold off	
        plot(Vm(start:stop),'b');
		hold on
        plot(Frames(start:stop),'r');
        plot(Current(start:stop)/10,'g');
        w=who;
        for c=1:length(w);
            m(c)=strcmp(w{c},'Stim');
        end
        if sum(m)>0;
            plot(Stim(start:stop)*10,'m');
        end
        j=find(framenums(:,2)<stop);
		i=find(framenums(:,1)>start);
		onscreen=intersect(i,j);
		onscreentimes=framenums(onscreen,:)-start;
        for b=1:length(onscreen);
            text(mean(onscreentimes(b,1),onscreentimes(b,2)),10,num2str(onscreen(b)),'color','k')
        end
        title([num2str(numintrain),' APs from frame ',num2str(first),' to ',num2str(last)]);
        typ=input('AP type?  C for Current, U for Upstate, O for Other: ','s');
        
        events(end+1).framespan(1)=first;
        events(end).framespan(2)=last;
        events(end).numspikes=numintrain;
        events(end).type=typ;
    end
end