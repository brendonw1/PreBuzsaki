godesk
cd analysis
%mt = dir('*mat');

for c = [1:120 122:129]
    load(mvs{c});
    s = rast2mat(spk,sz);
    fprintf(['Movie #' num2str(c) ': ' mvs{c} '. ' num2str(size(tpk,2)) ' peaks. Starting at ' datestr(clock,'HH:MM:SS') '.     ']);
    ct = [];
    for d = 1:size(cn,2)
        ct(d,:) = centroid(cn{d});
    end
    clust = zeros(size(tpk,2),11);
    col = zeros(size(tpk,2),11);
    lay = zeros(size(tpk,2),11);
    for d = 1:size(tpk,2)
        %f = [];
        %for e = -1:1
        %    if tpk(d)+e > 0 & tpk(d)+e <= size(s,2)
        %        f = [f; find(s(:,tpk(d)+e)==1)];
        %    end
        %end
        %f = unique(f);
        f = 1:size(ct,1); %this line is added for not-just-peak analysis
        
        cn2 = cell(1,size(f,2));
        for j = 1:size(f,2)
            cn2{j} = cn{f(j)};
        end
        s2 = s(f,:);
        for e = -10:10
            if tpk(d)+e > 0 & tpk(d)+e <= size(s,2)
                clust(d,e+11) = ClusterP(cn2,1,find(s2(:,tpk(d)+e)==1),1000);
                col(d,e+11) = ClusterP(cn2,2,find(s2(:,tpk(d)+e)==1),1000);
                lay(d,e+11) = ClusterP(cn2,3,find(s2(:,tpk(d)+e)==1),1000);
            else
                clust(d,e+11) = 2;
                col(d,e+11) = 2;
                lay(d,e+11) = 2;
            end
        end
        for e = -10:10
            if min([clust(d,e+11) col(d,e+11) lay(d,e+11)]) < 0.05
                fprintf('+');
            else
                fprintf('-');
            end
        end
        fprintf(' ');
    end
    fprintf('\n');
    
    save(['../cluster/' mvs{c}],'clust','col','lay');
end
