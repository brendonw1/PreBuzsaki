function flatshuffsorted=makeflatshufflibrary(sorted);
warning off MATLAB:conversionToLogical

for a=1:size(sorted,2)%for each slice
    a
    for b=1:size(sorted{a}.tstrain,2);%for each tstrain movie
        tic
        b
        sum(logical(sum(sorted{a}.tstrain(b).ons,1)))
        for z=1:1000;%for 1000 reshuffles
            flatshuffsorted{a}.tstrain(b).ons(:,:,z)=reshufflewhichcells(sum(sorted{a}.tstrain(b).ons,1));%store a reshuffled version of the collapsed movie
        end
        toc
    end
    for b=1:size(sorted{a}.tssingle,2);%for each tssingle movie
        b
        for z=1:1000;%for 1000 reshuffles
            flatshuffsorted{a}.tssingle(b).ons(:,:,z)=reshufflewhichcells(sum(sorted{a}.tssingle(b).ons,1));%store a reshuffled version of the collapsed movie
        end
    end
%     for b=1:size(sorted{a}.look,2);%for each look movie
%         b
%         for z=1:1000;%for 1000 reshuffles
%             flatshuffsorted{a}.look(b).ons(:,:,z)=reshufflewhichcells(sum(sorted{a}.look(b).ons,1));%store a reshuffled version of the collapsed movie
%         end
%     end
%     for b=1:size(sorted{a}.wdsingle,2);%for each wdsingle movie
%         b
%         for z=1:1000;%for 1000 reshuffles
%             flatshuffsorted{a}.wdsingle(b).ons(:,:,z)=reshufflewhichcells(sum(sorted{a}.wdsingle(b).ons,1));%store a reshuffled version of the collapsed movie
%         end
%     end
%     for b=1:size(sorted{a}.wdtrain,2);%for each wdtrain movie
%         b
%         for z=1:1000;%for 1000 reshuffles
%             flatshuffsorted{a}.wdtrain(b).ons(:,:,z)=reshufflewhichcells(sum(sorted{a}.wdtrain(b).ons,1));%store a reshuffled version of the collapsed movie
%         end
%     end
%     for b=1:size(sorted{a}.wdnostim,2);%for each wdnostim movie
%         b
%         for z=1:1000;%for 1000 reshuffles
%             flatshuffsorted{a}.wdnostim(b).ons(:,:,z)=reshufflewhichcells(sum(sorted{a}.wdnostim(b).ons,1));%store a reshuffled version of the collapsed movie
%         end
%     end
    for b=1:size(sorted{a}.spont,2);%for each spont movie
        tic
        b
        sum(logical(sum(sorted{a}.spont(b).ons,1)))
        for z=1:1000;%for 1000 reshuffles
            flatshuffsorted{a}.spont(b).ons(:,:,z)=reshufflewhichcells(sum(sorted{a}.spont(b).ons,1));%store a reshuffled version of the collapsed movie
        end
        toc
    end
end