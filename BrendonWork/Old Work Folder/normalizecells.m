function linnormmeans=normalizecells(contourmeans);
%takes output from contourvalues and normalizes the plot of each cell to 1.
%may want to make it just normalize within each movie... this normalizes
%across all movies in the matrix for each cell.

linearmeans=reshape(contourmeans, [size(contourmeans,1)*size(contourmeans,2) size(contourmeans,3)]);

ma=max(linearmeans,[],1);%find frame with max brightness value for each cell
mi=min(linearmeans,[],1);%find frame with min brightness value for each cell
ma=repmat(ma,[size(linearmeans,1) 1]);%prepare matrices to be subtracted element by element
mi=repmat(mi,[size(linearmeans,1) 1]);%from linearmeans

linnormmeans=(linearmeans-mi)./(ma-mi);


% %below find code to normalize each cell within each movie... in case it
% %should be needed.  Output of function should be renamed normmeans
%
% ma=max(contourmeans,[],1);%find max for each cell, within each movie
% mi=min(contourmeans,[],1);%find min for each cell, within each movie
% ma=repmat(ma,[size(contourmeans,1) 1 1]);%prepare matrices to be subtracted element by element
% mi=repmat(mi,[size(contourmeans,1) 1 1]);
% 
% normmeans=(contourmeans-mi)./(ma-mi);