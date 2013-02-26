function detrendhisto(filename);

a2=unbleach(filename);

figure
hist(a2,50);

title(['Histogram of brightness values.  Kurtosis = ',num2str(kurtosis(a2))]);