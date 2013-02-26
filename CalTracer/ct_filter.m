function handles = ct_filter(handles)
% function handles = ct_filter(handles)
% Midx is the mask that is currently being processed.
midx = handles.appData.currentMaskIdx;

if handles.appData.skipThroughSettings.skipFilter.index > 0;%if called as part
    %of skipping through
    filter_name = handles.appData.skipThroughSettings.skipFilter.options{1};
    param = handles.appData.skipThroughSettings.skipFilter.options{2};
else
    filter_names = uiget(handles, 'filterimage', 'dpfilters', 'String');
    fid = uiget(handles, 'filterimage', 'dpfilters', 'value');
    filter_name = handles.appData.filterNames(fid);
    filter_name = filter_name{1};
    param = [];
end

[loca, param] = feval(filter_name, handles.exp, midx , param);
if ~strcmpi(param.status, 'ok')
    return;
end


handles.exp.tcImage(midx).filteredImage = loca;
handles.exp.tcImage(midx).filterName = filter_name;
handles.exp.tcImage(midx).filterParam = param;

%%% What does this do, and where?
handles.appData.currentRegionIdx = 1;


