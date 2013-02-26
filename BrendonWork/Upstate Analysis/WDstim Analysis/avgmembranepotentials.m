function meanmemb=avgmembranepotentials(uptraces,varargin);

if length(size(uptraces))==4
    uptraces=byfiletobycell(uptraces);
end

if nargin==1;
    stimtype='wdtrain';%default
else
    stimtype=varargin{1};
end

beforedur=500;
afterdur=10000;

meanmemb=zeros(1,beforedur+afterdur+1);
for a=1:size(uptraces,1);
	for b=1:size(uptraces,2);
        if ~isempty(uptraces(a,b).stim);
			if strcmp(uptraces(a,b).stim,stimtype);
%                 if uptraces(a,b).wddelay==750;
					trains=separatetrains(uptraces(a,b).in6,5000);
                    m=[];%clear this from last time
                    if ~isempty(trains{1});%if some in6 found
                        for e=1:size(trains,2);%for each separate set of stims given
                            m(e)=trains{e}(1)>uptraces(a,b).ups(2) & trains{e}(1)<uptraces(a,b).ups(3);%record whether that stim was during an upstate
                        end
                    end
                    m=find(m);
                    if ~isempty(m);
                        data=uptraces(a,b).traces;
                        aps=findaps2(data);
                        disp([a b])
%                         if ~isempty(aps);
%                             data=elimaps(data);
%                         end
                        m=m(1);
                        nearin6=trains{m}-(uptraces(a,b).ups(1)-1);
%                         memb=(data(nearin6(1)-beforedur:nearin6(1)+afterdur))-data(nearin6(1)+5);%add 5 b/c if take point of first stim, it's always an artipfact
                        memb=(data(nearin6(1)-beforedur:nearin6(1)+afterdur));%-data(nearin6(1)+5);%add 5 b/c if take point of first stim, it's always an artipfact
                        memb=reshape(memb,[1 beforedur+afterdur+1]);
                        meanmemb=cat(1,meanmemb,memb);
                    end
%                 end
            end
        end
	end
end

meanmemb(1,:)=[];
% meanmemb=mean(meanmemb,1);