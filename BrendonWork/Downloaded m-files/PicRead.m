function [imout, chanls] = PicRead(filename, head)
%PicRead reads a bitmap file in the .PIC-format used by the palmtop
% computer PSION Series 3c.
%
% [imout, chanls] = PicRead(filename, head);
%
% filename ... filename of the .PIC-file, including extension.
%
% head ....... if head > 0 then all header info is displayed, 
%              default = 0.
%
% imout ...... output picture; = imout(row, col, bitmap_no); black is
%              coded as 0, white is coded as 1; output image, frame
%              interleaved.
%
% chanls ..... number of bitmaps, optional.
%
% If no output arguments are specified then imout is displayed.

% Code: Matlab 5.
%
% P M W Nave; peter.nave@dbag.muc.daimlerbenz.com
% 1997-05-22, latest revision: 1997-10-08.
%----------------------------------------------------------------------O
  if nargin == 0; filename = input(' >>> Filename: ', 's'); end
  if nargin < 2; head = 0; end
  
  fid = fopen(filename, 'r');
  if fid < 3; error(['### PicRead: ', filename, ' NOT opened.']); end;
  [xx, count] = fread(fid, inf, 'uchar');  
  if sum(abs(xx(1:6) - [80; 73; 67; 220; 48; 48]));
     error(['### PicRead: ', filename, ...
            ' is not a valid PIC binary encoded image.']); end;
  fclose(fid);
   
  ww = [1; 256];
  chans = xx( 7: 8)' * ww;
  Gcols = xx(11:12)' * ww; 
  Rows  = xx(13:14)' * ww;
  if nargout > 0
     imout = zeros(Rows, Gcols, chans);
  else 
     handle = zeros(4);
  end
%
% CRC is not checked.
%
  if head; PicRead3(filename, xx(1:8)); end

  for cc = 1:chans
     ct = 11 + (cc - 1) * 12;
     gcols = xx(ct:ct + 1)' * ww;
     rows  = xx(ct + 2:ct + 3)' * ww;
     bytfr = xx(ct + 4:ct + 5)' * ww;
     bordr = xx(ct + 6:ct + 9)' * [ww; 256 * 256 * ww] + ct + 9;
     bcols = bytfr / rows;
     if bcols ~= floor(bcols); 
        error('### PicRead: error in rows/cols.'); 
     end;
     if rows > Rows
        imout = [imout; zeros(rows - Rows, Gcols, chans)];
        Rows = rows;
     end
     if gcols > Gcols
        imout = [imout, zeros(Rows, gcols - Gcols, chans)];
        Gcols = gcols;
     end

     if head; PicRead3(cc, xx(ct - 2:ct + 9)); end
  
     hh = xx(bordr + 1:bytfr + bordr);   
     hh = (reshape(hh, bcols, rows))';
     hh = 1 - PicRead2(hh);
     hh = hh(:, 1:gcols);

     if nargout == 0
        loc = rem(cc, 4) + 1;
        if handle(loc) > 0; close(handle(loc)); end
        handle(loc) = figure;
        image(hh * 255); colormap(gray(256)); axis image
        title(['bitmap no. ', int2str(cc)]);
     else
        imout(1:rows, 1:gcols, cc) = hh;
     end
  end
  if nargout > 1; chanls = chans; end;

  disp(' ');
  if chans == 1; suff = ''; else; suff = 's'; end;
  disp(['--- PicRead: ', filename, ' successfully read,']);
  disp(['             ', int2str(chans), ' channel', suff, ', ', ...
       int2str(Rows), ' rows, ', int2str(Gcols), ' columns.']);
  disp(' ');
%
% End of PicRead.

function gg = PicRead2(bb);
% Decompresses a compressed image from bit/pixel to byte/pixel.
%
% bb ............... compressed image, eight pixels per byte.
%
% gg ............... decompressed binary image, one byte per pixel. gg
%                    can assume only the values 0 and 1. 

% Prepare table bt.
%
  bt = zeros(256, 8);
  xx = 0:255;
  for ii = 0:7
     bt(xx + 1, ii + 1) = (rem(floor(xx ./ 2^ii), 2))';
  end
%
% Expand.
%
  [rows, bcols] = size(bb);
  bb = reshape(bb', rows * bcols, 1) + 1;
  gg = zeros(rows * bcols, 8);
  gg(:, :) = bt(bb(:), :);
  gg = (reshape(gg', bcols * 8, rows))';
%
% End of PicRead2.

function PicRead3(filename, tt)
  ww = [1; 256];
  if prod(size(tt)) == 8
     disp(' ')
     disp(['--- Header of ', filename, ':']); 
     disp(['    Mandatory part:           ', char(tt(1:3)'), ' ', ...
                int2str(tt(4:6)')])

     chans = tt(7:8)' * ww;
     disp(['    Number of bit planes:     ', int2str(chans)])
  else
     cc = filename;
     rows = tt(5:6)' * ww; cols = tt(3:4)' * ww;
     disp(' ')
     disp(['    --- Bit plane no. ', int2str(cc), ' --- '])
     disp(['    CRC number:                 ', int2str(tt(1:2)' * ww)])
     disp(['    Number of rows:             ', int2str(rows)])
     disp(['    Number of columns:          ', int2str(cols)])
     disp(['    Number of bytes in plane:   ', int2str(tt(7:8)' * ww)])
     disp(['    Number of pixels in plane:  ', int2str(rows * cols)])
     disp(['    Offset:                     ', ...
                int2str(tt(9:12)' * [ww; 256 * 256 * ww])])
     disp(' ')
  end
%
% End of PicRead3.
% End of PicRead.m
