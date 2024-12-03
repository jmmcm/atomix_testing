%% Script to plot level 1 data before processing. 
% Shows time sampling information and basic data quality.
% Also plots spectra, if available (need to run calc_spectra_beamvel.m first)
%
% Nov 11, 2022
%
% TODO: 
% - Add graph of expected dissipation rate and theoretical inertial subrange
% - Histogram of speed to help choose speed bins for spectra

clear all
close all
addpath('functions')

% dataSet = 'RDI4beam_TidalChannel_GP130620BPb'; processID='JMM_M1aC_RM5';
% dataSet = 'RDIWH600_CANDYFLOSS_bedframe'; processID = 'BDS_M1aC_RM7p5';
dataSet = 'RDIWH600_CANDYFLOSS_TOP'; processID = 'BDS_M1aC_RM1p5';
% dataSet = 'Signature5beam_TidalShelf'; processID = 'CEB00';
% dataSet = 'AQD_Windermere_bedframe'; processID = 'BDS_M1aA_RM2';
% dataSet = 'NortekSig1000_TidalChannel_2019_Burst'; processID = 'NSL';

climVel = 0.5;

%% Load data
[dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet);
matFile =  [dataDir,dataFileRoot,'_',processID,'.mat'];
saveFile = [dataDir,dataFileRoot,'_spectra.mat'];


load(matFile);
L1 = data.L1;
try 
    Anc = data.Ancillary;
catch 
    disp('No ancillary data')
end

%% Calculate sample rate and bursting interval (if appropriate)
tRelH = 24* (L1.TIME -L1.TIME(1));
tRelS = tRelH*3600;
tDiff = diff(tRelS);

minBurstS = 10;
if max(tDiff)>minBurstS % Assume bursting if delta t > minBurstS
    [indStart,indEnd,npts] = get_burst_inds(tRelS,max(tDiff)/2);
    indOn = find(tDiff<minBurstS);
    fs = 1/mean(tDiff(indOn));
    tOnS = mean(npts)/fs;
    indOff = find(tDiff>minBurstS);
    tOffS = mean(tDiff(indOff));
    
    disp('=== First 10 Bursts ===')
    for ii= 1:100
        disp(['Sampling: ',datestr(L1.TIME(indStart(ii))) ' to ' datestr(L1.TIME(indEnd(ii))),...
            ', deltaT = ',num2str((L1.TIME(indEnd(ii))-L1.TIME(indStart(ii)))*24*60,'%5.2f'),' min',...
            ', numPoints = ',num2str(npts(ii))])
        disp(['Off: ',num2str((L1.TIME(indStart(ii+1))-L1.TIME(indEnd(ii)))*24*60,'%5.3f'),' min'])
    end
    disp('======================')
    
    titleStr = ['Burst, ',...
        num2str(tOnS/60,'%5.3f'),' mins on, ',...
        num2str(tOffS/60,'%5.2f'),' mins off, ',...
        'fs = ',num2str(fs,'%5.2f'),' Hz'];
    
else
    fs = 1/mean(tDiff);
    indOn = 1:length(tDiff);
    indOff = [];
    
    titleStr = ['Continuous, fs = ',num2str(fs,'%5.2f'),' Hz'];
end
disp(['Sample Rate: ',num2str(fs), ' Hz'])


%% Plot time first several hours of time steps and differences
figure_named(['TimeSteps']),clf,clear ax, clear plotData
opts.xlimHrs = [0 12]; % 

ax(1) = subplot(2,1,1);
plot(tRelS,'.')
ylabel('relative time [s]')
title(titleStr)

ax(2) = subplot(2,1,2);
plot(diff(tRelS),'.')
ylabel('\Delta t [s]')

linkaxes(ax,'x')
ind = find(tRelH>=opts.xlimHrs(1) & tRelH<opts.xlimHrs(2));
xlim([ind(1) ind(end)])
xlabel('index')

%% Plot time differences for when instrument On vs Off
figure_named(['Time On vs Time Off']),clf,clear ax, clear plotData

ax(1) = subplot(2,2,1);
plot(tDiff(indOn),'.')
hold all
plot(get(gca,'xlim'),1/fs*[1 1],'r')
ylabel('time diff when on [s]')
xlabel('index')
title(['TS: On, mean = ',num2str(mean(tDiff(indOn))),' s'])

ax(2) = subplot(2,2,2);
histogram(tDiff(indOn),5,'Orientation','horizontal')
hold all
plot(get(gca,'xlim'),1/fs*[1 1],'r')
linkaxes(ax(1:2),'y')
xlabel('count')
title(['Hist: On, mean = ',num2str(mean(tDiff(indOn))),' s'])

ax(3) = subplot(2,2,3);
plot(tDiff(indOff),'.')
ylabel('time diff when off [s]')
xlabel('index')
title(['TS: Off, mean = ',num2str(mean(tDiff(indOff))),' s'])

ax(4) = subplot(2,2,4);
histogram(tDiff(indOff),5,'Orientation','horizontal')
hold all
plot(get(gca,'xlim'),mean(tDiff(indOff))*[1 1],'r')
linkaxes(ax(3:4),'y')

