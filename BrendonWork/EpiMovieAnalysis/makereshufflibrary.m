function makereshufflibrary;

for a=49:57;
    load sorted%must have a copy of sorted in the directory you're using
    a
    name=['reshuffisi',num2str(a)];
    for b=1:size(sorted{a}.tstrain,2);
        b
        for z=1:1000;
            ex=[name,'(b,z).tstrain=reshuffleisis(sorted{a}.tstrain(b).ons);'];
            eval(ex);
        end
    end
    for b=1:size(sorted{a}.spont,2);
        b
        for z=1:1000;
            ex=[name,'(b,z).spont=reshuffleisis(sorted{a}.spont(b).ons);'];
            eval(ex);
        end
    end
    for b=1:size(sorted{a}.ttcore,2);
        b
        for z=1:1000;
            ex=[name,'(b,z).ttcore=reshuffleisis(sorted{a}.ttcore{b});'];
            eval(ex);
        end
    end
    for b=1:size(sorted{a}.stcore,2);
        b
        for z=1:1000;
            ex=[name,'(b,z).stcore=reshuffleisis(sorted{a}.stcore{b});'];
            eval(ex);
        end
    end
    for b=1:size(sorted{a}.sscore,2);
        b
        for z=1:1000;
            ex=[name,'(b,z).sscore=reshuffleisis(sorted{a}.sscore{b});'];
            eval(ex);
        end
    end
    for b=1:size(sorted{a}.tscore,2);
        b
        for z=1:1000;
            ex=[name,'(b,z).tscore=reshuffleisis(sorted{a}.tscore{b});'];
            eval(ex);
        end
    end
    clear a b z ex sorted;
    eval(['save ',name]);
    eval(['clear ',name,' name']);
end