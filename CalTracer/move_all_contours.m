function handles = move_all_contours(handles,x,y,midx);
% function handles=move_all_contours(hObject,handles);
% using 2 clicks, allows user to select how much to move all contours in x
% and y in all regions of a mask

for b = 1:length(handles.exp.regions.contours)%for each region
    if b ~= 1;%move the region itself... except the first region
        handles.exp.regions.coords{b}(:,1) = handles.exp.regions.coords{b}(:,1)+x;
        handles.exp.regions.coords{b}(:,2) = handles.exp.regions.coords{b}(:,2)+y;
    end
    for c = 1:length(handles.exp.regions.contours{b}{midx});%move the cells inside
        handles.exp.regions.contours{b}{midx}{c}(:,1) = handles.exp.regions.contours{b}{midx}{c}(:,1)+x;
        handles.exp.regions.contours{b}{midx}{c}(:,2) = handles.exp.regions.contours{b}{midx}{c}(:,2)+y;
    end
end
handles.exp.tcImage(midx).movementVector = handles.exp.tcImage(midx).movementVector + [x y];