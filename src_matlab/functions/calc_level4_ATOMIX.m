function lev4 = calc_level4_ATOMIX(lev3,options)
%CALC_LEVEL4_ATOMIX Calculate level 4 structure from level 3 data when
% processing ADCP data for ATOMIX testing.
%
% Syntax:
%  lev4 = CALC_LEVEL4_ATOMIX(lev3,indBeg,indEnd,options)
%
% Inputs:
%  - lev3: Structure with all level 3 variables
%  - binPairs: NRx2 matrix containing all the possible bin pairs to compute
%  - options: Structure with any required options
%      * dr: delta r value for one bin separation (i.e. dz/theta)
%      * nBinMax: maximum number of bin separation
%      * flagFile:
%
% Outputs:
%  - lev3: Structure with all level 2 variables
%
% Justine McMillan
% Apr 8, 2022
%
% 2022-06-20: Update for consistency of variables with Wiki
% 2022-06-29: Update to use separate function to apply flags
% 2023-04-08: Update to use forward difference DLL for all methods
% 2023-12-29: Update to output fitted R_DEL and DLL as matrices instead of cells
% 2025-11-07: Update to output bootstrapping results


if ~isfield(options,'figureCheck'); options.figureCheck = 1; end
if ~isfield(options,'Nbootstrap'); options.Nbootstrap = 0; end


%% Sizes
NT = length(lev3.TIME);
NZ = length(lev3.Z_DIST);
NB = length(lev3.N_BEAM);

%% Dimensions
lev4.TIME = lev3.TIME;
lev4.Z_DIST = lev3.Z_DIST;
lev4.N_BEAM = lev3.N_BEAM;
lev4.N_BOUND = [1 2];

%% Time bounds
lev4.TIME_BNDS = lev3.TIME_BNDS;

%% Initialize
lev4.EPSI = NaN*ones(NT,NZ,NB);
lev4.EPSI_FINAL = NaN*ones(NT,NZ);
lev4.C2 = options.Const; % Note: Should this just be in the yml file?
lev4.EPSI_FLAGS = zeros(NT,NZ,NB); % Perfect data
lev4.EPSI_CI_HIGH = NaN*ones(NT,NZ,NB);
lev4.EPSI_CI_LOW = NaN*ones(NT,NZ,NB);
lev4.EPSI_DEL_RATIO = NaN*ones(NT,NZ,NB); % MY METRIC
lev4.EPSI_CI_HIGH_BOOTSTRAP = NaN*ones(NT,NZ,NB);
lev4.EPSI_CI_LOW_BOOTSTRAP = NaN*ones(NT,NZ,NB);
lev4.EPSI_DEL_RATIO_BOOTSTRAP = NaN*ones(NT,NZ,NB); % MY METRIC
lev4.EPSI_CI_HIGH_REGRESSION = NaN*ones(NT,NZ,NB);
lev4.EPSI_CI_LOW_REGRESSION = NaN*ones(NT,NZ,NB);
lev4.EPSI_DEL_RATIO_REGRESSION = NaN*ones(NT,NZ,NB); % MY METRIC
lev4.MSPE = NaN*ones(NT,NZ,NB);
lev4.MAD = NaN*ones(NT,NZ,NB);
lev4.R_MAX = NaN*ones(NT,NZ,NB);
lev4.REGRESSION_COEFF_A0 = NaN*ones(NT,NZ,NB);
lev4.REGRESSION_COEFF_A1 = NaN*ones(NT,NZ,NB);
if options.Nbootstrap > 0
    lev4.REGRESSION_COEFF_A0_BOOTSTRAP = NaN*ones(NT,NZ,NB,options.Nbootstrap);
    lev4.REGRESSION_COEFF_A1_BOOTSTRAP = NaN*ones(NT,NZ,NB,options.Nbootstrap);
else
    lev4.REGRESSION_COEFF_A0_BOOTSTRAP = NaN;
    lev4.REGRESSION_COEFF_A1_BOOTSTRAP = NaN;
end
lev4.REGRESSION_R2 = NaN*ones(NT,NZ,NB);
lev4.REGRESSION_N = NaN*ones(NT,NZ,NB);

REGRESSION_DLL = cell(NT,NZ,NB);
REGRESSION_R_DEL = cell(NT,NZ,NB);


%%
%optionsLev3. % Assumes all bins are the same size and all beam angles are the same
%optionsLev3.nbinMax = floor(optionsLev3.rMax./optionsLev3.dr); % Max number of bins to use


