function [means,sems] = errorbargraphmeansem(varargin);
%varargin can be the bar width

barwidth = 1;
vidx = 1;
means = [];
sems = [];
while vidx <= nargin;
    if strcmp(varargin{vidx},'barwidth')
        barwidth = varargin{vidx+1};
        vidx = vidx+2;
    else
        means(end+1) = mean(varargin{vidx});
        sems(end+1) = std(varargin{vidx});
        sems(end) = sems(end)/(length(varargin{vidx})^.5);
        vidx = vidx+1;
    end
end

errorbargraph(means,sems,barwidth);