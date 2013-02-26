function expnotes=CombineSortedUprecords(sorted,uprecords);
%This function is designed to create a single notes file from the movie
%notes structure (sorted) and the electrophysiology notes structure (uprecords).
%All movie-related info (ie moviename) will come preferentially from sorted and
%ephys-related info will come preferentially from uprecords.  Other
%conflicts will be presented to the user for manual decision making and
%resolution.
% Sorted was created by... .  
%     0)each slice (field of view) gets a name: 9 digit date, ie 123105n20
%         for the second slice on December 31, 2005.  This will be called
%         "name"
%     1)combine and align all movies from a particular field of view (slice)
%         This will become variable ['pixels',name] when read by "readtifstack"
%     2)enhance that image (using) imageJ
%         This will become variable ['image',name] when read by "imread"
%     3)find contours using "findfrommatrix" on that enhanced image
%         This will become variable ['conts',name]
%     4)save a vector of the lengths of the original movies in frames
%         This will become variable ['lengths',name]
%     5) get notes, only keeping the notes with movies and that are good:
%         a) rawnotes=readnotebook('filename')
%         b) notes=reshapenotes(notes,keepers),with keepers being the ones 
%             to be kept
%         This will become variable ['notes',name]
%     6)save these 5 variables into a matfile called [name,'uptoons']
%     7)use doonseachmovie2 to go through a directory of these to find the 
%         firing events using epimovies
%         This will become variable ['ons',name] and will be saved into a new
%         .mat file.
%     8) go through this directory of new files with moviecell=makemoviecell
%     9) sorted=interpretmovie(moviecell)
%Uprecords was created piecemeal using :
%     for a=1:NumberOfSliceNotes;abfnotes{a}=readnotesabf(dir(a));end;
%     [evaluated]=evalwhich(abfnotes);
%     upstates=findallupstates(abfnotes,evaluated);
%     uptraces=saveupstatetraces(upstates,abfnotes);
%     uprecords=rmfield(uptraces,'traces');

%use uprecords as primary... find matching slice in sorted somehow??
%then put in movie values
%then look for conflicts and resolve either auto or manually

%%
matches=[];
%get names of all movies specified in uprecords
for a=1:size(uprecords,1);%for each slice
    disp(a)
    uprmovnames=[];
    for c=1:size(uprecords,3);%for each cell
        for b=1:size(uprecords,2);%for each trial
            temp=uprecords(a,b,c,1).moviename;
            if ~isempty(temp);%if a moviename
                if length(uprmovnames)==0;%if this is the first moviename
                    uprmovnames{end+1}=uprecords(a,b,c,1).moviename;
                else
                    trash=strmatch(temp,uprmovnames,'exact');
                    if isempty(trash)
                        uprmovnames{end+1}=temp;
                    end
                end
            end
        end
    end
% get all names of movies in each slice in sorted
    sortedcatnames={'tstrain';'tssingle';'look';'wdsingle';'wdtrain';'wdnostim'};
    for a2=1:length(sorted);
        for b2=1:length(sortedcatnames);
            scn=sortedcatnames{b2};
            temp=eval(['sorted{a2}.',scn]);%store a struct with that class of stims
            for c2=1:length(temp);%for each stim in that struct
                trash=strmatch(temp(c2).moviename,uprmovnames,'exact');%see if a movie name specified there matches the names in uprecords
                %see if a movie name specified there matches the names in
                %uprecords
                if ~isempty(trash);%if a match
                    temp2=[a a2];
                    if length(matches)==0;
                        matches(end+1,:)=temp2;
                    else
                        trash=logical(matches-repmat(temp2,[size(matches,1) 1]));%look for matches to temp in "matches"
                        trash=~(sum(trash,2));
                        if ~sum(trash);%if not any
                            matches(end+1,:)=temp2;%record the number of the sorted record that matched as a new matching pair
                        end
                    end
                end
            end
        end
    end
end
expnotes=matches;