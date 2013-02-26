function threshd=subtractmeanthreshsd(image);

mea=sum(sum(image))/(size(image,1)*size(image,2));
sdev=std2(image);
threshd=image-mea;
threshd(find(threshd<3*sdev))=0;