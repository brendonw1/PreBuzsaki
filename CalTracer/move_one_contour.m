function handles = move_one_contour(handles,x,y,ridx,cidx,midx);
% function handles=move_one_contour(hObject,handles);
% using 2 clicks, allows user to select how much to move all contours in x
% and y in all regions of a mask

% for b = 1:length(handles.exp.regions.contours)%for each region
%     if b ~= 1;%move the region itself... except the first region
%         handles.exp.regions.coords{b}(:,1) = handles.exp.regions.coords{b}(:,1)+x;
%         handles.exp.regions.coords{b}(:,2) = handles.exp.regions.coords{b}(:,2)+y;
%     end
    handles.exp.regions.contours{ridx}{midx}{cidx}(:,1) = handles.exp.regions.contours{ridx}{midx}{cidx}(:,1)+x;
    handles.exp.regions.contours{ridx}{midx}{cidx}(:,2) = handles.exp.regions.contours{ridx}{midx}{cidx}(:,2)+y;
% end