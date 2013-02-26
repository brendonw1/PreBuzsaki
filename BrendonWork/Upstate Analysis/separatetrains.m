function septrains=separatetrains(events,sepdist);
%Takes event timings as a vector and divides them into separate trains of events.
%Trains are defined as series of pulses that have differences between them of up 
%to sepdist (an input).  If there is a gap greater than maxdiff, the spikes on 
%either side will be considered parts of separate trains.  Each train is stored as a vector
%inside a cell array... each vector in the cell represents a separate train

events=sort(events);%make sure events are in numerical sequence... should be a list of times of events, in order
d=diff(events);
% d=5*round(d/5);%round to nearest 5 time points... so small errors are cancelled
ends=find(d>sepdist);%find the ends of all separate sequences (with intervals less than 100ms) except the last
ends(end+1)=length(events);%add the final last time, which equals the end of the entire sequence
starts=ends+1;%find whre most sequences start
starts(end)=1;%elim the start that would be one past the end of the entire sequence, sub in point one as the first start
starts=sort(starts);%sort, so in order, and correspond with ends

for d=1:length(starts);%for every separate train
    septrains{d}=events(starts(d):ends(d));%store each train as a matrix inside a cell
end