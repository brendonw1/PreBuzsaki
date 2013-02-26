function frames=laplace(pixels);

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

for a=1:size(linearpixels,3);
    m=-linearpixels(:,:,a);
    m=m(1:end);
    m=sort(m);
%     m=m-(m(1));
    mm=mean(m);
    mhi=mean(m(end-10:end));
    difference1(a)=mhi-mm;
    quotient1(a)=mhi/mm;
    sdev1(a)=std(m);
    avg1(a)=mean(m);
    
    lap=imfilter(linearpixels(:,:,a),h3);%filter/smooth
    lap=del2(lap);%take 2nd spatial derivative of each frame
    lap=imfilter(lap,h4);%filter/smooth
%     lap=del2(lap);%take 2nd spatial derivative of each frame
%     lap=imfilter(lap,h3);%filter/smooth
%     lap=-lap;

    m=lap;
    m=m(1:end);
    m=sort(m);
%     m=m-(m(1));
    mm=mean(m);
    mhi=mean(m(end-10:end));
    difference2(a)=mhi-mm;
    quotient2(a)=mhi/mm;
    sdev2(a)=std(m);
    avg2(a)=mean(m);

    linearpixels(:,:,a)=lap;
end

frames=reshape(linearpixels,size(df));

figure; plot (difference1);
figure; plot (quotient1);
figure; plot (sdev1);
figure: plot (avg1);

figure; plot (difference2);
figure; plot (quotient2);
figure; plot (sdev2);
figure: plot (avg2);

% on=on';
% on=reshape(on,[size(on,1) size(pixels,3)-1 size(pixels,4)]);
% on=shiftdim(on,1); %puts in format of frames x movies x cells