function p=mannfunc(ctrl,trt);
%Function to calculate the Mann-Whitney two-tailed p for samples ctrl and trt.
%Exact permutation method (I think...)
%
%
%by Emiliano Rial Verde
%Year 2002.


dif=[ctrl; trt];
[difabssor,index]=sort(dif);
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
c=size(ctrl,1);
t=size(trt,1);
n=size(dif,1);
sc=sum(rankss(1:c,1));
st=sum(rankss(c+1:end,1));
smaxc=c*t+c*(c+1)/2;
smaxt=c*t+t*(t+1)/2;
uc=smaxc-sc;
ut=smaxt-st;
u=ceil(min(uc,ut));
a=[];
in=max(c,t);
for i=1:in+1
   freq(i,1)=[1];
end
n1=in+2;
for i=n1:c*t+1
   freq(i,1)=[0];
end
b=[0];
for i=2:min(c,t)
   b(i,1)=[0];
   in=in+max(c,t);
   n1=in+2;
   l=1+in/2;
   k=i;
   for j=1:l
      k=k+1;
      n1=n1-1;
      addi=freq(j,1)+b(j,1);
      freq(j,1)=addi;
      b(k,1)=addi-freq(n1,1);
      freq(n1,1)=addi;
   end
end
addi=[0];
for i=1:c*t+1
   addi=addi+freq(i,1);
   freq(i,1)=addi;
end
for i=1:c*t+1
   freq(i,1)=freq(i,1)/addi;
end
p=2*freq(u+1,1);
if p>1
   p=1;
end

