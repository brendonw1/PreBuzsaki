function [medians,stds]=errorbargraphmediansd(varargin);
%varargin can be the bar width

barwidth = 1;
vidx = 1;
medians = [];
stds = [];
while vidx <= nargin;
    if strcmp(varargin{vidx},'barwidth')
        barwidth = varargin{vidx+1};
        vidx = vidx+2;
    else
        medians(end+1) = median(varargin{vidx});
        stds(end+1) = std(varargin{vidx});
        vidx = vidx+1;
    end
end

errorbargraph(medians,stds,barwidth);