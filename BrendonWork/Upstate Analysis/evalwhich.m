function [evaluated]=evalwhich(abfnotes);
%this function is one which will go through all of the electrophysiology
%files referred by in "abfnotes" and puts out a matrix called "evaluated" recording whether
%each file should be analyzed.  Evaluated has 1 in a position if a trace is to be evaluated for upstates
% and 0 if not.  The abfnotes variable comes from the
%readnotesabf function, the .stim field at position (x) in notes (y) will only have something in it if
%there was a file at that position in the notes that could have an upstate
%in it (ie nothing where there were firing patterns taken, current injected
%etc... no PIR, RAMP, TRIG).  Once such appropriate files are opened only
%traces which have means between -55 and -85 are further evaluated (others
%are given 0's).  When traces with reasonable means are found, they are
%presented to the user for evaluation, the user may accept or reject each
%trace with a y or n response.
%The dimensions of evaluated are D1=slice number
                                %D2=entry row number in notes file
                                %D3=number of trace in data file
%position (a,b,c) of "evaluated" is 1 if trace c from file specified in row
%b of notes a is to be evaluated, 0 of not (or if that position filler).  
%When using evalated, just look for 1's, don't look at 0s.





for a=1:size(abfnotes,2);%for each slice
    for b=1:size(abfnotes{a}.stimprotocol);%for each possible recording
        if isempty(abfnotes{a}.stim{b});%stim will not be empty only if there is a valid abf file associated with that trial (an abf which is a recording of the right thing)
            %not included will be RAMP, PIR, or TRIG files, since they record injected current.
            evaluated(a,b,:)=0;
        else%if a candidate recording...
            name1=abfnotes{a}.abfname{b};%get name of the electrophys recording to open... display it on screen
            load(name1);%load data from that file into the workspace... this will have multiple traces in it as columns of the variable "data"
			c=1;%establishing variable for a while-loop
            while c<=size(data,2);
                reading=data(:,c);
                if mean(reading)>-55 | mean(reading)<-85;%if mean outside range of neuron resting potentials (w/ potential depolarizations)
                    evaluated(a,b,c)=0;
                    c=c+1;
                else;%otherwise, if the mean is in the normal range of a neuron's membrane potential, then
                    a%display identifying info
                    b
                    c
                    name1
                    abfnotes{a}.stimprotocol{b}
                    abfnotes{a}.stim(b)%done displaying identifying info
 
                    evaluated(a,b,c)=1;%assume ...
                    [baseline,trash]=findbase(reading);%make a baseline for the whole reading... line of best fit to most common range in reading
                    figure;%present for evaluation
                    subplot(2,1,1);
                    zoom on;
                    plot(reading);
                    hold on; 
                    plot(baseline,'g');
                    title ('Whole trace');
                    subplot(2,1,2);
                    zoom on
                    plot(reading(1:10000));
                    hold on;
                    plot(baseline(1:10000),'g');
                    ylim([-80 -45]);
                    title ('First second of trace');
					x=0;
                    while x<1;
                        ans1=input ('Evaluate this trace?  y or n: ','s');
                        if strcmp('n',ans1);
                            disp('Trace will NOT be analyzed');
                            x=1;
                            evaluated(a,b,c)=0;
                            c=c+1;
		%                     continue;
                        elseif strcmp('y',ans1);
                            disp('Trace WILL be analyzed');
                            x=1;
                            c=c+1;
                        else 
                            disp ('Enter "y" or "n"')
                        end    
                    end
                    close;
                end
			end
            clear data%memory management
        end
    end
end