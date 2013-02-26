function p=wilcoxon(ctrl,trt)
%Script to calculate Wilcoxon paired two-tailed probability based on pairs of ctrl and trt values
%Name the vector with the control data as ctrl. The vector should be of size(n,1). The corresponding 
%data vactor to compare with should be called trt and also have size(n,1).
%
%
%by Emiliano Rial Verde
%Year 2002.


dif=ctrl-trt;
del=[];
for i=1:size(dif,1)
   if dif(i,1)==0
      del=[del; i];
   end
end
for i=1:size(del,1)
   dif(del(i,1)-(i-1),:)=[];
end
difabs=abs(dif);
[difabssor,index]=sort(difabs);
ranks=[];
for i=1:size(dif,1)
   ranks(i,1)=i;
end
for i=1:size(dif,1)-3
   if difabssor(i,1)==difabssor(i+3,1)
      ranks(i:i+3,1)=(ranks(i,1)+ranks(i+1,1)+ranks(i+2,1)+ranks(i+3,1))/4;
   else
      for i=1:size(dif,1)-2
         if difabssor(i,1)==difabssor(i+2,1)
            ranks(i:1+2,1)=(ranks(i,1)+ranks(i+1,1)+ranks(i+2,1))/3;
         else
            for i=1:size(dif,1)-1
               if difabssor(i,1)==difabssor(i+1,1)
                  ranks(i:i+1,1)=(ranks(i,1)+ranks(i+1,1))/2;
               end
            end
         end
      end
   end
end
rankss=[];
for i=1:size(dif,1)
   rankss(index(i,1),1)=ranks(i,1);
end

w=sum(abs(rankss));
n=size(dif,1);
wpos=[0];
wneg=[0];
for i=1:size(dif,1)
   if dif(i,1)>0
      wpos=wpos+rankss(i,1);
   elseif dif(i,1)<0
      wneg=wneg+rankss(i,1);
   end
end
s=ceil(min(wpos,wneg));
a=[1];
for i=1:n
   b=zeros(i,1);
   c=[a;b];
   d=[b;a];
   a=c+d;
end
pm=a/sum(a);
p=2*sum(pm(1:s+1));
