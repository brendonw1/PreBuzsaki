function doons

assignin('base','totalmovies',0);
for a=3:39;
    totalmovies=evalin('base','totalmovies');
    totalmovies=totalmovies+1;
    assignin('base','totalmovies',totalmovies);

    di=dir;
    load(di(a).name);
    base=di(a).name(1:9);%slice name and base portion of variables for this slice
    pix=strcat('pixels',base);
    conts=strcat('conts',base);
    lengths=strcat('lengths',base);
    newname=strcat('new',base,'uptoons');
    ons2=bandpassanalysis(eval(pix),eval(conts),eval(lengths));
    save(newname)%save all of the variables in the matlab file with the name ons2SLICENAME.mat
    clear    
%     
%     
%     di=dir;
%     load(di(a).name);
%     base=di(a).name(1:9);%slice name and base portion of variables for this slice
%     pix=strcat('pixels',base);
%     conts=strcat('conts',base);
%     lengths=strcat('lengths',base);
%     ons2=strcat('ons2',base);
%     newname=strcat('new',base,'uptoons')
%     
%     eval('ons2')=bandpassanalysis(eval('pix')
%     save(newname)%save all of the variables in the matlab file with the name ons2SLICENAME.mat
%     clear    
end
    