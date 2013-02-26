function [pval,del] = corind(spk,a,b,prec,tr,st,ttot)
%[pval,del] = corind(spk,a,b,prec,tr,st,ttot)

[ncorr del] = mycorr(spk{a},spk{b},prec);
del = mean(del);

switch st
case 'int'
   for c=1:tr;
      m(c) = mycorr(intres(spk{a},ttot),intres(spk{b},ttot),prec);
   end;
case 'mon'
   for c=1:tr
      m(c) = mycorr(monte(size(spk{a},2),ttot),monte(size(spk{b},2),ttot),prec);
   end
end

pval = size(find(m>=ncorr),2)/tr;