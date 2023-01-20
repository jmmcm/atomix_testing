%% plots_backtracking.m
%
% Plot the DLL and detrended velocities for the chosen indices
% 
% WARNING: Only currently works for method 1 if nDelR is an even integer
% (i.e. centered on indZ)
% - Doesn't currently work for method 3
%
% Justine McMillan
% Jan 11, 2023

clear all
mname = mfilename('fullpath');

set(groot,'DefaultFigurePosition',[0 0 500 500])
set(0,'defaultAxesXGrid','on')
set(0,'defaultAxesYGrid','on')
%% Select dataset and process ID numbers
% dataSet = 'RDI4beam_TidalChannel_GP130620BPb';

dataSet = 'RDIWH600_CANDYFLOSS_bedframe';
    processIDs = {'BDS_M1aC_RM7p5','JMM_M1aC_RM7p5'};
%      processIDs = {'JMM_M1aC_RM7p5','JMM_M3uC_RM7p5'};
    
% dataSet = 'RDIWH600_CANDYFLOSS_TOP';
% dataSet = 'Signature5beam_TidalShelf';

c1 = [0.4940 0.1840 0.5560];
c2 = [0.4660 0.6740 0.1880];

%% Data files
[dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet);

for ii = 1:length(processIDs)
    processID = processIDs{ii};
    matFile = [dataDir,dataFileRoot,'_',processID,'.mat'];
    d(ii) = load(matFile);
    data(ii) = d(ii).data;
    flags(ii) = d(ii).flags;
    names{ii} = [d(ii).infoProcessing.creator, '_', d(ii).infoProcessing.method];
end


%% Load plotting options
filePlotOptions = [metaDir,dataSet,'_plotOptions.yml'];
plotOptions = ReadYaml(filePlotOptions);
opts = plotOptions.plotBacktracking;

