function filtered=bandpassimage2(image,smalldiameter,largediameter);

centerx=size(image,2)/2;%center point of the x dimension
centery=size(image,1)/2;%center point of the y dimension

lfreq1=round(size(image,1)/largediameter);%frequency on image dimension 1 that corresponds to large diameter
lfreq2=round(size(image,2)/largediameter);%frequency on image dimension 2 that corresponds to large diameter
lfreq=min([lfreq1 lfreq2]);%smaller of the two must be used

sfreq1=round(size(image,1)/smalldiameter);%frequency on image dimension 1 that corresponds to small diameter
sfreq2=round(size(image,2)/smalldiameter);%frequency on image dimension 2 that corresponds to small diameter
sfreq=min([sfreq1 sfreq2]);%smaller of the two must be used

f=fft2(image);
f=fftshift(f);

filt=zeros(size(image));
for a=1:size(image,1);
    for b=1:size(image,2);
        dis(a,b)=((centery-a)^2+(centerx-b)^2)^.5;
        if dis(a,b)<lfreq | dis(a,b)>sfreq;
            filt(a,b)=1;
        end
    end
end
filt=logical(filt);
f(filt)=0;
f2=ifft2(f);
filtered=(real(f2).^2+imag(f2).^2).^.5;