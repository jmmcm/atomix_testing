%% plots_spectra.m
%
% A script to plot the along beam velocity spectra and the noise level
%
% Nov 24, 2022

clear
mname=mfilename('fullpath');
addpath(genpath('../../netcdftools_ceb/'))
addpath(genpath('../../utilitieswork/'))
addpath('functions')
colors = get(0,'DefaultAxesColorOrder');
flg.saveFigs = 1;

%% Dataset and processID (for Ancillary data and spectra parameters)
dataSet = 'RDI4beam_TidalChannel_GP130620BPb'; processID = 'JMM_M2uC_RM5';
% dataSet = 'RDIWH600_CANDYFLOSS_bedframe'; processID = 'JMM_M2uC_RM7p5';
% dataSet = 'RDIWH600_CANDYFLOSS_TOP'; processID = 'JMM_M2uC_RM1p5';
% dataSet = 'Signature5beam_TidalShelf'; processID = 'JMM_M2uC_RM2'; 
% dataSet = 'NortekSig1000_TidalChannel_2019_Burst'; processID = 'JMM_M2uC_RM5';
% dataSet = 'AQD_Windermere_bedframe'; processID = 'JMM_M2uC_RM2';
% dataSet = 'AQD_NorthSea_bedframe'; processID = 'JMM_M2uC_RM0p3';

%% Load data
[dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet);

matFile =  [dataDir,dataFileRoot,'_',processID,'.mat'];
load(matFile);
try
    Anc = data.Ancillary;
end
if ~isfield(Anc,'SPD') || ~isfield(Anc,'SIGNED_SPEED')
    Anc.SPD = sqrt(Anc.ENU(:,:,1).^2 + Anc.ENU(:,:,2).^2);
end

specFile = [dataDir,dataFileRoot,'_spectra','.mat'];
dataSpec = load(specFile);

%% Figures
figDir = 'Spectra';
% figPath=['../figures/',dataSet,'/',figDir,'/'];
figPath=['/home/jmm000/work/ATOMIX/figures/',dataSet,'/',figDir,'/'];

if ~exist(figPath,'dir') & flg.saveFigs
    disp(['Making ',figPath,'. Press a key to continue.']),pause
    mkdir(figPath)
end


%% Load plotting options
filePlotOptions = [metaDir,dataSet,'_plotOptions.yml'];
plotOptions = ReadYaml(filePlotOptions);

spdVar = plotOptions.plotSpectra.spdVar;
spdBins = plotOptions.plotSpectra.spdBins;
indZall = plotOptions.plotSpectra.indZall;
freqNoise = plotOptions.plotSpectra.freqNoise;
nZavg = plotOptions.plotSpectra.nZavg; %TODO: Not implemented yet
noiseLevel = plotOptions.plotSpectra.noiseLevel; % TODO: Calculate this from slow spectra
Afit = plotOptions.plotSpectra.Afit;
ylimF = plotOptions.plotSpectra.ylimF;
ylimK = plotOptions.plotSpectra.ylimK;
rMax = metadataGroups.L4.rMax;

