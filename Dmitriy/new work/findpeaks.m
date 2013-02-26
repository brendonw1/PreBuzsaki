function [tpk,wd] = findpeaks(s,thr,num)
%[tpk,wd] = findpeaks(s,thr,num)
%   detects peaks in rasterplot s with threshold vector thr that has an offset num

k = sum(s);
mx = intersect(find(k(2:end-1)-k(1:end-2)>0),find(k(2:end-1)-k(3:end)>0))+1;
issig = zeros(1,size(k,2));
frms = cell(1,size(k,2));
for c = 1:size(k,2)
    bg = min([num-1 c-1]);
    en = min([size(thr,2)-num size(k,2)-c]);
    m = (k(c-bg:c+en)>thr(num-bg:num+en));
    if sum(m) > 0
        issig(c) = 1;
        f = find(fliplr(m(1:num-1))==0);
        if ~isempty(f)
            f = min(f)-1;
        else
            f = num-1;
        end
        g = find(m(num+1:end)==0);
        if ~isempty(g)
            g = min(g)-1;
        else
            g = size(m,2)-num;
        end
        if f+g+m(num)==0
            issig(c) = 0;
        else
            frms{c} = [f g];
        end
    end
end

tpk = intersect(mx,find(issig==1));
wd = zeros(size(tpk,2),2);
for c = 1:size(tpk,2)
    wd(c,:) = frms{tpk(c)};
end