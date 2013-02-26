function [sem,sd]=jackknifelog(vector);

n=length(vector);
for a=1:n;
    means(a)=mean(vector([1:a-1,a+1:end]));
end
means=log(means);

diffs=(means-mean(means)).^2;
clear means;
sem=(((n-1)/n)*sum(diffs))^.5;

sd=sem*(n)^.5;