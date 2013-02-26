function n=insertrows(m,row,numb);
%will insert (numb) rows of zeros after the row specified

n=m(1:row,:);
n(row+1+numb:(size(m,1)+numb),:)=m(row+1:size(m,1),:);