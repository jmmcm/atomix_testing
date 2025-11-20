clear
addpath('../functions')
addpath('../../../adcp_toolbox/matlab/')
addpath('../../../utilitieswork')
addpath('../../../netcdftools_ceb/variables_flags_databases/YAMLMatlab_0/')
set(0,'defaultfigurecolor',[1 1 1 ])
set(0,'defaultAxesXGrid','on')
set(0,'defaultAxesYGrid','on')

colors = get(0,'defaultaxescolororder');
%%
figDir = '/home/jmm000/work/ATOMIX/figures/paper/';
figSave = 1;

%%
dd = 1;
plotOptions(dd).dataSet = 'AQD_Windermere_bedframe';
plotOptions(dd).dataSetSN = 'Lake Windermere';
plotOptions(dd).processID = 'JMM_M2uC_RM2';
plotOptions(dd).spdBin = [0.005 0.02];
plotOptions(dd).indZ = [10:15];
plotOptions(dd).spdVar = 'SPD';
plotOptions(dd).A = 0.000001;
plotOptions(dd).ylimitsF = [1e-6 1e-4];



dd = 2;
plotOptions(dd).dataSet = 'AQD_NorthSea_bedframe';
plotOptions(dd).dataSetSN = 'North Sea';
plotOptions(dd).processID = 'JMM_M2uC_RM0p3';
plotOptions(dd).spdBin = [0.1 0.2];
plotOptions(dd).indZ = [10:15];
plotOptions(dd).spdVar = 'SPD';
plotOptions(dd).A = 0.00001;
plotOptions(dd).ylimitsF = [2e-6 2e-4];



dd = 3;
plotOptions(dd).dataSet = 'RDIWH600_CANDYFLOSS_bedframe';
plotOptions(dd).dataSetSN = 'Celtic Sea Bedframe';
plotOptions(dd).processID = 'JMM_M2uC_RM7p5';
plotOptions(dd).spdBin = [0.15 0.3];
plotOptions(dd).indZ = [20:25];
plotOptions(dd).spdVar = 'ENU';
plotOptions(dd).A = 0.0001;
plotOptions(dd).ylimitsF = [1e-3 1e-1];




dd = 4;
plotOptions(dd).dataSet = 'RDIWH600_CANDYFLOSS_TOP';
plotOptions(dd).dataSetSN = 'Celtic Sea Mooring';
plotOptions(dd).processID = 'JMM_M2uC_RM0p75';
plotOptions(dd).spdBin = [0.3 0.4];
plotOptions(dd).indZ = [20:25];
plotOptions(dd).spdVar = 'ENU';
plotOptions(dd).A = 0.0001;
plotOptions(dd).ylimitsF = [4e-4 4e-1];




dd = 5;
plotOptions(dd).dataSet = 'NortekSig1000_TidalChannel_2019_Burst';
plotOptions(dd).dataSetSN = 'Menai Strait';
plotOptions(dd).processID = 'JMM_M2uC_RM5';
plotOptions(dd).spdBin = [0.3 0.5];
plotOptions(dd).indZ = [10:15];
plotOptions(dd).spdVar = 'SPD';
plotOptions(dd).A = 0.0002;
plotOptions(dd).ylimitsF = [4e-4 4e-1];




dd = 6;
plotOptions(dd).dataSet = 'RDI4beam_TidalChannel_GP130620BPb';
plotOptions(dd).dataSetSN = 'Grand Passage';
plotOptions(dd).processID = 'JMM_M2uC_RM5';
plotOptions(dd).spdBin = [1.5 2];
plotOptions(dd).indZ = [20:25];
plotOptions(dd).spdVar = 'SIGNED_SPD';
plotOptions(dd).A = 0.001;
plotOptions(dd).ylimitsF = [4e-4 4e-1];




%% Load data
% plotOptions = plotOptions(1:2); % TODO: Remove
for ff = 1:length(plotOptions)
    [dataFileRoot,dataDir,metaDir] = get_data_paths(plotOptions(ff).dataSet);

    matFile =  [dataDir,dataFileRoot,'_',plotOptions(ff).processID,'.mat'];
    d(ff) = load(matFile);

    specFile = [dataDir,dataFileRoot,'_spectra','.mat'];
    dataSpec(ff) = load(specFile);
end

%% Average Spectra

for ff = 1:length(plotOptions)   
    
   [NT,NZ,NB,NF] = size(dataSpec(ff).Sxx);
    
   % Depth average speed
   switch plotOptions(ff).spdVar 
       case 'SPD'
            speed = nanmean(d(ff).data.Ancillary.SPD(:,plotOptions(ff).indZ),2);
       case 'ENU'
           speed = nanmean(sqrt(d(ff).data.Ancillary.ENU(:,plotOptions(ff).indZ,1).^2 +...
                                d(ff).data.Ancillary.ENU(:,plotOptions(ff).indZ,2).^2),2);
       case 'SIGNED_SPD'
           speed = nanmean(d(ff).data.Ancillary.SIGNED_SPEED(:,plotOptions(ff).indZ),2);
   end
   
   % Median frequency and wavenumber spectra
   SffAvgS = NaN*ones(length(plotOptions(ff).indZ),NB,NF);
   SkkAvgS = NaN*ones(length(plotOptions(ff).indZ),NB,NF);
    
   minS = plotOptions(ff).spdBin(1);
   maxS = plotOptions(ff).spdBin(2);
   midS = mean([minS,maxS]);
       
   indS = find(speed>minS & speed<=maxS);
   nS = length(indS);
   SffAvgS(:,:,:) = squeeze(nanmedian(dataSpec(ff).Sxx(indS,plotOptions(ff).indZ,:,:),1));
       

   
   % Average spectra for z region
   SffAvgSZ = squeeze(nanmean(SffAvgS));
   
   % Save to structure
   dataSpec(ff).SffAvgSZ = SffAvgSZ;
   
   
end

%% Plot
figure(25),clf
flim = [5e-2 1e0];
for ii = 1:length(plotOptions)
    subplot(2,3,ii)
    p = loglog(dataSpec(ii).freq,dataSpec(ii).SffAvgSZ);
    for ll = 1:length(p)
        p(ll).DisplayName = ['Beam ' num2str(ll)];
    end
    hold all
    ylimits = get(gca,'ylim');
    plot(flim,plotOptions(ii).A*flim.^(-5/3),'k')
    ylim(ylimits)
    legend('location','northeast')
    spdBins = plotOptions(ii).spdBin;
    z = d(ii).data.L1.Z_DIST([plotOptions(ii).indZ(1) plotOptions(ii).indZ(end)]);
    title({plotOptions(ii).dataSetSN,...
        [num2str(spdBins(1)) ' < U [m/s] < ' num2str(spdBins(2)) ],...
        [ num2str(z(1)) ' < z [m] < ' num2str(z(2))]},'fontsize',10)
    xlim([1e-2 10])
    ylim(plotOptions(ii).ylimitsF)
    xlabel('f [Hz]')
    ylabel('S [m^2 s^{-2} Hz^{-1}]')
end

return
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