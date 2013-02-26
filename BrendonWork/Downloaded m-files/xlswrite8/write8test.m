disp( '*********************************************************' )
disp( '*** write8test - test routines for xlswrite8 function ***' )
disp( '*********************************************************' )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp( 'delete files from former test' )

if exist( '_gen_xlsTest_d.xls', 'file' ), delete( '_gen_xlsTest_d.xls' ); end;
if exist( '_gen_xlsTest_i32.xls', 'file' ), delete( '_gen_xlsTest_i32.xls' ); end;
if exist( '_gen_xlsTest_i32.xls', 'file' ), delete( '_gen_xlsTest_i32.xls' ); end;
if exist( '_gen_xlsTest_c.xls', 'file' ), delete( '_gen_xlsTest_c.xls' ); end;
if exist( '_gen_xlsTest_ce.xls', 'file' ), delete( '_gen_xlsTest_ce.xls' ); end;
if exist( '_gen_xlsTest_s.xls', 'file' ), delete( '_gen_xlsTest_s.xls' ); end;

disp( '-> ok' )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp( 'build matrices' )

  % build matrix
d = repmat( [1 2 3], 20, 1 );
i32 = int32(d);
c = char( 'hallo', 'wie', 'geht''s', 'denn', 'heute', 'so?' );
ce = num2cell( d );
ce{34} = 'this';
ce{3} = 'is';
ce{43} = 'a cell';
s = struct( 'Name', 'Paul', 'Datum', '14.9.1980' );
s(2).Name = 'Dana';
s(2).Datum = '9.2.1972';
s(3).Name = 'John';
s(3).Datum = '9.2.1965';
s(4).Name = 'Peter';
s(4).Datum = '19.8.1935';
s(4).Test = 'value of test 4';
  % header and columnheader
he = 'well, this is the header';
col{1}='first colheader';
col{2}='second...';
col{3}='...and third';

disp( '-> ok' )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp( 'write now' )

tic
xlswrite8( d,'_gen_xlsTest_d.xls' );                  % double; compact form 
time__xlsTest_d = toc
tic
xlswrite8( i32,'_gen_xlsTest_i32.xls', 3, 1 );        % int32; offset
time__xlsTest_i32 = toc
tic
xlswrite8( c,'_gen_xlsTest_c.xls', 0, 0, he, col );   % cell; header and colheader
time__xlsTest_c = toc
tic
xlswrite8( ce,'_gen_xlsTest_ce.xls', 4, 3, he, col ); % cell; offset, header and colheader
time__xlsTest_ce = toc
tic
xlswrite8( s,'_gen_xlsTest_s.xls' );                  % struct; colum header is written automatically
time__xlsTest_s = toc

disp( '-> ok' )

disp( '**********************************************************' )
disp( '*** write8test - Done. Please have a look at the files ***' )
disp( '**********************************************************' )