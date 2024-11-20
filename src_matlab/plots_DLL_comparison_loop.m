%% Script to compare data from tests
%
% Justine McMillan
% Jan 23, 2023

clear all
mname = mfilename('fullpath');

set(0,'defaultfigurecolor',[1 1 1 ])
set(0,'defaultAxesXGrid','on')
set(0,'defaultAxesYGrid','on')

%% Select dataset and process IDs
% dataSet = 'RDI4beam_TidalChannel_GP130620BPb';
% %     processIDs = {'JMMd_M2uC_RM5','JMM_M2uC_RM5'}; % COmpare to downloaded data
% %     processIDs = {'JMM_M1aC_RM5','JMM_M2aC_RM5','JMM_M2uC_RM5','JMM_M3uC_RM5'};
% %     processIDs = {'JMM_M2uC_RM5','JMM_M3uC_RM5'};
%     processIDs = {'JMM_M1aC_RM5','JMM_M2uC_RM5'};


% dataSet = 'RDIWH600_CANDYFLOSS_bedframe';
% %     processIDs = {'BDS_M1aC_RM7p5','JMM_M1aC_RM7p5'};
% %     processIDs = {'BDS_M2uC_RM7p5','JMM_M2uC_RM7p5_fromL2qc'};
% %     processIDs = {'BDS_M2uC_RM7p5','JMM_M2uC_RM7p5'};
% %      processIDs = {'JMM_M2uC_RM7p5','BDS_M1aC_RM7p5'};
% %     processIDs = {'JMM_M1aC_RM7p5','JMM_M3uC_RM7p5'};
%       processIDs = {'JMM_M1aC_RM7p5','JMM_M2uC_RM7p5'};

%     processIDs = {'JMM_M1aC_RM7p5','JMM_M2aC_RM7p5','JMM_M2uC_RM7p5','JMM_M3uC_RM7p5'};

% dataSet = 'RDIWH600_CANDYFLOSS_TOP';
%     processIDs = {'BDS_M1aC_RM1p5','JMM_M1aC_RM1p5'};
%     processIDs = {'BDS_M2uC_RM1p5','JMM_M2uC_RM1p5'};
%     processIDs = {'JMM_M1aC_RM1p5','JMM_M2uC_RM1p5'};

% dataSet = 'Signature5beam_TidalShelf';
%     processIDs = {'JMM_M2aC_RM2','JMM_M2uC_RM2'}; % Compare methods 2a and 2u
%     processIDs = {'JMM_M2uC_RM2','JMM_M2uC_RM4'}; % Compare rmax
%     processIDs = {'JMM_M1aC_RM4','JMM_M2uC_RM4'}; % Compare methods 1a and 2u

% dataSet = 'AQD_Windermere_bedframe';
%        processIDs = {'JMM_M1aC_RM2','JMM_M2uC_RM2'}; % Compare methods 1a and 2u
%      processIDs = {'JMM_M1aC_RM2','JMM_M2aC_RM2'}; % Compare methods 1a and 2a
%      processIDs = {'JMM_M2aC_RM2','JMM_M2uC_RM2'}; % Compare methods 2a and 2u

dataSet = 'NortekSig1000_TidalChannel_2019_Burst';
    processIDs = {'JMM_M1aC_RM5','JMM_M2uC_RM5'}; % Compare methods 1a and 2u
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

%%
figDir=[processIDs{1},'_vs_',processIDs{2}];
% figPath = ['../figures/',dataSet,'/',figDir,'/SFfits/'];
figPath = ['/home/jmm000/work/ATOMIX/figures/',dataSet,'/',figDir,'/SFfits/'];

%% Plot
opts.indB = 5;
opts.indZ = 10;
dr = (d(1).data.L1.Z_DIST(2) - d(1).data.L1.Z_DIST(1))/cosd(d(1).data.L1.THETA(opts.indB))
cMax = floor(d(1).metadataGroups.L4.rMax/2/dr);

[NT,NZ,NB] = size(data(1).L4.EPSI);
for tt = 88:NT
    opts.indT = tt;
   
    
    data(1).L4.procParams = d(1).metadataGroups.L4;
    data(2).L4.procParams = d(2).metadataGroups.L4;

    
    figure_named('DLL'),clf,clear ax
%     figure('Visible','off'), clf,clear ax
    set(gcf,'Position',[0,100,1200,600])
    axW = 0.18;
    offset = 0.06;
    axH = 0.7;
    axY = 0.15;
    x0 = 0.05;
    
    ax(1) = subplot('Position',[x0 axY axW axH]);
        [p,pl]=plot_DLL_compare(data(1).L3,data(1).L4,data(2).L3,data(2).L4,opts);
