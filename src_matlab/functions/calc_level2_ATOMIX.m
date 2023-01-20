function lev2 = calc_level2_ATOMIX(lev1,indBeg,indEnd,options)
%CALC_LEVEL2_ATOMIX Calculate level 2 structure from level 1 data when 
% processing ADCP data for ATOMIX testing.
%
% Syntax:
%  lev2 = CALC_LEVEL2_ATOMIX(lev1,indBeg,indEnd,options)
%
% Inputs:
%  - lev1: Structure with all level 1 variables
%  - indBeg: Vector of indices to start of ensemble
%  - indEnd: Vector of indices to end of ensemble
%  - options: Structure with any required options
%      * detrendMethod: method to detrend data ('Regress1D')
%
% Outputs:
%  - lev2: Structure with all level 2 variables
%
% Justine McMillan
% Apr 8, 2022

% Check inputs
if ~isfield(options,'figureCheck'); options.figureCheck = 1; end
if strcmp(options.detrendMethod, 'linear least squares regression') % What is in metadata file
    options.detrendMethod = 'Regress1D'; % Method expected by detrending function
end

% Sizes
NS = max(indEnd-indBeg)+1; % Number of points in an ensemble
NT = length(indEnd);
NZ = length(lev1.Z_DIST);
NB = length(lev1.N_BEAM);

% Dimensions
lev2.N_SEGMENT = [1:NT]';
lev2.N_SAMPLE = [1:NS]';
lev2.Z_DIST = lev1.Z_DIST; 
lev2.N_BEAM = lev1.N_BEAM;

% Initialize
lev2.TIME = NaN*ones(NT,NS);
lev2.R_VEL = NaN*ones(NT,NZ,NB,NS);
lev2.R_VEL_DETRENDED = NaN*ones(NT,NZ,NB,NS);
lev2.PROFILE_NUMBER = NaN*ones(NT,NS); % Optional variable for data point number to make it easy to go back to level 1 data

% Segment
disp('* SEGMENTING *')
for nn = 1:NT
    nPtsSegment = indEnd(nn) - indBeg(nn) + 1;
    
    %lev2.BURST_NUMBER(nn,:) = nn; % Not required TODO: Remove if unused
    lev2.TIME(nn,1:nPtsSegment) = lev1.TIME(indBeg(nn):indEnd(nn));
    lev2.PROFILE_NUMBER(nn,1:nPtsSegment) = indBeg(nn):indEnd(nn);

    % QC and detrend
    for bb = 1:NB
        % Get data
        velB = squeeze(lev1.R_VEL(indBeg(nn):indEnd(nn),:,bb));
        velBFlags = double(squeeze(lev1.R_VEL_FLAGS(indBeg(nn):indEnd(nn),:,bb)));
        
        % Check that dimensions
        if sum(size(velB)~=[nPtsSegment,NZ]) > 0 
            velB = velB';
            velBFlags = velBFlags';
            disp('Transposing so columns are Z dimension')
        end
        
        % Create mask and apply QC
        velBFlags(velBFlags>0) = NaN;
        velBFlags = velBFlags+1;
        velBqc = velB.*velBFlags;

        % Detrend (Transpose to detrend time series for each depth)
         velBdt = detrend_with_NaNs(velBqc,lev2.TIME(nn,1:nPtsSegment),struct('method',options.detrendMethod));
%         velBdt = detrend_with_NaNs(velBqc,[],struct('method',detrendMethod,'showOutput',0));
        
        % Assign
        lev2.R_VEL(nn,:,bb,1:nPtsSegment) = velBqc';
        lev2.R_VEL_DETRENDED(nn,:,bb,1:nPtsSegment) = velBdt';
    end

    disp_percdone(nn,NT,10)
end

%% Other Variables
lev2.THETA = lev1.THETA;
lev2.BIN_SIZE = lev1.BIN_SIZE;

%% Order fields
lev2 = orderfields_dim_first(lev2,{'N_SEGMENT','Z_DIST','N_BEAM','N_SAMPLE'});

%% Plot to check
if options.figureCheck
    figure(20),clf
    bb = 1;
    np = NT;
    for nn = 1:np
        subplot(1,np,nn)
    %     plot(24*(lev2.TIME(nn,:)-lev1.TIME(1)),squeeze(lev2.R_VEL(nn,20,:,1)))
        pcolor(24*(lev2.TIME(nn,:)-lev1.TIME(1)),lev2.Z_DIST,squeeze(lev2.R_VEL_DETRENDED(nn,:,bb,:))); shading flat
       % caxis([-1 1])
        ylim([0 30])
        set(gca,'yticklabel',[]);
    end
end

