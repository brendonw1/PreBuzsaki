function [aps,h]=metricfromabf(uprecords,afterdur,stimtype1,stimtype2);

% if nargin==1;
%     stimtype1='wdtrain';%default
% else
%     stimtype1=varargin{1};
% end

if length(size(uprecords))==4
    uprecords=byfiletobycell(uprecords);
end

millisecondbinsizes=[1 2 4 8 16 32 64 128 256 512];%arbitrary precisions for spike timing, in milliseconds
samplingrate=10000;%points per second
samplingrate=samplingrate/1000;%points per millisecond
costsperpoint=(1./millisecondbinsizes)./samplingrate;
costsperpoint(end+1)=0;

% afterdur=100;

% meanmemb=zeros(1,beforedur+afterdur+1);
for a=1:size(uprecords,1);%for each cell
    aps(a).type1={};
    aps(a).type2={};
	for b=1:size(uprecords,2);%for each recording
        if ~isempty(uprecords(a,b).stim);
			if strcmp(uprecords(a,b).stim,stimtype1) | strcmp(uprecords(a,b).stim,stimtype2);
				if ~isempty(uprecords(a,b).in6)
                    trains=separatetrains(uprecords(a,b).in6,5000);
					[data,sampling,channels]=abfload(uprecords(a,b).abfname);
					match=strmatch(uprecords(a,b).cellchannel,channels);
                    data=data(:,match);
                    disp([a b])
                    data=data(trains{1}(1):trains{1}(1)+afterdur);%add 5 b/c if take point of first stim, it's always an artifact
%                     hold on;plot(data)
                    switch uprecords(a,b).stim
                        case stimtype1
                            aps(a).type1{end+1}=findaps2(data);
                        case stimtype2
                            aps(a).type2{end+1}=findaps2(data);
                    end
                end
            end
        end
	end
%     if ~isempty???
    for c=1:length(costsperpoint);
        h(a,b,c)=discriminator([aps.type1 aps.type2],[ones(size(aps.type1)) 2*ones(size(aps.type2))],'spkd',costsperpoint(c),1);
    end
end