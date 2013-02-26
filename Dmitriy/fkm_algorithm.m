function [clust, centroid] = fkm_algorithm(spk,frm,sig,nclust)

% Calculate similarity indices
%fnotzero = find(sum(s,2)>0);
%s = s(fnotzero,:);
s = rast2mat(spk,frm);
vl = zeros(size(s));
for c = 1:size(s,1)
    for f = find(s(c,:)==1)
        vl(c,:) = vl(c,:) + exp(-((1:size(s,2))-f).^2/sig^2);
    end
end

%[clust mn] = kmeans(vl, nclust);
mindist = 0;
fuzz = 2;
%while mindist < eps & fuzz >= 1
    fprintf(['Fuzziness factor ' num2str(fuzz)]);
    [U, centroid, dist, W, obj] = fuzme(nclust,vl,rand(size(vl,1),nclust),fuzz,1000,1,1e-8);
    dst = pdist(centroid);
    mindist = min(dst);
    fprintf([' Minimum distance ' num2str(mindist) '\n']);
    %fuzz = fuzz-0.1;
    %end
%if fuzz < 0.9
%    clust = 0;
%    return;
%end
    
[dummy clust] = max(U');

nspk = cell(1,0);
for c = 1:nclust
    f = find(clust==c);
    for d = 1:length(f)
        nspk{size(nspk,2)+1} = spk{f(d)};
    end
end
rasterplot(nspk);
m = get(gca,'children');
h = get(m,'ydata');
for c = 1:length(h)
    ys(c) = max(h{c});
end
cl = hsv(nclust);
sz = 0;
for c = 1:nclust
    set(m(find(ys>sum(sz) & ys<=sum(sz)+length(find(clust==c)))),'color',cl(c,:));
    sz(c) = length(find(clust==c));
end
box on
set(gca,'color',[0 0 0]);
return

% Augment the dynamic range
mtau = 0;
sdvalue = inf;
for tau = 0.01:0.005:0.3
    b = 1./(1+exp(-(k-mean(mean(k)))/tau));
    sd = std(histc(reshape(b,1,prod(size(b))),0:0.02:1));
    if sd<sdvalue
        mtau = tau;
        sdvalue = sd;
    end
end
k = 1./(1+exp(-(k-mean(mean(k)))/mtau));

% Clustering
% Initialize
f = 2;
mindiff = 0;
while mindiff < 1e-6
    fprintf(['Caclulating f = ' num2str(f)])
    u = rand(size(k,1),nclust);
    cc = zeros(nclust,size(k,2));
    for j = 1:nclust
        cc(j,:) = sum(repmat(u(:,j).^f,1,size(k,2)).*k)/sum(u(:,j).^f);
    end
    uold = zeros(size(u));
    % Iterate
    d = zeros(size(k,1),nclust);
    while max(max(abs(u-uold))) > 1e-12
        uold = u;
        for j = 1:nclust
            d(:,j) = sqrt(sum((k-repmat(cc(j,:),size(k,1),1)).^2,2));
        end
        for j = 1:nclust
            u(:,j) = 1./sum((repmat(d(:,j),1,nclust)./d).^(2/(f-1)),2);
        end
        for j = 1:nclust
            cc(j,:) = sum(repmat(u(:,j).^f,1,size(k,2)).*k)/sum(u(:,j).^f);
        end
    end
    mindiff = inf;
    for c = 1:nclust
        for d = 1:c-1
            md = norm(cc(c,:)-cc(d,:));
            if md < mindiff
                mindiff = md;
            end
        end
    end
    fprintf([' Minimum distance = ' num2str(mindiff) '\n']);
    f = f-0.05;
end

clust = cc;