function lev4 = calc_level4_ATOMIX(lev3,options)
%CALC_LEVEL4_ATOMIX Calculate level 4 structure from level 3 data when 
% processing ADCP data for ATOMIX testing.
%
% Syntax:
%  lev4 = CALC_LEVEL4_ATOMIX(lev2,indBeg,indEnd,options)
%
% Inputs:
%  - lev2: Structure with all level 2 variables
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

if ~isfield(options,'figureCheck'); options.figureCheck = 1; end


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
lev4.R_MAX = NaN*ones(NT,NZ,NB);
lev4.REGRESSION_COEFF_A0 = NaN*ones(NT,NZ,NB);
lev4.REGRESSION_COEFF_A1 = NaN*ones(NT,NZ,NB);
lev4.REGRESSION_R2 = NaN*ones(NT,NZ,NB);
lev4.REGRESSION_N = NaN*ones(NT,NZ,NB);


%% Calculate epsilon
disp('* Computing epsilon *')
count = 0;
for bb = 1:NB
   
    for zz = 1:NZ
       
        % Loop through ensembles and calculate DLL and epsilon
        for tt = 1:NT
            % Get simple variables
            r_del = squeeze(lev3.R_DEL(bb,:));
            dll = squeeze(lev3.DLL(tt,zz,bb,:));
            dll_flags = squeeze(lev3.DLL_FLAGS(tt,zz,bb,:));
            
            % Create mask and apply QC
            dll_flags(dll_flags>0) = NaN;
            dll_flags = dll_flags+1;
            dllQC = dll.*dll_flags;
                        
            % Linear regression to get epsilon
            %if zz == 17; options.figure = 1; end %DEBUGGING
            [epsi,sigmaN,R2,Rinfo] = calc_eps_SF(r_del,dllQC',options);
            
            % Assign to structures
            lev4.EPSI(tt,zz,bb) = epsi; 
            lev4.R_MAX(tt,zz,bb) = max(r_del);
            lev4.REGRESSION_COEFF_A0(tt,zz,bb) = Rinfo.yint;
            lev4.REGRESSION_COEFF_A1(tt,zz,bb) = Rinfo.slope;
            lev4.REGRESSION_N(tt,zz,bb) = Rinfo.npts;
            lev4.REGRESSION_R2(tt,zz,bb) = R2;
            lev4.EPSI_CI_LOW(tt,zz,bb) = real((Rinfo.CI_slope(1)/options.Const)^(3/2)); % TODO: IS THIS THE CORRECT WAY TO PROPAGATE THIS?
            lev4.EPSI_CI_HIGH(tt,zz,bb) = real((Rinfo.CI_slope(2)/options.Const)^(3/2)); % TODO: IS THIS THE CORRECT WAY TO PROPAGATE THIS?
            lev4.EPSI_DEL_RATIO(tt,zz,bb) = Rinfo.d_eps/epsi; % MY METRIC
            
            count = count+1;
            disp_percdone(count,NZ*NT*NB,5)
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
