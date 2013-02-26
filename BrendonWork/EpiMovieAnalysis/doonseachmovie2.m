function doonseachmovie2

for k=46:59;
    k
    di=dir;
    load(di(k).name);
    base=di(k).name(7:15);%slice name and base portion of variables for this slice
    pix=strcat('pixels',base);
    conts=strcat('conts',base);
    len=strcat('lengths',base);
    ima=strcat('image',base);
    notes=strcat('notes',base);
    onname=strcat('ons',base);
    newname=strcat('z',base,'uptoons');
    
    pixels=eval(pix);
    lengths=eval(len);
    contours=eval(conts);
    csl=cumsum(lengths);
    ons=zeros(1,length(contours));
    for b=1:length(lengths);%for each movie
        movie=pixels(:,:,((csl(b)-lengths(b)+1):csl(b)));
        tempons=epimovies(movie,contours,2.75);
%         tempons=bandpassanalysis2(movie,contours,lengths(b));
        ons=cat(1,ons,tempons);
    end
    ons(1,:)=[];%correct for how ons were established before loop
    o=[onname,'= ons;'];
    eval(o);
    s=['save ',newname,' ',pix,' ',conts,' ',len,' ',ima,' ',notes,' ',onname];
    eval(s);
    clear    

end