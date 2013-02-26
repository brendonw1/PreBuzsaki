function [residuals,approximage]=getresiduals(image,level,wavelet);
[approx,horiz,vert,diag]=swt2(image,level,wavelet);
null=zeros(size(approx));
approximage=iswt2(approx,null,null,null,wavelet);
figure; colormap gray; imagesc(approximage);title 'Removed Noise'
horizimage=iswt2(null,horiz,null,null,wavelet);
vertimage=iswt2(null,null,vert,null,wavelet);
diagimage=iswt2(null,null,null,diag,wavelet);

residuals=horizimage+vertimage+diagimage;
figure; colormap gray; imagesc(residuals);title 'Remaining Signal'
figure; colormap gray; imagesc(image);title 'Original Frame'
