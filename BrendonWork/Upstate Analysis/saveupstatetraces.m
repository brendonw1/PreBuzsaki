function uptraces=saveupstatetraces(upstates,abfnotes);
%input is found upstates and abfnotes matching them.  Output is a cell
%array of vectors, each vector is the electrophysiologic trace for 1
%upstate.  Dimensions of the output are 1=slice, 2=file, 3=cell, 4=upstate
%number

warning off MATLAB:divideByZero

% uptraces.traces={};
uptraces.guide=[];
uptraces.traces=[];
uptraces.ups=[];
% uptraces.aps=[];
uptraces.in6=[];
uptraces.stim=[];
uptraces.abfname=[];
uptraces.wddelay=[];
uptraces.moviename=[];
uptraces.traces=[];
uptraces.cellchannel=[];
uptraces.celltype=[];
uptraces.stimnum=[];
uptraces.stimfreq=[];
uptraces.stimamp=[];
uptraces.stimprotocol=[];
uptraces.timesincelast=[];
uptraces.observation=[];
uptraces.otherdescrip=[];

for a=1:size(upstates,1);%for every slice
    for b=1:size(upstates,2);%for each file
        emp=[];
        for bb=1:size(upstates,3);%for each trace in that record
           emp(bb)=~isempty(upstates{a,b,bb});%record whether there is an upstate found in each record
        end
        if sum(emp)>0;%if there is any upstate in this file, load it by...
            name1=abfnotes{a}.abfname{b};%get name of the electrophys recording to open from the abfnotes cell
            disp([num2str(a),' ',num2str(b),' ',name1]);
            load(name1);%load data from that file into the workspace... this will have multiple traces in it as columns of the variable "data"
            for c=1:size(upstates,3);%for each trace in the loaded file
                if ~isempty(upstates{a,b,c});%if upstates detected;
                    match=channelmatch(header,c);%call on function that figures out which channel in the file corresponds to the cell we're calling for (c)
                    reading=data(:,match);  
                    ups=upstates{a,b,c};%bring in upstate matrix, which is x by 4
                    %reading=data(:,c);%extract the corresponding data trace for the same reason
                    for d=1:size(ups,1);%for every upstate detected
                        uptraces(1).guide(a,b,c,d)=1;%save whether or not there was an up state in this slot
                        uptraces(a,b,c,d).traces=reading(ups(d,1):ups(d,4));%extract and save the region in the upstate
                        uptraces(a,b,c,d).ups=ups(d,:);
%                         uptraces(a,b,c,d).aps=findaps2(reading);
                        uptraces(a,b,c,d).in6=findin6(header,data);
%                         uptraces.celltype(a,b,c,d)=
%                         if length(inup)>1 & rem(length(inup),20)=0;%if above zero and a multiple of 20 traces have been recorded...
%                             nu=length(inup/20);%find the number of the last UP state in the batch to be saved
%                             nd=nu-19;%find the number of the first;
%                             n=['traces',num2str(nu),'-',num2str(nd)];
%                             eval(n)=inup(nd:nu);???
%                             save (eval(n),n));???
%                             inup={};
%                         end
                    end
                    uptraces(a,b,c,d).stim=abfnotes{a}.stim{b};
                    uptraces(a,b,c,d).abfname=abfnotes{a}.abfname{b};
                    uptraces(a,b,c,d).wddelay=abfnotes{a}.wddelay{b};
                    uptraces(a,b,c,d).moviename=abfnotes{a}.moviename{b};
                    switch c
                        case 1
                            uptraces(a,b,c,d).cellchannel='IN 5';
                            uptraces(a,b,c,d).celltype=abfnotes{a}.in5cell;
						case 2
                            uptraces(a,b,c,d).cellchannel='IN 10';
                            uptraces(a,b,c,d).celltype=abfnotes{a}.in10cell;
				   		case 3
                            uptraces(a,b,c,d).cellchannel='IN 14';
                            uptraces(a,b,c,d).celltype=abfnotes{a}.in14cell;
					end
                    uptraces(a,b,c,d).stimnum=abfnotes{a}.stimnum{b};
                    uptraces(a,b,c,d).stimfreq=abfnotes{a}.stimfreq{b};
                    uptraces(a,b,c,d).stimamp=abfnotes{a}.stimamp{b};
                    uptraces(a,b,c,d).stimprotocol=abfnotes{a}.stimprotocol{b};
                    uptraces(a,b,c,d).timesincelast=abfnotes{a}.timesincelast{b};
                    uptraces(a,b,c,d).observation=abfnotes{a}.observation{b};
                    uptraces(a,b,c,d).otherdescrip=abfnotes{a}.otherdescrip{b};    
                end
            end
        end
    end           
end

%%%need to save absolute time of onset
%%%save a guide
%%%save 