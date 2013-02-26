function matnotes=ReadAllNotes2(varargin);
% function matnotes=readnotesabf(varargin);
%%% NOTE!!!
%%% This version ("2") removes all assumptions that were made when doing
%%% experiments with Jason... no abf files... different folder structure...
%%% different cell classification structure... BUT SAME MATNOTES
% May or may not enter pre-existing matnotes.

% matnotes.trial.ephys.cell.alivecell = [] if no patch, 0 if dead, 1 if
% alive

%% make sure we are dealing with the correct directory, then get and sort
%% file names
charcell = {'C:\Exchange\Data\Notebook Entries\Notes for Matlab' ...
    'C:\Exchange\J&B Project\Notebook Entries\Notes for Matlab' ...
    'E:\Abeles Data Folder\Notebook Entries\Notes for Matlab'};
dirname = findoutdirectory('Choose the folder containing the notes to be imported',charcell);
temp=cd;%store the current directory... we'll reset it later
if dirname==0;
    return;
end
di=getdir(dirname);
for a=1:length(di);%eliminate listings specifying folders or non-.xls files
    if di(a).isdir  | ~strcmpi(di(a).name(end-3:end),'.xls') | ~isempty(strfind(di(a).name,'Template'));
        di(a)=[];
    end
end

%% get directory for ephys files
charcell = {'C:\Exchange\Data\Axon Data' ...
    'C:\Exchange\J&B Project\Axon Data' ...
    'E:\Abeles Data Folder\Axon Data'};
ephysdirname = findoutdirectory('Choose the folder containing .abf files',charcell);
if ephysdirname==0;
    return;
end

%% Questions for user about how completely to run this program
ListString={};
for a=1:length(di);
    ListString{a}=di(a).name;
end
[Selection,ok] = listdlg('ListString',ListString,...
    'SelectionMode','multiple',...
    'InitialValue',1:length(ListString),...
    'PromptString','Choose Files to Deal With',...
    'Name','Choose Files');
if ok==0
    return
end
FilesToDealWith = {};
for a=length(di):-1:1;%keep only selected filenames
    if isempty(find(Selection==a));
        di(a)=[];
    else
        FilesToDealWith{end+1}=di(a).name;
    end
end

lookup = {'basicephys',...%corresponds with choices given in selection box below... use this to correlate with list dialog output
    'autoups',...
    'manualreviewups',...
    'classifycells',...
    'analyzemovies'};    
ListString = {'Basic Electrophys Analysis',...
    'Automatic UP state Detection',...
    'Manual UP state verification',...
    'Classify Cells',...
    'Analyze movies'};
[Selection,ok] = listdlg('ListString',ListString,...
    'SelectionMode','multiple',...
    'InitialValue',1:length(ListString),...
    'PromptString','What analyses would you like to do?',...
    'Name','Choose Analyses');
if ok==0
    return
end
for a = 1:size(lookup,2);%create variables with 1 or 0 depending on choices above
    if isempty(find(Selection == a))%if that option not chosen
        eval([lookup{a},'=0;']);
    else
        eval([lookup{a},'=1;']);
    end
end
if autoups == 1;
    basicephys = 1;
end

FilesToRead={};
%% Find files to be imported that have already been imported
if nargin;%if a matnotes entered as input
    matnotes=varargin{1};
    matlen=length(matnotes);
    for a=1:length(matnotes);%build a library of the slices already read in
        alreadyin{a}=matnotes(a).name;
    end
    for a=1:length(di);%which files in the directory are already in matnotes
        overlappers(a)=~isempty(strmatch(di(a).name,alreadyin,'exact'));
    end
    if sum(overlappers)%if not all were new
        button = questdlg('Some files in this folder are alredy in matlab.  Do you want overwrite matlab records of those files?',...
            'Check for changes?','No','Yes, for all files','Yes, for a few files','No');
        if strcmpi(button,'');
            return
        end
        if ~strcmp(button,'No');
            switch button
                case 'Yes, for all files'
                    toscan=find(overlappers);
                case 'Yes, for a few files'
                    temp=find(overlappers);
                    ListString={};
                    for a=1:length(temp);
                        ListString{a}=di(temp(a)).name;
                    end
                    [Selection,ok] = listdlg('ListString',ListString,...
                        'SelectionMode','multiple',...
                        'InitialValue',[],...
                        'PromptString','Choose Files to Scan for Changes',...
                        'Name','Choose Files');
                    if ok==0
                        return
                    end
                    toscan=temp(Selection);
            end
            if length(toscan)>0;
                button=questdlg('Scan Selected files for only cell-class changes?  And not for all changes?','Cell Class Only?','No');
                if strcmpi(button,'Yes');%if just reading for
                    for a=1:length(toscan);%just reading for cell class correction... no other changes (no analysis status changes)
                        temp=strmatch(di(toscan(a)).name,alreadyin,'exact');%find address in the matrix
                        matnotes(temp)=ReadJustCellClass(dirname,di(toscan(a)).name,matnotes(temp));
                    end                    
                else%if really reading in
                    for a=1:length(toscan);%just reading for correction, not analysis (all analysis status are set to 0 now)
                        temp=strmatch(di(toscan(a)).name,alreadyin,'exact');%find address in the matrix
                        matnotes(temp)=ReadAllNotesKernel(dirname,di(toscan(a)).name);
                    end
                end
            end
        end
        
        temp=find(~overlappers);%now will read files that were not in matnotes before
        for a=1:length(temp);
            FilesToRead{a}=di(temp(a)).name;
        end
    end
else%if no matfiles input given
    for a=1:length(di);%will read in all files in the folder
        FilesToRead{a}=di(a).name;
    end
    matlen=0;
end

%% For reading in new... never read-in files
for a=1:length(FilesToRead);%for each file to be read... assigned above
    ind=matlen+a;
    filename=FilesToRead{a};
    matnotes(ind)=ReadAllNotesKernel(dirname,filename);
    if basicephys
        button = questdlg(['Analyze Ephys for slice ',FilesToRead{a},'?']);
        if strcmpi(button,'yes');
            matnotes(ind)=AnalyzeSliceEphys(matnotes(ind),autoups,ephysdirname);
            matnotes(ind).EphysAnalyzed=1;%if everything goes well, mark ephys analyzed
            matnotes(ind).UpsAutoAnalyzed=autoups;%if everything goes well, mark upstates detected
            if manualreviewups;
                [matnotes(ind),thismanualreviewephys]=ManualReviewSliceEphys(matnotes(ind),ephysdirname,manualreviewups);
                matnotes(ind).EphysManualReviewed=thismanualreviewephys;
            end
        end
    end
%     if analyzemovies
%         button = questdlg(['Analyze Movies for slice ',FilesToRead{a},'?']);
%         if strcmpi(button,'yes');
%             %GET DIRECTORY FOR EACH SLICE?
%             matnotes(ind)=AnalyzeSliceMovies(matnotes(ind),moviesdirname);
%             matnotes(ind).MoviesAnalyzed=1;
%         end
%     end
end

%% Looking through old data which might not have been completely analyzed
%look for stuff which needs to have automatic analysis of it's ephys
%records
if basicephys%if in ephys analysis mode
    needsanalysisnames={};%for basic ephys analysis
    needsanalysisnumbers=[];
    for a=1:length(matnotes);
        if isempty(strmatch(matnotes(a).name,FilesToRead));%if not just read and asked about      
            if matnotes(a).EphysFilesAvailable
                if autoups==0
                    if ~matnotes(a).EphysAnalyzed%analyze ephys if it hasn't been yet
                        needsanalysisnames{end+1}=matnotes(a).name;
                        needsanalysisnumbers(end+1)=a;
                    end
                else
                    if ~matnotes(a).EphysAnalyzed | ~matnotes(a).UpsAutoAnalyzed%analyze ephys and ups if either haven't been done
                        needsanalysisnames{end+1}=matnotes(a).name;
                        needsanalysisnumbers(end+1)=a;
                    end
                end
            end
        end
    end
    if ~isempty(needsanalysisnames);
        [Selection,ok] = listdlg('ListString',needsanalysisnames,...
            'SelectionMode','multiple',...
            'InitialValue',1,...
            'PromptString','Choose Earlier Slices to Analyze Ephys for.',...
            'Name','Ephys Analysis');
        if ok~=0
            needsanalysisnames=needsanalysisnames(Selection);
            needsanalysisnumbers=needsanalysisnumbers(Selection);
            for a=1:length(needsanalysisnumbers);
                temp=needsanalysisnumbers(a);
                matnotes(temp)=AnalyzeSliceEphys(matnotes(temp),autoups,ephysdirname);%even if just autoups is necessary, do everything over again
                matnotes(temp).EphysAnalyzed=1;
                matnotes(temp).UpsAutoAnalyzed=autoups;%if everything goes well, mark upstates detected
            end
        end
    end
