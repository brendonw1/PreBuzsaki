function normalized=normalizemovie(movie);
%normalizes pixel values in a 3D moviematrix of multiple movies... 
%each movie is normalized within itself

m=movie(1:end);
mn=min(m);
mx=max(m);

normalized=(movie-mn)./(mx-mn);