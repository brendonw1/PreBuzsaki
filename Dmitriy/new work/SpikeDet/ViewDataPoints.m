%Turns the display data points option on/off

if strcmp(get(mvpts,'checked'),'on')
   set(mvpts,'checked','off');
else
   set(mvpts,'checked','on');
end
PlotTrace;