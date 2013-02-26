function [sorted,conttemplates]=addconttemps(sorted);
%add outcontours to sorted, make a new cell array: conttemplates

for a=1:size(sorted,2);
    for b=1:length(sorted{a}.contours);
        center=centroid(sorted{a}.contours{b});
        rad=poly_area(sorted{a}.contours{b});
        rad=2*((rad/pi)^.5);
        outconts{b}=pixellatedcircle(center(1),center(2),rad);
    end
    sorted{a}.outcontours=outconts;
end   
for a=1:size(sorted,2);
    a
    conts=sorted{a}.contours;
    outconts=sorted{a}.outcontours;
    template=zeros(256);
    for b=1:length(conts);%for each contour;
        ct=zeros(256);%2D zeros
        oct=zeros(256);
        for dim2=1:256;%for each 
            d2=dim2*(ones(1,256));
            in=inpolygon(1:256,d2,conts{b}(:,1),conts{b}(:,2));%a 1D line of 0's and 1's for all x's across 1 y value
            inout=inpolygon(1:256,d2,outconts{b}(:,1),outconts{b}(:,2));        
            ct(dim2,:)=in;%a matrix of the pixels inside a given contour... 2D by the time the for-loop is over
            oct(dim2,:)=inout;
	    end 
        template=ct+template;%create a template w/ 1's wherever inside any cell, 0 outside... for whole-frame background
        ct=find(ct);
        conttemplates{a}.inconts{b}=ct;%matrix of ins for all cell contours
        oct(ct)=0;%eliminate from the outside contour all pixels that are a part of the original contour
        oct=find(oct);
        conttemplates{a}.outconts{b}=oct;
    end
    for b=1:length(conts);%for each contour;
        t=conttemplates{a}.outconts{b};
        t=setdiff(t,find(template));%eliminate pixels that are in other contours
        conttemplates{a}.outconts{b}=t;
    end
end