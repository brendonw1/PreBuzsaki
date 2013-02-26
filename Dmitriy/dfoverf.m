function dfoverf = dfoverf(f,n)

if mean(f) == 0
   dfoverf = f / (max(f)-min(f)+eps);
else
   a = (f - mean(f))/mean(f);
   dfoverf = a ;
end
