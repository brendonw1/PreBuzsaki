

for a=1:length(abfnotes);%for each slice's notes
    abfnotes{a}.wddelay=cell(size(abfnotes{a}.stim));
     for b=1:size(abfnotes{a}.stim,1);%for each trial
         if strcmp(abfnotes{a}.stim{b,1},'wdtrain') | strcmp(abfnotes{a}.stim{b,1},'wdsingle');
             abfnotes{a}.wddelay{b,1}=750;
         end
     end
end