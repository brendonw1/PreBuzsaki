n = get(fmenu,'value');
load(mt(n).name);

s = rast2mat(spk,sz);

st = [];
if ~isempty(tpk)
    st = [num2str(tpk(1)) ' ( -' num2str(wd(1,1)) ', +' num2str(wd(1,2)) ' )'];
end
for c = 2:size(tpk,2)
    st = [st '|' num2str(tpk(c)) ' ( -' num2str(wd(c,1)) ', +' num2str(wd(c,2)) ' )'];
end

set(ppopup,'String',st);

set(ppopup,'value',1);

set(pslide,'Value',0);

delete(gca);
subplot('position',[0.2 0.1 0.725 0.7]);
set(gca,'xtick',[],'ytick',[],'ydir','reverse','box','on');
hold on
h = zeros(1,size(cn,2));
for c = 1:size(cn,2)
    h(c) = plot(cn{c}([1:end 1],1),cn{c}([1:end 1],2),'-k');
end
axis equal
axis tight

DrawFrame