function a2=unbleach(filename);
%This function detrends (unbleaches) a vector stored in excel 5.0 format and saves it to a
%comma-separated value file.  It also displays both the original and
%detrended (unbleached) data in figures and outputs the detrended data as a
%variable.

a=xlsread(filename);%read data from an excel 5.0/95 file
a=a(:,2);%save second column only

a2=detrend(a);%divide by line of best fit
a2=a2-min(a2);
a2=a2/max(a2);%normalize... all values now between 0 and 1

csvwrite(['unbleached_',filename],a2)

figure;
plot(a);
title('Original data');
xlabel('Frame number');
ylabel('Brightness');

figure;
plot(a2);
title('Unbleached data');
xlabel('Frame number');
ylabel('Brightness');