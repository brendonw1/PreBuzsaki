function [ctrldist, trtdist]=cumfreq(ctrl, trt, treatment)

%Function to plot cumulative frequency of data
%
%Inputs: ctrl is one data set (named Control in the plot)
%        trt in a second data set
%        treatment is the name for the trt data set
%
%Only the ctrl argument is necessary, trt and treatment are optional
%
%Outputs: ctrldist and trtdist are the cumulative frequency distributions for
% the ctrl and trt data sets.
%
%by Emiliano M. Rial Verde
%March 2004

if nargin == 1
    [ctrldist]=plotfreq1(ctrl);
elseif nargin ==2
    treatment='Treatment';
    [ctrldist, trtdist]=plotfreq(ctrl, trt, treatment);
elseif nargin ==3
    [ctrldist, trtdist]=plotfreq(ctrl, trt, treatment);
end

if nargout > nargin
    'ERROR: Too many output arguments.'
end


function [ctrldist, trtdist]=plotfreq(ctrl, trt, treatment)

a=ctrl;
b=trt;
amin=floor(min(a));
amax=ceil(max(a));
bmin=floor(min(b));
bmax=ceil(max(b));
intervalnum=(size(a,1)+size(b,1))*2;
interval=[];
interval=([min([amin bmin]):abs(max([amax bmax])-min([amin bmin]))/intervalnum:max([amax bmax])])';
c=[];
d=[];
for i=1:size(interval,1)
   c=[c; sum(a<=interval(i,1))/size(a,1)];
   d=[d; sum(b<=interval(i,1))/size(b,1)];
end

ksxaxis=interval;
ctrldist=c;
trtdist=d;

h0=figure;
set(h0, 'numbertitle', 'off', ...
  'name', 'Cumulative frequency plot', ...
  'units', 'normalized', ...
  'position', [.005 .35 .5469 .5469]);
orient landscape;
plot(ksxaxis, ctrldist, 'linewidth', [2]);
hold on;
plot(ksxaxis, trtdist, 'r', 'linewidth', [2]);
set(gca, 'ylim', [0 1], 'ylabel', text('string', 'Cumulative frequency', 'FontWeight', 'bold'), ...
  'xlim', [ksxaxis(1,1) -1], 'yaxislocation', 'right', 'xlabel', text('string', 'Amplitude (pA)', 'FontWeight', 'bold'), ...
  'xscale', 'log', 'FontWeight', 'bold');
text(ksxaxis(1,1),[1], [' Blue: Control. Red: ', treatment, '.'], ...
  'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'FontWeight', 'bold');


function [ctrldist]=plotfreq1(ctrl)

a=ctrl;
amin=floor(min(a));
amax=ceil(max(a));
intervalnum=size(a,1)*2;
interval=[];
interval=([amin : (abs(amax)-amin)/intervalnum : amax])';
c=[];
for i=1:size(interval,1)
   c=[c; sum(a<=interval(i,1))/size(a,1)];
end

ksxaxis=interval;
ctrldist=c;

h0=figure;
set(h0, 'numbertitle', 'off', ...
  'name', 'Cumulative frequency plot', ...
  'units', 'normalized', ...
  'position', [.005 .35 .5469 .5469]);
orient landscape;
plot(ksxaxis, ctrldist, 'linewidth', [2]);
set(gca, 'ylim', [0 1], 'ylabel', text('string', 'Cumulative frequency', 'FontWeight', 'bold'), ...
  'xlim', [ksxaxis(1,1) -1], 'yaxislocation', 'right', 'xlabel', text('string', 'Amplitude (pA)', 'FontWeight', 'bold'), ...
  'xscale', 'log', 'FontWeight', 'bold');