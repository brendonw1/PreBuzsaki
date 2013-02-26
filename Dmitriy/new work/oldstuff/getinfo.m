cd c:\windows\desktop\info2
mt = dir;
mt = mt(3:end);
for c = 1:20
   fclose('all');
   fid = fopen(mt(c).name);
   kval = 0;
   resno = [];
   res10 = [];
   sem = [];
   while kval<2
      st = repmat(' ',1,22);
      while ~(strcmp(st(1:22),' ANALYSIS INTERVAL	 3:') | strcmp(st(1:22),' ANALYSIS INTERVAL   3'))
         st = [fgetl(fid) repmat(' ',1,22)];
      end
      kval = str2num(st(61:end));
      for j = 1:25
         st = fgetl(fid);
      end
      jj = str2num(st);
      resno = [resno; jj(2:end)];
      for j = 1:11
         st = fgetl(fid);
      end
      jj = str2num(st);
      res10 = [res10; jj(2:end)];
      for j = 1:7
         st = fgetl(fid);
      end
      jj = str2num(st);
      sem = [sem; jj(2:end)];
   end
   save(['c:\windows\desktop\paper\new\' mt(c).name '.mat'],'resno','res10','sem');
   fprintf(num2str(c));
end
fclose('all');