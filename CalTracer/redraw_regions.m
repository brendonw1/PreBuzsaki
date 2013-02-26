function handles = redraw_regions(handles, hObject)
% function handles = draw_cell_contours(handles, varargin) 
%
% Delete and redraw region lines based on the values for them in the input
% handles structure.

%for each region
for a = 1:length(handles.exp.regions.bhand) 
    x = [handles.exp.regions.coords{a+1}(:,1); ...
       handles.exp.regions.coords{a+1}(1,1)];
    y = [handles.exp.regions.coords{a+1}(:,2); ...
       handles.exp.regions.coords{a+1}(1,2)];
    delete(handles.exp.regions.bhand(a));
    handles.exp.regions.bhand(a) = plot(x,y,':+y');
end
1;