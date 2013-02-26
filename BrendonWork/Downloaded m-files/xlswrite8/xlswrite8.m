function xlswrite8( arr, file, r, c, head, col );
%XLSWRITE8 Write Excel spreadsheets natively (v97-2003).
%
%   XLSWRITE8( M, 'FILENAME' ) creates a new spreadsheet FILENAME and 
%   writes the matrix M into it. M can be of type double, int32, char, cell 
%   or struct. For structs the fieldnames are taken as column headers. 
%
%   XLSWRITE8( M, 'FILENAME', R, C ) writes starting at an offset of R rows and 
%   an offset of C columns.  R and C are zero-based, so R = C = 0 specifies the
%   top left cell in the spreadsheet.
%
%   XLSWRITE8( M, 'FILENAME', R, C, HEAD, COL ) adds a header and a columnheader. 
%   HEAD must be a char array or a cell array of strings (for multiple lines). 
%   COL is always a cell array of strings.
%
%   It's not possible to write into a distinct sheet directly. But you can use 
%   this workaround: create a file with xlswrite8 and fill it with xlsappend8.
%
%   Donations: www.treetron.ch/~gchappi/xls8tools/donations.html. Thank you.
%
%   See also:  xlsappend8, xlsread8.

%   IMPORTANT: The file Book1.xls (enclosed in the zip file) is used as a 
%              template and must be placed in the directory where xlswrite8.m 
%              resides. The template can be adapted to your individual needs. 
%
%   License:   xlswrite8 is freeware, you may use and distribute it freely.
%              Please consider a donation if this script is useful for you.
%
%   Warranty:  xlswrite8 is supplied as is. The author disclaims all warranties,
%              expressed or implied, including, without limitation, the 
%              warranties of merchantability and of fitness for any purpose. 
%              The author assumes no liability for damages, direct or 
%              consequential, which may result from the use of xlswrite8.
%
%   Notes:     - Works on the Windows platform only (due to Delphi; a port 
%                to Linux (maybe even Mac) should be possible though).
%              - The files are written natively. This means, that no ActiveX 
%                server (Excel) needs to be loaded (or even installed at all).
%              - xlswrite8 is linked against Matlab.exe and doesn't work with 
%                compiled programs. Contact us for a redistributable version.
%              - The dll is compressed with upx (http://upx.sourceforge.net)
%
%              - Ancestor code of xlswrite8 is being used for some years in a
%                big company. Nevertheless the code could be improved in 2 areas:
%                o speedwise    (only important for large files, for small and
%                                medium files this is really a non issue)
%                o featurewise  (the library offers a lot more - formula, 
%                                formats, chart, managing sheets, range, ... 
%                                that we don't use. With suitable interface 
%                                this functionality could be exploited.
%                It's unlikely that we implement such things for us as we have no
%                need. Upon request optimizations could be done in either area.
%
%              - Last but not least: There's code "laying around" for superfast 
%                native Access database connection. It was needed some years ago 
%                to import millions of datarows (Java (with ODBC bridge) proved 
%                to be too slow). If there is need/interest it could be revived.
%                Unfortunately this will hardly be possible for free.
%
%   Bugs:      Info and support at: www.treetron.ch/~gchappi/xls8tools
% 
%   Author:    Hans-Peter Suter, gchappi@gmail.com
%   Date:      15.8.2005, v0.2.1
%
%   Copyright: Copyright (c) 2005, Treetron GmbH.
%              All rights reserved.


nosheet = -99;

%check nargin
error( nargchk( 2, 6, nargin ) );

% check file
if ~isstr( file )
  error( 'The second argument must be a char array (filename)' );
end;

% 2 arguments
if nargin == 2
  xlsWrite8DLL( arr, file, nosheet, 0, 0 );

% 4, 6
elseif nargin >= 4
  if ~(isnumeric( r ) & isnumeric( c ))
    error( 'Row- and Columnoffset must be numeric' );
  end;
  if nargin == 4
    xlsWrite8DLL( arr, file, nosheet, r, c );
  elseif nargin == 6
    if ~iscell( col )
      error( 'Column headers must be a cell array of strings' );
    end;
    if ~(iscell( head ) | isstr( head )) 
      error( 'The header must be a char array or a cell' );
    end;
    xlsWrite8DLL( arr, file, nosheet, r, c, head, col );
  else
    error( '5 arguments not allowed' );
  end;
else
  error( '3 arguments not allowed' );
end;
  