clear all
addpath('/home/jmm000/code/utilities/subaxis/')
mname = mfilename('fullpath');

%% 



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

%% Plot dissipation and speed

% indTall = []; % To override defaults
figure(1),clf,clear ax
set(gcf,'Name','EpsSpeed')
ax(1) = subaxis(3,1,1);
ax(2) = subaxis(3,1,3);
ax(3) = subaxis(3,1,2);
for dd = 1:3
    p = plot_epsi(ax(1),data(dd).L4,struct('indB',indB,'indZ',indZ,'col',colors{dd},'varX','index','marker','.'));
    set(p(1),'DisplayName',labels{dd})
    hold(ax(1),'on')
end
for tt = 1:length(indTall)
    plot(ax(1),[1 1]*indTall(tt),get(ax(1),'ylim'),'k','linewidth',1,'HandleVisibility','Off')
end
plot(ax(1), get(ax(1),'xlim'),0.1*d(1).metadataGroups.L4.sigmaN_v^3*[1 1],'--c','linewidth',2,'DisplayName','\epsilon_{min}')

set(ax(1),'yscale','log')
ylim(ax(1),limEpsi)
ylabel(ax(1),'\epsilon [W/kg]')

for dd = 1:3
    plot(ax(3),1:length(data(dd).Ancillary.TIME),data(dd).L4.EPSI_DEL_RATIO(:,indZ,indB)')
    hold(ax(3),'on')
end
for tt = 1:length(indTall)
    plot(ax(3),[1 1]*indTall(tt),get(ax(3),'ylim'),'k','linewidth',1)
end
plot(ax(3),get(ax(3),'xlim'),[1 1],'k','linewidth',1)
set(ax(3),'yscale','log')
ylabel(ax(3),'\Delta\epsilon/\epsilon')

speed = sqrt(data(1).Ancillary.ENU(:,:,1).^2 + data(1).Ancillary.ENU(:,:,2).^2);
pcolor(ax(2),1:length(data(1).Ancillary.TIME),1:length(data(1).Ancillary.Z_DIST),speed')
shading(ax(2),'flat')
colormap(cmocean('speed'))
p = get(ax(2),'Position');
c = colorbar('Position',[p(1)+p(3)+0.02 p(2) 0.01 p(4)]); 
hold(ax(2),'on')
for tt = 1:length(indTall)
    plot(ax(2),[1 1]*indTall(tt),get(ax(2),'ylim'),'k','linewidth',1)
end
plot(ax(2),get(ax(2),'xlim'),[1 1]*indZ,'k','linewidth',1)

ylabel(c,'speed [m/s]')
ylabel(ax(2),'z index')


xlabel(ax(2),'t index')

%shading(ax(3),'flat')
%caxis([0 1])
linkaxes(ax,'x')

% Plot SF Fit
for tt = 1:length(indTall)
    figure(1+tt),clf,clear ax
    set(gcf,'Name','SFfits')
    indT = indTall(tt);
    
    for pp = 1:5
        ax(pp) = subaxis(1,5,pp,'SpacingHoriz',0.02);
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
        title(ax(dd),{labels{dd},ax(dd).Title.String})
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



    end

    legend(ax(4),pAll)
    box(ax(4),'on')
    title(ax(4),{'Comparison',ax(4).Title.String})

    for pp = 2:4
        set(ax(pp),'yticklabels','')
        ylabel(ax(pp),'')
    end
    linkaxes(ax(1:4),'y')

    % Velocity profile
    axes(ax(5))
    dr = (data(1).L4.Z_DIST(2) - data(1).L4.Z_DIST(1))/cosd(data(1).L1.THETA(indB));
    cMax = floor(d(1).metadataGroups.L4.rMax/2/dr);

    z = data(1).Ancillary.Z_DIST;
    index = 1:length(z);

    % plot range of profile used
    dr = (data(1).L1.Z_DIST(2) - data(1).L1.Z_DIST(1))/cosd(data(1).L1.THETA(1));
    nMax(1) = floor(data(1).L4.R_MAX(opts.indT,opts.indZ,opts.indB)*1.000001 / dr /2); % Add very small percentage to RMAX to avoid rounding issues
    plot(speed(indT,opts.indZ-nMax(1):opts.indZ+nMax(1)), index(opts.indZ-nMax(1):opts.indZ+nMax(1)),'o-','color','#EDB120','linewidth',2)


    hold all
    scatter(speed(indT,:),index,35,index,'filled')
    caxis(opts.indZ+[-cMax-1 cMax+1])
    cmap = cmocean('balance','pivot',indZ)
    colormap(cmap)
    % colormap(cmocean('oxy',cMax*2,'pivot',indZ))
    c = colorbar;
    c.Position = [c.Position(1)+0.08 c.Position(2:4)];
    ylabel(c,'binL')
    plot(speed(indT,opts.indZ),index(opts.indZ),'*k')
    title('Speed Profile')
    xticks = get(gca,'xtick');
    yticks = get(gca,'ytick');
    ylabel(ax(5),'indZ')
    xlabel(ax(5),'speed [m/s]')

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
