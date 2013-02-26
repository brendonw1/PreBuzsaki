function mag=gradientmag(image);

[FX,FY]=gradient(image);
mag=abs(FX)+abs(FY);