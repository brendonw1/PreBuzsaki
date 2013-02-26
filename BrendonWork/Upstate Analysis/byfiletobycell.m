function mat=byfiletobycell(mat)
%takes a 4d matrix arranged as slice number, trial number, cell number,
%upstate number and rearranges to cell number (slice then cell) x upstate
%number (trial number, upstate number)

mat=ipermute(mat,[1 3 2 4]);
mat=reshape(mat,[prod([size(mat,1) size(mat,2)]) prod([size(mat,3) size(mat,4)])]);

if isfield(mat,'guide');
	if length(size(mat(1).guide))==4;
        mat(1).guide=ipermute(mat(1).guide,[1 3 2 4]);
        mat(1).guide=reshape(mat(1).guide,[prod([size(mat(1).guide,1) size(mat(1).guide,2)]) prod([size(mat(1).guide,3) size(mat(1).guide,4)])]);
	end
end

if isfield(mat,'coreguide');%if applied "scriptforaddingcore" this will be on uptraces
	if length(size(mat(1).coreguide))==2;
        mat(1).coreguide=reshape(mat(1).coreguide,[prod(size(mat(1).coreguide)) 1]);
	end
end

if isfield(mat,'spikeguide');%tells which upstates had spikes... is on spikereshuffuptraces
	if length(size(mat(1).spikeguide))==4;
        mat(1).spikeguide=ipermute(mat(1).spikeguide,[1 3 2 4]);
        mat(1).spikeguide=reshape(mat(1).spikeguide,[prod([size(mat(1).spikeguide,1) size(mat(1).spikeguide,2)]) prod([size(mat(1).spikeguide,3) size(mat(1).spikeguide,4)])]);
	end
end