%% Useful variables
[NT,NZ,NB,NF] = size(dataSpec.Sxx);
indFreqNoise = find(dataSpec.freq>=freqNoise(1) & dataSpec.freq<=freqNoise(2));
%% Plot speed and z levels
figure_named('Speed'),clf
try
    pcolor(1:NT,Anc.Z_DIST,Anc.SIGNED_SPEED'); shading flat; colorbar; 
    colormap(cmocean('balance'))
catch
    pcolor(1:NT,Anc.Z_DIST,Anc.SPD'); shading flat; colorbar;
    colormap(cmocean('speed'))
end

hold all
for zz = 1:length(indZall)
    plot(get(gca,'xlim'),Anc.Z_DIST(indZall(zz))*[1 1],'color',colors(zz,:))
    zTop = Anc.Z_DIST(indZall(zz)+(nZavg-1)/2);
    zBot = Anc.Z_DIST(indZall(zz)-(nZavg-1)/2);
    plot(get(gca,'xlim'),zTop*[1 1],'--','color',colors(zz,:))
    plot(get(gca,'xlim'),zBot*[1 1],'--','color',colors(zz,:))
end
xlabel('ind_T')
ylabel('z [m]')

%% Average Spectra
NS = length(spdBins)-1;
noiselevelCalc = zeros(length(indZall),NB,NS);

for zz = 1:length(indZall)
    
    indZ = indZall(zz);
    indZavg = indZ+[-(nZavg-1)/2:(nZavg-1)/2];
    
    % Get speed to use for reference
    if strcmp(spdVar,'SIGNED_SPEED') % TODO: Avg over z range
        speed = nanmean(Anc.(spdVar)(:,indZavg),2);
    elseif strcmp(spdVar,'SPD') % TODO: Avg over z range
        speed = nanmean(Anc.(spdVar)(:,indZavg),2);
    elseif strcmp(spdVar,'ENU_HOR')
        speed = nanmean(sqrt(Anc.ENU(:,indZavg,1).^2 + Anc.ENU(:,indZavg,2).^2),2);
    elseif strcmp(spdVar,'EVEL_HOR')
        speed = nanmean(sqrt(Anc.EVEL_E(:,indZavg).^2 + Anc.EVEL_N(:,indZavg).^2),2);
    end
    
    % Average spectra into speed bins (TODO: Rethink this... Should only do for
    % z region that I am averaging over since speed is depth dependent)
    
    SffAvgS = NaN*ones(length(indZavg),NB,NF,NS);
    SkkAvgS = NaN*ones(length(indZavg),NB,NF,NS);
    
    midS = NaN*ones(1,NS);
    for ss = 1:NS
        minS = spdBins(ss);
        maxS = spdBins(ss+1);
        midS(ss) = mean([minS,maxS]);
        
        indS = find(speed>minS & speed<=maxS);
        nS(ss) = length(indS);
        SffAvgS(:,:,:,ss) = squeeze(nanmedian(dataSpec.Sxx(indS,indZavg,:,:),1));
        
%         noiselevelCalc(:,ss) = squeeze(nanmedian(SffAvgS(:,:,indFreqNoise,ss),3));
%         SkkAvgS(:,:,:,ss) = abs(midS(ss))*(SffAvgS(:,:,:,ss)-noiseLevelCalc(:,ss)); 
    
    end
    
    % Average spectra for z region
    SffAvgSZ = squeeze(nanmean(SffAvgS));
    
    % Wave number
    kMin = dataSpec.freq(2)/abs(max(midS));
    kMax = dataSpec.freq(end)/abs(min(midS));
    for ss = 1:NS
        noiselevelCalc(zz,:,ss) = squeeze(nanmedian(SffAvgSZ(:,indFreqNoise,ss),2));
        for ii = 1:length(indZavg)
            SkkAvgS(ii,:,:,ss) = abs(midS(ss))*(squeeze(SffAvgS(ii,:,:,ss))-squeeze(noiselevelCalc(zz,:,ss))'*ones(1,NF)); 
        end
    end
    SkkAvgSZ = squeeze(nanmean(SkkAvgS));
    
    if 1 %debugging (beam 1)
        figure_named(['SpectraRaw_beam1_z' num2str(indZ)]),clf
        bb = 1;
        for ss = 1:NS
            subplot(1,NS,ss)
            minS = spdBins(ss);
            maxS = spdBins(ss+1);
        
            indS = find(speed>minS & speed<=maxS);
            if length(indS)>0
                for ii = 1:length(indZavg)
                    loglog(dataSpec.freq,squeeze(dataSpec.Sxx(indS,indZavg(ii),bb,:)),'color',0.6*[1 1 1])
                    if ii == 1; hold all; end
                    loglog(get(gca,'xlim'),noiselevelCalc(zz,bb,ss)*[1 1],'--k')
                end
            end
            for ii = 1:length(indZavg)
                pR(ii) = loglog(dataSpec.freq,squeeze(SffAvgS(ii,bb,:,ss)),'linewidth', 2,'DisplayName',['indZ = ',num2str(indZavg(ii))]);
            end
            pA = loglog(dataSpec.freq,SffAvgSZ(bb,:,ss),'k','linewidth',3,'DisplayName','Avg');
            title([num2str(midS(ss)),' m/s'])
            ylim(ylimF)
            xlim([min(dataSpec.freq) max(dataSpec.freq)])
            try
                legend([pR pA])
            end
        end
        
    end
    
    %% Plot
    figure_named(['Spectra_z',num2str(indZ)]),clf
    set(gcf,'Position',[0 -300 1400 1000])
    
    
    % Histogram
    ax(1) = subplot(3,NB,[NB-1:NB]);
    plot_histogram(ax(1),struct('values',speed,'var',spdVar),struct('nbins',10,'xlabelStr','speed [m/s]'))
    yLim = get(ax(1),'ylim');
    for ss = 1:NS
        ps(ss) = plot(ax(1),spdBins(ss:ss+1),0.9*yLim(2)*[1 1],'linewidth',2,'DisplayName',[num2str(midS(ss)) 'm/s (N=' num2str(nS(ss)) ')']);
    end
    xlim([spdBins(1) spdBins(end)])
    legend('location','eastoutside')
    
    % Timeseries
    ax0 = subplot(3,NB,[1:NB-2]);
    plot(speed,'.-','markersize',10)
    hold all
    for ss = 1:NS
        fill_transparent([1 NT],[spdBins(ss) spdBins(ss+1)],get(ps(ss),'Color'))
    end
    title(['Average for z = ' num2str(Anc.Z_DIST(indZ)) ' m (indZ = [',num2str(indZavg),'])'])

    
    % Freq spectra
    for bb = 1:NB
        axF(bb)=subplot(3,NB,bb+NB);
        for ss = 1:NS
            loglog(dataSpec.freq, squeeze(SffAvgSZ(bb,:,ss)),'DisplayName',num2str(midS(ss)),'Color',get(ps(ss),'Color'))
            if ss == 1; hold all; end
            loglog(get(gca,'xlim'),noiselevelCalc(zz,bb,ss)*[1 1],'--','color',get(ps(ss),'Color'), 'DisplayName','Noise')

        end
        fLim = [0.1 0.8];
        loglog(fLim,1e-3*fLim.^(-5/3),'k','DisplayName','f^{-5/3}')
        ylim(ylimF)
        xlabel('f [Hz]')
        ylabel('Sff [m^2 s^{-2} Hz^{-1}]')
        title(['Beam ',num2str(bb)])
    end
%     legend('location','southwest')
    linkaxes(axF,'y')
    
    % Wavenumber spectra
    for bb = 1:NB
        axK(bb)=subplot(3,NB,bb+2*NB);
        for ss = 1:NS
            loglog(dataSpec.freq/abs(midS(ss)), squeeze(SkkAvgSZ(bb,:,ss)),'DisplayName',[num2str(midS(ss)) 'm/s (N=' num2str(nS(ss)) ')'],'Color',get(ps(ss),'Color'))
            if ss == 1; hold all; end
        end
        kLim = [kMin kMax];
        loglog(kLim,Afit*kLim.^(-5/3),'k','linewidth',2,'DisplayName','k^{-5/3}')
        plot(1/rMax*[1 1],[1e-10 1e0],'--k','DisplayName',['rMax = ',num2str(rMax),' m'])
        ylim(ylimK)
        xlim([kMin kMax])
        xlabel('k [cpm]')
        ylabel('Skk [m^2 s^{-2} cpm^{-1}]')
        
        grid on
    end
%     legend('location','southwest')
    linkaxes(axK,'xy')
    
    add_fig_info(mname,[dataSet],struct())
    if flg.saveFigs
        figName = [figPath,'Spectra_z',num2str(indZ),'.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
    
end

%% Plot noise level
figure_named('NoiseLevel'),clf
subplot(1,NB+1,1)
for bb = 1:NB
        plot(nanmean(noiselevelCalc(:,bb,:),3),indZall,'.-','DisplayName',['beam = ',num2str(bb)])
        hold all
    
end
legend
title('Average')
for bb = 1:NB
    subplot(1,NB+1,1+bb)
    for ss = 1:NS
            plot(noiselevelCalc(:,bb,ss),indZall,'.-','DisplayName',[num2str(midS(ss)),' m/s'])
            hold all

    end
    legend
    title(['beam ' num2str(bb)])
end
add_fig_info(mname,[dataSet],struct())
if flg.saveFigs
    figName = [figPath,'NoiseLevels.png'];
    disp(['Saving: ',figName])
    saveas(gcf,figName);
end