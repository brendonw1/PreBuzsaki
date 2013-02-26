function [p, z, n]=distsym(x)

%Test for distributional symmetry
%from "Nonparametric Statistics for the Behavioral Sciences" Second Ed.
%by Siegel and Castellan, McGraw-Hill, 1988.
%Adapted from the program in the Apendix II of that book.
%Nonparametric test.
%Ho: The distribution of the data in x is symmetric
%CAUTION: N>=20 is desirable for the test to be acceptable.
%The p value is two-tailed. Obtained from the normal distribution as the z statistic
%   is asymptotically normally distributed with mean=0 and variance=1.
%
%
%by Emiliano Rial Verde
%Year 2003.


n=size(x,1);
t=0;
t1=zeros(n,1);
t2=zeros(n,n);

for i=1:(n-2)
   for j=(i+1):(n-1)
      for k=(j+1):n
         ave=(x(i)+x(j)+x(k))/3;
         numbers=[x(i); x(j); x(k)];
         numbers=sort(numbers);
         if ave>numbers(2)
            rl=1;
         elseif ave<numbers(2)
            rl=-1;
         else
            rl=0;
         end
         t=t+rl;
         t1(i)=t1(i)+rl;
         t1(j)=t1(j)+rl;
         t1(k)=t1(k)+rl;
         t2(i,j)=t2(i,j)+rl;
         t2(j,k)=t2(j,k)+rl;
         t2(i,k)=t2(i,k)+rl;
      end
   end
end
b1=t1(n)^2;
b2=0;
for i=1:(n-1)
   b1=b1+t1(i)^2;
   for j=(i+1):n
      b2=b2+t2(i,j)^2;
   end
end

variance=(b1*(n-3)*(n-4))/((n-1)*(n-2)) + b2*(n-3)/(n-4) + n*(n-1)*(n-2)/6 - (1-((n-3)*(n-4)*(n-5)/(n*(n-1)*(n-2))))*t^2;
z=t/sqrt(variance);
p=(1-((1+erf(z/sqrt(2)))./2))*2;
if p>1
   p=1;
end
