function newspikes=randomtimingspikes(spikes,starttime,stoptime)
%  newspikes=randomtimingspikes(spikes,lengthtrace)
%
% Takes the number of spikes in and creates a random set of spikes coming
% out.  All spikes coming out of this function (in "newspikes") will be at 
% a unique time and will be between "starttime" and "stoptime".  Incoming 
% spikes must also be between those times.


if isempty(spikes);
    newspikes=[];
else
    lengthtrace=stoptime-starttime+1;%get the total time in which spikes can happen
    newspikes=round(lengthtrace*rand(1,length(spikes)));%generate a random set of spike times
    newspikes=unique(newspikes);%keep only times that are not repeated
    while length(newspikes)<length(spikes);%if some times overlapped
        newspikes(end+1:end+(length(spikes)-length(newspikes)))=round(lengthtrace*rand(1,length(spikes)-length(newspikes)));%add on some new random spikes to the end of the vector
        newspikes=unique(newspikes);%keep only ones that are uinique... if some eliminated, go back to try to find more unique times
    end
    newspikes=sort(newspikes);%put in numerical order
    newspikes=newspikes+starttime-1;%set spikes in the timewindow of the incoming spike train (same start time)
end