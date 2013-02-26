function on=detectoncells(pixels,contours);

warning off MATLAB:conversionToLogical
pixels=double(pixels);
df=diff(pixels,1,3);
% denominator=pixels(:,:,1:(size(pixels,3)-1),:);
% df=df./denominator;

% linearpixels=outsidecontours(contours,df);%subtracts background from each frame, and linearizes movies into a big
%                                         % continuous string of frames, with no breaks for movies

linearpixels=reshape(df,[size(df,1) size(df,2) (size(df,3)*size(df,4))]);%a series of frames, not broken into movies

h4=ones(4,4)/16;
h3=ones(3,3)/9;
thr=40;

for a=1:size(linearpixels,3);
    m=-linearpixels(:,:,a);
    m=m(1:end);
    m=sort(m);
    m=m-(m(1));
    mm=mean(m);
    mhi=mean(m(end-10:end));
    difference(a)=mhi-mm;
    quotient(a)=mhi/mm;
    
    n=-linearpixels(:,:,a);
    n=imfilter(n,h4);
    nn=n(1:end);
    nn=mean(nn);
    n=n-nn;
    
    lap=imfilter(linearpixels(:,:,a),h3);%filter/smooth
    lap=del2(lap);%take 2nd spatial derivative of each frame
    lap=imfilter(lap,h4);%filter/smooth
%     lap=del2(lap);%take 2nd spatial derivative of each frame
%     lap=imfilter(lap,h3);%filter/smooth
%     lap=-lap;

%     l=lap(1:end);
%     l=sort(l);
%     l=mean(l(round(.25*length(l)):round(.75*length(l))));
%     lap=lap-l;

%     [thr,sorh,keepapp] = ddencmp('den','wv',lap);
%     [swa,swh,swv,swd] = swt2(lap,5,'sym2');
%     dswh = wthresh(swh,'h',thr);
%     dswv = wthresh(swv,'h',thr);
%     dswd = wthresh(swd,'h',thr);
%     lap = iswt2(swa,dswh,dswv,dswd,'sym2');

%     l=lap(1:end);
%     l=sort(l);
%     l=mean(l(round(.25*length(l)):round(.75*length(l))));
%     lap=lap-l;
%     
%     figure;hist(lap(1:end));
%     a
%     sdev=std(lap(1:end))
%     rng=range(lap(1:end))
    
    tempconts=[];
    tempconts=findfrommatrix(n,950,2,20);%find contours of active cells
    
    centers=[];
    for b=1:length(tempconts);%for each contour just created
        centers(b,:)=centroid(tempconts{b});%get centroid, put in "centers", which will have height b, width 2
    end
    if sum(sum(centers)) > 0;    
        i=[];
        for c=1:length(contours);%for each contour from original image...
            i(:,c)=inpolygon(centers(:,1),centers(:,2),contours{c}(:,1),contours{c}(:,2));%determine if any centroid 
            % is in that contour
            % i will have a row for each original contour, a column for each centroid
        end
        isum=sum(i,1);%produces a horizontal vector, width equals # of original contours: 1 if that cell turned on, 0 if not
        isum=logical(isum);%makes sure nothing more than 1
        on(a,:)=isum;%on will be 2D: cells x frames
%         plotfromcontours(contours);    
    end
end
figure; plot (difference)
figure; plot (quotient)

on=on';
on=reshape(on,[size(on,1) size(pixels,3)-1 size(pixels,4)]);
on=shiftdim(on,1); %puts in format of frames x movies x cells