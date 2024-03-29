function kcenter_index=gen_orthogonal_centers(uu)
  
% function kcenter=gen_orthogonal_centers(uu)
%
% generate the orthogonal centers given the k points . See then paper by
% Andrew Ng (On spectral clustering analysis and algo, footnote below the
% experiments ) 
% uu = The given points 
% kcenter = the assigned  k centers. 
%
% NOTE : uu must be NORMALIZED. This does NOT perform any normalization . 
  
  
  k=size(uu,1);
  n=size(uu,2);
 
  init_index=floor(1+(rand(1)*n));

  centers=uu(:,init_index)'; % is i x k where i is the number of
                             % centers. 
  kcenter_index=zeros(1,k);
  kcenter_index(1,1)=init_index;
  for i=2:k
	dotprod_abs=abs(centers*uu);
	max_dot_prod=max(dotprod_abs,[],1) ;
	[min_val, min_index]=min(max_dot_prod);
	centers=[centers ;uu(:,min_index)' ] ;
	kcenter_index(1,i)=min_index;
  end
  
  
