function match=ct_zstackTypeDefaultPreference(zstack_names);

%set default function to make a cell detection image (zstack function)
Desired_Default = 'ct_average';
match = strmatch(Desired_Default,zstack_names,'exact');