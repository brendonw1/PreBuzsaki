function subtracted=cellsminusbackground(pixels,conts,backs);


template=zeros(256);
for contournumber = 1:(length(pixels));
    for ycounter=1:256;
        yc=ycounter(ones(1,256));
        in=inpolygon(1:256,yc,conts{contournumber}(:,1),conts{contournumber}(:,2));%a 1D line of 
%                                                                             0's and 1's for all x's across 1 y value
        inmatrix(ycounter,:)=in;%a matrix of the pixels inside a given contour... 2D by the time the for-loop is over
	end
    template=inmatrix+template;%create a template w/ 1's wherever inside any cell, 0 outside... for whole-frame background
end

btemplate=~template;
template=repmat(template,[1,1,size(pixels,3)]);
btemplate=repmat(btemplate,[1,1,size(pixels,3)]);
template=logical(template);
btemplate=logical(btemplate);

for b=1:(size(pixels,4));
%     for c=1(size(pixels,3));
%         frame=pixels(:,:,c,b);
          movie=pixels(:,:,:,b);
          mt=movie(template);
          bt=movie(btemplate);
          subtracted(b)=mean(mt)-mean(bt);
%     end
end