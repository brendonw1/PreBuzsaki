function numstring=addzerostonumberstring(value,numzeros)

numstring=num2str(value);
for a=1:(numzeros-length(numstring));
    numstring=['0',numstring];
end