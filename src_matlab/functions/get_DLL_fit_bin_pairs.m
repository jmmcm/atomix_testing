function binPairs = get_DLL_fit_bin_pairs(nBinMin,nBinMax,method,zz,binsBoundaries)

% nBinMin = minimum number of bins for separation
% nBinMax = maximum number of bins for separation
% method: 'cloud','centered' or 'anchored'
% zz: vertical bin (if empty, returns relative bin Pairs (i.e. centered on
% zero))
% binsBoundaries: bins corresponding to the boundaries (to keep everything
% centered). Typically [1,NZ], but could also be [1,NZ-2] if max bin is 2
% above surface

switch method
    case 'centered' %BDS method,  i.e. 'central diff'
        nBinMaxHalf = floor((nBinMax+1)/2); % number of bins from centre for centered schemes 
        binPairsAll = nchoosek([-nBinMaxHalf:0, 1:nBinMaxHalf],2);
        % Get centered values
        binMean = mean(binPairsAll,2);
        expMean = (nBinMax+1)/2;
        ind = find(binMean > -1 & binMean < 1);
        binPairsRel = binPairsAll(ind,:);
    case 'cloud' %JMM method, (all possible separations within a cloud)
        nBinMaxHalf = floor((nBinMax+1)/2); % number of bins from centre for centered schemes
        binPairsAll = nchoosek([-nBinMaxHalf:0, 1:nBinMaxHalf],2);
        % Get all possible pairs
        binPairsRel = binPairsAll;
    case 'anchored' % Guerra Thomson method
        binPairsAll = nchoosek([-nBinMax:0, 1:nBinMax],2);
        % Get pairs that include center point
        ind = find( (binPairsAll(:,1) == 0) | (binPairsAll(:,2) == 0));
        binPairsRel = binPairsAll(ind,:);
    otherwise
        methods = {'centered','cloud','anchored'};
        disp([options.diffMethod,' not valid. Options for diffMethod:'])
        for m = methods; disp([' - ',m{:}]); end
        error('options.method not valid...Quitting')
end
binDiff = binPairsRel(:,2) - binPairsRel(:,1);
indKeep = find((binDiff >= nBinMin) & (binDiff <= nBinMax));
binPairsRel = binPairsRel(indKeep,:);

% Sort by separation (easier for viewing)
[~,indSort] = sort(binPairsRel(:,2)-binPairsRel(:,1));
binPairsRel = binPairsRel(indSort,:);

% Get absolute bin pairs
if ~isempty(zz)
     binPairs = binPairsRel + zz;
    
     % Get subset of bins if close to the boundaries (TODO: Move to function?)
     binsToBot = (zz-binsBoundaries(1));
     binsToTop = (binsBoundaries(2)-zz);
     binsFromC = max(abs(binPairsRel(:))); % from center (either 0.5*nBinMax or nBinMax, depending on method)
     minBin = max([binsBoundaries(1), zz-binsToTop,zz-binsFromC]);
     maxBin = min([binsBoundaries(2), zz+binsToBot,zz+binsFromC]);
     indBins = find((binPairs(:,1)>=minBin) & (binPairs(:,2)<=maxBin));
     binPairs = binPairs(indBins,:);
else
    binPairs = binPairsRel;
end