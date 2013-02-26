function grouped = groupedzprojector(movie,zgroupsize,projfcn);
%Takes a movie where the frames are on dim 3 and collapses every few frames
%(number specficied by zgroupsize input) into a single frame by taking the
%mean of those frames.  The string projfcn will be evaluated as the
%function to reduce each group of points to a single point (ie mean, max,
%min, median)

extraframes = mod(size(movie,3),zgroupsize);
if  extraframes ~= 0;%if number of group doesn't go evenly into the number of frames in the movie
    movie(:,:,end-(extraframes-1):end)=[];%just delete frames "hanging off the end"
end
    
grouped = reshape(movie,[size(movie,1) size(movie,2) zgroupsize size(movie,3)/zgroupsize]);
if strcmp(projfcn,'min') | strcmp(projfcn,'max')
    eval(['grouped = ',projfcn,'(grouped,[],3);']);
elseif strcmp(projfcn,'std')
    eval(['grouped = ',projfcn,'(grouped,1,3);']);
else
    eval(['grouped = ',projfcn,'(grouped,3);']);
end

grouped = squeeze(grouped);