function coords=pixellatedcircle(centerx ,centery, radius)
%gives pixel coords that fall nearest to a circle with specified center and
%radius

warning off MATLAB:conversionToLogical;

x=(centerx-radius:2*radius/1000:centerx+radius);
yup=((radius.^2)-(x-centerx).^2).^(.5) + centery;

x=round(x);
yup=round(yup);

xdf=diff(x);
ydf=diff(yup);

s=xdf+ydf;
s=logical(s);
s(1)=1;


x=x(s);
yup=yup(s);

ydown=2*centery-yup;

x=cat(2,x,fliplr(x));
y=cat(2,yup,fliplr(ydown));

coords(:,1)=x';
coords(:,2)=y';