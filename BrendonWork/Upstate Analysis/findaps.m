<<<<<<< findaps.m
function aps=findaps(data);
aps{size(data,2)}=[];
for a=1:size(data,2);
    reading=data(:,a);
	if mean(reading)<-55 & mean(reading)>-85;
        I=find(reading>-20);
        if ~isempty(I);
            ap=[];
            ends=[];
            begins=[];
            ends=find(diff(I)~=1);
            begins(2:length(ends)+1)=ends;
            begins(1)=0;
            begins=begins+1;
            begins=begins';
            begins=I(begins);
            ends=I(ends);
            ends(end+1)=I(end);
%             ap(:,1)=begins;
%             ap(:,2)=ends;
            for b=1:size(begins ,1);
                [c,d]=max(reading(begins(b):ends(b)));
                d=begins(b)+d-1;
                aps{a}(b)=d;
            end    
        end
    end
=======
function aps=findaps(data)
aps{size(data,2)}=[];
for a=1:size(data,2);
    reading=data(:,a);
	if mean(reading)<-55 && mean(reading)>-85;
        I=find(reading>-20);
        if ~isempty(I);
            ap=[];
            ends=[];
            begins=[];
            ends=find(diff(I)~=1);
            begins(2:length(ends)+1)=ends;
            begins(1)=0;
            begins=begins+1;
            begins=begins';
            begins=I(begins);
            ends=I(ends);
            ends(end+1)=I(end);
%             ap(:,1)=begins;
%             ap(:,2)=ends;
            for b=1:size(begins ,1);
                [c,d]=max(reading(begins(b):ends(b)));
                d=begins(b)+d-1;
                aps{a}(b)=d;
            end    
        end
    end
>>>>>>> 1.2
end