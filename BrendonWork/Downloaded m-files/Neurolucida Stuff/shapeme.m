%
% shapeme.m
%
% By this small Matlab script it is possible to graphically render the
% morphological data available in a *.ASC NeuroLucida ascii file. It is
% then possible to manipulate it and convert it to a variety of vectorized
% file format, such as encapsulated postscript.
%
% Michele Giugliano, PhD, Brain Mind Institute, EPFL, Lausanne (CH)
%
% Contact: michele@giugliano.info
%
% SEE ALSO: MichiTracer
%

%
% Let's make the user choosing the file to be processed..
%
clear all;

PLOTPOINTS = 0;
PLOTDIAMS  = 1;
SP         = 1;
CAL        = 1;

[filename, pathname] = uigetfile('*.asc', 'Pick a data file..');
fullname = sprintf('%s\\%s', pathname, filename);
if (length(filename)<2),
  disp(sprintf('File not found!'));  return;
  % If the file is not found, then return..
end

if (~exist(fullname, 'file')),
  disp(sprintf('File not found!')); return;
  % If the file is not found, then return..
end


figure(1); clf;
axes; 
hold on;
lmax = [-99999, -99999];
lmin = [99999, 999999];
fp = fopen(fullname, 'r'); % Let's open the file for reading..

%-----------------------------------------------------------------
Xs = []; Ys = [];           % Let's prepare to acquire soma countour coordinates..
tmp= '';
% Parsing the input file: search for the keywork '(CellBody)'..
while (~feof(fp) & (strcmp(tmp, '(CellBody)')==0)), tmp = fgetl(fp); end
if (feof(fp)), disp(sprintf('(CellBody) not found!')); fclose(fp); return;  end

% Parsing the input file: search each numeric entry..
tmp= '';
while (~feof(fp) & (strcmp(tmp,')  ;  End of contour')==0)), 
 tmp = fgetl(fp); 
 if (strcmp(tmp,')  ;  End of contour')==0)
  a   = find(tmp=='(');  b   = find(tmp==')');  c   = str2num(tmp(a+1:b-1));
  Xs  = [Xs, c(1)];  Ys  = [Ys, c(2)];
 end
end
if (feof(fp)), disp(sprintf('(CellBody)-end not found!')); fclose(fp); return;  end
Xs = [Xs, Xs(1)]; Ys = [Ys, Ys(1)]; 
if (PLOTDIAMS==0), plo = plot(Xs,Ys,'k-'); set(plo, 'LineWidth', 2); else soma = patch(Xs,Ys,[0 0 0]); end;
Xo = mean(Xs); Yo = mean(Ys);
%-----------------------------------------------------------------

% Parsing the input file: get numeric data for each connected segment..

while (~feof(fp))
 tmp = fgetl(fp); 
 if (strcmp(tmp, '(Dendrite)')==1), 
  if (exist('k', 'var')), plotutil;   end;
  X = {}; Y = {}; D = {}; P = [];
  k = 1;
  X{k} = [Xo]; Y{k} = [Yo]; D{k} = [2];
 end;
 
 if (~isempty(tmp))
  if (~isempty(find(tmp=='(')) & ~isempty(find(tmp==')')))
   a   = find(tmp=='(');    b   = find(tmp==')');   c   = str2num(tmp(a+1:b-1));
   if (~isempty(c)),   X{k} = [ X{k}, c(1) ]; Y{k} = [ Y{k}, c(2) ]; D{k} = [ D{k}, c(4) ]; end;
  end  
 end

 if (strcmp(tmp, '(')==1)
  P = [P ; X{k}(end), Y{k}(end), D{k}(end)]; 
  k = k+1;
  X{k} = []; Y{k} = []; D{k} = [];
  X{k} = [ X{k}, c(1) ]; Y{k} = [ Y{k}, c(2) ]; D{k} = [ D{k}, c(4) ];
 end;
    
 if ( (strcmp(tmp, ' |')==1) | (strcmp(tmp, '|')==1)),
  tmq = P(end,:); 
  k = k+1;
  X{k} = []; Y{k} = []; D{k} = [];
  X{k} = [ X{k}, tmq(1) ]; Y{k} = [ Y{k}, tmq(2) ]; D{k} = [ D{k}, tmq(3) ];
 end;

 if ( (strcmp(tmp, ' )')==1) | (strcmp(tmp, ')')==1)),
  P = P(1:end-1,:); 
 end;

 
end   % while

fclose(fp);
plotutil;
set(gca, 'Position', [0.01 0.01 .99 .99]);
set(gca, 'Visible', 'off');
set(gcf, 'Color', [1 1 1]);
set(gca, 'XLim', [lmin(1)*0.9 lmax(1)*1.1], 'YLim', [lmin(2)*0.9 lmax(2)*1.1]);
%axis square;

if (CAL)
 XLIM = get(gca, 'XLim'); XLIM = min(XLIM) + abs(diff(XLIM))*0.05;
 YLIM = get(gca, 'YLim'); YLIM = min(YLIM) + abs(diff(YLIM))*0.05;
 %L = line(lmin(1)*0.9 + [0 10], [1 1] * YLIM); set(L, 'Color', [0 0 0], 'LineWidth', 3);
 %L = line(lmin(1)*1.3 + [0 10], [1 1] * lmax(2)*0.9); set(L, 'Color', [0 0 0], 'LineWidth', 3);
 L = line(lmax(1)*0.4 - [10 0], [1 1] * lmax(2)*0.9); set(L, 'Color', [0 0 0], 'LineWidth', 3);
 T = text(XLIM*0.5, YLIM*2.3, sprintf('{10 \\mum}'));set(T, 'Color', [0 0 0], 'FontName', 'Arial', 'FontSize', 20, 'Interpreter', 'TeX');
end
hold off;
set(gca, 'View', [0 -90]);
%set(gca, 'XLim', [0 280], 'YLim', [0 280]);
printname = sprintf('%s.eps',fullname(1:end-4));
print(gcf, printname, '-depsc', '-loose');
%-----------------------------------------------------------------