temp=zeros(1,10000);
temp(501:9500)=1;
temp=repmat(temp,[1 100]);
frames=temp;
frames=repmat(frames,[1 3]);
frames=cat(2,zeros(1,30000),frames,zeros(1,30000));
clear temp

spikes=-70*ones(1,1000);
spikes(2:17)=10;
spikes=repmat(spikes,[1 5]);
spikes=cat(2,spikes,-70*ones(1,5000));
spikes=cat(2,spikes,-70*ones(1,40000));
spikes=repmat(spikes,[1 10]);
spikes=repmat(spikes,[1 2]);
spikes=cat(2,spikes,-70*ones(1,300000),spikes);
spikes=cat(2,-70*ones(1,350000),spikes);
spikes=cat(2,spikes,-70*ones(1,350000));
spikes=cat(2,-70*ones(1,30000),spikes,-70*ones(1,30000));

Frames=frames;clear frames;
Vm=spikes;clear spikes;



frametimes=continuousabove(Frames,zeros(1,length(Frames)),.1,8000,10000);%find frames

aps=findaps2(Vm);%find spikes
sep=separatetrains(aps,2000);%find spikes trains

for a=1:length(sep);
    temp=find(frametimes(:,2)>=sep{a}(end));%get first frame to finish after each spike train ends
    afterframe1(a)=temp(1);
end

beforeframe1=afterframe1-1;
beforeframe2=afterframe1-2;
afterframe2=afterframe1+1;
