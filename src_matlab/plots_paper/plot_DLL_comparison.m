clear all
addpath('/home/jmm000/code/utilities/subaxis/')
mname = mfilename('fullpath');

%%
nn = 5;
dataSets = {'RDI4beam_TidalChannel_GP130620BPb',...
            'AQD_NorthSea_bedframe',...
            'AQD_Windermere_bedframe',...
            'RDIWH600_CANDYFLOSS_TOP',...
            'RDIWH600_CANDYFLOSS_bedframe',...
            'NortekSig1000_TidalChannel_2019_Burst'};

dataSet = dataSets{nn};
switch dataSet
    case 'RDI4beam_TidalChannel_GP130620BPb'
        processIDs = {'JMM_M1aC_RM5','JMM_M2uC_RM5','JMM_M2aC_RM5'};
        indZ = 20;
        indB = 1;
        indTall = [101 110 144];
        limEpsi = [1e-8 3e-4];
    case 'AQD_NorthSea_bedframe'
        processIDs = {'JMM_M1aC_RM0p3','JMM_M2uC_RM0p3','JMM_M2aC_RM0p3'};
        indZ = 20;
        indB = 1;
        indTall = [50 74 110];
        limEpsi = [1e-9 1e-5];
    case 'AQD_Windermere_bedframe' % TODO DIfferent sigmaN for flagging?
        processIDs = {'JMM_M1aC_RM2','JMM_M2uC_RM2','JMM_M2aC_RM2'};
        indZ = 20;
        indB = 1;
        indTall = [25 63 152];
        limEpsi = [1e-13 1e-8];
    case 'RDIWH600_CANDYFLOSS_TOP'
        processIDs = {'JMM_M1aC_RM0p75','JMM_M2uC_RM0p75','JMM_M2aC_RM0p75'};
        indZ = 20;
        indB = 1;
        indTall = [56 223 278 497];
        limEpsi = [1e-10 2e-5];
    case 'RDIWH600_CANDYFLOSS_bedframe'
        processIDs = {'JMM_M1aC_RM7p5','JMM_M2uC_RM7p5','JMM_M2aC_RM7p5'};
        indZ = 20;
        indB = 1;
        indTall = [56 162 223 278];
        limEpsi = [1e-10 1e-5];
    case 'NortekSig1000_TidalChannel_2019_Burst'
        processIDs = {'JMM_M1aC_RM3','JMM_M2uC_RM3','JMM_M2aC_RM3'};
        indZ = 15;
        indB = 1;
        indTall = [44 110 140 184];
        limEpsi = [1e-9 1e-3];
end

markers = {'o','.','s'};
colors = {'r','b',[0 0.6 0]};
labels = {'Cen','All','AllAvg'};
%% Data files
[dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet);
metaDir = ['../' metaDir];
for ii = 1:length(processIDs)
    processID = processIDs{ii};
    matFile = [dataDir,dataFileRoot,'_',processID,'.mat'];
    d(ii) = load(matFile);
    data(ii) = d(ii).data;
    flags(ii) = d(ii).flags;
    names{ii} = [d(ii).infoProcessing.creator, '_', d(ii).infoProcessing.method];
end

filePlotOptions = [metaDir,dataSet,'_plotOptions.yml'];
plotOptions = ReadYaml(filePlotOptions);



%% Plot SF Fit
for tt = 2%1:length(indTall)
    figure(1+tt),clf,clear ax
    set(gcf,'Name','SFfits')
    indT = indTall(tt);
    
    for pp = 1:4
        ax(pp) = subaxis(1,4,pp,'SpacingHoriz',0.02);
    end

    pAll = [];
    for dd = 1:3
        opts.indB = indB;
        opts.indT = indT;
        opts.indZ = indZ;
        opts.dll_averaging = d(dd).metadataGroups.L4.dll_averaging;
        opts.rMin = d(dd).metadataGroups.L4.rMin;
        opts.rMax = d(dd).metadataGroups.L4.rMax;
        opts.points_select_method = d(dd).metadataGroups.L4.points_select_method;
        opts.colorbar = 0;

        axes(ax(dd))
        
        [ax(dd),p,t]= plot_DLL_fit(ax(dd),data(dd).L3,data(dd).L4,opts);
        set(p(1),'MarkerFaceColor',0.8*[1 1 1])
        delete(p(2))
        %set(p(2),'Marker','o','MarkerFaceColor',colors{dd})
        p(2) = plot(ax(dd),squeeze((data(dd).L4.REGRESSION_R_DEL(indT,indZ,indB,:))).^(2/3),squeeze(data(dd).L4.REGRESSION_DLL(indT,indZ,indB,:)),...
            'o','color',colors{dd},'MarkerFaceColor',colors{dd},'DisplayName','FittedPoints');
        legend([p(1) p(2) p(3)])
        delete(t)

        
        title(ax(dd),{labels{dd}})
        set(p(2),'color','k','linewidth',2)
        set(p(3:5),'color',colors{dd})
        box(ax(dd),'on')
        plot(ax(dd),0,2*d(dd).metadataGroups.L4.sigmaN_v^2,'^k','markerfacecolor','k','DisplayName','2\sigma^2')

        axes(ax(4))
        opts.colorbar = 0;
        [ax(4),pC,tC]= plot_DLL_fit(ax(4),data(dd).L3,data(dd).L4,opts);
        delete(pC(1))
        delete(tC)
        set(pC(2),'marker',markers{dd},'linewidth',1,'color',colors{dd},'DisplayName',labels{dd})
        set(pC(3:5),'color',colors{dd})
        plot(ax(4),0,2*d(dd).metadataGroups.L4.sigmaN_v^2,'^k','markerfacecolor','k','DisplayName','2\sigma^2')


        pAll = [pAll pC(2)];
        
        epsi(dd) = data(dd).L4.EPSI(indT,indZ,indB);
        epsi_flag(dd) = data(dd).L4.EPSI_FLAGS(indT,indZ,indB);
        epsi_del_ratio(dd) = data(dd).L4.EPSI_DEL_RATIO(indT,indZ,indB);



    end

    legend(ax(4),pAll)
    box(ax(4),'on')
    title(ax(4),{'Comparison'})

    for pp = 2:4
        set(ax(pp),'yticklabels','')
        ylabel(ax(pp),'')
    end
    linkaxes(ax(1:4),'y')

    for dd = 1:3
    text(ax(dd),0,0.0017, ...
        {[' \epsilon = ', num2str(epsi(dd),'%3.2e'),' W/kg (flag = ' num2str(epsi_flag(dd)) ')'],...
        [' \Delta \epsilon / \epsilon = ',num2str(epsi_del_ratio(dd))]},...
        'color','k');
    end
 

    ax2 = axes(gcf,'position',get(ax(5),'Position'),'color','none');
    set(ax2,'YAxisLocation','right')
    set(ax2,'xlim',get(ax(5),'xlim'))
    set(ax2,'xtick',xticks)
    %      set(ax2,'XTickLabels','') % Hack necessary to get nice saved figures
    set(ax2,'ylim',get(ax(5),'ylim'))
    dz = data(1).L1.Z_DIST(2)-data(1).L1.Z_DIST(1);
    set(ax2,'YTickLabels',strsplit(num2str(yticks*dz)))
    ylabel(ax2,'z [m]')

    text_rel_figure(0.02,0.9,{['indT = ',num2str(indT)],['indZ = ',num2str(indZ)]})
    add_fig_info(mname,dataSet,struct())
end
