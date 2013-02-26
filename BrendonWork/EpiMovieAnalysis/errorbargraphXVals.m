function errorbargraphxvals(xvalues,values,error,varargin);
%varargin can be the bar width

if ~isempty(varargin);
    barwidth = varargin{1};
else
    barwidth = 1;
end
% figure
hold on
errorbar(xvalues,values,error,'k')
plot(xvalues,values,'color',[1 1 1])
bar(xvalues,values,barwidth)