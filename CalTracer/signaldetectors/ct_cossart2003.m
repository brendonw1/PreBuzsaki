function [onsets, offsets, param] = ct_cossart2003(handles)
% function [onsets, offsets, param] = epo_cossart2003(handles)
% Called by epo (actually by "detect_signals.m" to evaluate 
% traces to find events that might correspond with action potentials
waithandle = waitbar(0,'Detecting signals');
onsets = cell(1,length(handles.exp.neurons));
offsets = cell(1,length(handles.exp.neurons));
param = [];
for c = 1:length(handles.exp.neurons)
    tr = handles.exp.neurons(c).intensity;
    
    k = tr - hmyfilter(tr,round(1/(handles.exp.timeRes*10)*325));
    spk{c} = find(hmyfilter(k/std([k(find(k>0)) -k(find(k>0))]),2)<-1);
    f = intersect([1 find(k(2:end)-k(1:end-1)<0)+1],[find(k(1:end-1)-k(2:end)<0) size(k,2)]);
    onsets{c} = intersect(spk{c},f);
    offsets{c} = onsets{c};
    waitbar(c/length(handles.exp.neurons),waithandle)
end
delete(waithandle);
function hmyfilter = hmyfilter(mm, num)
%myfilter = myfilter(m, num)
%   performs num-order Hanning filtering of the data
if num>length(mm);%added 2005, Brendon Watson, for faster shorter movies
    num=length(mm);
end
m = [mm(1:num) mm mm(end-num+1:end)];
fl = hanning(2*num+1)';
fl = fl/sum(fl);
sz = size(m,2);
[x1 y] = meshgrid(1:sz,1:num);
y = flipud(y);
x1 = x1-y;
x1 = x1.*((sign(x1-.5)+1)/2)+(1-(sign(x1-.5)+1)/2);
x2 = fliplr(flipud((sz+1)*ones(num,sz)-x1));
x = [x1; 1:sz; x2];
x = m(x);
myfilter = fl*x;
hmyfilter = myfilter(num+1:num+size(mm,2));