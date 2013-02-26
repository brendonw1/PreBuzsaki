% a script... that assumes the presence of "channels" and "data" from
% abfload. It then determines when in6 showed a blip... indicating 
% a potential thalamic stimulus.  Output, "stims" is the onset points of
% each signal
cn=strmatch('IN 6',channels,'exact');
if ~isempty(cn);
	temp=data(:,cn);%extract the in6 trace
	stims=continuousabove(temp,zeros(size(temp)),.1,0,Inf);%finds first and last points where IN 6 is indicating an out put was sent
	if ~isempty(stims);
        stims=stims(:,1);%just keep the onset times
	end
else
    stims=[];
end