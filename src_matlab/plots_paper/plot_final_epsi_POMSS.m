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
opts.indZ = 22;

%%
figure(1),clf
nanMask = ones(size(data.L4.EPSI));
ind = find(data.L4.EPSI_FLAGS>0);
nanMask(ind) = NaN;

epsiFlagged = data.L4.EPSI.*nanMask;
epsiMax = max(epsiFlagged,[],3,'omitnan');
epsiMin = min(epsiFlagged,[],3,'omitnan');


% t = (data.L4.TIME - data.L4.TIME(1))'*24 ;
t = 1:length(data.L4.TIME);
NP = 7;
ax0 = 0.05;
axW = 0.9;
axH = 0.44;
offset = 0.01;
y0 = 0.53;

axNum = 1;
ax(axNum) = axes('Position',[ax0 y0-0*(offset+axH) axW axH]);
pcolor(t,data.L4.Z_DIST,log10(data.L4.EPSI_FINAL(:,:))')
shading flat 
c = colorbar;
% tMat = ones(50,1)*t;
% zMat = data.L4.Z_DIST*ones(1,288);
% eMat = log10(data.L4.EPSI_FINAL(:,:))';
% scatter(tMat(:),zMat(:),30,eMat(:),'filled');
% c = colorbar;
ylabel(c,'log10(\epsilon_{Final} [W/kg]')
hold all
plot(get(gca,'xlim'),[1 1]*data.L4.Z_DIST(opts.indZ))
ylabel('z [m]')
set(gca,'Xticklabels',{})


axNum = 2;
ax(axNum) = axes('Position',[ax0 y0-1*(offset+axH) axW axH]);
plot(t,squeeze(epsiFlagged(:,opts.indZ,:)),'.-')
ylabel('\epsilon_i [W/kg]')
colorbar
hold all
plot(t,data.L4.EPSI_FINAL(:,opts.indZ),'-k','linewidth',3)
% semilogy(t,epsiMax(:,opts.indZ),'-k','linewidth',1)
% semilogy(t,epsiMin(:,opts.indZ),'-k','linewidth',1)

for ii = 2:288
    fill_between([t(ii-1:ii); t(ii-1:ii)], [epsiMin(ii-1:ii,opts.indZ) epsiMax(ii-1:ii,opts.indZ)]','r')
end
set(gca,'yscale','log')
linkaxes(ax,'x')
xlim([38 178])
xlabel('Segment')
ylabel('\epsilon [W/kg]')


figDir = '/home/jmm000/work/ATOMIX/figures/presentation/';
saveas(gcf,[figDir,'epsiFinal.png']);