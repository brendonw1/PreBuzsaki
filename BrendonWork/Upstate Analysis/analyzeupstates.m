function ud=analyzeupstates(abfnotes);
%Input is notes read from excel files for specific slices (ie
%notesMMDDYYn10) by the function "readnotesabf".  This program will read through the "abfname" column to
%find abfs.  If an abf is indicated in the notes, then the notes, which
%have already been converted to matlab files (.mat) are opened, assuming
%you are in the right directory (the one which has all the mat files).

for a=1:size(abfnotes,2);%for each slice
    for b=1:size(abfnotes{a}.stimprotocol);%for each possible recording
        if ~isempty(abfnotes{a}.stim{b});%stim will not be empty only if there is a valid abf file associated with that trial (an abf which is a recording of the right thing)
            %not included will be RAMP, PIR, or TRIG files, since they
            %record injected current.
            name1=abfnotes{a}.abfname{b}%get name of the electrophys recording to open
            load(name1);%load data from that file into the workspace... this will have multiple traces in it
            sliceaps{b}=findaps(data);%find maxpoints of action potentials in traces from cells
            [sliceups{b},sliceupaps{b},evaluated{a,b},rejected{a,b}]=findupstates(data,aps{b});%find upstates and start and end points of rise and fall from down to up and back
%             if ~isempty(sliceups{b});%if any upstates detected
%                 for c=1:length(sliceups{b});%for every trace
%                     if ~isempty(sliceups{b}{c});%if there was an upstate in that trace
%                         for d=1:size(sliceups{b}{c},2);%for every upstate found in that trace
%                             
%                             rampup=data(:,c);%take from trace in question
%                             rampup=rampup(sliceups{b}(d,1):sliceups{b}(d,2));%extract only the part preceeding the upstate
%                             tauon=polyfit(1:length(rampup),log(rampup),1);%fit the first log of the data to a line
%                             tauon(1)=tauon;%the first variable represents the slope of the line = tau for the exponential
%                             
%                             rampdown=data(:,c);%take from trace in question
%                             rampdown=rampdown(sliceups{b}(d,3):sliceups{b}(d,4));%extract only the part preceeding the upstate
%                             tauoff=polyfit(1:length(rampdown),log(rampdown),1);%fit the first log of the data to a line
%                             tauoff(1)=tauoff;%the first variable represents the slope of the line = tau for the exponential
%                             
%                             inup=data(:,c);
%                             inup=inup(sliceups{b}(d,2):sliceups{b}(d,3));
%                             normalmean=mean(inup);
%                             [basemean,trash]=findbase(inup);
%                             upsdev=std(inup);
%                             length=length(inup);
%                             
%                             
%                             !how to store data like lengths, etc... big structure with (slices x records) as dimensions
%                             !if spikes in it... give times, isi's,
%                             !test opening files w/ just first part of this function
%                             
%                         end
%                     end
%                 end
%             end
        end
    end
end

                