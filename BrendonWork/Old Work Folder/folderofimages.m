function folderofimages

di=dir;
for index=3:size(di,1);
    load(di(index).name);
    wh=whos;
    filename=di(index).name;
    filename(end-3:end)=[];
    filename=strcat(filename,'.tiff');
    image=eval(wh(index).name);
    image=image-min(min(image));
    image=image./max(max(image));
    imwrite(image,filename,'compression','none');
end