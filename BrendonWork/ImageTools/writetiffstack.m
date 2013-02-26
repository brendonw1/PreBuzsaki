function writetiffstack(movie,moviefilename)
%inputs should be 1) movie = 3D movie matrix.  X by Y by Z.  Z should be
%frame number.  2) moviefilename should be a text entry, if does not have
%'.tif' at end, '.tif' will be appended.

%add .tif to end if it's not there
if length(moviefilename)<4 %#ok<ISMT>
    moviefilename = [moviefilename '.tif'];
else
    if ~strcmp(moviefilename(end-3:end),'.tif');
        moviefilename = [moviefilename '.tif'];
    end
end

for fidx = 1:size(movie,3);
    imwrite(movie(:,:,fidx),moviefilename,'tif','compression','none','WriteMode','append');
end