function barbyme(data1, data2, name, bartitle, xtext, ytext)

%Bar graph
%Use vectors data1 and data2 to enter the elements of the first and second data sets.
%Complete title and xtext or leave blank.
%Use name1 and name2 for the names of data set 1 and 2.

if nargin < 2
   'Error: less than 2 data sets.'
   
elseif nargin>6
   'Error: too many arguments.'
else
   if exist('name')
      if iscell(name)
         if max(size(name))==2
         else
            name={'data1' 'data2'};
         end
      else
         name={'data1' 'data2'};
      end
   else
      name={'data1' 'data2'};
   end
   
   if exist('bartitle')
      if ischar(bartitle)
      else
         bartitle=' ';
      end
   else
      bartitle=' ';
   end
   
   if exist('xtext')
      if ischar(xtext)
      else
         xtext=' ';
      end
   else
      xtext=' ';
   end
   
   if exist('ytext')
      if ischar(ytext)
      else
         ytext=' ';
      end
   else
      ytext=' ';
   end

   a=[1 3];
   b=[median(data1) median(data2)];
   quart25=[prctile(data1,25) prctile(data2,25)];
   quart75=[prctile(data1,75) prctile(data2,75)];
   
   barfig=figure;
   set(barfig, 'numbertitle', 'off', ...
      'name', 'Median and IQR bar graph', ...
      'units', 'normalized', ...
      'position', [.446 .08 .5469 .5469]);
   orient landscape;
   h1=bar(a, b, .8, 'w');
   hold on;
   errorbar(a, b, quart25-b, quart75-b, '.k');
   hold off;
   set(gca, 'xlim', [a(1,1)-2 a(end,end)+2], 'xticklabel', name, ...
      'ylabel', text('string', [ytext, '. (median & IQR)'], 'FontSize',10, 'FontWeight', 'bold'), ...
      'xlabel', text('string', xtext, ...
      'FontSize',10, 'FontWeight', 'bold'), 'FontWeight', 'bold', 'FontSize',10);
   title(bartitle, 'FontSize',12, 'FontWeight', 'bold');
end