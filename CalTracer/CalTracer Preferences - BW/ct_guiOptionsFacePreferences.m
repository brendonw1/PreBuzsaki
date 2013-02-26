function handles=ct_guiOptionsFacePreferences(handles,nregions)

%set spatial brightness cutoff default
Desired_Default=12;
handles.guiOptions.face.thresh = Desired_Default*ones(1, nregions);
%set minimum cell area default
Desired_Default=25;
handles.guiOptions.face.minArea = Desired_Default*ones(1, nregions);
%set maximum cell area default
Desired_Default=1000;
handles.guiOptions.face.maxArea = repmat(Desired_Default,1, nregions);
%set pi limit default
Desired_Default=3.6;
handles.guiOptions.face.piLimit = Desired_Default*ones(1, nregions);
