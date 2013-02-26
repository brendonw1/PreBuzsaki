function make_square = make_square(m);
% make_square(m)
%   Works the same way as RESHAPE
%   Reshapes a matrix into a square matrix
%   Useful for modifying outputs of sq1c and spkdl


tot_size = size(m,1) * size(m,2);
tot_size = sqrt(tot_size);

if rem(tot_size,1) > 0
   error('the size of the output is not correct');
end

make_square = reshape(m,tot_size,tot_size);