function newspikes=reshufflespikeisis2(spikes,starttime,stoptime)
%  newspikes=reshufflespikeisis2(spikes,lengthtrace)
%THIS DIFFERS FROM RESHUFFLESPIKEISIS IN THAT IT DOES NOT RANDOMLY PICK A
%NEW TIME TO THE INITIAL SPIKE BUT INSTEAD KEEPS THE TIME TO THE FIRST
%SPIKE IN THE INPUT DATASET.
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
    timetofirstspike=spikes(1);%keep time delay to the first spike
    newspikes=cumsum([timetofirstspike newspikes]);%concatenate this with the reshuffled isis and then turn in to spike tims (cumsum)
    newspikes=newspikes+starttime-1;%set spikes in the timewindow of the incoming spike train (same start time)
end