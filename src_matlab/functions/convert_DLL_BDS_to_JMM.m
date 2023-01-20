function L3out = convert_DLL_BDS_to_JMM(L3in,rMax)
%% function L3out = convert_DLL_BDS_to_JMM(L3in,rMax)
%
% Function to convert DLL variables from BDS format (forward difference) to
% JMM format. Relevant for method 2.1 (i.e. 2u) differencing.
%
% Justine McMillan
% 2023-01-19

% Initialize
L3out = L3in;
[NT,NZ,NB,NR] = size(L3in.DLL);
dr = L3in.R_DIST(2) - L3in.R_DIST(1);

%% Get bin pairs for method 2

% Copied from calc_level3_ATOMIX
nBinMax = floor(rMax/dr);
nBinMaxHalf = floor((nBinMax)/2); % number of bins from centre for centered schemes (TODO: Update to include +1 like calc_level3_ATOMIX.m)
binPairsRel = nchoosek([-nBinMaxHalf:0, 1:nBinMaxHalf],2);
binDiff = binPairsRel(:,2) - binPairsRel(:,1);
% Remove 1 bin separation and bin pairs that exceed max specified separation (necessary if nbinMax is odd)
indKeep = find((binDiff >= 2) & (binDiff <= nBinMax));
binPairsRel = binPairsRel(indKeep,:);
% Sort by separation (easier for viewing)
[~,indSort] = sort(binPairsRel(:,2)-binPairsRel(:,1));
binPairsRel = binPairsRel(indSort,:);

nDel = binPairsRel(:,2) - binPairsRel(:,1);


%% Create binL and binU matrices that are the same size as DLL
binL = [1:NZ]'*ones(1,NR);
delta = [2:NZ-1];
binU = binL+ones(NZ ,1)*delta;

ind = find(binU>NZ);
binU(ind) = NaN;

%% Initialize output variables
NRout = length(binPairsRel);
L3out.DLL = NaN*ones(NT,NZ,NB,NRout);
L3out.DLL_N = NaN*ones(NT,NZ,NB,NRout);
L3out.DLL_FLAGS = NaN*ones(NT,NZ,NB,NRout);
L3out.BIN_U = NaN*ones(NT,NZ,NB,NRout);
L3out.BIN_L = NaN*ones(NT,NZ,NB,NRout);
L3out.R_DEL = NaN*ones(NB,NRout);
L3out.N_DEL = nDel;


%% Convert DLL matrices
for bb = 1:NB
    L3out.R_DEL(bb,:) = nDel*dr;
 
    for tt = 1:NT
        
        DLL = squeeze(L3in.DLL(tt,:,bb,:));
        DLL_N = squeeze(L3in.DLL_N(tt,:,bb,:));
        DLL_FLAGS = squeeze(L3in.DLL_FLAGS(tt,:,bb,:));

        for zz = 1:NZ
            % Get range of bins
            binsToBot = (zz-1);
            binsToTop = (NZ-zz);
            minBin = max([1, zz-binsToTop,zz-nBinMaxHalf]);
            maxBin = min([NZ,zz+binsToBot,zz+nBinMaxHalf]);
            
            % Get indices for bins within range
            indBDS = find(binL>=minBin & binU<=maxBin);
            
      
            % Map to correct locations in DLL matrix (to compare with JMM matrix)
            if ~isempty(indBDS)
                binPairsOut = [binL(indBDS) binU(indBDS)] - zz;
                ind = find(ismember(binPairsRel,binPairsOut,'rows'));
                
                L3out.DLL(tt,zz,bb,ind) = DLL(indBDS);
                L3out.DLL_N(tt,zz,bb,ind) = DLL_N(indBDS);
                L3out.DLL_FLAGS(tt,zz,bb,ind) = DLL_FLAGS(indBDS);
                L3out.BIN_L(tt,zz,bb,ind) = binL(indBDS);
                L3out.BIN_U(tt,zz,bb,ind) = binU(indBDS);
            end
        end
        
    end
end