end

%% Classifying each cell
% if classifycells
%     %key for inXcell.SpikesEvaluted 
%         %0 = never looked at
%         %1 = looked at and traces picked
%         %Nan = nothing to look at
%         %3 = looked at and nothing picked out (3 chosen b/c of chosing
%             %which slices to ask about for the future (needsanalysisnames)
%     
%     charcell = {'C:\Exchange\Data\ppt files' ...
%         'E:\Abeles Data Folder\ppt files'};
%     pptdir = findoutdirectory('Find directory containing ppt files',charcell);
%     charcell = {'C:\Exchange\Data\Cells\Image Files\20X Photos' ...
%         'E:\Abeles Data Folder\Cells\20X Photos'};
%     x20dir = findoutdirectory('Find directory containing 20X pic files',charcell);
%     if ~ischar(pptdir) ~ischar(x20dir)
%         return
%     end
%     needsanalysisnames = {};
%     needsanalysisslicenums = [];
%     needsanalysiscellnums = [];
%     for a = 1:length(matnotes);
%         if ~isempty(strmatch(matnotes(a).name,FilesToDealWith));%If within the set nominated to be dealt with at all           
%             evalslice = 0;
%             allchannelnames = matnotes(a).CellOrder.CellChannels;
%             cellfields = matnotes(a).CellOrder.CellFieldNames;
%             for cidx = 1:size(cellfields,2)
%                 eval(['temporary1 = matnotes(a).',cellfields{cidx},'.SpikesEvaluated;']);
%                 eval(['temporary2 = matnotes(a).',cellfields{cidx},'.MorphologyEvaluated;']);
%                 eval(['temporary3 = matnotes(a).',cellfields{cidx},'.FinalClassEvaluated;']);
%                 temp = temporary1 + temporary2 + temporary3;%see if even one is not filled in as 1
%                 if ~isnan(temp) & temp ~= 3%if anything is yet unclassified (written this way to allow for NaN)
%                     evalslice = 1;
%                     break
%                 end
%             end
%             if evalslice == 1;
%                 needsanalysisnames{end+1} = matnotes(a).name(1:end-4);
%                 needsanalysisslicenums(end+1) = a;
%     %             needsanalysiscellnums(end+1) = cidx;
%             end
%         end
%     end
%     [Selection,ok] = listdlg('ListString',needsanalysisnames,...
%             'SelectionMode','multiple',...
%             'InitialValue',1:length(needsanalysisnames),...
%             'PromptString','Choose Slices to Classify Cells For.',...
%             'Name','Cell Classification');    
%     missing = 1:length(needsanalysisnames);
%     missing = setdiff(missing, Selection);
% %     needsanalysisnames(missing) = [];
%     needsanalysisslicenums(missing) = [];
% %     needsanalysiscellnums(missing) = [];
% 
%     for a = needsanalysisslicenums%for each slice
% %         cidx = needsanalysiscellnums(idx);
%         allchannelnames = matnotes(a).CellOrder.CellChannels;
%         cellfields = matnotes(a).CellOrder.CellFieldNames;
%         cellsspikesevaluated = zeros(1,length(cellfields));%for later to keep track of which cells had spikes evaluated
%         CNs = 1:size(cellfields,2);
% %         ACs = find(matnotes(a).alivecells);
% %         if matnotes(a).alivecells(cidx);%if the specified cell was alive
% %         for cidx = ACs;%go thru each alive cell
%         for cidx = CNs;%go thru each alive cell
%             eval(['temp = matnotes(a).',cellfields{cidx},'.SpikesEvaluated;']);
%             if temp == 0;%if spikes specifically have not been evaluated... eval them
%                 filestoreview = {};
%                 for b = 1:length(matnotes(a).trial);%for each trial
%                     if isfield(matnotes(a).trial(b).ephys,'cell');%if there were cells in that trial
% %                         if ~isempty(matnotes(a).trial(b).ephys.cell(cidx).alivecell)%see if this cell was recorded
%                             cellname = matnotes(a).trial(b).ephys.cell(cidx).name;
%                             temp = strmatch(cellname,matnotes(a).trial(b).ephys.channels);
%                             if ~isempty(temp);%if this cell is in the file
%                                 otherchannelnames = allchannelnames;
%                                 match = strmatch(cellname,allchannelnames);
%                                 otherchannelnames(match) = [];%a list of all other cell names
%                                 match = 0;
%                                 for idx = 1:length(otherchannelnames);
%                                     temp = strmatch(otherchannelnames{idx},matnotes(a).trial(b).ephys.channels);
%                                     if ~isempty(temp);
%                                         match = match+1;
%                                     end
%                                 end
%                                 if match == 0;%if only one cell recorded...
%                                     %open file, check dimensionality of
%                                     %data
%                                     [data,trash,channels]=abfload([ephysdirname,'\',matnotes(a).trial(b).abfname]);
%                                     if length(size(data)) == 3;%if 3D... we have a "PIR" file
%                                         filestoreview{end+1} = [matnotes(a).trial(b).abfname];
%                                     end
%                                 end
%                             end
% %                         end
%                     end
%                 end
%                 [records,quantification,interpretation] = ViewCellSpikeTrains(ephysdirname,filestoreview);
%                 eval(['matnotes(a).',cellfields{cidx},'.SpikePatternRecords = records;']);
%                 eval(['matnotes(a).',cellfields{cidx},'.SpikePatternQuantification = quantification;']);
%                 eval(['matnotes(a).',cellfields{cidx},'.SpikePatternInterpretation = interpretation;']);
%                 eval(['matnotes(a).',cellfields{cidx},'.SpikesEvaluated = 1;']);
%             end
%             eval(['temp = matnotes(a).',cellfields{cidx},'.SpikesEvaluated;']);%even if not evaluated this time...
%             if temp == 0;%if not evaluated
%                 eval(['matnotes(a).',cellfields{cidx},'.SpikesEvaluated = NaN;']);%name as null... ie not evaluatable
%             end
%             if temp == 1;%if was evaluated - ever - and records were chosen to go on with
%                 eval(['temporary2 = matnotes(a).',cellfields{cidx},'.SpikePatternRecords;']);
%                 if ~isempty(temporary2)
%                     cellsspikesevaluated(cidx) = 1;%note that this cell was successfully evaluated  
%                 else
%                     eval(['matnotes(a).',cellfields{cidx},'.SpikesEvaluated = 3;']);%means spikes were looked at but nothing came out
%                 end
%             end
%         end%finish cycling through cells, still in same slice
%         
% %% below is big gui for evaluating cell images and correlating them to
% %% ephys channels
%         if logical(sum(cellsspikesevaluated));%if any cells in this slice were spikes eval'ed
%             matnotes(a) = morphologyGUI(matnotes(a),cellsspikesevaluated,ephysdirname,pptdir,x20dir);
%         end
%     end
% end

%%
if manualreviewups
    needsanalysisnames={};
    needsanalysisnumbers=[];
    for a=1:length(matnotes);
        if isempty(strmatch(matnotes(a).name,FilesToRead));%if not just read and asked about            
             if matnotes(a).EphysAnalyzed;
                if ~matnotes(a).EphysManualReviewed%analyze ephys if it hasn't yet been imported
                    needsanalysisnames{end+1}=matnotes(a).name;
                    needsanalysisnumbers(end+1)=a;
                end
             end
        end
    end
    if ~isempty(needsanalysisnames);
        [Selection,ok] = listdlg('ListString',needsanalysisnames,...
            'SelectionMode','multiple',...
            'InitialValue',[1:length(ListString)],...
            'PromptString','Choose Ephys Manually Review.',...
            'Name','Manual Ephys Review');
        if ok~=0
            needsanalysisnames=needsanalysisnames(Selection);
            needsanalysisnumbers=needsanalysisnumbers(Selection);
            for a=1:length(needsanalysisnumbers);
                temp=needsanalysisnumbers(a);
                [matnotes(temp),thismanualreviewephys]=ManualReviewSliceEphys(matnotes(temp),ephysdirname,manualreviewups);
                matnotes(temp).EphysManualReviewed=thismanualreviewephys;%mark successful review, if there was one
            end
        end
    end
end

% if reviewmovies
%     needsanalysisnames={};
%     needsanalysisnumbers=[];
%     for a=1:length(matnotes);
%         if reviewephys%if in ephys analysis mode
%             if isempty(strmatch(matnotes(a).name,FilesToRead));%if not just read and asked about            
%                 if ~matnotes(a).MoviesAnalyzed%analyze ephys if it hasn't
%                 yet been imported
%                     needsanalysisnames{end+1}=matnotes(a).name;
%                     needsanalysisnumbers(end+1)=a;
%                 end
%             end
%         end
%     end
%     if ~isempty(needsanalysisnames);
%         [Selection,ok] = listdlg('ListString',needsanalysisnames,...
%             'SelectionMode','multiple',...
%             'InitialValue',[],...
%             'PromptString','Choose already-imported slices whose movies should be analyzed.',...
%             'Name','Choose For Movie Analysis');
%         if ok==0
%             return
%         end
%         needsanalysisnames=needsanalysisnames(Selection);
%         needsanalysisnumbers=needsanalysisnumbers(Selection);
%         for a=1:length(needsanalysisnumbers);
%             temp=needsanalysisnumbers(a);
%             matnotes(temp)=AnalyzeSliceMovies(matnotes(temp),moviesdirname);
%             matnotes(temp).MoviesAnalyzed=1;
%         end
%     end
% end

%% for finding folders with certain files
function dirpath = findoutdirectory(questionstring,defaultcharcell)
trydir = cd;
for a = 1:length(defaultcharcell);
    if isdir(defaultcharcell{a});
        trydir = defaultcharcell{a};
        break
    end
end
dirpath=uigetdir(trydir,questionstring);

%% Read basic info from .xls file
function slicenotes=ReadAllNotesKernel(dirname,filename);
%Reads a file, and puts .xls entries into a matlab structure

warning off

[num,text]=xlsread([dirname,'\',filename]);
if strcmpi(text(1,1),'Ephys File') & strcmpi(text(1,2),'Protocol')
    text(1,:)=[];%% general xls quality checks:
end

% make sure excel file itself was formatted as we need it
if ~isempty(num);
    disp (['The Excel file ',filename,' incorrectly formatted.  Highlight all of file and put... all cells in "Text" format.'])
    disp ('Next go to every cell which has just a number in it, highlight the text and hit the ENTER key ON THE KEYBOARD section, not the numberpad ENTER');
    disp ('This will fix this class of problem')
    error ('stop')
end
%if no abfs recorded, all column one may not be in "text"...test for that 
for b=1:size(text,1);%for each row
    numtest(b)=isempty(num2str(text{b,1}));
    strtest(b)=strcmp(lower(text{b,1}),'ts') | ...
        strcmp(lower(text{b,1}),'tc') | ...
        strcmp(lower(text{b,1}),'wd') | ...
        strcmp(lower(text{b,1}),'scope');% | ...
%         strcmp(lower(text{b,1}(1:3)),'PIR') | ...
%         strcmp(lower(text{b,1}(1:4)),'TRIG');
end
numtest=double(numtest);
if prod(numtest) & sum(strtest)%if none of them were numeric 
        %and at least one matched the known experiment type-specifying strings
    text=[repmat({''},size(text,1),1),text];%add on a column of blank text
        %boxes for the abfnames
end
%to make sure only rows with real info are taken... not just cell id info
for a=1:size(text,1);
    for b=1:size(text,2);
        guide(a,b)=~isempty(text{a,b});
    end
end
guide=logical(sum(guide(:,1:3),2));%find rows that had either a .abf name, 
    %moviename or a protocol entry
guide=find(guide);

%% Record notes information into slicenotes structure
slicenotes.name=filename;
slicenotes.age=text{3,13};%
slicenotes.gender=text{2,15};
slicenotes.temperature=text{2,16};
slicenotes.loading=text{3,15};
slicenotes.weight=text{2,18};%
slicenotes.thickness=text{2,19};%
if size(text,2)>=21;
    slicenotes.other=text{2,21};
else
    slicenotes.other='';
end
slicenotes.CellOrder.CellChannels = {'IN 5' 'IN 10' 'IN 14' 'IN 8'};%get these from xls?
channelnames = slicenotes.CellOrder.CellChannels;
for cidx = 1:length(channelnames)%get names for fields from above
    slicenotes.CellOrder.CellFieldNames{cidx} = strcat(lower(elimspaces(channelnames{cidx})),'cell');
end
cellfields = slicenotes.CellOrder.CellFieldNames;
for cidx = 1:length(cellfields);
    if size(text,1)>=8;
        eval(['slicenotes.',cellfields{cidx},'.InitialInterpretation=text{',num2str(4+cidx),',13};']);
    else
        eval(['slicenotes.',cellfields{cidx},'.InitialInterpretation=[];']);
    end
    eval(['slicenotes.',cellfields{cidx},'.SpikesEvaluated=0;']);
    eval(['slicenotes.',cellfields{cidx},'.MorphologyEvaluated=0;']);
    eval(['slicenotes.',cellfields{cidx},'.FinalClassEvaluated=0;']);
    eval(['slicenotes.',cellfields{cidx},'.SpikePatternRecords=[];']);
    eval(['slicenotes.',cellfields{cidx},'.SpikePatternQuantification=[];']);
    eval(['slicenotes.',cellfields{cidx},'.SpikePatternInterpretation=[];']);
    eval(['slicenotes.',cellfields{cidx},'.X20Photo=[];']);
    eval(['slicenotes.',cellfields{cidx},'.X60Photo=[];']);
    eval(['slicenotes.',cellfields{cidx},'.BestPhoto=[];']);
    eval(['slicenotes.',cellfields{cidx},'.BestPhotoFrom=[];']);
    eval(['slicenotes.',cellfields{cidx},'.PipettePhoto=[];']);    
    eval(['slicenotes.',cellfields{cidx},'.X20Coordinates=[];']);
    eval(['slicenotes.',cellfields{cidx},'.X60Coordinates=[];']);
    eval(['slicenotes.',cellfields{cidx},'.BestCoordinates=[];']);
    eval(['slicenotes.',cellfields{cidx},'.PipetteCoordinates=[];']);    
    eval(['slicenotes.',cellfields{cidx},'.Reconstruction=[];']);
    eval(['slicenotes.',cellfields{cidx},'.MorphologyInterpretation=[];']);
    eval(['slicenotes.',cellfields{cidx},'.OverallInterpretation=[];']);
end
slicenotes.EphysFilesAvailable=1;%default assumption is abfs are present
if size(text,1)>=9;
    temp=text{9,13};
    if strcmpi(temp,'No') |strcmpi(temp,'n') | strcmpi(num2str(temp),0);
        slicenotes.EphysFilesAvailable=0;
    end
end
slicenotes.MovieFilesAvailable=1;%default assumption is no are present
if size(text,1)>=10;
    temp=text{10,13};
    if strcmpi(temp,'No') |strcmpi(temp,'n') | strcmpi(num2str(temp),0);
        slicenotes.MovieFilesAvailable=0;
    end
end

for b=1:length(guide);%for each trial
    slicenotes.trial(b).moviename=text{guide(b),3};
    slicenotes.trial(b).movies.moviename=text{guide(b),3};
    %initiate other ...movies. and ...ephys. fields here
    slicenotes.trial(b).abfname=text{guide(b),1};
    slicenotes.trial(b).ephys.abfname=text{guide(b),1};
    slicenotes.trial(b).stimprotocol=text{guide(b),2};
    slicenotes.trial(b).stimnum=text{guide(b),4};%
    slicenotes.trial(b).stimfreq=text{guide(b),5};%
    slicenotes.trial(b).stimamp=text{guide(b),6};%
    slicenotes.trial(b).timesincelast=text{guide(b),7};%
    slicenotes.trial(b).otherdescrip=text{guide(b),8};
    slicenotes.trial(b).observation=text{guide(b),9};
    slicenotes.trial(b).m8delay=text{guide(b),11};
    if size(text,2)==26;%looking for manually-entered in6 times
        slicenotes.trial(b).ephys.in6=str2num(text{guide(b),26});
    else
        slicenotes.trial(b).ephys.in6=[];        
    end
    slicenotes.trial(b).stim=[];
    if strcmpi(slicenotes.trial(b).stimprotocol,'tc');%if Thalamic Stimulation protocol and mislabeled as TC by mistake
        slicenotes.trial(b).stimprotocol='ts';%correct differently-entered note entries
    end
    if strcmpi(slicenotes.trial(b).stimprotocol,'ts');%if Thalamic Stimulation protocol and...
        if strcmp(slicenotes.trial(b).stimnum,'1');%if single stim given
            slicenotes.trial(b).stim='tssingle';%call it tssingle
        elseif ~isempty(slicenotes.trial(b).stimnum) & ~isempty(str2num(slicenotes.trial(b).stimnum));%or if is a number other than one
            slicenotes.trial(b).stim='tstrain';%call it tstrain
        end
    end
    if strcmpi(slicenotes.trial(b).stimprotocol,'gm');%if Thalamic Stimulation protocol and...
        if strcmp(slicenotes.trial(b).stimnum,'1');%if single stim given
            slicenotes.trial(b).stim='graysingle';%call it tssingle
        elseif ~isempty(slicenotes.trial(b).stimnum) & ~isempty(str2num(slicenotes.trial(b).stimnum));%or if is a number other than one
            slicenotes.trial(b).stim='graytrain';%call it tstrain
        end
    end
    if strcmpi(slicenotes.trial(b).stimprotocol,'wd') | strcmpi(slicenotes.trial(b).stimprotocol,'scope') | strcmpi(slicenotes.trial(b).stimprotocol,'look') | strcmpi(slicenotes.trial(b).stimprotocol,'spont');
            %if Window Discriminator protocol and...
        if strcmp(slicenotes.trial(b).stimnum,'1');%if single stim given
            slicenotes.trial(b).stim='wdsingle';%call it wdsingle
        elseif ~isempty(slicenotes.trial(b).stimnum) & ~isempty(str2num(slicenotes.trial(b).stimnum));%or if is a number other than one
            slicenotes.trial(b).stim='wdtrain';%call it wdtrain
        else%or if neither of the above
            slicenotes.trial(b).stim='spont';%call its spont
        end
    end
end
%% Correct for any slice where gray matter was stimulated (instead of Thalamus)
gmthisslice = 0;%check for any gray matter stim in a slice...
for tidx = 1:size(slicenotes.trial,2);
    if strcmpi(slicenotes.trial(tidx).stimprotocol,'gm')
        gmthisslice = 1;
    end
end
if gmthisslice == 1;%if was some, set all stimulus-type protocol names to gray matter versions
    for tidx = 1:size(slicenotes.trial,2);
        if strcmpi(slicenotes.trial(tidx).stim,'tstrain')
                slicenotes.trial(tidx).stim='graytrain';
        elseif strcmpi(slicenotes.trial(tidx).stim,'tssingle')
                slicenotes.trial(tidx).stim='graysingle';
        elseif strcmpi(slicenotes.trial(tidx).stim,'wdtrain')
                slicenotes.trial(tidx).stim='wdgraytrain';
        elseif strcmpi(slicenotes.trial(tidx).stim,'wdsingle')
                slicenotes.trial(tidx).stim='wdgraysingle';
        end
    end
end
%% initiating all other fields... important
slicenotes.alivecells=zeros(1,4);
slicenotes.spikingcells=zeros(1,4);
slicenotes.upstatecells=zeros(1,4);
slicenotes.corecells=zeros(1,4);
slicenotes.EphysAnalyzed=0;
slicenotes.EphysManualReviewed=0;
slicenotes.UpsAutoAnalyzed=0;
slicenotes.MoviesAnalyzed=0;

%% Read just cell class info from .xls file
function slicenotes=ReadJustCellClass(dirname,filename,slicenotes);
%Reads a file, and puts .xls entries into a matlab structure

warning off

[num,text]=xlsread([dirname,'\',filename]);
if strcmpi(text(1,1),'Ephys File') & strcmpi(text(1,2),'Protocol')
    text(1,:)=[];%% general xls quality checks:
end
% make sure excel file itself was formatted as we need it
if ~isempty(num);
    disp (['The Excel file ',filename,' incorrectly formatted.  Highlight all of file and put... all cells in "Text" format.'])
    disp ('Next go to every cell which has just a number in it, highlight the text and hit the ENTER key ON THE KEYBOARD section, not the numberpad ENTER');
    disp ('This will fix this class of problem')
    error ('stop')
end
%if no abfs recorded, all column one may not be in "text"...test for that 
for b=1:size(text,1);%for each row
    numtest(b)=isempty(num2str(text{b,1}));
    strtest(b)=strcmp(lower(text{b,1}),'ts') | ...
        strcmp(lower(text{b,1}),'tc') | ...
        strcmp(lower(text{b,1}),'wd') | ...
        strcmp(lower(text{b,1}),'scope');% | ...
%         strcmp(lower(text{b,1}(1:3)),'PIR') | ...
%         strcmp(lower(text{b,1}(1:4)),'TRIG');
end
numtest=double(numtest);
if prod(numtest) & sum(strtest)%if none of them were numeric 
        %and at least one matched the known experiment type-specifying strings
    text=[repmat({''},size(text,1),1),text];%add on a column of blank text
        %boxes for the abfnames
end
%% functional step
cellfields = slicenotes.CellOrder.CellFieldNames;
if size(text,1)>=8;
    for cidx = 1:length(cellfields);
        eval(['slicenotes.',cellfields{cidx},'.InitialInterpretation=text{',num2str(4+cidx),',13};']);
    end
else
    disp(['No cell class info available for slice ',slicenotes.name,'.'])
end


%% Analyze info in .abf file specified for each trial
function slicenotes=AnalyzeSliceEphys(slicenotes,autoups,dirname)
% Detects action potentials, upstates and stimulus times(in6) in ephys records

waithandle = waitbar(0,['Analyzing Electophysiology for Slice ',slicenotes.name],...
    'name',slicenotes.name);%for user
for a=1:length(slicenotes.trial);%for each trial
    slicenotes.trial(a).ephysupstate=0;%initiating field, default value
    if ~isempty(slicenotes.trial(a).abfname);%if there is an abf indicated there
        [data,trash,channels]=abfload([dirname,'\',slicenotes.trial(a).abfname]);%read file...
        slicenotes.trial(a).ephys.channels = channels;%for easier readout later
        findin6%a script using "channels" and "data"
        if ~(isempty(stims) & ~isempty(slicenotes.trial(a).ephys.in6))%fill in .in6
                %unless the in6 from the file is empty and .in6 already has a 
                %value (ie manually entered via the excel file)
            slicenotes.trial(a).ephys.in6=stims;
        end
% % % %reclassify .stim based on in6... (find errors, but also burst,
% % % %tonic, etc)... use separate trains a lot
        channelslist = slicenotes.CellOrder.CellChannels;
        slicenotes.trial(a).interactionstim = zeros(1,length(channelslist));%initiating field
        for b=1:length(channelslist);
            slicenotes.trial(a).ephys.cell(b).name=channelslist{b};
            cn=strmatch(channelslist{b},channels,'exact');
            if ~isempty(cn);
                if median(data(:,cn))<-85 | median(data(:,cn))>-55;
                    slicenotes.trial(a).ephys.cell(b).alivecell=0;
                    slicenotes.trial(a).ephys.cell(b).aps=[];%initiating field, default value
                    slicenotes.trial(a).ephys.cell(b).upstates=[];%initiating field, default value
                    slicenotes.trial(a).ephys.cell(b).interactiontype = '';%initiating field, default value
                else
                    slicenotes.trial(a).ephys.cell(b).alivecell=1;
                    slicenotes.alivecells(b)=(1);
                    slicenotes.trial(a).ephys.cell(b).aps=[];%initiating field, default value
                    slicenotes.trial(a).ephys.cell(b).upstates=[];%initiating field, default value
                    slicenotes.trial(a).ephys.cell(b).interactiontype = '';%initiating field, default value
                    if length(size(data))==2 & ~isempty(slicenotes.trial(a).stim);
                            %test if a multi-sweep dataset, and a classifiable
                            %trial
                        aps=findaps2(data(:,cn));%find aps    
                        slicenotes.trial(a).ephys.cell(b).aps=aps;
                        if ~isempty(aps);
                            slicenotes.spikingcells(b)=1;
                        end
                        if autoups;%if in auto upstate detection mode
                            potups=findupstates(data(:,cn));%find upstates
                            slicenotes.trial(a).ephys.cell(b).upstates=potups;
                        end
                    end
                end
            end
        end
    end
    waithandle = waitbar(a/length(slicenotes.trial),waithandle);
end

close(waithandle)

%% for looking at all spike patterns from each cell and picking good ones.
% function [records,quantification,interpretation] = ViewCellSpikeTrains(ephysdirname,filestoreview);
% 
% numfiles = size(filestoreview,2);
% if isempty (filestoreview);
%     records = [];
%     quantification = [];
%     interpretation = [];
% else
%     %first find out how many figs there will be and space them out
%     ss = get(0,'screensize');
%     ss = ss(3:4);
%     windowsize = [800 600];
%     lastleft = ss(1)-windowsize(1);
%     if numfiles == 1;
%         p1 = lastleft/2;
%     else
%         p1 = linspace(0,lastleft,numfiles);
%     end
%     p2 = repmat(ss(2)-windowsize(2)-50,[1 numfiles]);
%     p3 = repmat(windowsize(1),[1 numfiles]);
%     p4 = repmat(windowsize(2),[1 numfiles]);
%     for a = 1:numfiles;
%         [data,trash,channels]=abfload([ephysdirname,'\',filestoreview{a}]);
%         numsweeps = size(data,3);
%         d1 = sqrt(numsweeps);
%         d1 = ceil(d1);
%         if numsweeps <= d1*(d1-1);
%             d2 = d1;
%         else
%             d2 = d1+1;
%         end
%         spidx = 1:(d1*d2);
%         spidx(d2*(1:d1)) = [];
%         
%         handles{a}.figure = figure('tag',num2str(a),...
%             'CloseRequestFcn','',...%don't let them close all are ready
%             'position',[p1(a) p2(a) p3(a) p4(a)],...
%             'ToolBar', 'figure',...
%             'MenuBar','none',...
%             'NumberTitle','off',...
%             'Name',filestoreview{a});
%         
%         for b = 1:numsweeps;
%             handles{a}.axes(b) = subplot(d1,d2,spidx(b));
% %             set(handles{a}.axes(b),'tag',num2str(b),...
% %                 'hittest','on',...
% %                 'ButtonDownFcn',@LocalSpikeSelectFcn)
%             plot(data(:,:,b));
%             ylim([-150 50]);
%             xlim([0 size(data,1)]);
%             title(num2str(b),'color','r');
%             temp(b,:) = get(handles{a}.axes(b),'position');
%         end
%         rightlim = max(temp(:,1)+temp(1,3));
%         rightlim = .2*(1-rightlim)+rightlim; 
%         figpixels = get(handles{a}.figure,'position');
%         figwidthpixels = figpixels(3);
%         figheightpixels = figpixels(4);
% 
%         rightlimpixels = figwidthpixels*rightlim;
%         heightpixels = figheightpixels*.9;
%         widthpixels = (1-rightlim) * figwidthpixels;
% 
%         for b = 1:numsweeps;
%             sp1 = rightlimpixels;
%             sp2 = heightpixels - 15*(b-1);
%             sp3 = widthpixels;
%             sp4 = 15;
%             handles{a}.rads(b) = uicontrol('parent',handles{a}.figure,'style','radiobutton',...
%                 'position',[sp1 sp2 sp3 sp4],...
%                 'string',strcat('Sweep ',num2str(b)),...
%                 'BackgroundColor',[.8 .8 .8],...
%                 'Tag',num2str(b),...
%                 'Callback',@LocalSpikeSelectFcn);
%         end
%         set(handles{a}.rads,'units','normalized');%so buttons move properly with figure;
%         %quantify: spike rate, adaptation (ratio betw 1st ISI and 2nd ISI or 1st and
%         %   Last), resistance, ahp, rheobase, etc etc... 
%         %display quantification somehow
% 
%         setappdata(handles{a}.figure,'firstfig',handles{1}.figure);%each figure has a reference to the first figure, where all the data is
%     end
%     finisherfigure = figure('position',[lastleft/2 p2(1)-75 windowsize(1) 5],...
%         'numbertitle','off',...
%         'name','Close to Finish Chosing Spike Patterns',...
%         'menubar','none');
%     setappdata(finisherfigure,'firstfig',handles{1}.figure);
%     guidata(handles{1}.figure,handles);%main data in first figure
%     uiwait(finisherfigure);%wait for finisherfigure to close
% 
%     %no central dataset, just from ui objects in figure
%     records = [];
%     for a = 1:size(handles,2);
%         for b = 1:size(handles{a}.rads,2)
%             if get(handles{a}.rads(b),'value')
%                 records(end+1).file = filestoreview{a};
%                 records(end).sweep = b;
%             end
%         end
%         delete(handles{a}.figure);
%     end
%     interpretation = inputdlg('Type interpretation of cell spiking patterns','Interpretation');
%     %use handles to go through all radio buttons...
%     %use fig
% 
%     quantification = [];
% end
% 
% function LocalSpikeSelectFcn(obj,ev);
% num = get(obj,'tag');
% num = str2num(num);
% thisfig = get(obj,'parent');
% firstfig = getappdata(thisfig,'firstfig');
% handles = guidata(firstfig);
% currcol = get(handles{thisfig}.axes(num),'color');
% if get(handles{thisfig}.rads(num),'value')
%     set(handles{thisfig}.axes(num),'color',[0 1 0]);
% else
%     set(handles{thisfig}.axes(num),'color',[1 1 1]);
% end

%% Below (cell) are for correlating morphology to previously found spike patterns
% function slicenotes = morphologyGUI(slicenotes,cellsspikesevaluated,ephysdirname,pptdir,x20dir);
% %takes notes for one slice and then 
% 
% warning off
% handles.cellcolors = [[1 0 0];[0 0 1];[0 1 0];[.8 0 1]];
% cellfields = slicenotes.CellOrder.CellFieldNames;
% pptimage = [];
% x20image = [];
% pptd = getdir(pptdir);
% match = [];
% for idx = 1:length(pptd)
%     temp = strfind(pptd(idx).name,slicenotes.name(1:end-4));
%     if ~isempty(temp);
%         match(end+1) = idx;
%     end
% end
% if length(match) > 1;
%     charcell = {};
%     for idx = match;
%         charcell{end+1}=pptd(idx).name;
%     end
%     prompt = ['Which ppt for ',slicenotes.name(1:end-4)];
%     [Selection,ok] = listdlg('ListString',charcell,...
%         'SelectionMode','single',...
%         'promptstring',prompt,...
%         'name','Pipette Images');
%     match = match(Selection);
% end
% if ~isempty(match);
%     temp = strcat(pptdir,'\',pptd(match).name);
%     pptimage = imread(temp,'tif');
% end
% 
% eval(['temp = slicenotes.',cellfields{1},'.X20Photo;']);
% if ~isempty(temp)%if already an X20 photo indicated
%     temp = strcat(x20dir,'\',temp);
%     x20image = imread(temp,'tif');
%     x20image = permute(x20image,[2 1 3]);
%     for cidx = 1:size(cellfields,2);
%         [pathstr, name, ext, versn] = fileparts(temp);
%         eval(['slicenotes.',cellfields{cidx},'.X20Photo = ''',name,ext,''';']);
%     end
% else%if no X20 photo, go find one
%     x20d = getdir(x20dir);
%     match = [];
%     for idx = 1:length(x20d)
%         temp = strfind(x20d(idx).name,slicenotes.name(1:end-4));
%         if ~isempty(temp);
%             match(end+1) = idx;
%         end
%     end
%     if length(match) > 1;
%         charcell = {};
%         for idx = match;
%             charcell{end+1}=x20d(idx).name;
%         end
%         prompt = ['Which 20X for ',slicenotes.name(1:end-4)];
%         [Selection,ok] = listdlg('ListString',charcell,...
%             'SelectionMode','single',...
%             'promptstring',prompt,...
%             'name','X20 Images');
%         match = match(Selection);
%     end
%     if ~isempty(match);
%         temp = strcat(x20dir,'\',x20d(match).name);
%         x20image = imread(temp,'tif');
%         x20image = permute(x20image,[2 1 3]);
%         for cidx = 1:size(cellfields,2);
%             [pathstr, name, ext, versn] = fileparts(temp);
%             eval(['slicenotes.',cellfields{cidx},'.X20Photo = ''',name,ext,''';']);
%         end
%     %     for idx = 1:size(x20image,3);
%     %         x20image(:,:,idx) = flipud(x20image(:,:,idx));%should be in correct orientation now.  Flipped and rotated
%     %     end
%     end
% end
% 
% screensize=get(0,'ScreenSize');
% screensize=screensize(3:4);
% taskbarheight=38;%pixels (true for all screens?)
% figtoolbarheight=55;%pixels (true for all screens?)
% vertpix=taskbarheight+figtoolbarheight;%to subtract from height of fig
% proportion=(screensize(2)-vertpix)/screensize(2);
% figpos = [5 taskbarheight screensize(1)*proportion screensize(2)-vertpix];
% 
% handles.figure = figure('units','pixels',...
%     'position',figpos,...
%     'ToolBar', 'figure', ...
%     'NumberTitle','off',...
%     'MenuBar','none',...
%     'Name',slicenotes.name,...
%     'CloseRequestFcn','');
% if ~isempty(x20image);
%     axsz = [256/figpos(3) (256*(4/3))/figpos(4)];
% %             axsz(1) = min([axsz(1) .25]);
% %             axsz(2) = min([axsz(2) .45]);
%     axsz(1) = .25;
%     axsz(2) = .45;
%     axpos = [1-axsz(1)-.05 1-axsz(2)-.05 axsz];
%     handles.x20axes = axes('parent',handles.figure,...
%         'units','normalized',...
%         'position',axpos,...
%         'box','off',...
%         'dataaspectratio',[1 1 1]);
%     handles.x20im = imagesc(x20image,'parent',handles.x20axes,...
%         'ButtonDownFcn',@X20ImButtonDown);
%     handles.EnlargeX20=uicontrol('style','pushbutton',...
%         'units','normalized',...
%         'parent',handles.figure,...
%         'position',[.7 .96 .09 .03],...
%         'string','Enlarge 20X',...
%         'Callback',@EnlargeX20Fcn);
% end
% if ~isempty(pptimage);            
%     axsz = [256/figpos(3) 256/figpos(4)];
% %             axsz(1) = min([axsz(1) .25]);
% %             axsz(2) = min([axsz(2) .33]);%
%     axsz(1) = .25;
%     axsz(2) = .33;
%     axpos = [1-axsz(1)-.05 .02 axsz];
%     handles.pptaxes = axes('parent',handles.figure,...
%         'units','normalized',...
%         'position',axpos,...
%         'box','off',...
%         'dataaspectratio',[1 1 1]);
%     handles.pptim = imagesc(pptimage,'parent',handles.pptaxes,...
%         'buttondownfcn',@PptImButtonDown);
%     colormap('gray')
%     handles.EnlargePpt=uicontrol('style','pushbutton',...
%         'units','normalized',...
%         'parent',handles.figure,...
%         'position',[.8 .96 .09 .03],...
%         'string','Enlarge Ppt',...
%         'Callback',@EnlargePptFcn);
% 
% end
% 
% uibgpos = [.7 .46 .28 .03];
% handles.cellbuttongroup = uibuttongroup('parent',handles.figure,...
%     'units','normalized',...
%     'position',uibgpos,...
%     'backgroundcolor',[.8 .8 .8],...
%     'SelectionChangeFcn',@MorphoGUIRadioCallback);
% for idx = 1:length(cellfields);
%     radpos = [0+((idx-1)*1/length(cellfields)) .1 1/length(cellfields) .8];
% %                 radpos = [.72+((idx-1)*uibgpos(3)/length(cellfields)) .465 uibgpos(3)/length(cellfields) .02];
%     handles.radio(idx) = uicontrol('style','radio',...
%         'parent',handles.cellbuttongroup,...
%         'units','normalized',...
%         'position',radpos,...
%         'backgroundcolor',[.8 .8 .8],...
%         'string',cellfields{idx},...
%         'foregroundcolor',handles.cellcolors(idx,:),...
%         'tag',num2str(idx));
% end
% handles.allspikestitle = uicontrol('style','text',...
%     'parent',handles.figure,...
%     'units','normalized',...
%     'position',[.7 .425 .1 .02],...
%     'backgroundcolor',[.8 .8 .8],...
%     'string','Spikes',...
%     'horizontalalignment','left');
% handles.allspikesedit = uicontrol('style','edit',...
%     'parent',handles.figure,...
%     'units','normalized',...
%     'position',[.75 .425 .14 .02],...
%     'string',eval(['slicenotes.',cellfields{1},'.SpikePatternInterpretation']),...
%     'horizontalalignment','left',...
%     'callback',@AllSpikesEditCallback);
% handles.allspikesfilldownbtn = uicontrol('style','pushbutton',...
%     'parent',handles.figure,...
%     'units','normalized',...
%     'position',[.9 .425 .03 .02],...
%     'string','Fill Down',...
%     'horizontalalignment','left',...
%     'callback',@AllSpikesFillDownCallback);
% 
% 
% handles.morphotitle = uicontrol('style','text',...
%     'parent',handles.figure,...
%     'units','normalized',...
%     'position',[.7 .39 .1 .02],...
%     'backgroundcolor',[.8 .8 .8],...
%     'string','Morphology',...
%     'horizontalalignment','left');
% handles.morphoedit = uicontrol('style','edit',...
%     'parent',handles.figure,...
%     'units','normalized',...
%     'position',[.75 .39 .14 .02],...
%     'string',eval(['slicenotes.',cellfields{1},'.MorphologyInterpretation']),...
%     'horizontalalignment','left',...
%     'callback',@MorphoEditCallback);
% handles.morphofilldownbtn = uicontrol('style','pushbutton',...
%     'parent',handles.figure,...
%     'units','normalized',...
%     'position',[.9 .39 .03 .02],...
%     'string','Fill Down',...
%     'horizontalalignment','left',...
%     'callback',@MorphoFillDownCallback);
% 
% handles.allclasstitle = uicontrol('style','text',...
%     'parent',handles.figure,...
%     'units','normalized',...
%     'position',[.7 .355 .1 .02],...
%     'backgroundcolor',[.8 .8 .8],...
%     'string','Overall',...
%     'horizontalalignment','left');
% handles.allclassedit = uicontrol('style','edit',...
%     'parent',handles.figure,...
%     'units','normalized',...
%     'position',[.75 .355 .18 .02],...
%     'string',eval(['slicenotes.',cellfields{1},'.OverallInterpretation']),...
%     'horizontalalignment','left',...
%     'callback',@AllClassEditCallback);
% 
% handles.FinishButton = uicontrol('style','pushbutton',...
%     'parent',handles.figure,...
%     'units','normalized',...
%     'position',[.94 .355 .04 .09],...
%     'string','Finish',...
%     'callback',@MorphoGUIFinishFcn);
% 
% for cidx = find(cellsspikesevaluated);%for each cell with spike trains
%     traces = {};
%     tlims = [];
%     tranges = [];
%     tobservation={};
%     totherdescrip={};
%     oldname = [];
%     eval(['numtraces = size(slicenotes.',cellfields{cidx},'.SpikePatternRecords,2);']);%even if not evaluated this time...
%     for ridx = 1:numtraces;
%         eval(['name = slicenotes.',cellfields{cidx},'.SpikePatternRecords(ridx).file;']);
%         if ~strcmp(oldname,name);
%             path = [ephysdirname,'\',name];
%             [data,trash,channels]=abfload(path);
%         end
%         eval(['sweep = slicenotes.',cellfields{cidx},'.SpikePatternRecords(ridx).sweep;']);
%         traces{end+1} = data(:,1,sweep);
%         tlims(end+1,:) = [min(traces{end}) max(traces{end})];
%         tranges(end+1) = tlims(end,2) - tlims(end,1);
%         match = [];
%         for idx = 1:size(slicenotes.trial,2)
%             if strcmp(slicenotes.trial(idx).abfname,name);
%                 match = idx;
%             end
%         end       
%         tobservation{end+1} = slicenotes.trial(match).observation;
%         totherdescrip{end+1} = slicenotes.trial(match).otherdescrip;
%         oldname = name;
%     end
%     %plotting previously chosen spike patterns
%     %%assuming only 4 channels for this(!)
%     if ~isempty(tlims);
%         if cidx == 1;%lower right
%             spaxpos = [.35 .02 .3 .47];
%             spedpos = [.42 .02 .23 .02];
%         elseif cidx == 2;%lower left
%             spaxpos = [.02 .02 .3 .47];
%             spedpos = [.09 .02 .23 .02];
%         elseif cidx == 3;%upper right
%             spaxpos = [.02 .52 .3 .47];
%             spedpos = [.09 .52 .23 .02];
%         elseif cidx == 4;
%             spaxpos = [.35 .52 .3 .47];
%             spedpos = [.42 .52 .23 .02];
%         end
%         handles.spikesaxes(cidx) = axes('parent',handles.figure,...
%             'units','normalized',...
%             'position',spaxpos,...
%             'ylim',[0 sum(tranges)]);
%         for tidx = 1:size(traces,2);%for each trace
%             if tidx == 1;
%                 tcs = 0;
%             else
%                 tcs = sum(tranges(1:(tidx-1)));%total range for all below this one
%             end
%             thistrace = traces{tidx}-(tlims(tidx,1)-tcs);
%             line(1:length(thistrace),thistrace,'parent',handles.spikesaxes(cidx),'color',handles.cellcolors(cidx,:))
%             obstext = [totherdescrip{tidx},' | ',tobservation{tidx}];
%             text(.8*length(thistrace),tcs+(.9*tranges(tidx)),obstext);%plot comment from pir files
%         end
%         handles.spikesedit(cidx) = uicontrol('style','edit',...
%             'parent',handles.figure,...
%             'units','normalized',...
%             'position',spedpos,...
%             'string',eval(['slicenotes.',cellfields{cidx},'.SpikePatternInterpretation']),...
%             'horizontalalignment','left',...
%             'tag',num2str(cidx),...
%             'callback',@SpikesEditCallback);
%             eval(['sweep = slicenotes.',cellfields{cidx},'.SpikePatternRecords(ridx).sweep;']);
%         eval(['handles.SpikeString{cidx} = slicenotes.',cellfields{cidx},'.SpikePatternInterpretation;']);
%         eval(['handles.MorphoString{cidx} = slicenotes.',cellfields{cidx},'.MorphologyInterpretation;']);
%         eval(['handles.OverallString{cidx} = slicenotes.',cellfields{cidx},'.OverallInterpretation;']);                    
%     end
% end
% 
% guidata(handles.figure,handles);
% temp = find(cellsspikesevaluated);
% temp = min(temp);
% set(handles.cellbuttongroup,'SelectedObject',handles.radio(temp));
% temp.NewValue = handles.radio(temp);
% MorphoGUIRadioCallback(handles.cellbuttongroup,temp);
% 
% %GREAT!  can wait until a property changes in the fig before
% %going on... can change that property with a button, like the
% %finish button (can't apparently wait on properties of buttons
% %themselves, that's why this is necessary)
% waitfor(handles.figure,'CloseRequestFcn','closereq');
% 
% handles = guidata(handles.figure);
% delete(handles.figure);
% for cidx = find(cellsspikesevaluated);%for each cell with spike trains
%     eval(['slicenotes.',cellfields{cidx},'.SpikePatternInterpretation = handles.SpikeString{cidx};']);
%     eval(['slicenotes.',cellfields{cidx},'.MorphologyInterpretation = handles.MorphoString{cidx};']);
%     eval(['slicenotes.',cellfields{cidx},'.OverallInterpretation = handles.OverallString{cidx};']);       
% %% below is b/c of some error above somewhere, can't deal with figuring out
% %% sometimes these are strings inside a 1x1 cell instead of just strings...
% %% fix here
%     eval(['temp = slicenotes.',cellfields{cidx},'.SpikePatternInterpretation;']);
%     if iscell(temp);
%         eval(['slicenotes.',cellfields{cidx},'.SpikePatternInterpretation = temp{1};']);
%     end
%     eval(['temp = slicenotes.',cellfields{cidx},'.MorphologyInterpretation;']);
%     if iscell(temp);
%         eval(['slicenotes.',cellfields{cidx},'.MorphologyInterpretation = temp{1};']);
%     end
%     eval(['temp = slicenotes.',cellfields{cidx},'.OverallInterpretation;']);
%     if iscell(temp);
%         eval(['slicenotes.',cellfields{cidx},'.OverallInterpretation = temp{1};']);
%     end
% %%
%     if isfield(handles,'pptcoords');
%         if size(handles.pptcoords,1) >= cidx
%             eval(['slicenotes.',cellfields{cidx},'.PipetteCoordinates = handles.pptcoords(cidx,:);']);
%         end
%     end
%     if isfield(handles,'x20coords');
%         if size(handles.x20coords,1) >= cidx
%             eval(['slicenotes.',cellfields{cidx},'.X20Coordinates = handles.x20coords(cidx,:);']);
%         end
%     end
%     eval(['slicenotes.',cellfields{cidx},'.MorphologyEvaluated = 1;']);                    
%     eval(['slicenotes.',cellfields{cidx},'.FinalClassEvaluated = 1;']);
% end
% 
% %% subfunctions for morphologyGUI below
% function PptImButtonDown(obj,ev)
% handles = guidata(obj);
% whichradio = str2num(get(get(handles.cellbuttongroup,'SelectedObject'),'Tag'));
% oldunits = get(handles.pptaxes,'units');%probably "normalized"
% set(handles.pptaxes,'units','pixels');
% cp = get(handles.pptaxes,'CurrentPoint');
% axpos = get(handles.pptaxes,'position');
% % imcoords = [cp(1,1)/axpos(3) cp(1,2)/axpos(4)];
% handles.pptcoords(whichradio,:) = [cp(1,1) cp(1,2)];
% markercoords = [cp(1,1) cp(1,2)];
% indicator = 0;
% if isfield(handles,'pptmarkers');
%     if size(handles.pptmarkers,2)>=whichradio;
%         if handles.pptmarkers(whichradio)~=0;
%             set(handles.pptmarkers(whichradio),'xdata',markercoords(1),'ydata',markercoords(2));
%             indicator = 1;
%         end
%     end
% end
% if indicator == 0;
%     handles.pptmarkers(whichradio) = line(markercoords(1),markercoords(2),...
%         'parent',handles.pptaxes,...
%         'marker','o',...
%         'markersize',10,...
%         'markeredgecolor',handles.cellcolors(whichradio,:),...
%         'hittest','off');%add a circle with the correct color
% end
% set(handles.pptaxes,'units',oldunits);
% guidata(handles.figure,handles);
% 
% function X20ImButtonDown(obj,ev)
% handles = guidata(obj);
% whichradio = str2num(get(get(handles.cellbuttongroup,'SelectedObject'),'Tag'));
% oldunits = get(handles.x20axes,'units');%probably "normalized"
% set(handles.x20axes,'units','pixels');
% cp = get(handles.x20axes,'CurrentPoint');
% axpos = get(handles.x20axes,'position');
% % imcoords = [cp(1,1)/axpos(3) cp(1,2)/axpos(4)];
% handles.x20coords(whichradio,:) = [cp(1,1) cp(1,2)];
% markercoords = [cp(1,1) cp(1,2)];
% indicator = 0;
% if isfield(handles,'x20markers');
%     if length(handles.x20markers)>=whichradio;
%         if handles.x20markers(whichradio)~=0;
%             set(handles.x20markers(whichradio),'xdata',markercoords(1),'ydata',markercoords(2));
%             indicator = 1;
%         end
%     end
% end
% if indicator == 0;
%     handles.x20markers(whichradio) = line(markercoords(1),markercoords(2),...
%         'parent',handles.x20axes,...
%         'marker','o',...
%         'markersize',10,...
%         'markeredgecolor',handles.cellcolors(whichradio,:),...
%         'hittest','off');%add a circle with the correct color
% end
% set(handles.x20axes,'units',oldunits);
% guidata(handles.figure,handles);
% 
% function MorphoGUIRadioCallback(obj,ev)
% handles = guidata(obj);
% whichradio = str2num(get(ev.NewValue,'tag'));
% if length(handles.spikesedit)>=whichradio;
%     set(handles.allspikesedit,'string',handles.SpikeString{whichradio});
%     set(handles.morphoedit,'string',handles.MorphoString{whichradio});
%     set(handles.allclassedit,'string',handles.OverallString{whichradio});
% else
%     set(handles.allspikesedit,'string',[]);
%     set(handles.morphoedit,'string',[]);
%     set(handles.allclassedit,'string',[]);
% end
% set(handles.allspikestitle,'foregroundcolor',handles.cellcolors(whichradio,:));
% set(handles.morphotitle,'foregroundcolor',handles.cellcolors(whichradio,:));
% set(handles.allclasstitle,'foregroundcolor',handles.cellcolors(whichradio,:));
% 
% function AllSpikesEditCallback(obj,ev);
% handles = guidata(obj);
% whichradio = str2num(get(get(handles.cellbuttongroup,'SelectedObject'),'Tag'));
% if length(handles.spikesedit)>=whichradio;
%     set(handles.spikesedit(whichradio),'string',get(obj,'string'));
% end
% handles.SpikeString{whichradio} = get(obj,'string');
% guidata(handles.figure,handles);
% 
% function AllSpikesFillDownCallback(obj,ev);
% handles = guidata(obj);
% whichradio = str2num(get(get(handles.cellbuttongroup,'SelectedObject'),'Tag'));
% set(handles.allclassedit,'string',get(handles.allspikesedit,'string'));
% handles.OverallString{whichradio} = get(handles.allspikesedit,'string');
% guidata(handles.figure,handles);
% 
% function MorphoFillDownCallback(obj,ev);
% handles = guidata(obj);
% whichradio = str2num(get(get(handles.cellbuttongroup,'SelectedObject'),'Tag'));
% set(handles.allclassedit,'string',get(handles.morphoedit,'string'));
% handles.OverallString{whichradio} = get(handles.morphoedit,'string');
% guidata(handles.figure,handles);
% 
% function SpikesEditCallback(obj,ev);
% handles = guidata(obj);
% whichradio = str2num(get(get(handles.cellbuttongroup,'SelectedObject'),'Tag'));
% if str2num(get(obj,'tag')) == whichradio
%     set(handles.allspikesedit,'string',get(obj,'string'));
% end
% handles.SpikesString{get(obj,'tag')} = get(obj,'string');
% guidata(handles.figure,handles);
% 
% function MorphoEditCallback(obj,ev);
% handles = guidata(obj);
% whichradio = str2num(get(get(handles.cellbuttongroup,'SelectedObject'),'Tag'));
% handles.MorphoString{whichradio} = get(obj,'string');
% guidata(handles.figure,handles);
% 
% function AllClassEditCallback(obj,ev);
% handles = guidata(obj);
% whichradio = str2num(get(get(handles.cellbuttongroup,'SelectedObject'),'Tag'));
% handles.OverallString{whichradio} = get(obj,'string');
% guidata(handles.figure,handles);
% 
% %%
% function MorphoGUIFinishFcn(obj,ev);
% handles = guidata(obj);
% set(handles.figure,'CloseRequestFcn','closereq');
% 
% %%
% function EnlargeX20Fcn(obj,ev)
% handles = guidata(obj);
% figure;
% imagesc(get(handles.x20im,'CData'));
% axis equal;
% 
% %%
% function EnlargePptFcn(obj,ev)
% handles = guidata(obj);
% figure;
% imagesc(get(handles.pptim,'CData'));
% axis equal; colormap gray
% %% If a manual review is all that's needed... run this to allow user to
% %% look through upstates
% 
%%
function [slicenotes,manualreview]=ManualReviewSliceEphys(slicenotes,dirname,manualreview)
% Allows manual review of upstates.  Will then perform analyses based on
% upstates (core)

channelslist = slicenotes.CellOrder.CellChannels;
waithandle = waitbar(0,['Analyzing Electophysiology for Slice ',slicenotes.name],...
    'name',slicenotes.name);%for user
for a=1:length(slicenotes.trial);%for each trial
    if ~isempty(slicenotes.trial(a).abfname)
             %if there is an abf indicated there and there was an upstate detected
        [data,trash,channels]=abfload([dirname,'\',slicenotes.trial(a).abfname]);%read file...
%         [data,channels,units,rate]= paq2lab;
        for b=1:length(channelslist);
            cn=strmatch(channelslist{b},channels,'exact');
            if length(size(data))==2 & ~isempty(slicenotes.trial(a).stim);
                %test if a multi-sweep dataset, and a classifiable
                %trial
                if ~isempty(slicenotes.trial(a).ephys.cell(b).upstates);%if ups were found
                    potups=slicenotes.trial(a).ephys.cell(b).upstates;
                    if ~isempty(potups) & manualreview;
                        h=figure('Visible','off');%create an invisible figure as a marker
                        ReviewUpstatesInTrace(potups,data,cn,h,'potups');
                        waitfor(h);
                    end
                    if closedproperly==0%assigned in by ReviewUpstatesInTrace fcn
                        manualreview=0;%if window not closed right, manualreview went wrong
                    end
                    slicenotes.trial(a).ephys.cell(b).upstates=potups;
                    if ~isempty(potups);
                        slicenotes.upstatecells(b)=1;
                        slicenotes.trial(a).ephysupstate=1;
                    end
% % % %analyze for plasticity, mark in slicenotes.ephysplasticity=1 or 0
                end
            end
        end
    end
    waithandle = waitbar(a/length(slicenotes.trial),waithandle);
end

%% analyze by cell... for core
if sum(slicenotes.upstatecells);%if any cells had upstates
    for b=1:length(channelslist);%for each cell
        listups=[];
        for a=1:length(slicenotes.trial);%for each trial
            if isfield(slicenotes.trial(a).ephys,'cell');
                if isfield(slicenotes.trial(a).ephys.cell(b),'upstates');
                    ups=slicenotes.trial(a).ephys.cell(b).upstates;
                    aps=slicenotes.trial(a).ephys.cell(b).aps;
                    if ~isempty(ups);
                        for c=1:size(ups,1);%for each up in that file
                            listups(end+1)=0;%record there was an upstate
                            if ~isempty(aps)%if not aps at all... don't bother
                                temp1=find(aps>ups(2));
                                temp2=find(aps<ups(3));
                                temp=intersect(temp1,temp2);
                                if ~isempty(temp);%if aps during the upstate
                                    listups(end)=1;%record that
                                end
                            end
                        end
                    end
                end
            end
        end
        if length(listups>=4);%if at least four upstates in this cell
            if length(listups)==sum(listups);%if an ap in every upstate
                slicenotes.corecells(b)=1;%record that this cell was a core cell
            end
        end
    end
end
close(waithandle)

%% Using Epo... analyze movies
function slicenotes=AnalyzeSliceMovies(slicenotes)
