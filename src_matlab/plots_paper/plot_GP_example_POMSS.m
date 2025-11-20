clear
addpath('functions')
addpath('../../../adcp_toolbox/matlab/')
addpath('../../../utilitieswork')
addpath('../../../netcdftools_ceb/variables_flags_databases/YAMLMatlab_0/')
set(0,'defaultfigurecolor',[1 1 1 ])
set(0,'defaultAxesXGrid','on')
set(0,'defaultAxesYGrid','on')

colors = get(0,'defaultaxescolororder');
%%
figDir = '/home/jmm000/work/ATOMIX/figures/presentation/';
figSave = 1;

%% L1 to L4 figures
% -------------------

dataSet = 'RDI4beam_TidalChannel_GP130620BPb';
processIDs = {'JMM_M1aC_RM5'};

%% load data
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

figure(1),clf
t1 = (data(1).L4.TIME - data(1).L4.TIME(1))*24;

ax(1) = subplot(211);
pcolor(t1,data.Ancillary.Z_DIST, data.Ancillary.SIGNED_SPEED')
shading flat
colormap(ax(1),cmocean('balance')); cb = colorbar; 
ylabel(cb,'signed speed [m/s]')
ylabel('z [m]')


ax(2) = subplot(212);
pcolor(t1,data.L4.Z_DIST, log10(data.L4.EPSI(:,:,1))')
caxis([-5.5 -3.5])
shading flat
colormap(ax(2), cmocean('thermal')); cb = colorbar; 
ylabel(cb,'log10(\epsilon_1) [W/kg]')
xlabel('time [hours]')
ylabel('z [m]')

saveas(gcf,[figDir,'GP_example.png']);

return
