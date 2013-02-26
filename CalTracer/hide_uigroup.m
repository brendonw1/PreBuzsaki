function handles = hide_uigroup(handles, label)
% Hide a group of uicontrols.
handles = change_uigroup(handles, label, ...
		       {'Visible'}, ...
		       {'off'});