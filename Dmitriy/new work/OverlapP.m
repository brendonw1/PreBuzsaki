function OverlapP = OverlapP(N,a,b,k,tr)
%OverlapP = OverlapP(N,a,b,k)
%   estimates the probability of randomly picking a subset of a objects and a subset of b objects
%   from a set of N objects and getting two subsets with at least k objects in the intersection
%   by performing tr trials

nums = zeros(1,tr);
for c = 1:tr
    r = randperm(N);
    s = randperm(N);
    nums(c) = size(intersect(r(1:a),s(1:b)),2);
end
OverlapP = size(find(nums>=k),2)/tr;