godesk
load princor
cd analysis/spkmin/peaks
mt = dir('*mat');
cd ../..

for c = 1:size(mt,1)
    load(mt(c).name)
    load(['spkmin/peaks/' mt(c).name])
    fprintf(['Movie #' num2str(c) ': ' mt(c).name(1:8) '. ' num2str(size(pk,2)) ' peaks. Starting at ' datestr(clock,'HH:MM:SS') '\n']);
    ct = [];
    for d = 1:size(cn,2)
        ct(d,:) = centroid(cn{d});
    end
    m = [cos(-po(c)+pi/2) -sin(-po(c)+pi/2); sin(-po(c)+pi/2) cos(-po(c)+pi/2)];
    ct = ct*m;
    ct = ct-repmat(min(ct),size(ct,1),1);
    
    col = cell(1,size(pk,2));
    lay = cell(1,size(pk,2));
    
    for d = 1:size(pk,2)
        fprintf([' ' datestr(clock,'HH:MM:SS') ' Peak #' repmat('0',1,1-fix(log(d)/log(10))) num2str(d) ' at t = ' repmat('0',1,2-fix(log(pk(d))/log(10))) num2str(pk(d)) '. ']);
        fprintf('Analyzing Columns ');
        for e = 10:10:250
            col{d} = [col{d}; LayerP(ct,union(md{d},mr{d}),1,e,10000)];
            if col{d}(end,end)<0.05
                fprintf('#');
            else
                fprintf('.');
            end
        end
        fprintf(' Layers ');
        for e = 10:10:250
            lay{d} = [lay{d}; LayerP(ct,union(md{d},mr{d}),2,e,10000)];
            if lay{d}(end,end)<0.05
                fprintf('#');
            else
                fprintf('.');
            end
        end
        fprintf('\n');
    end
    
    save(['../layersu/' mt(c).name],'col','lay');
end