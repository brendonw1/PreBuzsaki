function handles = ct_setup_signalsPreferences(handles)

lidx = get_label_idx(handles, 'signals');

%set default dimensionality reducer
Desired_Default='_no_dim_reduc';
match=strmatch(Desired_Default,get(handles.uigroup{lidx}.dpdimreducers,'String'),'exact');
set(handles.uigroup{lidx}.dpdimreducers,'value',match);

%set default classifier
Desired_Default='spectral';
match=strmatch(Desired_Default,get(handles.uigroup{lidx}.dpclassifiers,'String'),'exact');
set(handles.uigroup{lidx}.dpclassifiers,'value',match);

%set default number of clusters to look for
Desired_Default=3;
set(handles.uigroup{lidx}.txnclusters,'String',Desired_Default);

%set default number of clustering trials
Desired_Default=10;
set(handles.uigroup{lidx}.txntrials,'String',Desired_Default);

%set default order routine
Desired_Default='by_mean_intensity';
match=strmatch(Desired_Default,get(handles.uigroup{lidx}.dporderroutines,'String'),'exact');
set(handles.uigroup{lidx}.dporderroutines,'value',match);

%set default signal detector
Desired_Default='detectspikesintegrals';
match=strmatch(Desired_Default,get(handles.uigroup{lidx}.dpdetectors,'String'),'exact');
set(handles.uigroup{lidx}.dpdetectors,'value',match);