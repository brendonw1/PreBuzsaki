function memb=avgmembranepotentials(uptraces,varargin);

if length(size(uptraces))==4
    uptraces=byfiletobycell(uptraces);
end

if nargin==1;
    stimtype='wdtrain';%default
else
    stimtype=varargin{1};
end

beforedur=0;
afterdur=250;

% meanmemb=zeros(1,beforedur+afterdur+1);
for a=1:size(uptraces,1);%for each cell
	for b=1:size(uptraces,2);%for each trial
        if ~isempty(uptraces(a,b).stim);%if there was an experiment recorded in that slot
			if strcmp(uptraces(a,b).stim,stimtype);
                                    disp([a b])

                if strcmp(stimtype,'wdtrain') | strcmp(stimtype,'wdsingle');
                    disp([a b])
					trains=separatetrains(uptraces(a,b).in6,5000);
                    m=[];%clear this from last time
                    if ~isempty(trains{1});%if some in6 found
                        if ~isempty(uptraces(a,b).ups);
                            for e=1:size(trains,2);%for each separate set of stims given
                                m(e)=trains{e}(1)>uptraces(a,b).ups(2) & trains{e}(1)<uptraces(a,b).ups(3);%record whether that stim was during an upstate
                            end
                        end
                    end
                    m=find(m);
                    if ~isempty(m);
                        data=uptraces(a,b).traces;
%                         aps=findaps2(data);
                        m=m(1);
	%                     nearin6=trains{m}-(uptraces(a,b).ups(1)-1);
                        nearin6=trains{1}-(uptraces(a,b).ups(1)-1);%convert trains to specifying points relevant to the .trace vector
	%                         memb=(data(nearin6(1)-beforedur:nearin6(1)+afterdur))-data(nearin6(1)+5);%add 5 b/c if take point of first stim, it's always an artipfact
                        memb{a,b}=(data(nearin6(1)-beforedur:nearin6(end)+afterdur));%-data(nearin6(1)+5);%add 5 b/c if take point of first stim, it's always an artipfact
                        memb{a,b}=reshape(memb{a,b},[1 prod(size(memb{a,b}))]);
%                         meanmemb{a}=cat(1,meanmemb,memb);
                    end
                elseif strcmp(stimtype,'tstrain') | strcmp(stimtype,'tssingle');
                    trains=separatetrains(uptraces(a,b).in6,5000);
                    if ~isempty(trains{1});
                        if trains{1}~=0;%find out why emtpy and has this label... fix
                            load(uptraces(a,b).abfname);
                            switch uptraces(a,b).cellchannel
								case 'IN 5'
									match=channelmatch(header,1);
								case 'IN 10'
									match=channelmatch(header,2);
								case 'IN 14'
									match=channelmatch(header,3);
							end
                            data=data(:,match);
                            memb{a,b}=(data(trains{1}(1)-beforedur:trains{1}(end)+afterdur));%-data(trains{1}(1)+5);%add 5 b/c if take point of first stim, it's always an artipfact
		%                     memb{a,b}=reshape(memb,[1 prod(size(memb{a,b}))]);
						end
					end
                end
            end
        end
	end
%     meanmemb{a}(1,:)=[];
end

% meanmemb(1,:)=[];
% meanmemb=mean(meanmemb,1);



if length(size(uptraces))==4
    uptraces=byfiletobycell(uptraces);
end

if nargin==1;
    stimtype='wdtrain';%default
else
    stimtype=varargin{1};
end
% 
% beforedur=500;
% afterdur=10000;
% 
% meanmemb=zeros(1,beforedur+afterdur+1);
% for a=1:size(uptraces,1);
% 	for b=1:size(uptraces,2);
%         if ~isempty(uptraces(a,b).stim);
% 			if strcmp(uptraces(a,b).stim,stimtype);
% 				trains=separatetrains(uptraces(a,b).in6,5000);
% %                     m=[];%clear this from last time
% %                     if ~isempty(trains{1});%if some in6 found
% %                         for e=1:size(trains,2);%for each separate set of stims given
% %                             m(e)=trains{e}(1)>uptraces(a,b).ups(2) & trains{e}(1)<uptraces(a,b).ups(3);%record whether that stim was during an upstate
% %                         end
% %                     end
% %                     m=find(m);
% %                 if ~isempty(m);
%                     data=uptraces(a,b).traces;
%                     aps=findaps2(data);
%                     disp([a b])
% %                         m=m(1);
% %                     nearin6=trains{m}-(uptraces(a,b).ups(1)-1);
%                     nearin6=trains{1}-(uptraces(a,b).ups(1)-1);
%                     nearin6=trains{1}-(uptraces(a,b).ups(1)-1);
% %                         memb=(data(nearin6(1)-beforedur:nearin6(1)+afterdur))-data(nearin6(1)+5);%add 5 b/c if take point of first stim, it's always an artipfact
%                     memb=(data(nearin6(1)-beforedur:nearin6(1)+afterdur));%-data(nearin6(1)+5);%add 5 b/c if take point of first stim, it's always an artipfact
%                     memb=reshape(memb,[1 beforedur+afterdur+1]);
%                     meanmemb=cat(1,meanmemb,memb);
%                 end
%             end
%         end
% 	end
% end
% 
% meanmemb(1,:)=[];
% % meanmemb=mean(meanmemb,1);