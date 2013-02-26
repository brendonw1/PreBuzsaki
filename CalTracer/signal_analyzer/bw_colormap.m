function c = bw_colormap(m)
%Gives white to red in shades of pink
%   bw_colormap(M) returns an M-by-3 matrix containing a pinkish colormap.
%   bw_colormap, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%
%   For example, to reset the colormap of the current figure:
%
%       colormap(autumn)
%
%   See also HSV, GRAY, HOT, BONE, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2007/02/12 16:11:06 $

if nargin < 1, m = size(get(gcf,'colormap'),1); end
r = (0:m-1)'/max(m-1,1);

%% blue > purple > red 
c = [r zeros(m,1) 1-r];%


%% white > pink > red 
% c = [ones(m,1) r r];%
% c = flipud(c);