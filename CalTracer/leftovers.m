tracereaders


%inf = imfinfo(filename);
%inflen = length(inf);

%if strcmp(inf(1).ByteOrder,'little-endian');
%    readspec='ieee-le';
%elseif strcmp(inf(1).ByteOrder,'big-endian');
%    readspec='ieee-be';
%end
%fid = fopen(filename, 'rb', readspec);


%h = waitbar(0, 'Reading traces (1/2).  Please wait.');
%for c = 1:contourslen    
%    %waitbar(c/contourslen);
%    ps = round(contours{c});
%    [subx suby] = meshgrid(min(ps(:,1)):max(ps(:,1)), ...
%			   min(ps(:,2)):max(ps(:,2)));
%    inp = inpolygon(subx, suby, ...
%		    contours{c}(:,1), ...
%		    contours{c}(:,2));
%    cidxx = subx(find(inp == 1));
%    cidxy = suby(find(inp == 1));
%    cidx{c} = sub2ind(size(image'), cidxx, cidxy);% contour indices in image.
    
%    for d = 1:inflen
%        fseek(fid,inf(d).StripOffsets(1)+2*min(cidx{c})-2,'bof');
%        [im count] = fread(fid,max(cidx{c})-min(cidx{c})+1,'*uint16');
%        tr(c,d) = mean(im(cidx{c}-min(cidx{c})+1));
%    end
%end
%close(h);



%h = waitbar(0, 'Reading traces from file (2/2).  Please wait.');
%for d = 1:inflen
%    waitbar(d/inflen);
%    for c = 1:contourslen
%        fseek(fid,inf(d).StripOffsets(1)+2*min(cidx{c})-2,'bof');
%        [im count] = fread(fid,max(cidx{c})-min(cidx{c})+1,'*uint16');
%        traces(c,d) = mean(im(cidx{c}-min(cidx{c})+1));
%    end
%end
%close(h);

