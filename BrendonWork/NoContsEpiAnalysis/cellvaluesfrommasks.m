function values=cellvaluesfrommasks(pixels,masks)
% Inputs are a 3D movie matrix and a set of masks from "objectdetector",
% each representing a stationary object, in the same place in every frame.
% This function will extract the mean value of each object in each frame
% and give an output "values", which is a 2D matrix of cell x frame.
values=zeros(size(masks,2),size(pixels,3));%preallocate output matrix of the is function
pixels=reshape(pixels,[size(pixels,1)*size(pixels,2),size(pixels,3)]);%make each frame a vector, with each point keeping the same overall address index number
for a=1:size(masks,2);%for each cell
    values(a,:)=mean(pixels(masks{a},:),1);%store the mean of the pixels in each frame of each cell
end
% 
% for a=1:size(masks,2);%for each cell
%     for b=1:size(pixels,3);
%         frame=pixels(:,:,b);%temporarily assigning frame to be stored
%         values(a,b)=mean(frame(m));
%     end
% end
% 
% 