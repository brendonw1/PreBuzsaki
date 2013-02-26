% switch_uigroups
function handles = switch_uigroups(handles, label1, label2)
% Make one group of uicontrols visible while turning another group
% off. Group label1 goes off, group label2 goes on.
handles = change_uigroup(handles, label1, ...
		       {'Enable', 'Visible'}, {'off', 'off'});
handles = change_uigroup(handles, label2, ...
		       {'Enable', 'Visible'}, {'on', 'on'});
