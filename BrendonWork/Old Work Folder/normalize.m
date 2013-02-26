function array=normalize(array,varargin);


if nargin==1;%if no input arguments
    dim=1;%default is first dimension
elseif nargin==2;%if one input
   dim=varargin{1};%user specified
end

m=min(array,[],dim);
m2=m;
for a=1:size(array,dim)-1;
    m2=cat(dim,m2,m);
end
array=array-m2;

m=max(array,[],dim);
m2=m;
for a=1:size(array,dim)-1;
    m2=cat(dim,m2,m);
end
array=array./m2;



% %normalizes pixel values in a 4D moviematrix of multiple movies... 
% %each movie is normalized within itself
% 
% 
% [a b c d]=size(moviematrix);
% moviematrix=double(moviematrix);
% 
% mini(:,:,1:d)=min(moviematrix(:,:,:,1:d),[],3);%make a movie of min of each pixel across all frames of each movie
% mini=min(mini,[],2);% take min of y of above
% mini=squeeze(mini);
% mini=min(mini,[],1);
% mini=double(mini);
% mini=repmat(mini,[a,1,b,c]);
% mini=ipermute(mini,[1 4 2 3]);
% 
% maxi(:,:,1:d)=max(moviematrix(:,:,:,1:d),[],3);
% maxi=max(maxi,[],2);
% maxi=squeeze(maxi);
% maxi=max(maxi,[],1);
% maxi=double(maxi);
% maxi=repmat(maxi,[a,1,b,c]);
% maxi=ipermute(maxi,[1 4 2 3]);
% 
% normalized=(moviematrix-mini)./(maxi-mini);