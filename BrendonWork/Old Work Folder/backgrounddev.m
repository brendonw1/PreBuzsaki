function backsds=backgrounddev(pixels,template);

for movie=1:size(pixels,4);
    for frame=1:size(pixels,3);
        f=pixels(:,:,frame,movie);
        backsds(:,frame,movie)=f(template);
    end
end

backsds=std(backsds,0,1);