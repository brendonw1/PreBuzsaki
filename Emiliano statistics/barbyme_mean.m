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
   b=[mean(data1) mean(data2)];
   quart25=[mean(data1)-std(data1)/sqrt(length(data1)) mean(data2)-std(data2)/sqrt(length(data2))];
   quart75=[mean(data1)+std(data1)/sqrt(length(data1)) mean(data2)+std(data2)/sqrt(length(data2))];
   
   barfig=figure;
   set(barfig, 'numbertitle', 'off', ...
      'name', 'Median and IQR bar graph', ...
      'units', 'normalized', ...
      'position', [.446 .08 .5469 .5469]);
   orient landscape;
   h1=bar(a, b, .8, 'w');
   hold on;
   errorbar(a, b, quart25, quart75, '.k');
   hold off;
   set(gca, 'xlim', [a(1,1)-2 a(end,end)+2], 'xticklabel', name, ...
      'ylabel', text('string', [ytext, '. (mean +/- SEM)'], 'FontSize',10, 'FontWeight', 'bold'), ...
      'xlabel', text('string', xtext, ...
      'FontSize',10, 'FontWeight', 'bold'), 'FontWeight', 'bold', 'FontSize',10);
   title(bartitle, 'FontSize',12, 'FontWeight', 'bold');
end