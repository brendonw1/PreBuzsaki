function errorbargraph(values,error,varargin);
%varargin can be the bar width

if ~isempty(varargin);
    barwidth = varargin{1};
else
    barwidth = 1;
end
figure
hold on
errorbar(values,error,'k')
plot(1:length(values),values,'color',[1 1 1])
bar(1:length(values),values,barwidth)