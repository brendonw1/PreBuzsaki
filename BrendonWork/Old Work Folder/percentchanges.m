function percents = percentchanges(matrix)
% creates a matrix of the percent changes from one component of a matrix to
% the next along the first dimension.  Each value represents the
% proportion change of the next value over the current: ie number 1 is
% equal to value(2)-value(1)/value(1)

shifted=circshift(matrix,-1);
percents = (shifted-matrix)./matrix;
h=size(matrix,1);
percents=percents (1:h-1,:,:);