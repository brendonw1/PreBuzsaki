function handles = reorder_contours_early(handles)
% Because the data structures are different in the early part of the
% program, we have to rewrite the reorder contour routine to handle
% these different data strutures.  It seems easier to do this as a
% seperate routine rather than clogging the logic up at every line to
% distinguish the two cases.

ridx = handles.appData.currentRegionIdx;
midx = handles.appData.currentMaskIdx;

% Draw the line for reording.
height = handles.exp.tcImage(1).nY;
width = handles.exp.tcImage(1).nX;    
[x, y, h] = draw_region(width, height, ...
			'tag', 'orderingline', ...
			'userdata', ridx, ...
			'nclicks', 2);


% Put into first quadrant cause it's bugging me to death!
y = -y+height;
[ang, rotation_mat] = compute_rotation_angle(x,y);

% Here is where things start to change.
%%%

% Now we compute the order of the contours.  

num_contours = length([handles.exp.regions.contours{ridx}{midx}]);
centroids = zeros(num_contours,2);
for c = 1:num_contours
    cn = handles.exp.regions.contours{ridx}{midx}{c};
    centroids(c,:) = create_centroid(cn);
end

% Determine which cells are closest to which lines. This is important
% to determine which ordering regime they are in.  Right now we assume
% there is only one line.
translated_centroids = rotation_mat * centroids';

% Recompute the centroid for each contour in the translated origin of
% the reordering line.  Sort the rows by the X dimension.
if (sqrt(y(2)^2+x(2)^2) > sqrt(y(1)^2+x(1)^2))
    order = 1;				% ascending
else
    order = -1;				% descending
end
    
[sorted, index] = sortrows(translated_centroids', order*1);
[sorted2, index2] = sortrows(index);
% Index gives the order for each id.  That is 
% [1 5 12] says that contours 1 5 12 are in order 1 2 3.


% Btw, this kind of thing is exactly why one uses structure arrays!
% -DCS:2005/06/21
contours = handles.exp.regions.contours{ridx}{midx};
handles.exp.regions.contours{ridx}{midx} = contours(index);
hands = handles.guiOptions.face.handl{ridx}{midx};
handles.guiOptions.face.handl{ridx}{midx} = hands(index);


% Index2 gives the order for each id, so that you can reference the 
% order _with_ the id.  [_1_ 11 8 5 _2_ 21 18 15 12 9 6 _3_ ...]

% I guess we could be nice and show this to the user.
1;					%  not implemented yet.

% Delete the contour highlighting lines.
1;					% not implemented yet.

% Delete the reordering line from the screen.  This implies a good
% management of all the lines, patches, etc. on the plot.
pause(1);
lidx = get_label_idx(handles, 'image');
handles = show_ordering_line(handles, handles.uigroup{lidx}.imgax,0);