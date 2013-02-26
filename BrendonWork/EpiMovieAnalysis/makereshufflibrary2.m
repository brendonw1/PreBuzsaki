function makereshufflibrary2;

for a=1:57;
    load sorted%must have a copy of sorted in the directory you're using
    a
    name=['reshuffcellisi',num2str(a)];
    for b=1:size(sorted{a}.tstrain,2);
        b
        for z=1:1000;
            ex=[name,'(b,z).tstrain=reshufflecellisis(sorted{a}.tstrain(b).ons);'];
            eval(ex);
        end
    end
    for b=1:size(sorted{a}.spont,2);
        b
        for z=1:1000;
            ex=[name,'(b,z).spont=reshufflecellisis(sorted{a}.spont(b).ons);'];
            eval(ex);
        end
    end
    clear a b z ex sorted;
    eval(['save ',name]);
    eval(['clear ',name,' name']);
end