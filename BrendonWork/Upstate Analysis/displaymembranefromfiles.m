function allmemb=displaymembranefromfiles(uprecords,varargin);

if nargin==1;
    stimtypes={'tstrain','wdtrain'};%default
else
    stimtypes=varargin{1};
end

if length(size(uprecords))==4
    uprecords=byfiletobycell(uprecords);
end

beforedur=500;
afterdur=2000;

for a=1:size(uprecords,1);%for each cell 
    allmemb={};  
    postypes=zeros(1,length(stimtypes));
    for b=1:size(uprecords,2);%for each trial
        for c=1:length(stimtypes);
            if ~isempty(uprecords(a,b).stim);
				if strcmp(uprecords(a,b).stim,stimtypes{c});
					if ~isempty(uprecords(a,b).in6)
                        postypes(c)=1;
                    end
                end
            end
        end
    end
    if sum(postypes)==length(stimtypes);%if all this cell had all the desired types of events              
        for c=1:length(stimtypes);
            allmemb{c}=zeros(1,beforedur+afterdur+1);
        end
		for b=1:size(uprecords,2);%for each trial
            for c=1:length(stimtypes);
                if ~isempty(uprecords(a,b).stim);
					if strcmp(uprecords(a,b).stim,stimtypes{c});
						if ~isempty(uprecords(a,b).in6)
                            trains=separatetrains(uprecords(a,b).in6,5000);
							[data,sampling,channels]=abfload(uprecords(a,b).abfname);
							match=strmatch(uprecords(a,b).cellchannel,channels);
                            data=data(:,match);
                            disp([a b])
                            data=(data(trains{1}(1)-beforedur:trains{1}(1)+afterdur));%add 5 b/c if take point of first stim, it's always an artipfact                    memb=(data(trains{1}(1)-beforedur:trains{1}(1)+afterdur));%-data(trains{1}(1)+5);%add 5 b/c if take point of first stim, it's always an artipfact
                            data=reshape(data,[1 beforedur+afterdur+1]);
                            allmemb{c}=cat(1,allmemb{c},data);
                            slicename=uprecords(a,b).moviename;
                        end
                    end
                end
            end
        end
        for c=1:length(stimtypes);
            allmemb{c}(1,:)=[];
        end

        
        
        try
            slicename=[slicename(1:8),'0 Cell#',num2str(a)];
            figure('NumberTitle','Off','Name',slicename)
        catch
            figure('NumberTitle','Off')
        end
        for c=1:length(stimtypes);
            subplot(length(stimtypes),1,c);
            plot(allmemb{c}');
            set(gca,'XLim',[0 beforedur+afterdur])
            set(gca,'XTickLabel',num2str(str2num(get(gca,'XTickLabel'))-beforedur))
            
            if ~isempty(uprecords(a,1).core)
				cs='Core. ';
			else
				cs='Non-core. ';
			end
            if ~isempty(uprecords(a,1).directinput)
				ds='Direct. ';
			else
				ds='Not Direct. ';
			end
                    
            text(0,1.1,[upper(stimtypes{c}),'. ',ds,cs]...
                ,'units','normalized','parent',gca)
        end
    end
end

% allmemb=mean(allmemb,1);