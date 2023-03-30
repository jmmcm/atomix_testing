function lev3 = calc_level3_ATOMIX(lev2,options)
%CALC_LEVEL3_ATOMIX Calculate level 3 structure from level 2 data when 
% processing ADCP data for ATOMIX testing.
%
% Syntax:
%  lev3 = CALC_LEVEL3_ATOMIX(lev2,indBeg,indEnd,options)
%
% Inputs:
%  - lev2: Structure with all level 2 variables
%  - binPairs: NRx2 matrix containing all the possible bin pairs to compute
%  - options: Structure with any required options
%      * nbinMax: maximum number of bin separation
%      * diffMethod: differencing method to use
%      * dllAvg: sets if averaging of DLL is on or off %REMOVE?
%      * flagFile: string specifying yml file that contains flag info
%
% Outputs:
%  - lev3: Structure with all level 2 variables
%
% Justine McMillan
% Apr 8, 2022
%
% 2022-06-29: Function updated for consistency with Wiki
% 2022-06-29: Function updated to apply flags with separate function 
% 2022-06-30: Function updated to handle options for different differencing
%             methods and for averaging DLL


if ~isfield(options,'figureCheck'); options.figureCheck = 1; end
if ~isfield(options,'nbinMax'); options.nbinMax = length(lev2.Z_DIST); end
if ~isfield(options,'diffMethod'); options.diffMethod = 'forward'; end
if ~isfield(options,'dllAvg'); options.dllAvg = false; end



%% Get bin pairs based on the method
% nBinMax = options.nbinMax;
% 
% switch options.diffMethod
%     case 'method 1' %BDS method,  i.e. 'central diff'
%         nBinMaxHalf = floor((nBinMax+1)/2); % number of bins from centre for centered schemes 
%         binPairsAll = nchoosek([-nBinMaxHalf:0, 1:nBinMaxHalf],2);
%         % Get centered values
%         binMean = mean(binPairsAll,2);
%         expMean = (options.nbinMax+1)/2;
%         ind = find(binMean > -1 & binMean < 1);
%         binPairsRel = binPairsAll(ind,:);
%     case 'method 2' %JMM method, (all possible separations within a cloud)
%         nBinMaxHalf = floor((nBinMax+1)/2); % number of bins from centre for centered schemes
%         binPairsAll = nchoosek([-nBinMaxHalf:0, 1:nBinMaxHalf],2);
%         % Get all possible pairs
%         binPairsRel = binPairsAll;
%     case 'method 3' % Guerra Thomson method
%         binPairsAll = nchoosek([-options.nbinMax:0, 1:options.nbinMax],2);
%         % Get pairs that include center point
%         ind = find( (binPairsAll(:,1) == 0) | (binPairsAll(:,2) == 0));
%         binPairsRel = binPairsAll(ind,:);
%     otherwise
%         methods = {'method 1','method 2'};
%         disp([options.diffMethod,' not valid. Options for diffMethod:'])
%         for m = methods; disp([' - ',m{:}]); end
%         error('options.diffMethod not valid...Quitting')
% end
% binDiff = binPairsRel(:,2) - binPairsRel(:,1);
% % Remove 1 bin separation (TODO: INCLUDE AS OPTION) and bin pairs that exceed max specified separation (necessary if nbinMax is odd)
% indKeep = find((binDiff >= 2) & (binDiff <= options.nbinMax));
% % indKeep = find((binDiff <= options.nbinMax)); % NEED TO ADD FLAG TO USE THIS, and still include 1 bin separation
% binPairsRel = binPairsRel(indKeep,:);
% 
% % Sort by separation (easier for viewing)
% [~,indSort] = sort(binPairsRel(:,2)-binPairsRel(:,1));
% binPairsRel = binPairsRel(indSort,:);

