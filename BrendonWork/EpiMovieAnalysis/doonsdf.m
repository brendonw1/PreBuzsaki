function doonsdf

assignin('base','totalmovies',0);
for a=3:39;
    totalmovies=evalin('base','totalmovies');
    totalmovies=totalmovies+1;
    assignin('base','totalmovies',totalmovies);

    di=dir;
    load(di(a).name);
    base=di(a).name(10:18);%slice name and base portion of variables for this slice
    pix=strcat('pixels',base);
    conts=strcat('conts',base);
    len=strcat('lengths',base);
    dfname=strcat('df',base);
    newname=strcat('new',base,'uptoons');
    cs=cumsum(eval(lengths));

    pixels=eval(pix);
    lengths=eval(len);
    assignin('base','lengths',lengths);
    
    ons2=bandpassanalysisdf(eval(dfname),eval(conts),eval(lengths));
    save(newname)%save all of the variables in the matlab file with the name ons2SLICENAME.mat
    clear    

end
    