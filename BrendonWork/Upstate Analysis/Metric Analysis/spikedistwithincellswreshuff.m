function distances=spikedistbetweenupstateswreshuff(spikesreshuffuptraces,goodpercell)

%how to choose... optimize time on whole dataset?  
%optimize on each & see how different each set is... 

millisecondbinsizes=2.^(11:-1:0);%[2048 1024 512 256 128 64 32 16 8 4 2 1] arbitrary precisions for spike timing, in milliseconds
samplingrate=10000;%points per second

samplingrate=samplingrate/1000;%points per millisecond
Q=(1./millisecondbinsizes)./samplingrate;
Q(end+1)=0;%this is for only 

if length(size(spikesreshuffuptraces))==4%if spikesreshuffuptraces input is in the original "by file" format
    spikesreshuffuptraces=byfiletobycell(spikesreshuffuptraces);%convert to a cell number by trial number format
end

for a=1:size(spikesreshuffuptraces,1);%for each cell
    disp(a)
    for b=1:length(costsperpoint);%go through each level of precision
        if sum(spikesreshuffuptraces(1).spikeguide(a,:))>=goodpercell;%if at least goodpercell upstates had spikes in this cell
            whereups=find(spikesreshuffuptraces(1).spikeguide(a,:));%record which indices refer to upstates
            combs=nchoosek(whereups,2);%pairwise combinations of all upstates from each cell
            distances(a,b).origcomparisons=zeros(size(combs,1),1);
            distances(a,b).shuffcomparisons=zeros(size(combs,1),size(spikesreshuffuptraces(a,whereups(1)).spikes,1));
            for c=1:size(combs,1)%go through each pairwise combo
                aps1=spikesreshuffuptraces(a,combs(c,1)).original;
                aps2=spikesreshuffuptraces(a,combs(c,2)).original;
                distances(a,b).origcomparisons(c)=spkd(aps1,aps2,costsperpoint(b));
                for z=1:size(spikesreshuffuptraces(a,whereups(1)).spikes,1);
                    aps1=spikesreshuffuptraces(a,combs(c,1)).spikes(z,:);
                    aps2=spikesreshuffuptraces(a,combs(c,2)).spikes(z,:);
                    distances(a,b).shuffcomparisons(c,z)=spkd(aps1,aps2,costsperpoint(b));
                end
            end
        end
    end
end


for a=1:size(distances,1);
	for b=1:size(distances,2);
        if ~isempty(distances(a,b).origcomparisons);
			origmeans(a,b)=mean(distances(a,b).origcomparisons);
            shuffmeans(a,b)=mean(distances(a,b).shuffcomparisons(:));
            shuffmins(a,b)=min(mean(distances(a,b).shuffcomparisons,1));
            shuffmaxs(a,b)=max(mean(distances(a,b).shuffcomparisons,1));
        end
	end
    if shuffmeans(a,1);
		figure(a)
		hold on;plot(origmeans(a,:),'k')
		errorbar(1:length(shuffmeans(a,:)),shuffmeans(a,:),shuffmins(a,:)-shuffmeans(a,:),shuffmaxs(a,:)-shuffmeans(a,:))
    end
end


% 
% origmeans2=origmeans';
% origmeans2=origmeans2(:,find(sum(origmeans)));
% origmeans2=origmeans2-repmat(min(origmeans2),[size(origmeans2,1) 1]);
% origmeans2=origmeans2./repmat(max(origmeans2),[size(origmeans2,1) 1]);
% shuffmeans2=shuffmeans';
% shuffmeans2=shuffmeans2(:,find(sum(shuffmeans)));
% shuffmeans2=shuffmeans2-repmat(min(shuffmeans2),[size(shuffmeans2,1) 1]);
% shuffmeans2=shuffmeans2./repmat(max(shuffmeans2),[size(shuffmeans2,1) 1]);
% 
% figure(a+1);
% plot(origmeans2);
% hold
% plot(shuffmeans2);