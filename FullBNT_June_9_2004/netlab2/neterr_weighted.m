function [e, varargout] = neterr_weighted(w, net, x, t, eso_w)
%NETERR	Evaluate network error function for generic optimizers
%
%	Description
%
%	E = NETERR(W, NET, X, T) takes a weight vector W and a network data
%	structure NET, together with the matrix X of input vectors and the
%	matrix T of target vectors, and returns the value of the error
%	function evaluated at W.
%
%	[E, VARARGOUT] = NETERR(W, NET, X, T) also returns any additional
%	return values from the error function.
%
%	See also
%	NETGRAD, NETHESS, NETOPT
%

%	Copyright (c) Ian T Nabney (1996-9)

errstr = [net.type, 'err_weighted'];
net = netunpak(net, w);

[s{1:nargout}] = feval(errstr, net, x, t, eso_w);
e = s{1};
if nargout > 1
  for i = 2:nargout
    varargout{i-1} = s{i};
  end
end
