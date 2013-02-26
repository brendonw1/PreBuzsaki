function data=elimaps(data);

data=reshape(data,[1 prod(size(data))]);
aps=findaps2(data,'durations');
dd=diff(data);
dd=reshape(dd,[1 size(data,2)-1]);
dur=continuousabove(abs(dd),zeros(1,size(data,2)-1),2*std(dd),4,200);

a=1;
b=1;
elim={};
while a<size(dur,1);
    a
    b=1;
    while b<=size(aps,1);
        b
        if overlapping(dur(a,:),aps(b,:));%make sure rising phase overlaps with ap
            if overlapping(dur(a+1,:),aps(b,:));%make sure falling phase overlaps
                elim{end+1}=dur(a,1);
                [temp,high]=max(data(aps(b,1):aps(b,2)));
                high=high+aps(b,1)-1;
                temp=find(data<data(dur(a,1)));
                trash=find(temp>high);
                elim{end}(1,2)=temp(trash(1));
%                 data(elim(1):elim(2))=polyfit...;
                a=a+2;
                b=Inf;
            else
                disp('An error may have occurred in detecting action potentials')
                a=a+1;
                b=b+1;
            end
        else
            a=a+1;
            b=b+1;
        end
    end
end

for z=1:size(elim,2);
    step=(data(elim{z}(2))-data(elim{z}(1)))/(elim{z}(2)-elim{z}(1));
    between=1:(elim{z}(2)-elim{z}(1));
    between=(between*step)+data(elim{z}(1));
    data(elim{z}(1)+1:elim{z}(2))=between;
end