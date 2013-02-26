function [meanvalue, standarddev, dfmeanvalue, dfstandarddev]=pixelsstats(pixels);

df=diff(pixels,1,3);

for m=1:size(pixels,4);
	mv=0;
	mv=sum(sum(sum(pixels(:,:,:,m))));
	meanvalue(m)=mv/(size(pixels,1)*size(pixels,2)*size(pixels,3)*size(pixels,4));%mean of all pixels
	sd=0;
	for movie=1:size(pixels,4);
        for frame=1:size(pixels,3);
            v=sum(sum((pixels(:,:,frame,movie)-meanvalue(m)).^2));
            sd=sd+v;%summating squared diffs.
        end
	end
	standarddev(m)=(sd/(size(pixels,1)*size(pixels,2)*size(pixels,3)*size(pixels,4))).^.5;
end

for m=1:size(pixels,4);
	dmv=0;
	dmv=sum(sum(sum(df(:,:,:,m))));
	dfmeanvalue(m)=dmv/(size(df,1)*size(df,2)*size(df,3)*size(df,4));%mean of all pixels
	dsd=0;
	for movie=1:size(df,4);
        for frame=1:size(df,3);
            v=sum(sum((df(:,:,frame,movie)-dfmeanvalue(m)).^2));
            dsd=dsd+v;%summating squared diffs.
        end
	end
	dfstandarddev(m)=(dsd/(size(df,1)*size(df,2)*size(df,3)*size(df,4))).^.5;
end