%% Calculate epsilon
disp('* Computing epsilon *')
count = 0;
binL = lev3.BIN_L;
binU = lev3.BIN_U;
for bb = 1:NB
    rDel = squeeze(lev3.R_DEL(bb,:));
    dr = rDel(2) - rDel(1); % Assumes uniform separation
    
    nBinMin = floor(options.rMin./dr); % Min number of bins to use
    nBinMax = floor(options.rMax./dr); % Max number of bins to use
    
    
    % Loop through ensembles and calculate DLL and epsilon
    for tt = 1:NT
        % disp([num2str(tt) ' of ', num2str(NT)])
        % Get simple variables
        
        dll = squeeze(lev3.DLL(tt,:,bb,:));
        dll_flags = squeeze(lev3.DLL_FLAGS(tt,:,bb,:));
        
        
        
        % Create mask and apply QC
        dll_flags(dll_flags>0) = NaN;
        dll_flags = dll_flags+1;
        dllQC = dll.*dll_flags;
        
        for zz = 1:NZ
            
            
            % Get points for fit (depends on the method)
            [rDelFit,dllFit,rDelAll,dllAll,indDll,binPairs] = get_DLL_fit_data(zz,rDel,dllQC,binL,binU,dr,options);
            %             % Get bin pairs for fit
            %             binPairs = get_DLL_fit_bin_pairs(nBinMin,nBinMax,options.points_selection,zz,[1, NZ]);
            %
            %
            %             if ~isempty(binPairs)
            %                 % Get indices for bin Pairs
            %                 indDll = get_DLL_fit_inds(binL,binU,binPairs);
            %                 [indDllRow,indDllCol] = ind2sub(size(dll),indDll);
            %                 rDeltmp = rDel(indDllCol);
            %                 dllQCtmp = dllQC(indDll);
            %
            %                 % Average Dll if necessary
            %                 if options.dll_averaging
            %                     [rDelFit,dllQCfit] = get_DLL_averages(rDeltmp,dllQCtmp);
            %                 else
            %                     rDelFit = rDeltmp;
            %                     dllQCfit = dllQCtmp;
            %                 end
            
            % Linear regression to get epsilon
            if length(rDelFit)>0
                %                  if zz == 4;  options.figure = 1; end %DEBUGGING
                [epsi,sigmaN,Rinfo] = calc_eps_SF(rDelFit,dllFit,options);
                
                % Assign to structures
                lev4.EPSI(tt,zz,bb) = epsi;
                lev4.R_MAX(tt,zz,bb) = max(rDelFit);
                lev4.REGRESSION_COEFF_A0(tt,zz,bb) = Rinfo.yint;
                lev4.REGRESSION_COEFF_A1(tt,zz,bb) = Rinfo.slope;
                if options.Nbootstrap>0
                    lev4.REGRESSION_COEFF_A0_BOOTSTRAP(tt,zz,bb,:) = Rinfo.bootstrap_coeff(:,1);
                    lev4.REGRESSION_COEFF_A1_BOOTSTRAP(tt,zz,bb,:) = Rinfo.bootstrap_coeff(:,2);
                end
                lev4.REGRESSION_N(tt,zz,bb) = Rinfo.npts;
                lev4.REGRESSION_R2(tt,zz,bb) = Rinfo.R2;
                lev4.EPSI_CI_LOW_BOOTSTRAP(tt,zz,bb) = Rinfo.CI_epsi_bootstrap(1); 
                lev4.EPSI_CI_HIGH_BOOTSTRAP(tt,zz,bb) = Rinfo.CI_epsi_bootstrap(2); 
                lev4.EPSI_DEL_RATIO_BOOTSTRAP(tt,zz,bb) = Rinfo.d_epsi_bootstrap/epsi; % MY METRIC
                lev4.EPSI_CI_LOW_REGRESSION(tt,zz,bb) = Rinfo.CI_epsi_regression(1); % TODO: Remove if we settle on using bootstrap
                lev4.EPSI_CI_HIGH_REGRESSION(tt,zz,bb) = Rinfo.CI_epsi_regression(2); % TODO: Remove if we settle on using bootstrap
                lev4.EPSI_DEL_RATIO_REGRESSION(tt,zz,bb) = Rinfo.d_epsi_regression/epsi; % MY METRIC % TODO: Remove if we settle on using bootstrap
                lev4.MSPE(tt,zz,bb) = Rinfo.MSPE;
                lev4.MAD(tt,zz,bb) = Rinfo.MAD;
                REGRESSION_R_DEL{tt,zz,bb} = rDelFit;
                REGRESSION_DLL{tt,zz,bb} = dllFit;
            end
            
            count = count+1;
            disp_percdone(count,NT*NB*NZ,1)
        end
    end
end

%% Assign confidence intervals and errors to be bootstrap unless not implemented
if options.Nbootstrap>0
    lev4.EPSI_DEL_RATIO = lev4.EPSI_DEL_RATIO_BOOTSTRAP;
    lev4.EPSI_CI_LOW = lev4.EPSI_CI_LOW_BOOTSTRAP;
    lev4.EPSI_CI_HIGH = lev4.EPSI_CI_HIGH_BOOTSTRAP;
else
    lev4.EPSI_DEL_RATIO = lev4.EPSI_DEL_RATIO_REGRESSION;
    lev4.EPSI_CI_LOW = lev4.EPSI_CI_LOW_REGRESSION;
    lev4.EPSI_CI_HIGH = lev4.EPSI_CI_HIGH_REGRESSION;
end


%% Convert cells to matrices
len = cellfun(@length,REGRESSION_DLL);
NR = max(len(:));

