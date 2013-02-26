function newspikes=gaussianjitterspikes(spikes,starttime,stoptime,sigma)
%  newspikes=gaussianjitterspikes(spikes,lengthtrace)
%
%Given a spike train, ie from findaps2 in vector form, and the total length
%of a trace, this function jitters the timing of each spike using a
%gaussian probability function with standard dev=sigma.  All spikes coming
%out of this function (in "newspikes") will be at a unique time and will be 
%between "starttime" and "stoptime".  Incoming spikes must also be between 
%those times.
if isempty(spikes);
    newspikes=[];
    return
end
newspikes=randn([1 length(spikes)]);%a random number for each spike
newspikes=round((newspikes*sigma)+spikes); 
%     newspikes=newspikes+starttime-1;%set spikes in the timewindow of the
%     incoming spike train (same start time)
indicator=1;
while indicator==1;
%         just sort and diff
%%
%find spikes with duplicate times and then ones that are out of range of
%start and stop time
    if sum(diff(sort(newspikes))==0)%if any newly-created spikes have the same value
        [b,m]=unique(newspikes);%keep only spikes with unique times, and record which index numbers they occupied
        same=setdiff(1:length(newspikes),m);%figure out which spikes should be regenerated
        if ~isempty(same);
            same=find(newspikes==newspikes(same));%find where those two spikes were
            same=same(randperm(length(same)));%pick one of them at random (to re-create later)
            same=same(1);%just take one
        end
    else
        same=[];
    end
    outofrange=cat(2,find(newspikes<starttime),find(newspikes>stoptime));
    redoindices=cat(2,same,outofrange);%make a list of all spikes to remake
    if isempty(redoindices)%if none to remake...
        indicator=0;%exit loop
    else%if to remake some
        redos=spikes(redoindices);%take just the spikes to remake into a new train
        newredos=randn([1 length(redos)]);%randomize them
        newredos=round((newredos*sigma)+redos);%...
        newspikes(redoindices)=newredos;%sub them back into the old ones
%             newspikes=newspikes+starttime-1;%set spikes in the timewindow
%             of the incoming spike train (same start time)
    end
end