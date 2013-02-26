upaps={};
sumaps=[];
for a=1:size(uptraces,1);
	for b=1:size(uptraces,2);
        if ~isempty(uptraces(a,b).stim);
			if strcmp(uptraces(a,b).stim,'wdtrain');
                if uptraces(a,b).wddelay==750;
					trains=separatetrains(uptraces(a,b).in6,5000);
                    m=[];%clear this from last time
                    if ~isempty(trains{1});%if some in6 found
                        for e=1:size(trains,2);%for each separate set of stims given
                            m(e)=trains{e}(1)>uptraces(a,b).ups(2) & trains{e}(1)<uptraces(a,b).ups(3);%record whether that stim was during an upstate
                        end
                    end
                    m=find(m);
                    if ~isempty(m);
                        m=m(1);
                        aps=findaps2(uptraces(a,b).traces);
                        if ~isempty(aps);    
                            nearin6=trains{m}-(uptraces(a,b).ups(1)-1);
%                             nearin6=[nearin6(1) nearin6(end)+1000];
                            upaps{end+1}=aps-nearin6(1);
                            sumaps=cat(2,sumaps,upaps{end});
                        end
                    end
                end
            end
        end
	end
end
upaps{1}=[];

sa=sumaps(find(sumaps>-2500 & sumaps<5000))

array1=quant.bycell.avgfiring.wdtrain750in;
av=mean(array1(find(array1)))/10000*250*48

hist(sa,30);hold on
plot([-2500 5000],[2.3675 2.3675],'r')
xlim([-2500 5000])
ylim([0 10])
plot([0 0],[0 10])
xlabel('10000 pts/sec')
title('APs per 25ms bin in 48 pooled wdtrain750 upstates.  Time zero=start of stimulation')
ylabel('red line = avg firing for 48 cells per 25ms in wdtrain750 (=2.3675)')