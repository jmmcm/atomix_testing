clear all

%%

dataSet = 'RDI4beam_TidalChannel_GP130620BPb';
processIDs = {'JMM_M2uC_RM5'};

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
opts.indB = 1;
opts.indZ = 17;
opts.dll_averaging = d(1).metadataGroups.L4.dll_averaging;
opts.points_select_method = d(1).metadataGroups.L4.points_select_method;

opts.rMin = d(1).metadataGroups.L4.rMin;
opts.rMax = d(1).metadataGroups.L4.rMax;
%%

figure(1),clf
% set(gcf, 'DefaultTextBackgroundColor', [1,1,1])


set(gcf,'Position',[0,100,1200,600])
axW = 0.3;
offset = 0.01;
axH = 0.7;
axY = 0.15;
x0 = 0.08;

ax(1) = subplot('Position',[x0 axY axW axH]);
opts.indT = 3;
[~,p1,t1] = plot_DLL_fit(ax(1),data(1).L3,data(1).L4,opts);
% caxis(opts.indZ+[-cMax cMax])
colormap(cmocean('balance'))
plot(ax(1),0,2*d.metadataGroups.L4.sigmaN_v^2,'s','Markersize',8,...
    'Color',[0 0.5 0],'MarkerFaceColor',[0 0.5 0],'DisplayName','2\sigma_N^2')

ax(2) = subplot('Position',[x0+offset+axW axY axW axH]);
opts.indT = 33;
[~,p2,t2] = plot_DLL_fit(ax(1),data(1).L3,data(1).L4,opts);
% caxis(opts.indZ+[-cMax cMax])
colormap(cmocean('balance'))
set(ax(2),'ylim',[3.8e-3 5.4e-3])
plot(ax(2),0,2*d.metadataGroups.L4.sigmaN_v^2,'s','Markersize',8,...
    'Color',[0 0.5 0],'MarkerFaceColor',[0 0.5 0],'DisplayName','2\sigma_N^2')

ax(3) = subplot('Position',[x0+2*offset+2*axW axY axW axH]);
opts.indT = 35;
[~,p3,t3] = plot_DLL_fit(ax(1),data(1).L3,data(1).L4,opts);
% caxis(opts.indZ+[-cMax cMax])
colormap(cmocean('balance'))
set(ax(3),'ylim',[3.8e-3 5.4e-3])
plot(ax(3),0,2*d.metadataGroups.L4.sigmaN_v^2,'s','Markersize',8,...
    'Color',[0 0.5 0],'MarkerFaceColor',[0 0.5 0],'DisplayName','2\sigma_N^2')

try
    delete(p1(2))
    delete(p2(2))
    delete(p3(2))
    
%     ylim(ax(3),[0 0.016])

%     set(p1(2),'Marker','x','markersize',1,'color','k')
end

% Position text
t1.Position = [0.1 0.016];
t2.Position = [0.1 5.2e-3];
t3.Position = [1.5 5.3e-3];

