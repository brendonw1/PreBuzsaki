function [myfilter, expa] = myfilter(mm, num)
%myfilter = myfilter(m, num)
%   performs num-order Hanning filtering of the data

m=reshape(mm,[length(mm) 1]);%necessary for padding
m = padarray(m,num,'symmetric','both');
m = m';%make a horizontal vector again... in case necessary
% [mm(1:num) mm mm(end-num+1:end)];%padding?
fl = hanning(2*num+1)';%
fl = fl/sum(fl);

sz = size(m,2);%convolving manually?
[x1 y] = meshgrid(1:sz,1:num);
y = flipud(y);
x1 = x1-y;
x1 = x1.*((sign(x1-.5)+1)/2)+(1-(sign(x1-.5)+1)/2);
x2 = fliplr(flipud((sz+1)*ones(num,sz)-x1));
x = [x1; 1:sz; x2];
x = m(x);

myfilter = fl*x;
myfilter = myfilter(num+1:num+size(mm,2));%get rid of pads
expa = max(x);