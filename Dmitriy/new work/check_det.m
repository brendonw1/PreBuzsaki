function check_det = check_det(nbin,pw,q)
%check_det = check_det(nbin,pw,q)
%   check the Cayley_Menger determinant for nbin bin and pw powers

godesk
c = 2^nbin;
h = [reshape(str2num(reshape(dec2bin((0:c-1)'),c*log(c)/log(2),1)),c,log(c)/log(2)).*repmat(1:log(c)/log(2),c,1) repmat(-1,c,1)];
h = reshape(h',prod(size(h)),1);
h = h(find(not(h==0)));
h(end)=-3;

fid = fopen('tlist.txt','w');
fprintf(fid,'%1.0f\n',h);
fclose('all');

m = distmat('tlist.txt',[],[],inf,q);

check_det = [];
for d = 1:size(q,2)
    if mod(d,40)==0
        fprintf(num2str(d/40));
    end
    for c = 1:size(pw,2)
        n = m{d}.^pw(c);
        check_det(c,d) = det([0 ones(1,size(n,2)); ones(size(n,1),1) n.^2]);
    end
end