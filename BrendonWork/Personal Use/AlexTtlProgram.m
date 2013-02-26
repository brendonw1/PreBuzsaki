AlexTtlProgram (NumTtlsToTrigger, MaxAllowableIntervalInSeconds)
% AlexTtlProgram (NumTtlsToTrigger, MaxAllowableIntervalInSeconds)
% Looks for X number of TTLs in and then triggers a TTL out.  Probably
% inefficient computationally since it uses a costly while loop... may be
% able to fix with a timer function or other event-based function based
% on a property of whatever aquisition object you end up using... or not.
% - NumTtlsToTrigger is the number of input TTLs the program must detect
% before it will put out an output signal
% - MaxAllowableIntervalInSeconds is the total span allowable between the
% first and the last ttls coming in that can be considered close enough to
% trigger an output.  

Ttls = []; %will use this to keep track of timestamps of ttls that come in
GaveOutputTtl = 0; %will use this to keep track of whether an output was given... for now this program just gives a single ttl then stops... you could easily change this


while TaveOutputTtl == 0; %as long as the program hasn't met criteria to give an output yet, keep doing...
    if DATA ACQUISITION OBJECT SHOWS A TTL PULSE %don't really know how you'll do this
        Ttls(end+1,:) = clock; %When a ttl comes in, record the timestamp in absolute time
        if size(Ttls)>=NumTtlsToTrigger %once a ttl comes in and is recorded, see if the total number needed to trigger has come in
            if etime(Ttls(end,:),Ttls(1,:)) <- MaxAllowableIntervalInSeconds %if yes to above, then check whether the first and last timestamps are within the parameter set
                TTL OUTPUT SOMEHOW %if it's short enough, send your ttl out... you gotta figure you this too
                GaveOutputTtl = 1; %change this variable... will end the while loop and therefore this script
            else %if the interval was too long between TTLs...
                Ttls (1,:) = [];%delete the first timestamp and wait for the next... will loop again to reassess after that one to see if the next first/last stamps are close enough
            end
        end
    end
end



