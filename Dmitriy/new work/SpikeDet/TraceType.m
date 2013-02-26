%Changes trace type (fluorescence <==> DF/F)

if n == 1
   set(mtrad,'Checked','on');
   set(mtraf,'Checked','off');
else
   set(mtraf,'Checked','on');
   set(mtrad,'Checked','off');
end
PlotTrace