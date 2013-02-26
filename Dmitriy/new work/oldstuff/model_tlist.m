function model_tlist(fout,nphase,ntrial,varargin)
%model_tlist(fout,nphase,ntrial,varargin)
%   generates a Poisson model tlist
%   every component must be in the form [mean_rate peak_phase start end]

m = cell(nphase,ntrial);
for c = 1:size(varargin,2)
   inp = varargin{c};
   mnrt = inp(1);
   pkph = inp(2);
   strt = inp(3);
   ends = inp(4);
   rt = cos(((0:nphase-1)-pkph/(360/nphase))/nphase*2*pi);
   rt = rt + 1;
   rt = rt * mnrt;
   for ph = 1:nphase
      for tr = 1:ntrial
         m{ph,tr} = [m{ph,tr} poisson(rt(ph),ends-strt)+strt];
      end
   end
end

fid = fopen(fout,'w');
for ph = 1:nphase
   for tr = 1:ntrial
      m{ph,tr} = sort(m{ph,tr});
      for c = 1:size(m{ph,tr},2)
         fprintf(fid,num2str(m{ph,tr}(c)));
         fprintf(fid,'\n');
      end
      if tr < ntrial
         fprintf(fid,'-1\n');
      end
   end
   if ph < nphase
      fprintf(fid,'-2\n');
   end
end
fprintf(fid,'-3');
fclose(fid);