function handles = adjust_contours_towards_pi(handles)
% function handles = adjust_contours_towards_pi(handles)

% Midx is the mask that is currently being processed.
midx = handles.appData.currentMaskIdx;
% Ridx is the region currently being processed.
ridx = handles.appData.currentRegionIdx;
nhandlr = length(handles.guiOptions.face.handl{ridx}{midx});
handlr = handles.guiOptions.face.handl{ridx}{midx};
cnr = handles.exp.regions.contours{ridx}{midx};
tc_image = handles.exp.tcImage(midx).image;
clr = handles.exp.regions.cl(ridx,:);
filtered_image = handles.exp.tcImage(midx).filteredImage;
wd = zeros(1,length(handlr));
% The linewidth is the way the GUI detects for bad contours.
for c = 1:nhandlr
    wd(c)= get(handlr(c),'linewidth');
end
f = find(wd==2);

tempcn = [];
spl = [];
for c = 1:length(cnr)
    if isempty(find(f==c))
        tempcn{length(tempcn)+1} = cnr{c};
    else
        newcn = {};
        crd = cnr{c};
        x = max([fix(min(crd(:,1)))-2 1]):min([fix(max(crd(:,1)))+2 ...
		    size(tc_image,2)]);
        y = max([fix(min(crd(:,2)))-2 1]):min([fix(max(crd(:,2)))+2 ...
		    size(tc_image,1)]);
        vls = filtered_image(y,x);
        [xs ys] = meshgrid(x,y);
        in = inpolygon(xs,ys,crd(:,1),crd(:,2));
        vls = vls.*in;
        
        mx = zeros(size(vls));
        for xf = -1:1
            for yf = -1:1
                mx(2:end-1,2:end-1) = max(cat(3,mx(2:end-1,2:end-1),vls((2:end-1)+yf,(2:end-1)+xf)),[],3);
            end
        end
        
        [j i] = find(vls>=mx & vls~=0);
        i = x(1)+i-1;
        j = y(1)+j-1;
        
        dst = [];
        for d = 1:length(i)
            dst(:,d) = sum((crd-repmat([i(d) j(d)],size(crd,1),1)).^2,2);
        end
        [mn bestcell] = min(dst,[],2);
        set(handlr(c),'visible','off');
        for d = 1:length(i)
            newcn{d} = crd(find(bestcell==d),:);
            if ~isempty(newcn{d})
                v1 = newcn{d}([2:end 1],:)-newcn{d};
                v2 = newcn{d}([end 1:end-1],:)-newcn{d};
                angl = sum(v1.*v2,2)./(sum(v1.^2,2).*sum(v2.^2,2)+eps);
                newcn{d} = newcn{d}(find(angl<0),:);
                if ~isempty(newcn{d})
                    spl = [spl plot(newcn{d}([1:end 1],1),newcn{d}([1:end 1],2),'linewidth',2,'Color',1-clr)];
                end
            end
            tempcn{length(tempcn)+1} = newcn{d};
        end
        drawnow;
        refresh;
    end
end

cnr = [];
% Check to make sure that the new contours are still greater than
% the min area. -DCS:2005/03/30
min_area = handles.guiOptions.face.minArea;
for c = 1:length(tempcn)
    if (polyarea(tempcn{c}(:,1),tempcn{c}(:,2))*(handles.exp.mpp^2) >= min_area)
        cnr{size(cnr,2)+1} = tempcn{c};
    end
end

handles.guiOptions.face.handl{ridx}{midx} = handlr;
handles.exp.regions.contours{ridx}{midx} = cnr;
handles.guiOptions.face.isAdjusted(ridx) = 1;

delete(spl);

