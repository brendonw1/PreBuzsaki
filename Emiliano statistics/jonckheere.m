%Performs Jonckheere test (See: Nonparametric statistics by Siegel and Castellan)
%3 groups a,b,c in that order
%
%
%by Emiliano Rial Verde
%Year 2002.


ab=[];
ac=[];
bc=[];
for i=1:size(a,1)
   ab=[ab; a(i,1)<b];
   ac=[ac; a(i,1)<c];
end
for i=1:size(b,1)
   bc=[bc; b(i,1)<c];
end
absum=sum(ab);
acsum=sum(ac);
bcsum=sum(bc);
j=sum([absum; acsum; bcsum]);
muj=(size([a;b;c],1)^2-sum([size(a,1)^2; size(b,1)^2; size(c,1)^2]))/4;
sigma2j=(1/72)*((size([a;b;c],1)^2)*(2*size([a;b;c],1)+3)-sum([size(a,1)^2*(2*size(a,1)+3); size(b,1)^2*(2*size(b,1)+3); size(c,1)^2*(2*size(c,1)+3)]));
js=(j-muj)/sigma2j;

jp=(1+erf(js/sqrt(2)))./2;