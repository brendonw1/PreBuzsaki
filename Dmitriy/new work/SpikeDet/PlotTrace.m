%Plots the CellNumth trace

if HowChange == 1
   CellNum = round(get(slide,'Value'));
   HowChange = 0;
end
set(slide,'Value',CellNum);

if strcmp(get(mtrad,'Checked'),'on')
   ctr = (Traces(CellNum,:)-mean(Traces(CellNum,1:DffOrd)))/mean(Traces(CellNum,1:DffOrd));
else
   ctr = Traces(CellNum,:);
end

subplot('position',[.05 .1 .7 .85]);
if Filt == 0
   h = plot(ctr,'-b');
else
   h = plot(Mfilter(ctr,Filt),'-b');
end
if strcmp(get(mvpts,'Checked'),'on')
   set(h,'Marker','.','MarkerSize',4,'MarkerEdgeColor',[1 1 0]);
end
xlim([0 size(Traces,2)]);
set(gca,'Color',[0 0 0],'xcolor',[1 1 1],'ycolor',[1 1 1]);
%axis manual
yl = get(gca,'ylim');

if Filt == 0
   BaseLine = CalcBase(ctr,BasePts);
else
   BaseLine = CalcBase(Mfilter(ctr,Filt),BasePts);
end

if strcmp(get(mvbas,'Checked'),'on')
   hold on
   plot(BaseLine,'-g');
   hold off
end

if Threshold(CellNum) == 0
   %Threshold(CellNum) = mean(Threshold(1:CellNum));
   Threshold(CellNum) = -1.5*std(Traces(CellNum,:))/mean(Traces(CellNum,:));
end
hold on
ThresCurve = plot(BaseLine+Threshold(CellNum),':r');
hold off

subplot('position',[.825 .1 .15 .15]);
plot(Coords{CellNum}([1:end 1],1),Coords{CellNum}([1:end 1],2),'-y');
ct = CenterMass(Coords{CellNum});
if strcmp(get(mvcen,'Checked'),'on');
   hold on
   plot(ct(1),ct(2),'.y');
   hold off
end
axis tight
axis equal
axis off
set(atext,'String',['Area = ' num2str(round(poly_area(Coords{CellNum})*AreaInd*10)/10) ' µm²']);
set(ftext,'String',['Trace ' num2str(CellNum) ' of ' num2str(size(Traces,1))]);
if CellNum < size(Traces,1)
   set(bforw,'Enable','on');
else
   set(bforw,'Enable','off');
end
if CellNum == 1
   set(bback,'Enable','off');
else
   set(bback,'Enable','on');
end

set(sblev,'Enable','on');
if Threshold(CellNum) < yl(1)-max(BaseLine)
   Threshold(CellNum) = yl(1)-max(BaseLine);
end
if Threshold(CellNum) > yl(2)-max(BaseLine)
   Threshold(CellNum) = yl(2)-max(BaseLine);
end

set(sblev,'SliderStep',[range(yl)/750 range(yl)/40],'Min',yl(1)-max(BaseLine),'Max',yl(2)-max(BaseLine),...
   'Value',Threshold(CellNum));