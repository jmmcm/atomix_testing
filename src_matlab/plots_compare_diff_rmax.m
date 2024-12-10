% Compare effect of using different rmax values

clear all

mname = mfilename('fullpath');

set(groot,'DefaultFigurePosition',[0 0 500 500])
set(0,'defaultfigurecolor',[1 1 1 ])
set(0,'defaultAxesXGrid','on')
set(0,'defaultAxesYGrid','on')


%% Select dataset and process IDs

dataSet = 'RDIWH600_CANDYFLOSS_TOP';
    processIDs = {'JMM_M1aC_RM0p75','JMM_M2uC_RM0p75',...
                  'JMM_M1aC_RM1p0','JMM_M2uC_RM1p0',...
                  'JMM_M1aC_RM1p5','JMM_M2uC_RM1p5'}; 


%% Figure Options
flg.saveFigs = 1;
figDir = 'CompareRmax'
figPath = ['/home/jmm000/work/ATOMIX/figures/',dataSet,'/',figDir,'/'];

%% Load data
[dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet);

for ii = 1:length(processIDs)
    processID = processIDs{ii};
    matFile = [dataDir,dataFileRoot,'_',processID,'.mat'];
    d(ii) = load(matFile);
    data(ii) = d(ii).data;
    flags(ii) = d(ii).flags;
    switch d(ii).infoProcessing.method
        case 'M1aC'; sn = 'Cen';
        case 'M2uC'; sn = 'All';
    end
    names{ii} = [ sn '_rmax_' num2str(d(ii).metadataGroups.L4.rMax)];
end

%% plot options
filePlotOptions = [metaDir,dataSet,'_plotOptions.yml'];
plotOptions = ReadYaml(filePlotOptions);

%% pcolor plot

figure_named('EPSI_TS'),clf
indB = plotOptions.plotEpsTS.indB;
for ii = 1:length(data)
    t = 1:length(data(ii).L4.TIME);
    z = 1:length(data(ii).L4.Z_DIST);
    epsi = data(ii).L4.EPSI(:,:,indB);
    ax(ii) = subplot(length(data),1,ii);
    plotData = struct('x',t,'y',z,'values',log10(epsi'),'var','EPSI');
    opts = struct('ylabel','z index','clabel',['log10(\epsilon)'],'clim',plotOptions.plotEpsTS.clim);
    plot_pcolor(ax(ii),plotData,opts);
    title(clean_string(names{ii}))
end
    
linkaxes(ax,'x')
xlim([min(t) max(t)])
xlabel(' time index ')

add_fig_info(mname,[dataSet],struct())
if flg.saveFigs
    figName = [figPath,'EPSI_TimeSeries.png'];
    disp(['Saving: ',figName])
    saveas(gcf,figName);
end

%% Timeseries at one bin
figure_named('EPSI_TS_onebin'),clf
indB = plotOptions.plotEpsTS.indB;
indZ = plotOptions.plotEpsTS.indZ;

for ii = 1:length(data)
    t = 1:length(data(ii).L4.TIME);
    epsi = data(ii).L4.EPSI(:,indZ,indB);
    semilogy(t,epsi,'linewidth',2,'DisplayName',clean_string(names{ii}));
    if ii == 1; hold all; end   
end
legend()
ylabel('\epsilon [W/kg]')
xlabel('t index')

add_fig_info(mname,[dataSet],struct())
if flg.saveFigs
    figName = [figPath,'EPSI_TimeSeries_bin' num2str(indZ,'%02d') '.png'];
    disp(['Saving: ',figName])
    saveas(gcf,figName);
end

%% Timeseries at one bin (smoothed)
figure_named('EPSI_TS_onebin'),clf
indB = plotOptions.plotEpsTS.indB;
indZ = plotOptions.plotEpsTS.indZ;
Nsmooth = 12; % Approximately one hour smoothing

for ii = 1:length(data)
    t = 1:length(data(ii).L4.TIME);
    epsi = smooth(data(ii).L4.EPSI(:,indZ,indB),Nsmooth); 
    semilogy(t,epsi,'linewidth',2,'DisplayName',clean_string(names{ii}));
    if ii == 1; hold all; end   
end
legend()
ylabel('\epsilon [W/kg]')
xlabel('t index')

add_fig_info(mname,[dataSet, ', Nsmooth = ' num2str(Nsmooth) ' pts'],struct())
if flg.saveFigs
    figName = [figPath,'EPSI_TimeSeries_bin' num2str(indZ,'%02d') '_smoothed.png'];
    disp(['Saving: ',figName])
    saveas(gcf,figName);
end

%% PDFs
varName = 'EPSI';
figure_named([varName,'_Hist']), clf, clear ax plotData
plotData.var = varName ;
opts = plotOptions.plotEpsHist;
opts.xlabelStr = ['log_{10}(',clean_string(varName),')'];

opts.displayStyle = 'stairs';
opts.lineWidth = 2;
ph = []; lstr = [];
ax = subplot('Position',[0.12 0.2 0.8,0.7]);
for dd = 1:length(data)
    plotData(dd).values = log10(data(dd).L4.(varName));
    plotData(dd).label = [clean_string(names{dd})];
end
[ax,ph]=plot_histogram(ax,plotData,opts);
for dd = 1:length(data)
    if contains(names{dd},'Cen')
        ph(dd).LineWidth = 1;
        ph(dd).EdgeColor = ph(dd+1).EdgeColor;
    end
end
add_fig_info(mname,[dataSet],struct())
if flg.saveFigs
    figName = [figPath,varName,'_hist.png'];
    disp(['Saving: ',figName])
    saveas(gcf,figName);
end

varName = 'EPSI';
figure_named([varName,'_Hist_Separate']), clf, clear ax plotData
plotData.var = varName ;
opts = plotOptions.plotEpsHist;
opts.displayStyle = 'stairs';
opts.lineWidth = 2;


ph = []; lstr = [];
cc = 0; aa = 0;
for dd = 1:length(data)
    if contains(names{dd},'Cen')
        cc = cc +1;
        plotDataCen(cc).values = log10(data(dd).L4.(varName));
        plotDataCen(cc).label = [clean_string(names{dd})];
    else
        aa = aa+1;
        plotDataAll(aa).values = log10(data(dd).L4.(varName));
        plotDataAll(aa).label = [clean_string(names{dd})];
    end
end
ax(1) = subplot(121);
[ax(1),ph]=plot_histogram(ax(1),plotDataCen,opts);
ax(2) = subplot(122);
[ax(2),ph]=plot_histogram(ax(2),plotDataAll,opts);
linkaxes(ax,'y')
add_fig_info(mname,[dataSet],struct())
if flg.saveFigs
    figName = [figPath,varName,'_hist_Separate.png'];
    disp(['Saving: ',figName])
    saveas(gcf,figName);
end
%% Plot eps vs speed?