[NT,NZ,NB] = size(lev4.EPSI);
lev4.REGRESSION_DLL = NaN*ones(NT,NZ,NB,NR);
lev4.REGRESSION_R_DEL = NaN*ones(NT,NZ,NB,NR);

for tt = 1:NT
    for zz = 1:NZ
        for bb=1:NB
            nr = length(REGRESSION_DLL{tt,zz,bb});
            lev4.REGRESSION_DLL(tt,zz,bb,1:nr) = REGRESSION_DLL{tt,zz,bb};
            lev4.REGRESSION_R_DEL(tt,zz,bb,1:nr) = REGRESSION_R_DEL{tt,zz,bb};
        end
    end
end

%% Apply flags
disp('* Applying Flags *')
lev4 = apply_ATOMIX_flags(lev4,'L4','EPSI_FLAGS',options.flagFile,struct('dispOutput',1));

%% Calculate final spsilon
epsitmp = lev4.EPSI;
epsitmp(lev4.EPSI_FLAGS>0) = NaN;

lev4.EPSI_FINAL = squeeze(nanmean(epsitmp,3));

%%
%% Plots to check (Level 4 diagnostics)
if options.figureCheck
    indB = 1;
    figure(40),clf
    ax(1) = subplot(511);
    pcolor(lev4.TIME,lev4.Z_DIST,log10(squeeze(lev4.EPSI(:,:,indB)))')
    shading flat
    colorbar
    title('\epsilon')
    
    ax(2) = subplot(512);
    pcolor(lev4.TIME,lev4.Z_DIST,squeeze(lev4.REGRESSION_N(:,:,indB))')
    shading flat
    colorbar
    title('REGRESSION\_N')
    
    ax(3) = subplot(513);
    pcolor(lev4.TIME,lev4.Z_DIST,squeeze(lev4.REGRESSION_R2(:,:,indB))')
    shading flat
    colorbar
    title('REGRESSION\_R2')
    
    ax(4) = subplot(514);
    pcolor(lev4.TIME,lev4.Z_DIST,squeeze(lev4.EPSI_DEL_RATIO(:,:,indB))')
    shading flat
    colorbar
    caxis([0 1])
    title('\Delta\epsilon/\epsilon')
    
    ax(5) = subplot(515);
    pcolor(lev4.TIME,lev4.Z_DIST,squeeze(lev4.EPSI_FLAGS(:,:,indB))')
    shading flat
    colorbar
    title('FLAGS')
    
    % Same as above, but for one bin
    indZ = 8;
    figure(41),clf
    ax(1) = subplot(611);
    plot(get_yd(lev4.TIME),log10(lev4.EPSI(:,indZ,indB)'))
    hold all
    plot(get_yd(lev4.TIME),log10(lev4.EPSI_CI_LOW(:,indZ,indB)'),'--')
    plot(get_yd(lev4.TIME),log10(lev4.EPSI_CI_HIGH(:,indZ,indB)'),'--')
    title('\epsilon')
    
    ax(2) = subplot(612);
    plot(get_yd(lev4.TIME),squeeze(lev4.REGRESSION_N(:,indZ,indB)'))
    hold all
    flagInfo = get_flag_info(options.flagFile,'L4','EPSI_FLAGS','regression_poorly_conditioned',struct());
    plot(get(gca,'xlim'),[1 1]*flagInfo.flag_thresholds,'--')
    title('REGRESSION\_N')
    
    ax(3) = subplot(613);
    plot(get_yd(lev4.TIME),squeeze(lev4.REGRESSION_COEFF_A0(:,indZ,indB)'))
    hold all
    flagInfo = get_flag_info(options.flagFile,'L4','EPSI_FLAGS','dll_intercept_too_low',struct());
    plot(get(gca,'xlim'),[1 1]*flagInfo.flag_thresholds,'--')
    flagInfo = get_flag_info(options.flagFile,'L4','EPSI_FLAGS','dll_intercept_too_high',struct());
    plot(get(gca,'xlim'),[1 1]*flagInfo.flag_thresholds,'--')
    title('REGRESSION\_A0')
    
    ax(4) = subplot(614);
    plot(get_yd(lev4.TIME),squeeze(lev4.REGRESSION_R2(:,indZ,indB)'))
    hold all
    flagInfo = get_flag_info(options.flagFile,'L4','EPSI_FLAGS','Rsquared_too_low',struct());
    plot(get(gca,'xlim'),[1 1]*flagInfo.flag_thresholds,'--')
    title('REGRESSION\_R2')
    
    ax(5) = subplot(615);
    plot(get_yd(lev4.TIME),squeeze(lev4.EPSI_DEL_RATIO(:,indZ,indB))')
    hold all
    flagInfo = get_flag_info(options.flagFile,'L4','EPSI_FLAGS','delta_epsi_too_large',struct());
    plot(get(gca,'xlim'),[1 1]*flagInfo.flag_thresholds,'--')
    ylim([0 5])
    title('\Delta\epsilon/\epsilon')
    
    ax(6) = subplot(616);
    plot(get_yd(lev4.TIME),squeeze(lev4.EPSI_FLAGS(:,indZ,indB))')
    title('FLAGS')
    
    grid on
    linkaxes(ax,'x')
end
