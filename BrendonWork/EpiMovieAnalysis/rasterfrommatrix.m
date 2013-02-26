function rasterfrommatrix(ons)

% input is matrix in form of ones and zeros... as is produced in the variable "ons" in the function
% ons.  Has the form of frames x cell.

% newon=shiftdim(ons,2);%now in format of cells x frames x movies
ons=ons';%accounting for fact that this program was written when ons was inverted
sums=sum(ons,1);
sums=squeeze(sums);

[a b]=find(ons(:,:)==1);%a and b are addresses for all instances where a cell is on: any cell in any frame 
                            %(a is frame, b is cell)
figure;

hold on;
for y=1:size(b)%for each cell
%     subplot(2,1,1); 
    patch([b(y)-.2 b(y)+.2 b(y)+.2 b(y)-.2],[a(y)-.6 a(y)-.6 a(y)-.4 a(y)-.4],'k','linewidth',1);%plotting a vertical line at each point 
                                                            %corresponding to a cell turning on in a frame         
    ylim([0 size(ons,1)]);
    xlim([.5 size(ons,2)+.5]);
    hold on
end

% subplot(2,1,1);
% hold on;
% plot([0 size(ons,2)+.5 size(ons,2)+.5 0 0],[0 0 size(ons,1) size(ons,1) 0],'k')

% subplot(2,1,2);
% bar(sums)
% xlim([.5 size(ons,2)+.5])
% 
% subplot(2,1,1);
% hold on;
% plot([0 size(ons,2)+.5 size(ons,2)+.5 0 0],[0 0 size(ons,1) size(ons,1) 0],'k')