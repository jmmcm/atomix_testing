clear all
addpath('/home/jmm000/code/utilities/subaxis/')
mname = mfilename('fullpath');


%%
nn = 6;
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
        limEpsi = [1e-8 3e-4];
    case 'AQD_NorthSea_bedframe'
        processIDs = {'JMM_M1aC_RM0p3','JMM_M2uC_RM0p3','JMM_M2aC_RM0p3'};
        indZ = 20;
        indB = 1;
        limEpsi = [1e-9 1e-5];
    case 'AQD_Windermere_bedframe'
        processIDs = {'JMM_M1aC_RM2','JMM_M2uC_RM2','JMM_M2aC_RM2'};
        indZ = 20;
        indB = 1;
        limEpsi = [1e-13 1e-8];
    case 'RDIWH600_CANDYFLOSS_TOP'
        processIDs = {'JMM_M1aC_RM0p75','JMM_M2uC_RM0p75','JMM_M2aC_RM0p75'};
        indZ = 20;
        indB = 1;
        limEpsi = [1e-10 2e-5];
    case 'RDIWH600_CANDYFLOSS_bedframe'
        processIDs = {'JMM_M1aC_RM7p5','JMM_M2uC_RM7p5','JMM_M2aC_RM7p5'};
        indZ = 20;
        indB = 1;
        limEpsi = [1e-10 1e-5];
    case 'NortekSig1000_TidalChannel_2019_Burst'
        processIDs = {'JMM_M1aC_RM3','JMM_M2uC_RM3','JMM_M2aC_RM3'};
        indZ = 15;
        indB = 1;
        limEpsi = [1e-9 1e-3];
end



flg.saveFigs = 1;
flg.plotSlope = 1;
flg.plotNpts = 1;
flg.plotYInt = 1;
flg.plotRegQual = 1;
flg.plotDev23 = 1;
flg.plotEpsMin = 1;
flg.plotSummary = 1;

markers = {'.','o','s'};
colors = {'r','b',[0 0.6 0]};
labels = {'Cen','All','AllAvg'};

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

filePlotOptions = [metaDir,dataSet,'_plotOptions.yml'];
plotOptions = ReadYaml(filePlotOptions);

%% Thresholds
threshold.slope = 0;
threshold.nPts = 3;
threshold.yInt = [0 4*d(1).metadataGroups.L4.sigmaN_v^2];
threshold.R2 = 0.6;
threshold.EPSI_DEL_RATIO = 1;
threshold.epsMin = 0.1*d(1).metadataGroups.L4.sigmaN_v^3; % Brian's paper draft

%% 
figPath = ['/home/jmm000/work/ATOMIX/figures/' dataSet '/Flagging/'];
if ~exist(figPath,'dir') & flg.saveFigs
    disp(['Making ',figPath,'. Press a key to continue.']),pause
    mkdir(figPath)
end

%% Simple variables
x = 1:length(data(1).L4.TIME);

