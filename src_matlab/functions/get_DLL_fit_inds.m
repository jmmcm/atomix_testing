function indDLL = get_DLL_fit_inds(binL,binU,binPairs)

% binL = matrix of lower bin numbers
% binU = matrix of upper bin numbers


[nPairs,~] = size(binPairs);

% Initialize 
indDLL = NaN*ones(1,nPairs);

% Get indices
for bb = 1:nPairs
    binPair = binPairs(bb,:);
    ind = find(binL == binPair(1) & binU == binPair(2));
    
    if ~isempty(ind)
        indDLL(bb) = ind;
    else
        indDLL(bb) = NaN;
    end
end

% Remove nans
indDLL = indDLL(find(~isnan(indDLL)));