function [means,stds] = errorbargraphmeansd(varargin);
%varargin can be the bar width

barwidth = 1;
vidx = 1;
means = [];
stds = [];
while vidx <= nargin;
    if strcmp(varargin{vidx},'barwidth')
        barwidth = varargin{vidx+1};
        vidx = vidx+2;
    else
        means(end+1) = mean(varargin{vidx});
        stds(end+1) = std(varargin{vidx});
        vidx = vidx+1;
    end
end

errorbargraph(means,stds,barwidth);