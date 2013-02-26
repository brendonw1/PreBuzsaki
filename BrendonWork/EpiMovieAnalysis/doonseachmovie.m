function doonseachmovie

% assignin('base','totalmovies',0);
for a=3:39;
%     totalmovies=evalin('base','totalmovies');
%     totalmovies=totalmovies+1;
%     assignin('base','totalmovies',totalmovies);

    di=dir;
    load(di(a).name);
    base=di(a).name(1:9);%slice name and base portion of variables for this slice
    pix=strcat('pixels',base);
    conts=strcat('conts',base);
    len=strcat('lengths',base);
    dfname=strcat('df',base);
    newname=strcat('new',base,'uptoons');

    pixels=eval(pix);
    lengths=eval(len);
    contours=eval(conts);
    csl=cumsum(lengths);
    ons2=zeros(1,length(contours));
    for b=1:length(lengths);%for each movie
        movie=pixels(:,:,((csl(b)-lengths(b)+1):csl(b)));
        tempons2=bandpassanalysis(movie,contours,lengths(b));
        ons2=cat(1,ons2,tempons2);
%         assignin('base','ons2',ons2);
    end
    ons2(1,:)=[];
    clear di base pix conts len dfname pixels lengths contours tempons2 a b
    save(newname)%save all of the variables in the matlab file with the name ons2SLICENAME.mat
    clear    

end
    