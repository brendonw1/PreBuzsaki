function stims=findin6(header,data);
% This takes the header and data from an axon file and determines when in6 showed a blip... indicating 
% a potential thalamic stimulus.  Output, stims is the onset points of
% each signal

c=channelnames(header);
ic=[];
for a=1:length(c);%go thru each channel name
    if strcmp(c(a),'IN 6');%find if it is "IN 6"
        ic=a;%if it is, store the number in ic
    end
end
if ~isempty(ic);
	in6=data(:,ic);%extract the in6 trace
	stims=continuousabove(in6,zeros(size(in6)),.1,0,Inf);%finds first and last points where IN 6 is indicating an out put was sent
	if ~isempty(stims);
        stims=stims(:,1);%just keep the onset times
	end
else
    stims=[];
end



