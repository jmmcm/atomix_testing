%% plots_spectra.m
%
% A script to plot the along beam velocity spectra and the noise level
%
% Nov 24, 2022

clear
mname=mfilename('fullpath');
flg.saveFigs = 1;

%% Dataset and processID (for Ancillary data and spectra parameters)
% dataSet = 'RDI4beam_TidalChannel_GP130620BPb'; processID = 'JMM_M2uC_RM5';
% dataSet = 'RDIWH600_CANDYFLOSS_bedframe'; processID = 'JMM_M2uC_RM7p5';
dataSet = 'RDIWH600_CANDYFLOSS_TOP'; processID = 'JMM_M2uC_RM1p5';
% dataSet = 'Signature5beam_TidalShelf'; processID = 'JMM_M2uC_RM2'; 


%% Load data
[dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet);

matFile =  [dataDir,dataFileRoot,'_',processID,'.mat'];
load(matFile);
try
    Anc = data.Ancillary;
end

specFile = [dataDir,dataFileRoot,'_spectra','.mat'];
dataSpec = load(specFile);

%% Figures
figDir = 'Spectra';
figPath=['../figures/',dataSet,'/',figDir,'/'];

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
nZavg = plotOptions.plotSpectra.nZavg; %TODO: Not implemented yet
noiseLevel = plotOptions.plotSpectra.noiseLevel; % TODO: Calculate this from slow spectra
Afit = plotOptions.plotSpectra.Afit;
ylimF = plotOptions.plotSpectra.ylimF;
ylimK = plotOptions.plotSpectra.ylimK;
rMax = metadataGroups.L3.rMax;

%% Useful variables
[NT,NZ,NB,NF] = size(dataSpec.Sxx);

%% Average Spectra

for zz = 1:length(indZall)
    
    indZ = indZall(zz);
    indZavg = indZ+[-(nZavg-1)/2:(nZavg-1)/2];
    
    % Get speed to use for reference
    if strcmp(spdVar,'SIGNED_SPEED') % TODO: Avg over z range
        speed = nanmean(Anc.(spdVar)(:,indZavg),2);
    elseif strcmp(spdVar,'ENU_HOR')
        speed = nanmean(sqrt(Anc.ENU(:,indZavg,1).^2 + Anc.ENU(:,indZavg,2).^2),2);
    elseif strcmp(spdVar,'EVEL_HOR')
        speed = nanmean(sqrt(Anc.EVEL_E(:,indZavg).^2 + Anc.EVEL_N(:,indZavg).^2),2);
    end
    
    % Average spectra into speed bins (TODO: Rethink this... Should only do for
    % z region that I am averaging over since speed is depth dependent)
    NS = length(spdBins)-1;
    
    SffAvgS = NaN*ones(length(indZavg),NB,NF,NS);
    SkkAvgS = NaN*ones(length(indZavg),NB,NF,NS);
    
    midS = NaN*ones(1,NS);
    for ss = 1:NS
        minS = spdBins(ss);
        maxS = spdBins(ss+1);
        midS(ss) = mean([minS,maxS]);
        
        indS = find(speed>minS & speed<=maxS);
        nS(ss) = length(indS);
        SffAvgS(:,:,:,ss) = squeeze(nanmean(dataSpec.Sxx(indS,indZavg,:,:),1));
        SkkAvgS(:,:,:,ss) = abs(midS(ss))*(SffAvgS(:,:,:,ss)-noiseLevel); % Only really works for the depth I've chosen for indZ TODO: Make more robust
    end
    kMin = dataSpec.freq(2)/abs(max(midS));
    kMax = dataSpec.freq(end)/abs(min(midS));
    
    % Average spectra for z region
    SffAvgSZ = squeeze(nanmean(SffAvgS));
    SkkAvgSZ = squeeze(nanmean(SkkAvgS));
    
    %% Plot
    figure_named(['Spectra_z',num2str(indZ)]),clf
    set(gcf,'Position',[0 -300 1400 1000])
    % Histogram
    ax(1) = subplot(3,NB,[1:NB]);
    plot_histogram(ax(1),struct('values',speed,'var',spdVar),struct('nbins',20,'normalization','probability','xlabelStr','speed [m/s]'))
    yLim = get(ax(1),'ylim');
    for ss = 1:NS
        ps(ss) = plot(ax(1),spdBins(ss:ss+1),0.9*yLim(2)*[1 1],'linewidth',2);
    end
    xlim([spdBins(1) spdBins(end)])
    title(['Average for indZ = [',num2str(indZavg),']'])
    
    % Freq spectra
    for bb = 1:NB
        axF(bb)=subplot(3,NB,bb+NB);
        for ss = 1:NS
            loglog(dataSpec.freq, squeeze(SffAvgSZ(bb,:,ss)),'DisplayName',num2str(midS(ss)),'Color',get(ps(ss),'Color'))
            if ss == 1; hold all; end
        end
        fLim = [0.1 0.8];
        loglog(fLim,1e-3*fLim.^(-5/3),'k','DisplayName','f^{-5/3}')
        loglog(get(gca,'xlim'),noiseLevel*[1 1],'color',[0.6 0.6 0.6], 'DisplayName','Noise')
        ylim(ylimF)
        xlabel('f [Hz]')
        ylabel('Sff [m^2 s^{-2} Hz^{-1}]')
        title(['Beam ',num2str(bb)])
    end
    legend('location','southwest')
    linkaxes(axF,'y')
    
    % Wavenumber spectra
    for bb = 1:NB
        axK(bb)=subplot(3,NB,bb+2*NB);
        for ss = 1:NS
            loglog(dataSpec.freq/abs(midS(ss)), squeeze(SkkAvgSZ(bb,:,ss)),'DisplayName',num2str(midS(ss)),'Color',get(ps(ss),'Color'))
            if ss == 1; hold all; end
        end
        kLim = [kMin kMax];
        loglog(kLim,Afit*kLim.^(-5/3),'k','linewidth',2,'DisplayName','k^{-5/3}')
        plot(1/rMax*[1 1],[1e-4 1e0],'--k','DisplayName',['rMax = ',num2str(rMax),' m'])
        ylim(ylimK)
        xlim([kMin kMax])
        xlabel('k [cpm]')
        ylabel('Skk [m^2 s^{-2} cpm^{-1}]')
        
        grid on
    end
    legend('location','southwest')
    linkaxes(axK,'xy')
    
    add_fig_info(mname,[dataSet],struct())
    if flg.saveFigs
        figName = [figPath,'Spectra_z',num2str(indZ),'.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
    
end

