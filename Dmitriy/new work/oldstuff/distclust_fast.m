function anear=distclust_fast(dists,nsam,expo,ifresamp,iftrump)
%ANEAR=DISTCLUST_FAST(DISTS,NSAM,EXPO,IFRESAMP,IFTRUMP).
% DISTS     matrix of pairwise distances, diagonally symmetric with 0's on the diagonal
% NSAM      vector, each entry is the number of trials in each condition; size(DISTS,1)=size(DISTS,2)=sum(nsam)
% EXP       averaging exponent, or 'median'
% IFRESAMP  0 not to perform a relabel-resampling, 1 otherwise
% IFTRUMP   1 if 0-distances trump all others, 0 if not; iftrump=0 automatically if expo<0
%
% ANEAR     confusion matrix, length(NSAM) x length(NSAM)
%
% (c) 2000 by Daniel Reich. All rights reserved.
% Revision 1.0 2000/06/23.

if ~isstr(expo) & expo<0 iftrump=1; end
ncla=length(nsam);
anear=zeros(ncla,ncla);
if ifresamp
   ind=randperm(size(dists,2));
   dists=dists(ind,ind);
end
samend=cumsum(nsam);
samstart=[1 samend(1:ncla-1)+1];
av=zeros(ncla,size(dists,2));
if iftrump==0
   for i=1:ncla 
      if isstr(expo)
         av(i,:)=median(dists(samstart(i):samend(i),:));
         %don't include self-distances (diagonal) in the calculation:
         for j=samstart(i):samend(i) av(i,j)=median([dists(samstart(i):j-1,j);dists(j+1:samend(i),j)]); end
      else
         av(i,:)=(sum(dists(samstart(i):samend(i),:).^expo)/nsam(i)).^(1/expo);
         %don't include self-distances (diagonal) in the calculation:
         for j=samstart(i):samend(i) av(i,j)=(sum([dists(samstart(i):j-1,j);dists(j+1:samend(i),j)].^expo)/(nsam(i)-1)).^(1/expo); end
      end
   end      
else
   dists(find(eye(size(dists,1))))=NaN;
   for i=1:ncla 
      nsm=nsam(i)*ones(1,size(dists,2));
      nsm(1,samstart(i):samend(i))=nsam(i)-1;
      temp=dists(samstart(i):samend(i),:);
      nz=find(temp<eps);
      temp=zeros(size(temp));
      temp(nz)=1;
      av(i,:)=-sum(temp)./nsm; % -fraction of zeros in each column
      nz=find(av(i,:)==0); % columns with no zero values
      ident=find(nz>=samstart(i) & nz<=samend(i));
      temp=dists(samstart(i):samend(i),nz); % non-zero columns are not all ones
      if isstr(expo) 
         md=median(temp);
         temp=sort(temp(:,ident));
         md(ident)=median(temp(1:nsam(i)-1,:));
      else 
         md=(sum(temp.^expo)./nsam(i)).^(1/expo);
         temp=sort(temp(:,ident));
         md(ident)=(sum(temp(1:nsam(i)-1,:).^expo,1)/(nsam(i)-1)).^(1/expo);
      end
      av(i,nz)=md;
   end
end
a=min(av);
for i=1:size(dists,2)
   icla=max(find(samstart<=i));
   indx=find(av(:,i)==a(i));
   anear(icla,indx)=anear(icla,indx)+1/length(indx);
end


% the following is a slightly faster algorithm that can be used if:
% 1. all classes have the same number of trials
% 2. 0's don't trump
% 3. self-distances can be included in the median calculation
% in general, these conditions are not met, so this algorithm is not implemented
if 0
   av=reshape(median(reshape(dists,nsam(1),size(dists,2)*ncla)),ncla,nsam(1),ncla);
   for i=1:ncla
      a=min(av(:,:,i));
      for j=1:nsam(1)
         indx=find(av(:,j,i)==a(j));
         anear(i,indx)=anear(i,indx)+1/length(indx);
      end
   end
end
%a useful command:
%dists=dists(find(tril(ones(size(dists)),-1))); % pack the matrix into the form of pdist


%old methods


%temp=ones(nsam(i),size(dists,2));
%temp(:,nz)=dists(samstart(i):samend(i),nz); % only non-zero columns are not all ones
%md=zeros(1,size(dists,2));
%if isstr(expo) 
%   md(1,1:samstart(i)-1)=median(temp(:,1:samstart(i)-1));
%   md(1,samend(i)+1:size(dists,2))=median(temp(:,samend(i)+1:size(dists,2)));
%   temp=sort(temp(:,samstart(i):samend(i)));
%   md(1,samstart(i):samend(i))=median(temp(1:nsam(i)-1,:));
%else 
%   md(1,1:samstart(i)-1)=(sum(temp(:,1:samstart(i)-1).^expo)/nsam(i)).^(1/expo);
%   md(1,samend(i)+1:size(dists,2))=(sum(temp(:,samend(i)+1:size(dists,2)).^expo)/nsam(i)).^(1/expo);
%   temp=sort(temp(:,samstart(i):samend(i)));
%   md(1,samstart(i):samend(i))=(sum(temp(1:nsam(i)-1,:).^expo)/(nsam(i)-1)).^(1/expo);
%end
%av(i,nz)=md(1,nz);

%for j=1:length(nz)
%   ndx=find(dists(samstart(i):samend(i),nz(j)) & ~isnan(dists(samstart(i):samend(i),nz(j))));
%   if isstr(expo) av(i,nz(j))=median(dists(samstart(i)+ndx-1,nz(j)));
%   else av(i,nz(j))=(sum(dists(samstart(i)+ndx-1,nz(j)).^expo)/length(ndx)).^(1/expo);
%   end
%end
