%Turns the display data points option on/off

if strcmp(get(mvbas,'checked'),'on')
   set(mvbas,'checked','off');
else
   set(mvbas,'checked','on');
end
PlotTrace;