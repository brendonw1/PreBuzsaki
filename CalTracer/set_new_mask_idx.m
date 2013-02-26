function handles = set_new_mask_idx(handles, label)
midx = find(strcmpi(handles.appData.maskLabels, label));
if ~isempty(midx)
    error('Mask label already exists!');
else
    handles.appData.maskLabels{end+1} = label;
    midx = find(strcmpi(handles.appData.maskLabels, label));
end



