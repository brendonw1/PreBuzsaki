function [res, head] = xlsread8( file, header, cls, sheet );
%XLSREAD8 Read Excel spreadsheets natively (v97-2003).
%
%   [RES HEAD] = XLSREAD8( 'FILENAME', HEADER, 'CLASS', SHEET ) reads data from 
%   the selected SHEET in the spreadsheet FILENAME. The data can be retrieved in
%   different formats according to CLASS and will be returned in RES. The sheet
%   may contain a header and/or a columnheader, both of which will be returned in 
%   HEAD. SHEET, CLASS and HEADER are optional arguments. Possible values are:
%
%      o 'HEADER'     0: no header, 1: only header, 2: only columnheader,
%                     3: both, eg. header and columnheader. Default is 2 !!
%                     HEAD(1) is the header and HEAD(2) are the columnheaders.
%      o 'CLASS'      'double', 'struct' or 'cell'. Default is 'double'.
%      o 'SHEET'      String defining the name of the sheet name or double 
%                     for the worksheet index. If omited, first sheet is taken.
%
%   SHEETNAMES = XLSREAD8( 'FILE', -99 ) returns the SHEETNAMES in a cellstring. 
%
%   Donations: www.treetron.ch/~gchappi/xls8tools/donations.html. Thank you.
%
%   See also:  xlswrite8, xlsappend8.

%   License:   xlsread8 is freeware, you may use and distribute it freely.
%
%   Warranty:  xlsread8 is supplied as is. The author disclaims all warranties,
%              expressed or implied, including, without limitation, the 
%              warranties of merchantability and of fitness for any purpose. 
%              The author assumes no liability for damages, direct or 
%              consequential, which may result from the use of xlsread8.
%
%   Notes:     - Works on the Windows platform only (due to Delphi; a port 
%                to Linux (maybe even Mac) should be possible though).
%              - The files are written natively. This means, that no ActiveX 
%                server (Excel) needs to be loaded (or even installed at all).
%              - xlsread8 is linked against Matlab.exe and doesn't work with 
%                compiled programs. Contact us for a redistributable version.
%              - The dll is compressed with upx (http://upx.sourceforge.net)
%
%              - Ancestor code of xlsread8 is being used for some years in a
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


% some checks
error( nargchk( 1, 4, nargin ) );

if ~ischar( file )
  error( 'The first argument must be a char array (filename)' );
end;

if nargin < 2, header = 2; end;
if nargin < 3, cls = 'double'; end;
if nargin < 4, sheet = 1; end;

if ~isnumeric( header ) error( 'The second argument must be a numeric array (header)' ); end;
if (nargin > 2) && (~ischar( cls )) error( 'The third argument must be a char array (class)' ); end;
if (nargin == 4) && ~(ischar( cls ) || isnumeric( cls )) error( 'The forth argument must be a char or a number' ); end;

% call now
[res head] = xlsRead8DLL( file, header, cls, sheet );
