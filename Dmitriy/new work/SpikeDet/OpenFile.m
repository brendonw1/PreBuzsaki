%Opens a file

[fname,pname] = uigetfile('*.mat','Open File');

if [pname fname] == 0
   return
end

load([pname fname]);
Filt = fix(10/str2num(fname(7:8)));
if str2num(fname(7:8)) > 6
   AreaInd = 1;
else
   AreaInd = 2.25;
end
Traces = tr;
Coords = cn;
Spk = [];
CellNum = 1;
Threshold = zeros(1,size(Traces,1));

set(bwbck,'Enable','on');
set(bwfrw,'Enable','on');
set(slide,'Enable','on');
set(slide,'SliderStep',[1/size(Traces,1) 1/size(Traces,1)],'Min',1,'Max',size(Traces,1));
set(mview,'Enable','on');
set(mtrac,'Enable','on');
set(msdet,'Enable','on');

PlotTrace;