for ii = 1:length(opts.indT)
    indT = opts.indT(ii);
    indZ = opts.indZ(ii);
    indB = opts.indB(ii);
    nDelR = opts.nDelR(ii);
    
    
    
    % Get bins based on dr
    dr = (data(1).L1.Z_DIST(2) - data(1).L1.Z_DIST(1))/cosd(data(1).L1.THETA(indB));
    delR = nDelR*dr;
    
    for dd = 1:2
        indVDT(dd).indR = find(abs(data(dd).L3.R_DEL(indB,:) - delR)<1e-4);
        if isfield(data(dd).L3,'BIN_L')
            indVDT(dd).binL = squeeze(data(dd).L3.BIN_L(indT,indZ,indB,indVDT(dd).indR))';
            indVDT(dd).binU = squeeze(data(dd).L3.BIN_U(indT,indZ,indB,indVDT(dd).indR))';
        else
            if mod(nDelR,2) ~= 0
                error('Not centered bin pairs')
            end
            indVDT(dd).binL = indZ - nDelR/2;
            indVDT(dd).binU = indZ + nDelR/2;
        end
        ind = find(~isnan(indVDT(dd).binL));
        indVDT(dd).indR = indVDT(dd).indR(ind);
        indVDT(dd).binL = indVDT(dd).binL(ind);
        indVDT(dd).binU = indVDT(dd).binU(ind);
    end
    
    nS = length(data(1).L2.N_SAMPLE);
    [nR,indLonger] = max([length(indVDT(1).binU),length(indVDT(2).binU)]);
    binsL = indVDT(indLonger).binL;
    binsU = indVDT(indLonger).binU;
    
    v1low = NaN*ones(nR,nS);
    v2low = NaN*ones(nR,nS);
    v1upp = NaN*ones(nR,nS);
    v2upp = NaN*ones(nR,nS);
    indR1 = NaN*ones(1,nR);
    indR2 = NaN*ones(1,nR);
    DLL1calc = NaN*ones(1,nR);
    DLL1file = NaN*ones(1,nR);
    DLL2calc = NaN*ones(1,nR);
    DLL2file = NaN*ones(1,nR);
    
    for rr = 1:length(indVDT(1).indR)
        ind = find(binsL == indVDT(1).binL(rr));
        
        indR1(ind) = indVDT(1).indR(rr);
        v1low(ind,:) = squeeze(data(1).L2.R_VEL_DETRENDED(indT,indVDT(1).binL(rr),indB,:));
        v1upp(ind,:) = squeeze(data(1).L2.R_VEL_DETRENDED(indT,indVDT(1).binU(rr),indB,:));
        DLL1calc(ind) = nanmean((v1upp(ind,:) - v1low(ind,:)).^2,2);
        DLL1file(ind) = data(1).L3.DLL(indT,indZ,indB,indVDT(1).indR(rr));
    end
    
    for rr = 1:length(indVDT(2).indR)
        ind = find(binsL == indVDT(2).binL(rr));
        indR2(ind) = indVDT(2).indR(rr);
        v2low(ind,:) = squeeze(data(2).L2.R_VEL_DETRENDED(indT,indVDT(2).binL(rr),indB,:));
        v2upp(ind,:) = squeeze(data(2).L2.R_VEL_DETRENDED(indT,indVDT(2).binU(rr),indB,:));
        DLL2calc(ind) = nanmean((v2upp(ind,:) - v2low(ind,:)).^2,2);
        DLL2file(ind) = data(2).L3.DLL(indT,indZ,indB,indVDT(2).indR(rr));
    end

    % plot
    for rr = 1:nR
        binL = binsL(rr);
        binU = binsU(rr);
        
        figure_named(['BackTracking',num2str(ii),'-',num2str(rr)]),clf
        set(gcf,'Position',[10 10 1420 1200])
        ax1 = subplot(3,3,[1:2]);
        pos = get(gca,'Position');
        set(gca,'Position',[0.08 pos(2:4)])
        semilogy(data(1).L4.EPSI(:,indZ,indB),'linewidth',2)
        hold all
        semilogy(data(2).L4.EPSI(:,indZ,indB),'linewidth',2)
        plot(indT*[1 1],get(gca,'ylim'),'--k')
        legend(clean_string(names{1}),clean_string(names{2}))
        ylabel('\epsilon [W/kg]')
        title(['indT = ',num2str(indT),', indZ = ',num2str(indZ)])
        ylim([1e-9 1e-5])
        xlim(indT+[-50 50])
        xlabel('N\_SEGMENT')

        ax2 = subplot(3,3,[3]);
        pos = get(gca,'Position');
        set(gca,'Position',[pos(1)-0.05 pos(2:4)])
        p = plot_DLL_compare(data(1).L3,data(1).L4,data(2).L3,data(2).L4,struct('indB',indB,'indZ',indZ,'indT',indT));
        %plot(delR.^(2/3)*[1 1],get(gca,'ylim'),'--k')
        try
            plot(data(1).L3.R_DEL(indB,indR1(rr)).^(2/3),data(1).L3.DLL(indT,indZ,indB,indR1(rr)),...
                '^','color',c1,'markersize',15,'linewidth',2)
        end
        try
            plot(data(2).L3.R_DEL(indB,indR2(rr)).^(2/3),data(2).L3.DLL(indT,indZ,indB,indR2(rr)),...
                'v','color',c2,'markersize',15,'linewidth',2)
        end
        
        ax3 = subplot(3,3,[4:6]);
        pos = get(gca,'Position');
        set(gca,'Position',[0.08 pos(2:4)])
        p(1) = plot(v1low(rr,:),'.-','Color',c1,'DisplayName',clean_string(names{1}),'markersize',10);
        hold all
        p(2) = plot(v2low(rr,:),'Color',c2,'DisplayName',clean_string(names{2}));
        p(3) = plot(squeeze(data(2).L2.R_VEL(indT,binL,indB,:)),'Color',0.6*[1 1 1],'DisplayName','Raw data');
        title(['bin = ',num2str(binL)])
        legend(p)
        ylabel('vdt_L [m/s]')
        xlabel('N\_SAMPLE')

        ax4 = subplot(3,3,[7:9]);
        pos = get(gca,'Position');
        set(gca,'Position',[0.08 pos(2:4)])
        p(1) = plot(v1upp(rr,:),'.-','Color',c1,'DisplayName',clean_string(names{1}),'markersize',10);
        hold all
        p(2) = plot(v2upp(rr,:),'Color',c2,'DisplayName',clean_string(names{2}));
        p(3) = plot(squeeze(data(2).L2.R_VEL(indT,binU,indB,:)),'Color',0.6*[1 1 1],'DisplayName','Raw data');
        title(['bin = ',num2str(binU)])
        legend(p)
        ylabel('vdt_U [m/s]')
        xlabel('N\_SAMPLE')


        info = {
          '===CHECK===',...
          ['nR\_DEL = ',num2str(nDelR), ' bins'],...
          clean_string(names{1}), ...
          [' - calc: ',num2str(DLL1calc(rr),'%5.4e')], ...
          [' - file: ',num2str(DLL1file(rr),'%5.4e')], ...
          clean_string(names{2}), ...
          [' - calc: ',num2str(DLL2calc(rr),'%5.4e')], ...
          [' - file: ',num2str(DLL2file(rr),'%5.4e')] ...
        };
        annotation('textbox', [0.86, 0.65, 0, 0], 'String', info, 'FitBoxToText', 'on','FontName','FixedWidth');
        add_fig_info(mname,[dataSet],struct())
    end
    
    for pp = 1:2
    r_del = data(pp).L3.R_DEL(indB,:);
    dll = squeeze(data(pp).L3.DLL(indT,indZ,indB,:));
    dll_n = squeeze(data(pp).L3.DLL_N(indT,indZ,indB,:));
    dll_flags = squeeze(data(pp).L3.DLL_FLAGS(indT,indZ,indB,:));
    try
        binL = squeeze(data(pp).L3.BIN_L(indT,indZ,indB,:));
        binU = squeeze(data(pp).L3.BIN_U(indT,indZ,indB,:));
    catch
        binL = NaN*dll;
        binU = NaN*dll;
    end
    
    processIDs{pp}
    [r_del' r_del'/dr binU-binL binL binU dll dll_n dll_flags]
    end
disp('======')
end

%%
