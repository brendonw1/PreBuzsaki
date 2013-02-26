function dataout=out_lier(data, crit)

%Outlier removal function. Using crit*StDev criterion.
%Inputs: data must be a vector and crit a number.
%The default criterion is 2.5
%
%by Emiliano Rial Verde
%Year 2003.

if nargin<2
   crit=2.5;
end

a=1;
while a>0
   b=[];
   b=mean(data)-crit*std(data);
   c=[];
   c=mean(data)+crit*std(data);
   a=size([find(data<b); find(data>c)]);
   if isempty(a)
      a=0;
   end
   data(find(data<b))=[];
   data(find(data>c))=[];
end

dataout=data;