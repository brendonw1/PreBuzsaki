function stims = findin62(data);
% that assumes the presence of "channels" and "data" from
% abfload. It then determines when in6 showed a blip... indicating 
% a potential thalamic stimulus.  Output, "stims" is the onset points of
% each signal
stims=continuousabove(data,zeros(size(data)),1.5,0,Inf);%finds first and last points where IN 6 is indicating an out put was sent
if ~isempty(stims);
    stims=stims(:,1);%just keep the onset times
end