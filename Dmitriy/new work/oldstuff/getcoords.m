function getcoords = getcoords(fname)
%coords = getcoords(fname)
%   Opens the file fname and reads all MDS coordinates.
%
%   The output structure, coords, contains the following fields:
%         .ncl: number of classes
%         .int: analysis intervals (#ints x 2)
%         .lp: label parameters (1 x #params)
%              (empty if fname is not a labeled metric file)
%         .cps: cost/second parameters (1 x #costs)
%         .type: distance type (#types x 10 character array)
%         .ish: boolean arrays specifying which coordinates are
%               hyperbolic (i.e. which eigenvalues are negative)
%               (#ints x #types x #costs x #params 4-D cell array
%                  or #ints x #types x #costs 3-D cell array,
%                  depending on whether the metric is labeled,
%               each entry is 1 x #eigs)
%         .eiv: coordinate arrays
%              (same as .ish, each entry is #classes x #eigs)
%   If a particular combination of parameters was not found in the
%      file, corresponding entries in .ish and .eiv will be empty.
%
%   To create an input file for the MDS program save these three
%      variables to a .mat file:
%         eiv = coords.eiv{int,type,q,k}
%         ish = coords.ish{int,type,q,k}
%         npt = ones(1,coords.ncl)
%      where int, type, q, k, are the indexes of parameters
%      (analysis interval, distance type, cost/sec, label parameter
%       respectively) that need to be visualized.
%      Omit k if the metric is not labeled.
%
%   Written by Dmitriy Aronov, 8/31/2000.

tempn = tempname;
width = set_width(fname,tempn,[]);
fid = fopen(tempn);
st = fread(fid,'char');
st = reshape(st,width,size(st,1)/width)';
st = char(st);
st = st(:,2:end);
fclose(fid);
delete(tempn);

f = strmatch('TOTAL NUMBER OF CLASSES',st);
ncl = str2num(st(f,25:end));
coords.ncl = ncl;
anal = strmatch('ANALYSIS INTERVAL',st);
lbl = sort(str2num(st(anal,18:21)));
for c = 1:max(lbl)
   f = find(lbl==c);
   f = f(1);
   coords.int(c,1) = str2num(st(anal(f),23:31));
   coords.int(c,2) = str2num(st(anal(f),34:43));
end
strt = strmatch('INTERVAL',st);
begn = strmatch('MULTIDIMENSIONAL SCALING',st)+1;
endn = strmatch('NUMBER OF COSTS',st)-1;
lbl = strmatch('LABELPARAMS',st(:,48:58));
lbl = sort(str2num(st(lbl,60:end)));
if isempty(lbl)
   lbl = 0;
end
lbls = lbl(1);
for c = 2:size(lbl,1)
   if lbls(end) ~= lbl(c)
      lbls = [lbls; lbl(c)];
   end
end
coords.lp = lbls';
lbl = sort(str2num(st(strt+2,16:end)));
costs = lbl(1);
for c = 2:size(lbl,1)
   if costs(end) ~= lbl(c)
      costs = [costs; lbl(c)];
   end
end
coords.cps = costs';
for c = begn:endn
   types(c-begn+1,:) = st(c,1:10);
end
coords.type = types;
for c = 1:size(strt,1)
   beg = strt(c);
   int = str2num(st(beg,9:12));
   type = strmatch(st(beg+2,1:10),types);
   cps = str2num(st(beg+2,16:end));
   cps = find(costs == cps);
   f = find(anal < beg);
   f = anal(f(end));
   lp = str2num(st(f,60:end));
   if isempty(lp)
      lp = 0;
   end
   lp = find(lbls == lp);
   ish = sign(sign(str2num(st(beg+10,8:end))) + 0.5);
   coords.ish{int,type,cps,lp} = -sign(ish-1);
   coords.eiv{int,type,cps,lp} = str2num(st((beg+15):(beg+14+ncl),8:end));
end

if coords.lp == 0
   coords.lp = [];
end
getcoords = coords;
   
function width = set_width(input,output,width)
%set_width(input,output,width)
%   Adds spaces at the end of all lines in the file to make them the same width.
%   If width is empty, it is set to the longest line in the file

fin = fopen(input,'r');
if fin == -1
   error('Error reading input file!');
end
fout = fopen(output,'w');
if fout == -1
   error('Error creating output file!');
end

st = fread(fin,'char')';
f = find(st == 13);
rp = f - [-1 f(1:end-1)] - 2;
st(f) = rp;
if isempty(width)
   width = max(rp);
end

st = char(st);
for c = min(rp):max(rp)
   st = strrep(st,[char(c) char(10)],repmat(' ',1,width-c));
end

fwrite(fout,st);
fclose(fin);
fclose(fout);