function filtered=bandpassimage(image,diameter);

f=fft2(image);
f([1:2,end-1:end],:)=0;
f(:,[1:2,end-1:end])=0;

freq1=round(size(image,1)/diameter);
freq2=round(size(image,2)/diameter);

f(freq1:(size(image,1)-(freq1-1)),:)=0;
f(:,freq2:(size(image,2)-(freq2-1)))=0;

f2=ifft2(f);
filtered=(real(f2).^2+imag(f2).^2).^.5;