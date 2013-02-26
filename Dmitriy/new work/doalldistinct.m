godesk
cd newth
mt = dir('*mat')
cd ..

for c = 1:size(mt,1)
    load(['analysis/' mt(c).name]);
    load(['analysis/spkmin/' mt(c).name]);
    load(['newth/' mt(c).name]);
    fprintf(['\n' num2str(c) ') ' mt(c).name '. ']);
    s = rast2mat(spk,sz);
    ct = [];
    for d = 1:size(cn,2)
        ct(d,:) = centroid(cn{d});
    end
    dist = cell(1,size(tpk,2));
    for d = 1:size(tpk,2);
        for e = -5:5
            for f = e:5
                if tpk(d)+e > 0 & tpk(d)+e <= size(s,2) & tpk(d)+f > 0 & tpk(d)+f <= size(s,2)
                    dist{d}(e+6,f+6) = DistinctP(ct,find(s(:,tpk(d)+e)==1),find(s(:,tpk(d)+f)==1),1000);
                    dist{d}(f+6,e+6) = dist{d}(e+6,f+6);
                else
                    dist{d}(e+6,f+6) = 2;
                    dist{d}(f+6,e+6) = 2;
                end
                if dist{d}(e+6,f+6) < 0.05
                    fprintf('+');
                else
                    fprintf('-');
                end
            end
        end
        fprintf(' ');
    end
    save(['distinct/' mt(c).name],'dist');
end
