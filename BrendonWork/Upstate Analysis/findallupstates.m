function allupstates=findallupstates(abfnotes,evaluated);

%Takes inputs from "evalwhich" and "readnotesabf".
%abfnotes is used because it contains names of files to be evaluated and
%the names contained therein are used as text to open files... IF the
%current directory of MATLAB is pointed to the folder with all of the .mat
%files with data.
%Each of the traces (many traces can be in each file) that was nominated to
%be evaluated (done in "evalwhich" program, which generated "evaluated") is
%opened and upstates are automatically detected with the function
%"findupstates".  All upstate data are stored in the cell array
%"allupstates".




for a=1:size(evaluated,1);%for each slice
    for b=1:size(evaluated,2);%for each possible recording file taken from that slice
        if sum(evaluated(a,b,:),3)>0;%if any reading in this trace is to be evaluated
            a
            b
            name1=abfnotes{a}.abfname{b};%get name of the electrophys recording to open from the abfnotes cell
            load(name1);%load data from that file into the workspace... this will have multiple traces in it as columns of the variable "data"
            channels=channelnames(header);
            for c=1:size(evaluated,3);%for each possible trace in that file
                if evaluated(a,b,c)==1;%if that trace is to be evaluated
                    reading=data(:,c);
                    a
                    b
                    c
                    disp (name1)
                    if strcmp(channels(c),'IN 5') | strcmp(channels(c),'IN 11');
                        w=1;
                    elseif strcmp(channels(c),'IN 10') | strcmp(channels(c),'IN 7');
                        w=2
                    elseif strcmp(channels(c),'IN 14')| strcmp(channels(c),'IN 15');
                        w=3;
                    end
                    allupstates{a,b,w}=findupstates(reading);%put the indices indicating beginning and end, start of rise and end off fall for upstates into a cell array
                end
			end
            clear data header labels comments;%memory management 
        end
    end
end