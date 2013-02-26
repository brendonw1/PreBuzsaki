function [x,map] = rtifc(filename,n)
%RTIFC Read a TIFF image.
%   [X,MAP] = READTIFC(FILENAME,N) reads the Nth image from the
%   TIFF file specified by the string variable FILENAME.  X
%   contains the image data; its class is uint8.  MAP contains
%   the colormap information if it exists; its class is uint16.
%   MAP is empty if the image is an RGB or grayscale; X is
%   M-by-N-by-3 if the image is RGB.
%
%   [X,MAP] = READTIFC(FILENAME) reads the first image from the
%   file. 
%
%   See also WTIFC, IMWRITE, IMREAD, and IMFINFO.

%   Chris Griffin 6-12-96
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.1.1 $  $Date: 2005/03/01 18:12:00 $
%#mex

error('Missing MEX-file RTIFC');

