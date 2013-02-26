function newspikes=reshufflespikeisis(spikes,starttime,stoptime)
%  newspikes=reshufflespikeisis(spikes,lengthtrace)
%given a spike train, ie from findaps2 in vector mode, and the total length
%of a trace, this function reshuffles the isis and changes the time of
%delay to the first spike in order to output a new spiketrain.  All spikes coming
%out of this function (in "newspikes") will be at a unique time and will be 
%between "starttime" and "stoptime".  Incoming spikes must also be between 
%those times.


if isempty(spikes);
    newspikes=[];
else
    lengthtrace=stoptime-starttime+1;
	isis=diff(spikes);%find isis
	neworder=randperm(length(isis));%randomly shuffle their order
	newspikes=isis(neworder);%put them in that order
	timespiking=sum(isis);%find total time spiking
	timetofirstspike=ceil(lengthtrace-timespiking)*rand;%assign a random amount of time before the first spike
	newspikes=cumsum([timetofirstspike newspikes]);%concatenate this with the reshuffled isis and then turn in to spike tims (cumsum)
    newspikes=newspikes+starttime-1;%set spikes in the timewindow of the incoming spike train (same start time)
end