xlabel('count')
title(['TS: On, mean = ',num2str(mean(tDiff(indOff))),' s'])


%% Plot beam velocities (pcolor)
if 0
    figure_named(['BeamVel_TS']),clf,clear ax, clear plotData
    set(gcf,'Position',[200,100,700,600])
    axL = 0.10;
    axR = 0.87;
    axH = 0.14;
    axW = axR - axL;
    if length(data.L1.N_BEAM) == 4
        axB = [0.8:-.22:0];
    elseif length(data.L1.N_BEAM) == 5
        axB = [0.83:-.18:0];
    end
    t = get_yd(L1.TIME);
    for bb = 1:length(data.L1.N_BEAM)
        ax(bb) = axes('Position',[axL,axB(bb),axW,axH]);
        plotData = struct('x',t','y',L1.Z_DIST','values',L1.R_VEL(:,:,bb)','var','R_VEL');
        opts = struct('ylabel','z [m]','clabel',['R\_VEL(:,:,',num2str(bb),') [m/s]']);
        plot_pcolor(ax(bb),plotData,opts);
        colormap(ax(bb),cmocean('balance'))
    end
    title(ax(1),['Beam Velocities'])
    xlabel('year day')
end

%% Plot ENU velocities (pcolor)
if exist('Anc','var')
    figure_named(['ENUVel_TS']),clf,clear ax, clear plotData
    set(gcf,'Position',[200,100,700,600])
    axL = 0.10;
    axR = 0.87;
    axH = 0.14;
    axW = axR - axL;
    axB = [0.8:-.22:0];

    t = get_yd(Anc.TIME);
    for bb = 1:length(data.L1.N_BEAM)
        ax(bb) = axes('Position',[axL,axB(bb),axW,axH]);
        plotData = struct('x',t','y',Anc.Z_DIST','values',Anc.ENU(:,:,bb)','var','R_VEL');
        opts = struct('ylabel','z [m]','clabel',['ENU(:,:,',num2str(bb),') [m/s]']);
        plot_pcolor(ax(bb),plotData,opts);
        caxis([-1 1]*climVel)
        colormap(ax(bb),cmocean('balance'))
    end
    title(ax(1),['ENU Velocities'])
    xlabel('year day')
end

%% Plot ENU velocities (middepth, or 1/3 depth for Tidal Shelf)
if exist('Anc','var')
    if strcmp(dataSet,'Signature5beam_TidalShelf')
        indZ = floor(length(Anc.Z_DIST)/3);
    else
        indZ = floor(length(Anc.Z_DIST)/2);
    end
    figure_named(['ENU_middepth']),clf,clear ax, clear plotData
    for bb = 1:length(data.L1.N_BEAM)
        ax(bb) = subplot(4,1,bb);
        plot(get_yd(Anc.TIME),Anc.ENU(:,indZ,bb))
        switch bb
            case 1; ylabel('east vel [m/s]')
            case 2; ylabel('north vel [m/s]')
            case 3; ylabel('vert vel [m/s]')
            case 4; ylabel('error vel [m/s]')
        end
    end
    xlabel('year day')
    title(ax(1),['ENU velocities, indZ = ',num2str(indZ),' (',num2str(L1.Z_DIST(indZ)),' m)'])

end
%% Orientation
figure_named(['Orientation']),clf,clear ax, clear plotData
plotData.x = get_yd(L1.TIME);
if ~isfield(L1,'PRES')
   L1.PRES = NaN*zeros(size(L1.TIME));
end
plotData.y = [L1.PRES L1.HEADING L1.PITCH L1.ROLL;];
if isfield(L1,'HEADING5')
    plotData.y5 = [L1.PRES5 L1.HEADING5 L1.PITCH5 L1.ROLL5;];
end
plotData.yLabels = {'Pressure','Heading [deg]','Pitch [deg]','Roll [deg]'};
for ii = 1:4
    ax(ii) = subplot(4,1,ii);
    plot(plotData.x,plotData.y(:,ii),'linewidth',2)
    if isfield(plotData,'y5')
        hold all
        plot(plotData.x,plotData.y5(:,ii),'--','linewidth',2)
    end
    ylabel(plotData.yLabels{ii})
end
xlabel('year day')
title(ax(1),['Orientation'])

%% Histogram of speed with same averaging as spectra (NOT COMPLETED)
%     plot_histogram(gca,struct('values',speed,'var','speed'),struct())

%% plot amplitude and surface
figure_named(['Amplitude']),clf,clear ax, clear plotData
NB = length(data.L1.THETA);

for bb = 1:NB
    subplot(NB,1,bb)
    try
        pcolor(data.L1.TIME,data.L1.Z_DIST,data.L1.ABSIC(:,:,bb)')
    catch
       pcolor(data.L1.TIME,data.L1.Z_DIST,data.L1.ABSI(:,:,bb)') 
    end
    shading flat
    colorbar
    hold all
    plot(data.L1.TIME,data.L1.PRES,'w')
end