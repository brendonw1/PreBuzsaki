function outputrec=bootstrap_mann(x,y,rep,nrep1,nrep2)

%Function to bootstrap from 2 datasets and test for difference using mannfunc.m
%Inputs: x and y are the two datasets
%        nrep1 and nrep2 are the min and max n the randomly selected datasets will have
%        rep is the number of times that the test will be repeated per each datasets of size n
%        nrep1, nrep2 and rep are optional arguments
%
%
%by Emiliano Rial Verde
%Year 2003.

if nargin<2
   errordlg('At least 2 sets of data have to be provided');
else
   
   xl=max(size(x));
   yl=max(size(y));
   if size(x,2)==xl
      x=x';
   end
   if size(y,2)==yl
      y=y';
   end
   
   if nargin<3
      rep=100;
      nrep1=2;
      nrep2=max(xl,yl);
   else   
      if nargin<4
         nrep1=2;
         nrep2=max(xl,yl);
      else
         if nargin<5
            if nrep1<=max(xl,yl)
               nrep2=max(xl,yl);
            else
               nrep2=nrep1;
            end
         else
            if nrep2<nrep1
               nrep2=nrep1;
            end
         end
      end
   end
   
   outputrec=[];
   for i=nrep1:nrep2
      significance=[];
      for j=1:rep %repetitions of virtual expt
         index1=ceil(rand(i,1).*xl);
         index2=ceil(rand(i,1).*yl);
         p=mannfunc(x(index1),y(index2));
         significance=[significance; p];
      end
      outputrec=[outputrec significance];
   end
   figure;
   hold on;
   plot((nrep1:1:nrep2), median(outputrec),'-or');
   plot((nrep1:1:nrep2), outputrec','ok','MarkerSize',2);
   beta=sum(outputrec>0.05)/rep;
   plot((nrep1:1:nrep2), beta,'-b');
   hold off;
   ylabel('Mann-Whitney p value');
   xlabel('N');
end