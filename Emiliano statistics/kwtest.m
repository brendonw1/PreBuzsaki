%Performs Kruskal-Wallis (See: Nonparametric Statistics by Siegel and Castellan, McGraw Hill, 1988)
%Assumes Chi-square distribution. Valid if 3 or more groups with n>5.
%No ties correction!
%Post-hoc test as in Siegel and Castellan. One-tailed for comparisons against a control group.
%The post-hoc test it is the same or similar to the Dunnett's test.
%Choose control group to do the post-hoc test
%
%
%by Emiliano Rial Verde
%Year 2002.


data=reshape(datamat, size(datamat,1)*size(datamat,2),1);

[sor, index]=sort(data);
rank=[];
for i=1:size(data,1)
   rank(i,1)=i;
end
ranks=[];
for i=1:size(data,1)
   ranks(index(i,1),1)=rank(i,1);
end

datarankmean=mean(reshape(ranks, size(datamat,1),size(datamat,2)))
dataranksum=sum(reshape(ranks, size(datamat,1),size(datamat,2)))
kw=((12/(size(data,1)*(size(data,1)+1)))*sum(size(datamat,1).*(datarankmean.^2)))-3*(size(data,1)+1)
kwp=1-gammainc(kw/2, (size(datamat,2)-1)/2)
%Post-Hoc test to compare against the selected control group
a=[];
b=[];
c=[];
diff=[];
ctrln=[];
n=[];
root=[];
a=datarankmean;
a(ctrlgroup)=[];
b=datarankmean(ctrlgroup);
diff=abs(b-a);
ctrln=size(datamat,1);
n=[];
n=repmat(size(datamat,1), 1, size(datamat,2));
n(ctrlgroup)=[];
c=(size(datamat,1)-1); %For the one-tailed distribution. For two-tailed multiply c by 2
root=sqrt(((size(data,1)*(size(data,1)+1))/12).*((1/ctrln)+(1./n)));
php=(1-normp(diff./root)).*c