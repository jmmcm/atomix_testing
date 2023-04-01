function [rDelFit,DllFit,rDelAll,DllAll,indD,binPairs] = get_DLL_fit_data(zz,rDelVec,DllMat,binL,binU,dr,options)
% DllMat = matrix of Dll values for a specific time and beam number
% rDelVec = vector of rDel values for a specific beam number
% zz = z index at which to get fit values for
%
% Justine McMillan
% Mar 23, 2023

% Initialize outputs
rDelFit = NaN;
DllFit = NaN;
rDelAll = NaN;
DllAll = NaN;
indD = NaN;
binPairs = NaN;



% Handle inputs
DllMat = squeeze(DllMat);
rDelVec = squeeze(rDelVec);

% Size
[NZ,NR] = size(DllMat);

% Get minimum and maximum bin separation
nBinMin = floor(options.rMin/dr);
nBinMax = floor(options.rMax/dr);

% Get bin pairs for fit (depends on method)
binPairs = get_DLL_fit_bin_pairs(nBinMin,nBinMax,options.points_select_method,zz,[1, NZ]);

if ~isempty(binPairs)
    % Get DLL indices for bin pairs
    indD = get_DLL_fit_inds(binL,binU,binPairs);
    
    % Get R_DEL indices for bin pairs
    [~,indR] = ind2sub(size(DllMat),indD);
    
    % Get values at indices
    rDelAll = rDelVec(indR);
    DllAll = DllMat(indD);
    
    % Average Dll if necessary
    if options.dll_averaging
        [rDelFit,DllFit] = get_DLL_averages(rDelAll,DllAll);
    else
        rDelFit = rDelAll;
        DllFit = DllAll;
    end
end





