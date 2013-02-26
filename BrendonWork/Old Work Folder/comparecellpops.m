function comparecellpops(df, ons, mt, st, base, sn)
% - df is a matrix of movies where actual contour values are replaced by
%values subtracted from following frames
% - ons is 1's and 0's.  1 where a cell was on in a frame, 0 all else
%  - mt is mean of each cell in each movie over the frames... the matrix is replicated over all frames
%  - base is a moving baseline of the brightness curve of each cell for each movie
%  - sn is similar to mt, but is the standard dev. of the noise of that brightness profile (noise based on subtracting
%  from the baseline)
%  
%  this function will plot various functions of the "on" cells and the "off" cells in the population against each other.

onvalues=df(ons);%diff values of cells which were on
offvalues=df(~ons);%diff values of cells which were not on
onmeans=mt(ons);
offmeans=mt(~ons);
onsds=mt(ons);
offsds=mt(~ons);
onbase=base(ons);
offbase=base(~ons);
onsdnoise=sn(ons);
offsdnoise=sn(~ons);

onfrommean=onvalues-onmeans;
offfrommean=offvalues-offmeans;
onfrombase=onvalues-onbase;
offfrombase=offvalues-offbase;
onsdnoisefrommean=onfrommean./onsdnoise;
offsdnoisefrommean=offfrommean./offsdnoise;
onsdnoisefrombase=onfrombase./onsdnoise;
offsdnoisefrombase=offfrombase./offsdnoise;

% figure

[onv,lonv]=hist(onvalues,25);
onv=onv/max(onv);
[offv,loffv]=hist(offvalues,25);
offv=offv/max(offv);
s=sort(offvalues);
thresh=s(floor(.05*length(s)));
thresh=[thresh thresh];
plotter=[0 1];
subplot(2,3,1)
hold on
plot(lonv,onv,loffv,offv,thresh,plotter);
xlabel('Brightness value of df/fo contours');ylabel('Count');


[onfm,lonfm] = hist(onfrommean,25);
onfm=onfm/max(onfm);
[offfm,lofffm] = hist(offfrommean,25);
offfm=offfm/max(offfm);
s=sort(offfrommean);
thresh=s(floor(.05*length(s)));
thresh=[thresh thresh];
plotter=[0 1];
subplot(2,3,2)
hold on
plot(lonfm,onfm,lofffm,offfm,thresh,plotter);
xlabel('Brightness minus mean for that contour in that movie');ylabel('Count');

[onfb,lonfb] = hist(onfrombase,25);
onfb=onfb/max(onfb);
[offfb,lofffb] = hist(offfrombase,25);
offfb=offfb/max(offfb);
s=sort(offfrommean);
thresh=s(floor(.05*length(s)));
thresh=[thresh thresh];
plotter=[0 1];
subplot(2,3,3)
hold on
plot(lonfb,onfb,lofffb,offfb,thresh,plotter);
xlabel('Brightness minus baseline for that contour in that movie');ylabel('Count');

[onsd,lonsd]=hist(onsds,25);
onsd=onsd/max(onsd);
[offsd,loffsd]=hist(offsds,25);
offsd=offsd/max(offsd);
subplot(2,3,4);
hold on
plot(lonsd,onsd,loffsd,offsd);
ylim([0,max(onsd)]);

[onnfm,lonnfm] = hist(onsdnoisefrommean,25);
onnfm=onnfm/max(onnfm);
[offnfm,loffnfm] = hist(offsdnoisefrommean,25);
offnfm=offnfm/max(offnfm);
s=sort(offsdnoisefrommean);
thresh=s(floor(.05*length(s)));
thresh=[thresh thresh];
plotter=[0 1];
subplot(2,3,5)
hold on
plot(lonnfm,onnfm,loffnfm,offnfm);
xlabel('Brightness minus mean/divided by sd of noise');ylabel('Count');


[onnfb,lonnfb] = hist(onsdnoisefrombase,25);
onnfb=onnfb/max(onnfb);
[offnfb,loffnfb] = hist(offsdnoisefrombase,25);
offnfb=offnfb/max(offnfb);
s=sort(offsdnoisefrombase);
thresh=s(floor(.05*length(s)));
thresh=[thresh thresh];
plotter=[0 1];
subplot(2,3,6)
hold on
plot(lonnfb,onnfb,loffnfb,offnfb,thresh,plotter);
xlabel('Brightness minus baseline/divided by sd of noise');ylabel('Count');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure

[onv,lonv]=hist(onvalues,25);
[offv,loffv]=hist(offvalues,25);
s=sort(offvalues);
thresh=s(floor(.05*length(s)));
thresh=[thresh thresh];
plotter=[0 max(onv)];
subplot(2,3,1)
hold on
plot(lonv,onv,loffv,offv,thresh,plotter);
xlabel('Brightness value of df/fo contours');ylabel('Count');
ylim([0,max(onv)]);

[onfm,lonfm] = hist(onfrommean,25);
[offfm,lofffm] = hist(offfrommean,25);
s=sort(offfrommean);
thresh=s(floor(.05*length(s)));
thresh=[thresh thresh];
plotter=[0 max(onfm)];
subplot(2,3,2)
hold on
plot(lonfm,onfm,lofffm,offfm,thresh,plotter);
xlabel('Brightness minus mean for that contour in that movie');ylabel('Count');
ylim([0,max(onfm)]);

[onfb,lonfb] = hist(onfrombase,25);
[offfb,lofffb] = hist(offfrombase,25);
s=sort(offfrommean);
thresh=s(floor(.05*length(s)));
thresh=[thresh thresh];
plotter=[0 max(onfb)];
subplot(2,3,3)
hold on
plot(lonfb,onfb,lofffb,offfb,thresh,plotter);
xlabel('Brightness minus baseline for that contour in that movie');ylabel('Count');
ylim([0,max(onfb)]);

[onsd,lonsd]=hist(onsds,25);
[offsd,loffsd]=hist(offsds,25);
subplot(2,3,4);
hold on
plot(lonsd,onsd,loffsd,offsd);
ylim([0,max(onsd)]);

[onnfm,lonnfm] = hist(onsdnoisefrommean,25);
[offnfm,loffnfm] = hist(offsdnoisefrommean,25);
s=sort(offsdnoisefrommean);
thresh=s(floor(.05*length(s)));
thresh=[thresh thresh];
plotter=[0 max(onnfm)];
subplot(2,3,5)
hold on
plot(lonnfm,onnfm,loffnfm,offnfm);
xlabel('Brightness minus mean/divided by sd of noise');ylabel('Count');
ylim([0,max(onnfm)]);

[onnfb,lonnfb] = hist(onsdnoisefrombase,25);
[offnfb,loffnfb] = hist(offsdnoisefrombase,25);
s=sort(offsdnoisefrombase);
thresh=s(floor(.05*length(s)));
thresh=[thresh thresh];
plotter=[0 max(onnfb)];
subplot(2,3,6)
hold on
plot(lonnfb,onnfb,loffnfb,offnfb,thresh,plotter);
xlabel('Brightness minus baseline/divided by sd of noise');ylabel('Count');
ylim([0,max(onnfb)]);