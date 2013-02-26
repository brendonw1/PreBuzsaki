function midx = get_mask_idx(handles, label)
% Get the index to a mask given the label.
midx = find(strcmpi(handles.appData.maskLabels, label));
if isempty(midx)
    error('You must input a valid mask label string');
end