%     set(p(1),'color',get(p1(2),'b'))
%     set(pl(1),'color',get(p1(2),'b'))
%     set(p(2),'color',get(p2(2),'r'))
%     set(pl(2),'color',get(p2(2),'r'))
    title(ax(1),'Comparison')
    
    
    
    ax(2) = subplot('Position',[x0+offset+axW axY axW axH]);
    opts.dll_averaging = d(1).metadataGroups.L4.dll_averaging;
    opts.rMin = d(1).metadataGroups.L4.rMin;
    opts.rMax = d(1).metadataGroups.L4.rMax;
    opts.points_select_method = d(1).metadataGroups.L4.points_select_method;
    [~,p1,t1] = plot_DLL_fit(ax(1),data(1).L3,data(1).L4,opts);
    caxis(opts.indZ+[-cMax cMax])
    colormap(cmocean('balance'))
    try
        set(p1(2),'Marker','x','markersize',5,'color','k')
    end
    title(ax(2),clean_string(names{1}))
    
    
    
    ax(3) = subplot('Position',[x0+2*(offset+axW) axY axW axH]);
    opts.dll_averaging = d(2).metadataGroups.L4.dll_averaging;
    opts.rMin = d(2).metadataGroups.L4.rMin;
    opts.rMax = d(2).metadataGroups.L4.rMax;
    opts.points_select_method = d(2).metadataGroups.L4.points_select_method;
    [~,p2,t2]= plot_DLL_fit(ax(2),data(2).L3,data(2).L4,opts);
    caxis(opts.indZ+[-cMax cMax])
    colormap(cmocean('balance'))
    set(p2(1),'Marker','s')
    set(p2(2),'Marker','x','markersize',3,'color','k')%[0.9290 0.6940 0.1250])
    title(ax(3),clean_string(names{2}))
    
    % Velocity profile
    ax(4) = subplot('Position',[x0+3*(offset+axW) axY axW axH]);
    
    if ~strcmp(dataSet,'AQD_Windermere_bedframe') % ENU has wrong dimensions for AQD data
        speed = sqrt(data(1).Ancillary.ENU(opts.indT,:,1).^2 + data(1).Ancillary.ENU(opts.indT,:,2).^2);

        speed = sqrt(data(1).Ancillary.ENU(opts.indT,:,1).^2 + data(1).Ancillary.ENU(opts.indT,:,2).^2);
        
        z = data(1).Ancillary.Z_DIST;
        index = 1:length(z);
        
        % plot range of profile used
         dr = (data(1).L1.Z_DIST(2) - data(1).L1.Z_DIST(1))/cosd(data(1).L1.THETA(1));
         nMax(1) = floor(data(1).L4.R_MAX(opts.indT,opts.indZ,opts.indB) / dr /2);
         plot(speed(opts.indZ-nMax(1):opts.indZ+nMax(1)), index(opts.indZ-nMax(1):opts.indZ+nMax(1)),'o-','color','#EDB120','linewidth',2)
         
        
        hold all
%         plot(speed,index,'linewidth',2)
        scatter(speed,index,35,index,'filled')
        caxis(opts.indZ+[-cMax cMax])
        colormap(cmocean('balance'))
%         % plot center point
        plot(speed(opts.indZ),index(opts.indZ),'*k')
        
    end
    title('Speed Profile')
    yticks = get(gca,'ytick');
    ylabel(ax(4),'indZ')
    
    ax2 = axes(gcf,'position',get(ax(4),'Position'),'color','none');
    set(ax2,'YAxisLocation','right')
    set(ax2,'xlim',get(ax(4),'xlim'))
    set(ax2,'ylim',get(ax(4),'ylim'))
    dz = data(1).L1.Z_DIST(2)-data(1).L1.Z_DIST(1);
    set(ax2,'YTickLabels',strsplit(num2str(yticks*dz)))
    ylabel(ax2,'z [m]')
    

    
    ylabel(ax(2),'')
    ylabel(ax(3),'')
    
    xlabel(ax(4),'speed [m/s]')
    linkaxes(ax(1:3),'xy')
    ylim = get(ax(1),'ylim');
    t1.Position = [0 ylim(2)];
    t2.Position = [0 ylim(2)];
    
    
    
    add_fig_info(mname,[dataSet,...
        ' ( indT = ',num2str(opts.indT),', ',...
        ' indZ = ',num2str(opts.indZ),...
        ',  indB = ',num2str(opts.indB),' )'],struct())
    

    text_rel_figure(0.05,0.97,['indT = ',num2str(tt),...
                             ', indZ = ',num2str(opts.indZ),...
                             ', indB = ',num2str(opts.indB)])
    
    ratio = data(2).L4.EPSI(tt,opts.indZ,opts.indB)/data(1).L4.EPSI(tt,opts.indZ,opts.indB);
    log10(ratio);
    data(1).L4.EPSI_CI_HIGH(tt,opts.indZ,opts.indB);
    data(1).L4.EPSI_CI_LOW(tt,opts.indZ,opts.indB);

    figPathFull = [figPath,'z',num2str(opts.indZ,'%02d'),'/'];
    figName = [figPathFull 't_',num2str(tt,'%03d'),'.png'];
    disp(['Saving: ',figName])
    drawnow
    if ~exist(figPathFull)
        disp(['Making ' figPathFull])
        mkdir(figPathFull)
    end
    saveas(gcf,figName);
    
%     if tt == 1
%         gif(figName,'overwrite',true,'DelayTime',1/3);
%     else
%         gif
%     end
    
end