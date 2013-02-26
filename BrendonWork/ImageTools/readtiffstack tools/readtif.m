function [X,map] = readtif(filename, index)
%READTIF Read an image from a TIFF file.
%   [X,MAP] = READTIF(FILENAME) reads the first image from the
%   TIFF file specified by the string variable FILENAME.  X will
%   be a 2-D uint8 array if the specified data set contains an
%   8-bit image.  It will be an M-by-N-by-3 uint8 array if the
%   specified data set contains a 24-bit image.  MAP contains the
%   colormap if present; otherwise it is empty. 
%
%   [X,MAP] = READTIF(FILENAME, 'Index', N) reads the Nth image
%   from the file.
%
%   See also IMREAD, IMWRITE, IMFINFO.
%   Steven L. Eddins, June 1996
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2007-11-29 15:54:37 $
error(nargchk(1, 2, nargin));
if (nargin < 2)
    index = 1;
end
[X,map] = rtifc(filename, index);
map = double(map)/65535;
