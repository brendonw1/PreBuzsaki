function handles = display_zstack_image(handles)
% function display_zstack_image(handles)
% Display the zstack image in the large axis in the middle of the
% GUI.  This is largely used for creating and handling contours.

% Midx is the mask that is currently being processed.
midx = handles.appData.currentMaskIdx;
lidx = get_label_idx(handles, 'image');
axes(handles.uigroup{lidx}.imgax);
if isfield(handles.appData,'mainTcImage');
    delete(handles.appData.mainTcImage);
end
handles.appData.mainTcImage = imagesc(handles.exp.tcImage(midx).image);
hold on;
set(gca, 'xtick', [], 'ytick', []);
axis equal;
axis tight;
box on;
colormap gray;
handles.exp.tcImageTitle = title(texlabel(handles.exp.tcImage(midx).title, 'literal'));
%zoom on;
if ~isempty(handles.exp.regions.bhand)
    c = get(handles.uigroup{lidx}.imgax, 'Children');    
    cch = find(strcmpi(get(c, 'Tag'), 'cellcontour'));
    delete(c(cch));
    %%% Delete the handles from the array. -DCS:2005/04/04
    c = get(handles.uigroup{lidx}.imgax, 'Children');
    ctag = get(c, 'Tag');
    rbh_idx = find(strcmpi(ctag, 'regionborder'));
    not_rbh_idx = find(~strcmpi(ctag, 'regionborder')); 
    newc = [c(rbh_idx); c(not_rbh_idx)];
    set(handles.uigroup{lidx}.imgax, 'Children', newc);
end
