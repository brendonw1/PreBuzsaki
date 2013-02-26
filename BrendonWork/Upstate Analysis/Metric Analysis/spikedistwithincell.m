function distances=spikedistwithincell(spikesreshuffuptraces,goodpercell)

%how to choose... optimize time on whole dataset?  
%optimize on each & see how different each set is... 

millisecondbinsizes=[1 2 4 8 16 32 64 128 256 512];%arbitrary precisions for spike timing, in milliseconds
samplingrate=10000;%points per second

samplingrate=samplingrate/1000;%points per millisecond
costsperpoint=(1./millisecondbinsizes)./samplingrate;

if length(size(uptraces))==4%if uptraces input is in the original "by file" format
    uptraces=byfiletobycell(uptraces);%convert to a cell number by trial number format
end


for a=1:size(uptraces,1);%for each cell
    for b=1:length(costsperpoint);%go through each level of precision
        whereups=find(uptraces(1).guide(a,:));%record which indices refer to upstates
        if length(whereups)>=goodpercell;
            combs=nchoosek(whereups,2);%pairwise combinations of all upstates from each cell
            distances(a,b).comparisons=zeros(size(combs,1),1);
            for c=1:size(combs,1)%go through each pairwise combo
                aps1=findaps2(uptraces(a,combs(c,1)).traces);
                aps2=findaps2(uptraces(a,combs(c,2)).traces);
                distances(a,b).comparisons(c)=spkd(aps1,aps2,costsperpoint(b));
            end
        distances(a,b).mean=mean(distances(a,b).comparisons);
        end
    end
end

% for a=1:size(distances,1);
% 	for b=1:size(distances,2);
% 		if ~isempty(distances(a,b).mean);
% 			if distances(a,b).mean;
% 				ms(a,b)=distances(a,b).mean;
% 			end
%         end
%     end
% end
% ms=ms';
% ms2=ms(:,find(sum(ms)));
% ms2=ms2-repmat(min(ms2),[size(ms2,1) 1]);
% ms2=ms2./repmat(max(ms2),[size(ms2,1) 1]);