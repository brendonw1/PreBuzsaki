function X = SuperscopeReader;
% 
% * @author Volodymyr Nikolenko 
% * Department of Biological Sciences, Columbia University
% * @version 0.10
% */

[filename, pathname] = uigetfile({'*.*'}, 'Choose file to read');
fnm = strcat(pathname,filename)
prompt = {'Start point :'};
dlg_title = 'Define frames to process';
num_lines= 1;
def     = {'106'};
answer  = inputdlg(prompt,dlg_title,num_lines,def);
startPoint = strread(answer{1}, '%u' )
fid = fopen(fnm,'r','b');
fseek(fid, startPoint, 'bof');
[X, count] = fread(fid, inf, 'float32');