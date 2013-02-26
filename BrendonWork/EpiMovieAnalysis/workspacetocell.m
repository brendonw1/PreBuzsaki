w=whos;
for a=1:size(w,1);
    n=w(a).name;
    m=eval(n);
    cell{a}=m;
end
clear w a n m