%% Plot slope
if flg.plotSlope
    figure(1),clf, clear ax
    set(gcf,'Name','Slope')
    ax(1) = subaxis(3,1,1);
    ax(2) = subaxis(3,1,2);
    ax(3) = subaxis(3,1,3);
    for dd = 1:length(data)
        p = plot_epsi(ax(1),data(dd).L4,struct('indB',indB,'indZ',indZ,'col',colors{dd},'varX','index','marker','.'));
        set(p(1),'DisplayName',labels{dd})

        plot(ax(2),x,data(dd).L4.REGRESSION_COEFF_A1(:,indZ,indB),'.','color',colors{dd})
        hold(ax(2),'on')

        indBad = find(data(dd).L4.REGRESSION_COEFF_A1(:,indZ,indB) < threshold.slope);
        plot(ax(3),x(indBad),1+0*indBad,'color',colors{dd},...
            'marker',markers{dd},'linestyle','none',...
            'DisplayName',['nBad = ',num2str(length(indBad))])
        hold(ax(3),'on')
    end

    set(ax(1),'ylim',limEpsi)

    axes(ax(2))
    plot(get(ax(2),'xlim'),threshold.slope*[1 1],'r')
    ylims = get(ax(2),'ylim');
    fill_transparent(get(ax(2),'xlim'),[ylims(1) threshold.slope],'r')

    legend(ax(3))


    ylabel(ax(1),'\epsilon [W/kg]')
    ylabel(ax(2),'slope')
    ylabel(ax(3),'flag')
    xlabel(ax(3),'index')

    linkaxes(ax,'x')
    set(ax(1),'xlim',[min(x) max(x)])

    add_fig_info(mname,[dataSet ' (rMax = ',num2str(d(1).metadataGroups.L4.rMax) ' m)'],struct())

    if flg.saveFigs
        figName = [figPath,'Flag_Slope_z', num2str(indZ,'%02d'),'.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
end

%% Plot Number of points
if flg.plotNpts
    figure(2),clf, clear ax
    set(gcf,'Name','Npts')
    ax(1) = subaxis(3,1,1);
    ax(2) = subaxis(3,1,2);
    ax(3) = subaxis(3,1,3);
    for dd = 1:length(data)
        p = plot_epsi(ax(1),data(dd).L4,struct('indB',indB,'indZ',indZ,'col',colors{dd},'varX','index','marker','.'));
        set(p(1),'DisplayName',labels{dd})

        plot(ax(2),x,data(dd).L4.REGRESSION_N(:,indZ,indB),'color',colors{dd},'marker',markers{dd},'linestyle','none')
        hold(ax(2),'on')

        indBad = find(data(dd).L4.REGRESSION_N(:,indZ,indB) < threshold.nPts);
        plot(ax(3),x(indBad),1+0*indBad,'color',colors{dd},...
            'marker',markers{dd},'linestyle','none',...
            'DisplayName',['nBad = ',num2str(length(indBad))])
        hold(ax(3),'on')
    end
    set(ax(1),'ylim',limEpsi)

    axes(ax(2))
    plot(get(ax(2),'xlim'),threshold.nPts*[1 1],'r')
    fill_transparent(get(ax(2),'xlim'),[0 threshold.nPts],'r')

    legend(ax(3))

    ylabel(ax(1),'\epsilon [W/kg]')
    ylabel(ax(2),'NPts')
    ylabel(ax(3),'flag')
    xlabel(ax(3),'index')

    linkaxes(ax,'x')
    set(ax(1),'xlim',[min(x) max(x)])

    add_fig_info(mname, [dataSet ' (rMax = ',num2str(d(1).metadataGroups.L4.rMax) ' m)'],struct())

    if flg.saveFigs
        figName = [figPath,'Flag_Npts_z', num2str(indZ,'%02d'),'.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
end

%% Plot yintercept
if flg.plotYInt
    figure(3),clf, clear ax
    set(gcf,'Name','YInt')
    ax(1) = subaxis(3,1,1);
    ax(2) = subaxis(3,1,2);
    ax(3) = subaxis(3,1,3);
    for dd = 1:length(data)

        p = plot_epsi(ax(1),data(dd).L4,struct('indB',indB,'indZ',indZ,'col',colors{dd},'varX','index','marker','.'));
        set(p(1),'DisplayName',labels{dd})

        plot(ax(2),x,data(dd).L4.REGRESSION_COEFF_A0(:,indZ,indB),'color',colors{dd},'marker',markers{dd},'linestyle','none')
        hold(ax(2),'on')

        indBad = find(data(dd).L4.REGRESSION_COEFF_A0(:,indZ,indB) < threshold.yInt(1) | data(dd).L4.REGRESSION_COEFF_A0(:,indZ,indB) > threshold.yInt(2));
        plot(ax(3),x(indBad),1+0*indBad,'color',colors{dd},...
            'marker',markers{dd},'linestyle','none',...
            'DisplayName',['nBad = ',num2str(length(indBad))])
        hold(ax(3),'on')
    end
    set(ax(1),'ylim',limEpsi)

    axes(ax(2))
    plot(get(ax(2),'xlim'),threshold.yInt(1)*[1 1],'r')
    plot(get(ax(2),'xlim'),threshold.yInt(2)*[1 1],'r')
    ylims = get(ax(2),'ylim');
    fill_transparent(get(ax(2),'xlim'),[ylims(1) threshold.yInt(1)],'r')
    fill_transparent(get(ax(2),'xlim'),[threshold.yInt(2) ylims(2)],'r')
    set(ax(2),'ylim',ylims)

    legend(ax(3))


    ylabel(ax(1),'\epsilon [W/kg]')
    ylabel(ax(2),'yInt')
    ylabel(ax(3),'flag')
    xlabel(ax(3),'index')

    linkaxes(ax,'x')
    set(ax(1),'xlim',[min(x) max(x)])

    add_fig_info(mname, [dataSet ' (rMax = ',num2str(d(1).metadataGroups.L4.rMax) ' m)'],struct())

    if flg.saveFigs
        figName = [figPath,'Flag_yInt_z', num2str(indZ,'%02d'),'.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
end

%% Plot regression quality
if flg.plotRegQual 
    figure(4),clf,clear ax
    set(gcf,'Name','RegressionQuality')
    ax(1) = subaxis(6,1,1);
    ax(2) = subaxis(6,1,2);
    ax(3) = subaxis(6,1,3);
    ax(4) = subaxis(6,1,4);
    ax(5) = subaxis(6,1,5);
    ax(6) = subaxis(6,1,6);
    for dd = 1:length(data)

        p = plot_epsi(ax(1),data(dd).L4,struct('indB',indB,'indZ',indZ,'col',colors{dd},'varX','index','marker','.'));
        set(p(1),'DisplayName',labels{dd})

        plot(ax(2),x,data(dd).L4.REGRESSION_R2(:,indZ,indB),'color',colors{dd},'marker',markers{dd},'linestyle','none')
        hold(ax(2),'on')
        
        plot(ax(3),x,data(dd).L4.MAD(:,indZ,indB),'color',colors{dd},'marker',markers{dd},'linestyle','none')
        hold(ax(3),'on')
        
        plot(ax(4),x,data(dd).L4.MSPE(:,indZ,indB),'color',colors{dd},'marker',markers{dd},'linestyle','none')
        hold(ax(4),'on')
        
        plot(ax(5),x,data(dd).L4.EPSI_DEL_RATIO(:,indZ,indB),'color',colors{dd},'marker',markers{dd},'linestyle','none')
        hold(ax(5),'on')
        
        indBad1 = find(data(dd).L4.REGRESSION_R2(:,indZ,indB) < threshold.R2);
        plot(ax(6),x(indBad1),1+0*indBad1,'color',colors{dd},...
            'marker',markers{dd},'linestyle','none',...
            'DisplayName',['nBad1 = ',num2str(length(indBad1))])
        indBad4 = find(data(dd).L4.EPSI_DEL_RATIO(:,indZ,indB) > threshold.EPSI_DEL_RATIO);
        plot(ax(6),x(indBad4),4+0*indBad4,'color',colors{dd},...
            'marker',markers{dd},'linestyle','none',...
            'DisplayName',['nBad4 = ',num2str(length(indBad4))])
        hold(ax(6),'on')
    end
    set(ax(1),'ylim',limEpsi)

    axes(ax(2))
    plot(get(ax(2),'xlim'),threshold.R2*[1 1],'r')
    ylims = get(ax(2),'ylim');
    fill_transparent(get(ax(2),'xlim'),[ylims(1) threshold.R2],'r')
    set(ax(2),'ylim',ylims)
    
    axes(ax(5))
    set(ax(5),'Yscale','log')
    ylims = get(ax(5),'ylim');
    fill_transparent(get(ax(5),'xlim'),[threshold.EPSI_DEL_RATIO ylims(2)],'r')

    legend(ax(6))


    ylabel(ax(1),'\epsilon [W/kg]')
    ylabel(ax(2),'R2 (flag=1)')
    ylabel(ax(3),'MAD (flag=2)')
    ylabel(ax(4),'MSPE (flag=3)')
    ylabel(ax(5),'\Delta\epsilon/\epsilon  (flag=4)')
    ylabel(ax(6),'flag')
    xlabel(ax(6),'index')

    linkaxes(ax,'x')
    set(ax(1),'xlim',[min(x) max(x)])

    add_fig_info(mname, [dataSet ' (rMax = ',num2str(d(1).metadataGroups.L4.rMax) ' m)'],struct())

    if flg.saveFigs
        figName = [figPath,'Flag_RegQual_z', num2str(indZ,'%02d'),'.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end

end

%% Plot minimum epilon
if flg.plotEpsMin
    figure(5),clf,clear ax
    set(gcf,'Name','MinEps')
    ax(1) = subaxis(3,1,1);
    ax(2) = subaxis(3,1,2);
    ax(3) = subaxis(3,1,3);
    for dd = 1:length(data)

        p = plot_epsi(ax(1),data(dd).L4,struct('indB',indB,'indZ',indZ,'col',colors{dd},'varX','index','marker','.'));
        set(p(1),'DisplayName',labels{dd})

        p = plot_epsi(ax(2),data(dd).L4,struct('indB',indB,'indZ',indZ,'col',colors{dd},'varX','index','marker','.'));        
        hold(ax(2),'on')
        set(ax(2),'yscale','linear')

        indBad = find(data(dd).L4.EPSI(:,indZ,indB) < threshold.epsMin);
        plot(ax(3),x(indBad),1+0*indBad,'color',colors{dd},...
            'marker',markers{dd},'linestyle','none',...
            'DisplayName',['nBad = ',num2str(length(indBad))])
        hold(ax(3),'on')
    end
    axes(ax(1))
    set(ax(1),'ylim',limEpsi)
    plot(get(ax(1),'xlim'),threshold.epsMin*[1 1],'r')
    ylims = get(ax(1),'ylim');
    fill_transparent(get(ax(1),'xlim'),[ylims(1) threshold.epsMin],'r')

    axes(ax(2))
    plot(get(ax(2),'xlim'),threshold.epsMin*[1 1],'r')
    ylims = get(ax(2),'ylim');
    fill_transparent(get(ax(2),'xlim'),[ylims(1) threshold.epsMin],'r')
    set(ax(2),'ylim',ylims)

    legend(ax(3))


    ylabel(ax(1),'\epsilon [W/kg]')
    ylabel(ax(2),'\epsilon [W/kg]')
    ylabel(ax(3),'flag')
    xlabel(ax(3),'index')

    linkaxes(ax,'x')
    set(ax(1),'xlim',[min(x) max(x)])

    add_fig_info(mname, [dataSet ' (rMax = ',num2str(d(1).metadataGroups.L4.rMax) ' m)'],struct())

    if flg.saveFigs
        figName = [figPath,'Flag_minEps_z', num2str(indZ,'%02d'),'.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
    
    
end
%% Plot deviation from 2/3
if flg.plotDev23
    figure(6),clf,clear ax
    set(gcf,'Name','Dev2/3')
end

%% Summary table
clear indBad*
flagNames = ["slope";"nPts";"yInt";"RegQual";"minEps";"Dev2/3";"TOTAL"];
for dd = 1:length(data)
    method = labels{dd};
    indBad1.(method) = find(data(dd).L4.REGRESSION_COEFF_A1(:,indZ,indB) < threshold.slope);
    indBad2.(method) = find(data(dd).L4.REGRESSION_N(:,indZ,indB) < threshold.nPts);
    indBad3.(method) = find(data(dd).L4.REGRESSION_COEFF_A0(:,indZ,indB) < threshold.yInt(1) | data(dd).L4.REGRESSION_COEFF_A0(:,indZ,indB) > threshold.yInt(2));
    indBad4.(method) = find(data(dd).L4.EPSI_DEL_RATIO(:,indZ,indB) > threshold.EPSI_DEL_RATIO);
    indBad5.(method) = find(data(dd).L4.EPSI(:,indZ,indB) < threshold.epsMin);
    indBad6.(method) = [];
    indBadT.(method) = unique([indBad1.(method); indBad2.(method); indBad3.(method); indBad4.(method); indBad5.(method); indBad6.(method)]);
    
    N = length(x);
    
    counts.(method) = [length(indBad1.(method)) ; ...
                       length(indBad2.(method)) ; ...
                       length(indBad3.(method)) ; ...
                       length(indBad4.(method)) ; ...
                       length(indBad5.(method)) ; ...
                       length(indBad6.(method)) ; ...
                       length(indBadT.(method))];
    perc.(method) = counts.(method)/N*100;
    
   
end

t = table(flagNames,perc.Cen,perc.All,perc.AllAvg,'VariableNames',["flags","Cen","All","AllAvg"]);
disp(t)


%% Plot summary plot
if flg.plotSummary
    figure(7),clf,clear ax
    set(gcf,'Name','Summary')
    
    vspace = 0.01;
    ax(1) = subaxis(7,1,1,'SpacingVert',vspace);
    ax(2) = subaxis(7,1,2,'SpacingVert',vspace);
    ax(3) = subaxis(7,1,3,'SpacingVert',vspace);
    ax(4) = subaxis(7,1,4,'SpacingVert',vspace);
    ax(5) = subaxis(7,1,5,'SpacingVert',vspace);
    ax(6) = subaxis(7,1,6,'SpacingVert',vspace);
    ax(7) = subaxis(7,1,7,'SpacingVert',vspace);
    
    for dd = 1:length(data)
        method = labels{dd};

        p = plot_epsi(ax(1),data(dd).L4,struct('indB',indB,'indZ',indZ,'col',colors{dd},'varX','index','marker','.'));
        set(p(1),'DisplayName',labels{dd})
        set(p(2:3),'HandleVisibility','off')

        plot(ax(2),x,data(dd).L4.REGRESSION_COEFF_A1(:,indZ,indB),'color',colors{dd},'marker',markers{dd},'linestyle','none')
        hold(ax(2),'on')
        
        plot(ax(3),x,data(dd).L4.REGRESSION_N(:,indZ,indB),'color',colors{dd},'marker',markers{dd},'linestyle','none')
        hold(ax(3),'on')
        
        plot(ax(4),x,data(dd).L4.REGRESSION_COEFF_A0(:,indZ,indB),'color',colors{dd},'marker',markers{dd},'linestyle','none')
        hold(ax(4),'on')
        
        plot(ax(5),x,data(dd).L4.EPSI_DEL_RATIO(:,indZ,indB),'color',colors{dd},'marker',markers{dd},'linestyle','none')
        hold(ax(5),'on')
        
        plot(ax(7),x(indBad1.(method)),1+0*indBad1.(method),'color',colors{dd},'marker',markers{dd},'linestyle','none')
        hold(ax(7),'on')
        plot(ax(7),x(indBad2.(method)),2+0*indBad2.(method),'color',colors{dd},'marker',markers{dd},'linestyle','none')
        plot(ax(7),x(indBad3.(method)),3+0*indBad3.(method),'color',colors{dd},'marker',markers{dd},'linestyle','none')
        plot(ax(7),x(indBad4.(method)),4+0*indBad4.(method),'color',colors{dd},'marker',markers{dd},'linestyle','none')
        plot(ax(7),x(indBad5.(method)),5+0*indBad5.(method),'color',colors{dd},'marker',markers{dd},'linestyle','none')
        %TODO: Add flag for bad 2/3
    end
    axes(ax(1))
    set(ax(1),'ylim',limEpsi)
    plot(get(ax(1),'xlim'),threshold.epsMin*[1 1],'r','HandleVisibility','off')
    ylims = get(ax(1),'ylim');
    fill_transparent(get(ax(1),'xlim'),[ylims(1) threshold.epsMin],'r')

    axes(ax(2))
    plot(get(ax(2),'xlim'),threshold.slope*[1 1],'r')
    ylims = get(ax(2),'ylim');
    fill_transparent(get(ax(2),'xlim'),[ylims(1) threshold.slope],'r')
    set(ax(2),'ylim',ylims)
    
    axes(ax(3))
    plot(get(ax(3),'xlim'),threshold.nPts*[1 1],'r')
    ylims = get(ax(3),'ylim');
    fill_transparent(get(ax(3),'xlim'),[0 threshold.nPts],'r')
    set(ax(3),'ylim',ylims)
    
    axes(ax(4))
    plot(get(ax(4),'xlim'),threshold.yInt(1)*[1 1],'r')
    plot(get(ax(4),'xlim'),threshold.yInt(2)*[1 1],'r')
    ylims = get(ax(4),'ylim');
    fill_transparent(get(ax(4),'xlim'),[ylims(1) threshold.yInt(1)],'r')
    fill_transparent(get(ax(4),'xlim'),[threshold.yInt(2) ylims(2)],'r')
    set(ax(4),'ylim',ylims)
    
    axes(ax(5))
    set(ax(5),'Yscale','log')
    ylims = get(ax(5),'ylim');
    fill_transparent(get(ax(5),'xlim'),[threshold.EPSI_DEL_RATIO ylims(2)],'r')
    

%     legend(ax(3))


    ylabel(ax(1),'\epsilon [W/kg]')
    ylabel(ax(2),'Slope')
    ylabel(ax(3),'nPts')
    ylabel(ax(4),'yInt')
    ylabel(ax(5),'\Delta\epsilon/\epsilon')
    ylabel(ax(6),'Dev2/3')
    ylabel(ax(7),'flag')
    xlabel(ax(7),'index')
    yticks(ax(7),1:6)
    ylim(ax(7),[0.5 6.5])
    yticklabels(ax(7),{'slope','nPts','yInt','RegQual','minEps','Dev2/3'})
    set(ax(7),'ydir','rev')
    
    for ii = 1:6
        set(ax(ii),'xticklabels',[])
    end

    linkaxes(ax,'x')
    set(ax(1),'xlim',[min(x) max(x)])

    add_fig_info(mname, [dataSet ' (rMax = ',num2str(d(1).metadataGroups.L4.rMax) ' m)'],struct())

    if flg.saveFigs
        figName = [figPath,'Flag_Summary_z', num2str(indZ,'%02d'),'.png'];
        disp(['Saving: ',figName])
        saveas(gcf,figName);
    end
    
end

