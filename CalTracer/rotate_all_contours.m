function handles = rotate_all_contours(handles,diffang,fulcrum,midx);
% function handles = rotate_all_contours(hObject,handles);
% using 2 clicks, allows user to select how much to move all contours in x
% and y in all regions of a mask

for b = 1:length(handles.exp.regions.contours)%for each region
    for c = 1:length(handles.exp.regions.contours{b}{midx});%rotate contours inside the region
        for d =1:size(handles.exp.regions.contours{b}{midx}{c},1);
            cx = handles.exp.regions.contours{b}{midx}{c}(d,1) - fulcrum(1);%get coords relative axis
            cy = handles.exp.regions.contours{b}{midx}{c}(d,2) - fulcrum(2);
            
            [theta,radius] = cart2pol(cx,cy); %just convert to polar...
            theta = theta + diffang;%and add angles, then... 
            [cx,cy] = pol2cart(theta,radius);%convert back to cartesian
            
            handles.exp.regions.contours{b}{midx}{c}(d,1) = cx + fulcrum(1);
            handles.exp.regions.contours{b}{midx}{c}(d,2) = cy + fulcrum(2);            
        end
    end
end
handles.exp.tcImage(midx).rotationRadians = handles.exp.tcImage(midx).rotationRadians + diffang;
    %keep track of move in case want to load contours and move them