%% Get n_del based on whether DLL will be averaged or not
% if options.dllAvg
%     n_del = unique(binPairsRel(:,2) - binPairsRel(:,1));
%     options.methodMultDll = 'Average';
% else
%     n_del = binPairsRel(:,2) - binPairsRel(:,1);
%     options.methodMultDll = 'None';
% end
%% Sizes
NT = length(lev2.N_SEGMENT);
NZ = length(lev2.Z_DIST);
NB = length(lev2.N_BEAM);
NR = length(lev2.Z_DIST)-1; 
NS = length(lev2.N_SAMPLE);

%% Dimensions
lev3.TIME = nanmean(lev2.TIME,2);
lev3.Z_DIST = lev2.Z_DIST;
lev3.N_BEAM = lev2.N_BEAM;
lev3.N_DEL = [1:NZ-1]; 
lev3.N_BOUND = [1 2];

%% Time bounds
lev3.TIME_BNDS = [nanmin(lev2.TIME,[],2) nanmax(lev2.TIME,[],2)];

%% Initialize
lev3.R_DEL = NaN*ones(NB,NR); 
lev3.R_DIST = ((lev3.Z_DIST*ones(1,NB)) ./ cosd(ones(NZ,1)*lev2.THETA'));
lev3.N_SEGMENT = lev2.N_SEGMENT; % Note: NOT NEEDED FOR ANALYSIS, SHOULD THIS BE OPTIONAL?

lev3.BIN_L = NaN*ones(NT,NZ,NB,NR); % My variable: Lower bin for difference
lev3.BIN_U = NaN*ones(NT,NZ,NB,NR); %  My variable: Upper bin for difference
lev3.DLL = NaN*ones(NT,NZ,NB,NR);
lev3.DLL_FLAGS = zeros*ones(NT,NZ,NB,NR); % Perfect data
lev3.DLL_N = zeros(NT,NZ,NB,NR);

%% Calculate structure function (i.e. DLL)
count = 0;
disp('* Computing DLL *')
for bb = 1:NB
    dr = lev3.R_DIST(2,bb)-lev3.R_DIST(1,bb); % Assumes uniform bin separation
    lev3.R_DEL(bb,:) = lev3.N_DEL*dr;
    
    % Loop through ensembles and calculate DLL
    for tt = 1:NT
        
        % Get velocity timeseries for range bins
        vp = reshape(lev2.R_VEL_DETRENDED(tt,:,bb,:),[NZ,NS])';
        
        % Get SF parameters
        [dll,dll_n,binL,binU] = calc_DLL(vp,options);
        
        % Assign to structures
        lev3.BIN_L(tt,:,bb,:) = binL;
        lev3.BIN_U(tt,:,bb,:) = binU;
        lev3.DLL(tt,:,bb,:) = dll;
        lev3.DLL_N(tt,:,bb,:) = dll_n;
        lev3.N_SEGMENT(tt) = tt;
        
        % Show progress
        count = count+1;
        disp_percdone(count,NT*NB,5)
    end % tt
end % bb

%% Apply flags
disp('* Applying Flags *')
lev3.DLL_N_ratio = lev3.DLL_N / NS;
lev3 = apply_ATOMIX_flags(lev3,'L3','DLL_FLAGS',options.flagFile,struct('dispOutput',1));
lev3 = rmfield(lev3,'DLL_N_ratio');

%% Plot to check (Level 3 diagnostics)
if options.figureCheck
    bb = 3;
    rr = 3;
    drBins = lev3.R_DEL(bb,rr)/dr;

    figure(30),clf
    ax(1) = subplot(311);
    pcolor(get_yd(lev3.TIME),lev3.Z_DIST,squeeze(lev3.DLL(:,:,bb,rr))')
    shading flat
    caxis([0,0.02])
    colorbar
    title(['DLL - \delta r = ',num2str(drBins),' bins'])


    ax(2) = subplot(312);
    pcolor(get_yd(lev3.TIME),lev3.Z_DIST,squeeze(lev3.DLL_N(:,:,bb,rr))')
    shading flat
    colorbar
    title('DLL_N')

    ax(3) = subplot(313);
    pcolor(get_yd(lev3.TIME),lev3.Z_DIST,squeeze(lev3.DLL_FLAGS(:,:,bb,rr))')
    shading flat
    colorbar
    title('Flags')

end
