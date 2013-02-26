function spk = text2spikes(fin)
%spk = text2spikes(fin)
%   extracts data from text data files

[datapt, dt, pos] = text2mat(fin);
for c = 1:size(datapt,1)
   j = myfilter(datapt(c,:),50);
   spk{c} = detspikes(fitexp(j),80,0.2,100,0.25);
   fprintf(num2str(c));
end