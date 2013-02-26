disp( '*******************************************************' )
disp( '*** read8test - test routines for xlsread8 function ***' )
disp( '*******************************************************' )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp( 'check sheetnames and sheetcount' )

sn = xlsread8( '_TestReadFile.xls', -99 );
if strcmp( sn{1}, 'Tabelle1' ) == 0, error( 'first sheetname should be "Tabelle1"' ); end;
if strcmp( sn{2}, 'Tabelle2' ) == 0, error( 'second sheetname should be "Tabelle2"' ); end;
if strcmp( sn{3}, 'Tabelle3' ) == 0, error( 'third sheetname should be "Tabelle3"' ); end;
if size( sn, 1 ) ~= 3, error( 'sheetcount should be 3' ); end;

disp( '-> ok' )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp( 'check call with 1, 2, 3 and 4 arguments' )

x = xlsread8( '_TestReadFile.xls' );
[x head] = xlsread8( '_TestReadFile.xls' );                   % 1 argument
[x head] = xlsread8( '_TestReadFile.xls', 0 );                % 2 arguments
[x head] = xlsread8( '_TestReadFile.xls', 0, 'double' );      % 3 arguments
[x head] = xlsread8( '_TestReadFile.xls', 0, 'double', 1 );   % 4 arguments

disp( '-> ok' )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp( 'check header (and sheet indexing)' )

[x head] = xlsread8( '_TestReadFile.xls', 0, 'double', 3 );          % no header
if ~isempty( head ), error( 'head should be empty' ); end;
if x(3, 1) ~= 1, error( '1 expected' ); end;              
[x head] = xlsread8( '_TestReadFile.xls', 1, 'double', 3 );          % only header
if strcmp( head{1}, 'Well, this is the header' ) == 0, error( 'head should be "Well, this is the header"' ); end;
if x(2, 1) ~= 1, error( '1 expected' ); end;
[x head] = xlsread8( '_TestReadFile.xls', 2, 'double', 3 );          % only column header
if strcmp( head{1}, 'Well, this is the header' ) == 0, error( 'head should be "Well, this is the header"' ); end;
if size( head, 1 ) ~= 3, error( 'head size should be 3' ); end;
[x head] = xlsread8( '_TestReadFile.xls', 3, 'double', 'Tabelle3' ); % both headers
if strcmp( head{1}, 'Well, this is the header' ) == 0, error( 'head should be "Well, this is the header"' ); end;
if strcmp( head{2}(1), 'firstCol' ) == 0, error( 'head should be "firstCol"' ); end;
if strcmp( head{2}(2), 'secondCol' ) == 0, error( 'head should be "secondCol"' ); end;
if strcmp( head{2}(3), 'thirdCol' ) == 0, error( 'head should be "thirdCol"' ); end;
if x(1, 1) ~= 1, error( '1 expected' ); end;

disp( '-> ok' )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp( 'check cell data' )

[x head] = xlsread8( '_TestReadFile.xls', 0, 'cell', 1 );     % cell (sheet 1)
if ~iscell( x ), error( 'x should be of class cell' ); end;
if strcmp( x{2, 2}, 'Hoi' ) == 0, error( '"Hoi" expected' ); end;
if strcmp( x{3, 3}, 'Chappi' ) == 0, error( '"Chappi" expected' ); end;
if strcmp( x{4, 4}, 'Link: treetron' ) == 0, error( '"Link: treetron" expected' ); end;
if x{6, 1} ~= 998877, error( '98877 expected' ); end;
if x{8, 4} ~= 37614, error( '37614 expected' ); end;

[x head] = xlsread8( '_TestReadFile.xls', 0, 'cell', 2 );     % cell (sheet 2)
if ~iscell( x ), error( 'x should be of class cell' ); end;
if x{7, 2}(1) ~= 'p', error( '"p" expected' ); end;
if x{7, 2}(3) ~= 'o', error( '"o" expected' ); end;
if x{10, 2} ~= 37369, error( '37369 expected' ); end;
if x{11, 2} ~= 2, error( '2 expected' ); end;
y = round( x{15, 2}*100 )/100;   % auf 2 Stellen runden
if y ~= 3454632.46, error( '3454632.46 expected' ); end;
if x{21, 2} ~= 12, error( '12 expected' ); end;

[x head] = xlsread8( '_TestReadFile.xls', 3, 'cell', 3 );     % cell (sheet 3)
if ~iscell( x ), error( 'x should be of class cell' ); end;
if x{2, 1} ~= 2, error( '2 expected' ); end;
if strcmp( x{3, 2}, 'green' ) == 0, error( '"green" expected' ); end;
if x{4, 3} ~= 272, error( '272 expected' ); end;

disp( '-> ok' )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp( 'check struct data' )

[x head] = xlsread8( '_TestReadFile.xls', 3, 'struct', 3 );   % struct
if ~isstruct( x ), error( 'x should be of class cell' ); end;
if x(2).firstCol ~= 2, error( '2 expected' ); end;
if strcmp( x(3).secondCol, 'green' ) == 0, error( '"green" expected' ); end;
if x(4).thirdCol ~= 272, error( '272 expected' ); end;

disp( '-> ok' )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp( 'check double data' )

[x head] = xlsread8( '_TestReadFile.xls', 0, 'double', 1 );     % double
if ~isnan( x(2, 2) ), error( 'NaN expected' ); end;
if ~isnan( x(3, 3) ), error( 'NaN expected' ); end;
if ~isnan( x(4, 4) ), error( 'NaN expected' ); end;
if x(6, 1) ~= 998877, error( '98877 expected' ); end;
if x(8, 4) ~= 37614, error( '37614 expected' ); end;

disp( '-> ok' );

disp( '*******************************************************' )
disp( '*** read8test - Done.                               ***' )
disp( '*******************************************************' )