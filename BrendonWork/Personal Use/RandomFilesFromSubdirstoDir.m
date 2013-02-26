function RandomFilesFromSubdirstoDir

sourcedirpath=uigetdir; %get name of folder containing all folders where photos are
destdirpath=uigetdir; %get name of destination folder 
destsize=inputdlg('Enter size free space left on destination folder, in GB');
destsize=str2num(destsize{1});

sourcelist = listallsubdirfiles(sourcedirpath);%get all files in all subdirectories of the specified source area
candidateslist = {};
sizeslist=[];
for a = 1:length(sourcelist)%will keep only tif, jpg, bmp or gif files
    if length(sourcelist{a})>3
        suff = lower(sourcelist{a}(end-2:end));
%             if strcmp(suff,'tif') | strcmp(suff,'jpg') | strcmp(suff,'bmp') | strcmp(suff,'gif')
        if strcmp(suff,'jpg')
            fileinfo = dir(sourcelist{a});
            if prod(size(fileinfo))>0
                sizeslist(end+1) = fileinfo.bytes;
                candidateslist{length(candidateslist)+1} = sourcelist{a};
            end
        end    
    end
end

% orderlist = 1:length(candidateslist);
priorityorder = randperm(length(candidateslist));
availsize = destsize * 1000000000 - 100000;

%first... 
if sum(sizeslist) < availsize;
    keepers = priorityorder;
else%find a way to find just the first x to keep... use cumsum
    talliedsizes = cumsum(sizeslist(priorityorder));
    numfiles = find(talliedsizes<availsize,1,'last');%the X'th file is the one that keeps from going over the allotted size
    keepers = priorityorder(1:numfiles);
end

for a=1:length(keepers);
    thisfile = candidateslist{priorityorder(a)};
    [sourcedir,sourcefilename]=separatepath(thisfile);%get this  filename
    %get source dirname
    copyfile(thisfile,[destdirpath,'\',sourcefilename])
    h=waitbar(a/length(keepers));
end
close(h)
