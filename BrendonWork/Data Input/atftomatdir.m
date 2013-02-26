%converts all files in current directory from atfs to .mat files containing
%header, labels, comments and data variables.  Assumes all files in
%directory are .atf files (Axon Text Files).  .mat files are saved in
%current directory

di=dir;di=di(3:end);

for a=1:length(dir);
	[header, labels, comments, data] = import_atf(di(a).name);
	eval(['save ',di(a).name(1:end-4),' header labels comments data'])
	clear header labels comments data
    disp([num2str(a),' out of ',num2str(length(di))])
end