function percenthist(vect,bins);

[values,index]=hist(vect,bins);
values=values./length(vect);
bar(index,values);
ylim([0 1]);