% function [clust, centroid] = bfkm(waves,nclust,thresh)
function [clust, U, centroid] = bfkm(ons,numclust,sigma,fuzzy,thresh)
%ons is cells x frames input

warning off MATLAB:conversionToLogical

g=gaussian(-size(ons,2):size(ons,2),0,sigma);%create a gaussian kernel
newons=zeros(size(ons));
for a=1:size(ons,1);%each cell
    temp=conv(g,ons(a,:));%convolve the spiking profile of that cell with the kernel
    newons(a,:)=temp(size(ons,2)+1:end-(size(ons,2)));%extract the useful part of the convolution output
end

% [clust mn] = kmeans(newons, numclust,'replicates',10,'emptyaction','drop');

mindist = 0;
% fuzzy = 1.5;%this determines how much a single input vector (ie cell) is allowed to be in multiple clusters instead of just one.  1.3 is suggested by program writer for euclidian distance measures.  2 suggested by fellous and sejnowski for spike trains

% while mindist < eps & fuzzy >= 1
%     fprintf(['Fuzziness factor ' num2str(fuzzy) '\n']);
    [U, centroid, dist, W, obj] = fuzme(numclust,newons,rand(size(ons,1),numclust),fuzzy,1000,1,1e-8);
    mindst = min(pdist(centroid));
%     fprintf(['Minimum distance between cluster centroids ' num2str(mindist) '\n']);
%     fuzzy = fuzzy-0.1;
% end

clust=U;
clust(clust<thresh)=0;%keep only values above thresh
temp=sum(clust,2);%sum all probabilities... to look for cells which have no probabilities above thresh
[trash,clust]=max(clust,[],2);%find cluster of max probablility for each cell
clust(find(temp==0))=size(U,2)+1;%assign all cells with no probability above thresh to a new extra cluster

sortedons=zeros(1,size(ons,2));
for a=1:max(clust);
   temp=ons(find(clust==a),:);
   sortedons=cat(1,sortedons,temp,ones(5,size(ons,2)));
end
sortedons([1, end-4:end],:)=[];

figure;
imagesc(sortedons)
colormap gray


% while mindist < eps & fuzz >= 1
%     fprintf(['Fuzziness factor ' num2str(fuzz)]);
%     [U, centroid, dist, W, obj] = fuzme(nclust,waves,rand(size(waves,1),nclust),fuzz,1000,1,1e-8);
%     dst = pdist(centroid);
%     mindist = min(dst);
%     fprintf([' Minimum distance ' num2str(mindist) '\n']);
%     fuzz = fuzz-0.1;
% end
% 
% nu=U;
% nu(nu<=thresh)=0;%keep only values above thresh
% nu=logical(nu);
% [X,trash] = meshgrid(1:size(U,2),1:size(U,1));
% clust=X.*nu;
% clust=sum(clust,2);
% clust(clust==0)=size(U,2)+1;%create an extra "cluster" of vectors that were not certainly enough in one group or the other
% 
% sortedwaves=zeros(1,size(waves,2));
% for a=1:max(clust);
%    temp=waves(find(clust==a),:);
%    sortedwaves=cat(1,sortedwaves,temp,ones(5,size(waves,2)));
% end
% sortedwaves([1, end-4:end],:)=[];
% 
% figure
% imagesc(sortedwaves);
% colormap gray
% % 
% % [trash clust] = max(U');
% % a=find(clust==1);
% % b=find(clust==2);
% % figure
% % new1=waves(a,:);
% % new2=waves(b,:);
% % new=cat(1,new1,-3*ones(2,size(waves,2)),new2);
% % imagesc(new);
% % colormap gray
% 
% 
% 
% % 
% % nspk = cell(1,0);
% % for c = 1:nclust
% %     f = find(clust==c);
% %     for d = 1:length(f)
% %         nspk{size(nspk,2)+1} = spk{f(d)};
% %     end
% % end
% % rasterplot(nspk);
% % m = get(gca,'children');
% % h = get(m,'ydata');
% % for c = 1:length(h)
% %     ys(c) = max(h{c});
% % end
% % cl = hsv(nclust);
% % sz = 0;
% % for c = 1:nclust
% %     set(m(find(ys>sum(sz) & ys<=sum(sz)+length(find(clust==c)))),'color',cl(c,:));
% %     sz(c) = length(find(clust==c));
% % end
% % box on
% % set(gca,'color',[0 0 0]);
% % return
% % 
% % % Augment the dynamic range
% % mtau = 0;
% % sdvalue = inf;
% % for tau = 0.01:0.005:0.3
% %     b = 1./(1+exp(-(k-mean(mean(k)))/tau));
% %     sd = std(histc(reshape(b,1,prod(size(b))),0:0.02:1));
% %     if sd<sdvalue
% %         mtau = tau;
% %         sdvalue = sd;
% %     end
% % end
% % k = 1./(1+exp(-(k-mean(mean(k)))/mtau));
% % 
% % % Clustering
% % % Initialize
% % f = 2;
% % mindiff = 0;
% while mindiff < 1e-6
%     fprintf(['Caclulating f = ' num2str(f)])
%     u = rand(size(k,1),nclust);
%     cc = zeros(nclust,size(k,2));
%     for j = 1:nclust
%         cc(j,:) = sum(repmat(u(:,j).^f,1,size(k,2)).*k)/sum(u(:,j).^f);
%     end
%     uold = zeros(size(u));
%     % Iterate
%     d = zeros(size(k,1),nclust);
%     while max(max(abs(u-uold))) > 1e-12
%         uold = u;
%         for j = 1:nclust
%             d(:,j) = sqrt(sum((k-repmat(cc(j,:),size(k,1),1)).^2,2));
%         end
%         for j = 1:nclust
%             u(:,j) = 1./sum((repmat(d(:,j),1,nclust)./d).^(2/(f-1)),2);
%         end
%         for j = 1:nclust
%             cc(j,:) = sum(repmat(u(:,j).^f,1,size(k,2)).*k)/sum(u(:,j).^f);
%         end
%     end
%     mindiff = inf;
%     for c = 1:nclust
%         for d = 1:c-1
%             md = norm(cc(c,:)-cc(d,:));
%             if md < mindiff
%                 mindiff = md;
%             end
%         end
%     end
%     fprintf([' Minimum distance = ' num2str(mindiff) '\n']);
%     f = f-0.05;
% end
% 
% clust = cc;