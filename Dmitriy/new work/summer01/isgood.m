function isgood = isgood(c)
%isgood = isgood(c)
%    asks user to determine whether a trace is good

warning off;
gonorm;
mt = dir('*.txt');
set(gcf,'position',[1 29 1024 672]);
set(gcf,'numbertitle','off');
[datapt, deltat, pos] = text2mat(mt(c).name);
if prod(pos) == 0
   isgood = 0;
else
   for j = 1:size(datapt,1)
      set(gcf,'name',['File ' num2str(c) '; trace ' num2str(j) ' of ' num2str(size(datapt,1))]);
      plot(datapt(j,:));
      xlim([1 size(datapt,2)]);
      k = waitforbuttonpress;
   end
   delete(gcf);
   button = questdlg('Was this a good trace?','Decision','Yes','No','Yes');
   if strcmp(button,'Yes')
      isgood = 1;
   else
      isgood = 0;
   end
end