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
%     processIDs = {'JMMd_M2uC_RM5','JMM_M2uC_RM5'}; % COmpare to downloaded data
%     processIDs = {'JMM_M1aC_RM5','JMM_M2aC_RM5','JMM_M2uC_RM5','JMM_M3uC_RM5'};
%     processIDs = {'JMM_M2uC_RM5','JMM_M3uC_RM5'};
%     processIDs = {'JMM_M1aC_RM5','JMM_M2uC_RM5'};


dataSet = 'RDIWH600_CANDYFLOSS_bedframe';
%     processIDs = {'BDS_M1aC_RM7p5','JMM_M1aC_RM7p5'};
%     processIDs = {'BDS_M2uC_RM7p5','JMM_M2uC_RM7p5_fromL2qc'};
%     processIDs = {'BDS_M2uC_RM7p5','JMM_M2uC_RM7p5'};
%      processIDs = {'JMM_M2uC_RM7p5','BDS_M1aC_RM7p5'};
%     processIDs = {'JMM_M1aC_RM7p5','JMM_M3uC_RM7p5'};
      processIDs = {'JMM_M1aC_RM7p5','JMM_M2uC_RM7p5'};

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
%       processIDs = {'JMM_M1aC_RM2','JMM_M2uC_RM2'}; % Compare methods 1a and 2u
%      processIDs = {'JMM_M1aC_RM2','JMM_M2aC_RM2'}; % Compare methods 1a and 2a
%      processIDs = {'JMM_M2aC_RM2','JMM_M2uC_RM2'}; % Compare methods 2a and 2u
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
figPath = ['../figures/',dataSet,'/',figDir,'/SFfits/'];
%% Plot
opts.indB = 1;
opts.indZ = 25;

[NT,NZ,NB] = size(data(1).L4.EPSI);
for tt = 2:NT
    opts.indT = tt;
   
    
    data(1).L4.procParams = d(1).metadataGroups.L4;
    data(2).L4.procParams = d(2).metadataGroups.L4;

    
    figure_named('DLL'),clf,clear ax
    set(gcf,'Position',[0,100,1200,600])
    axW = 1/length(processIDs)/2;
    axH = 0.7;
    axY = 0.2;
    
    ax(1) = subplot('Position',[0.10 axY axW axH]);
    opts.dll_averaging = d(1).metadataGroups.L4.dll_averaging;
    opts.rMin = d(1).metadataGroups.L4.rMin;
    opts.rMax = d(1).metadataGroups.L4.rMax;
    opts.points_select_method = d(1).metadataGroups.L4.points_select_method;
    [~,p1] = plot_DLL_fit(ax(1),data(1).L3,data(1).L4,opts);
    set(p1(2),'Marker','x','markersize',5,'color','k')
    title(ax(1),clean_string(names{1}))
    
    ax(2) = subplot('Position',[0.4 axY axW axH]);
    opts.dll_averaging = d(2).metadataGroups.L4.dll_averaging;
    opts.rMin = d(2).metadataGroups.L4.rMin;
    opts.rMax = d(2).metadataGroups.L4.rMax;
    opts.points_select_method = d(2).metadataGroups.L4.points_select_method;
    [~,p2]= plot_DLL_fit(ax(2),data(2).L3,data(2).L4,opts);
    set(p2(1),'Marker','s')
    set(p2(2),'Marker','x','markersize',3,'color','k')%[0.9290 0.6940 0.1250])
    title(ax(2),clean_string(names{2}))
    
    ax(3) = subplot('Position',[0.7 axY axW axH]);
    [p,pl]=plot_DLL_compare(data(1).L3,data(1).L4,data(2).L3,data(2).L4,opts);
%     set(p(1),'color',get(p1(2),'b'))
%     set(pl(1),'color',get(p1(2),'b'))
%     set(p(2),'color',get(p2(2),'r'))
%     set(pl(2),'color',get(p2(2),'r'))
    title(ax(3),'Comparison')
    
    ylabel(ax(2),'')
    ylabel(ax(3),'')
    linkaxes(ax,'xy')
    
    add_fig_info(mname,[dataSet,...
        ' ( indT = ',num2str(opts.indT),', ',...
        ' indZ = ',num2str(opts.indZ),...
        ',  indB = ',num2str(opts.indB),' )'],struct())
    

    text_rel_figure(0.05,0.95,['indT = ',num2str(tt),...
                             ', indZ = ',num2str(opts.indZ),...
                             ', indB = ',num2str(opts.indB)])
    
    ratio = data(2).L4.EPSI(tt,opts.indZ,opts.indB)/data(1).L4.EPSI(tt,opts.indZ,opts.indB);
    log10(ratio);
    data(1).L4.EPSI_CI_HIGH(tt,opts.indZ,opts.indB);
    data(1).L4.EPSI_CI_LOW(tt,opts.indZ,opts.indB);

    figName = [figPath,'z',num2str(opts.indZ,'%02d'),'/t_',num2str(tt,'%03d'),'.png'];
    disp(['Saving: ',figName])
    drawnow
    saveas(gcf,figName);
    
%     if tt == 1
%         gif(figName,'overwrite',true,'DelayTime',1/3);
%     else
%         gif
%     end
    
end