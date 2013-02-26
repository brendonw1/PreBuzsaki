function df=dffo(pixels);

df=diff(pixels,1,3);
df=df./(pixels(:,:,1:(size(pixels,3)-1)));