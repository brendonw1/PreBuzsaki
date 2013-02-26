function enh=epienhance(image);
%Enhances images taken under 40X objective .5X magnifier from Jason 
%MacLean's setup: (256x256) cCCD from Princeton Instruments, EPIFLUORESCENT
%excitation.  
%First, images are analyzed two ways: First, selecting for bright centers 
%using a LaPlacian (del2) and then selecting for edges using magnitudes of
%2D gradients (gradientmag).  These two images are then median filtered, 
%normalized to between 0 and 1 and then added together for a final enhanced 
%image.  (This can more easily be thresholded to find cells now).

mag=gradientmag(image);%enhance edges
lap=-del2(image);%enhance middles of cells

lap=medfilt2(lap,[5 5]);%median filter both enhanced images, according to the size of a cell (5 pixels wide)
mag=medfilt2(mag,[5 5]);%use 3 instead of 5 for 20X movie

lap=lap-min(min(lap));%set image min to 0
lap=lap/max(max(lap));%set max to 1
mag=mag-min(min(mag));%set image min to 0
mag=mag/max(max(mag));%set max to 1

enh=mag+lap;%and add together... this is final output