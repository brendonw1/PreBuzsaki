function writevnt(filename,tmatrix);
%this will create a targets file for vovan fluoview using a premade matrix 
%of targets and target times etc. (6 rows per cell... these will be
%converted into columns in the vnt file)
%Rows of the input tmatrix (each column is a cell):
% 1st row is x-coord
% 2nd row is y
% 3rd row is exposure time in ms
% 4th row is percent pockels cell voltage
% 5th row is 0 for imaging target, 1 for stimulation target
% 6th row is 1 if exectuted, 0 if not

fid=fopen(filename,'w');
fprintf(fid,'%0.3f\t%0.3f\t%0.3f\t%0.3f\t%0.3f\t%0.3f\n',tmatrix);
fclose(fid);