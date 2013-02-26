function on=contourseveryframe(contours,pixels,thresh,minarea,maxarea);
%may want to take derivative of movies over frames before puttting into
%this program.

% df=diff(pixels,1,3);
% df2=reshape(df,[size(df,1) size(df,2) (size(df,3)*size(df,4))]); %a series of df frames, not broken into movies
% df3=-df2;


linearpixels=reshape(pixels,[size(pixels,1) size(pixels,2) (size(pixels,3)*size(pixels,4))]);%a series of df frames, not broken into movies
% template=outsidecontours(contours,pixels);


% m=min(df3);n=max(df3);
% m=min(m);n=max(n);
% m=min(m);n=max(n);
% d=n-m;
% df3=df3-m;df3=df3*(256/d);%normalized all diffs in all movies all together

for a=1:size(linearpixels,3);%for each frame
    tempconts=findfrommatrix(linearpixels(:,:,a),thresh,minarea,maxarea);
%     centers=zeros(length(tempconts));
    for b=1:length(tempconts);%for each contour just created
        centers(b,:)=centroid(tempconts{b});%get centroid, put in centers, which will have height b, width 2
    end
    i=[];
    for c=1:length(contours);%for each contour from original image
        i(:,c)=inpolygon(centers(:,1),centers(:,2),contours{c}(:,1),contours{c}(:,2));%determine if any centroid is in that contour
        % i will have a row for each original contour, a column for each centroid
    end
    isum=sum(i,2);%produces a vertical vector, height equals # of original contours: 1 if that cell turned on, 0 if not
    isum=logical(isum);%makes sure nothing more than 1
    on=[];
    on(:,c)=isum;%on will be 2D: cells x frames
end

% on=on';
on=reshape(on,[size(on,1) size(pixels,3)-1 size(pixels,4)]);
on=shiftdim(on,2); %puts in format of frames x movies x cells