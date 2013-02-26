function max_corr = max_corr(mt)
%max_corr = max_corr(mt)
%   maximizes the average correlation coefficient between vectors	
%   returns the indexes of those vectors that need to be negated

v = mt*linfit(mt);
max_corr = find(v<0)';
