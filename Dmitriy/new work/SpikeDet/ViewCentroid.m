%Turns the display data points option on/off

if strcmp(get(mvcen,'checked'),'on')
   set(mvcen,'checked','off');
else
   set(mvcen,'checked','on');
end
PlotTrace;