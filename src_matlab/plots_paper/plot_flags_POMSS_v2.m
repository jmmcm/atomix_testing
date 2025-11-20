clear all

%%

% dataSet = 'AQD_NorthSea_bedframe';
% processIDs = {'JMM_M1aC_RM0p3'};

dataSet = 'AQD_Windermere_bedframe';
processIDs = {'JMM_M1aC_RM2'};

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
opts.indZ = 16;


%%
figure(1),clf
set(gcf,'Position',[50 100 1400 800])
t = 1:length(data.L4.TIME);
NP = 7;
ax0 = 0.05;
axW = 0.9;
axH = 0.125;
offset = 0.01;
y0 = 0.86;

axNum = 1;
ax(axNum) = axes('Position',[ax0 y0 axW axH]);
semilogy(t,squeeze(data.L4.EPSI(:,opts.indZ,:)),'.-')
ylabel('\epsilon_i [W/kg]')


axNum = axNum+1;
ax(axNum) = axes('Position',[ax0 y0-axH-offset axW axH]);
plot(t,squeeze(data.L4.REGRESSION_COEFF_A1(:,opts.indZ,:)),'.-')
ylabel('slope [m^3 s^{-2}]')
hold all
fill_transparent(get(gca,'xlim'),[-1e-5 0],'r')
text(1,-1e-3,['Flag Mask = ',num2str(flags.L4.EPSI_FLAGS.dll_slope_out_of_range.mask)])


axNum = axNum+1;
ax(axNum) = axes('Position',[ax0 y0-2*(axH+offset) axW axH]);
plot(t,squeeze(data.L4.REGRESSION_N(:,opts.indZ,:)),'.-')
hold all
fill_transparent(get(gca,'xlim'),[0 3],'r')
ylabel('N')
text(1,5,['Flag Mask = ',num2str(flags.L4.EPSI_FLAGS.regression_poorly_conditioned.mask)])


axNum = axNum+1;
ax(axNum) = axes('Position',[ax0 y0-3*(axH+offset) axW axH]);
plot(t,squeeze(data.L4.REGRESSION_COEFF_A0(:,opts.indZ,:))/ (flags.L4.EPSI_FLAGS.dll_intercept_too_high.threshold/2),'.-')
hold all
fill_transparent(get(gca,'xlim'),[-0.1 0],'r')
fill_transparent(get(gca,'xlim'),[2 10],'r')
ylabel('A_0/2\sigma^2')
text(1,1.5,['Flag Masks = ',num2str(flags.L4.EPSI_FLAGS.dll_intercept_too_high.mask), ', ',num2str(flags.L4.EPSI_FLAGS.dll_intercept_too_low.mask)])


axNum = axNum+1;
ax(axNum) = axes('Position',[ax0 y0-4*(axH+offset) axW axH]);
plot(t,squeeze(data.L4.EPSI_DEL_RATIO(:,opts.indZ,:)),'.-')
hold all
ylim = get(gca,'ylim');
fill_transparent(get(gca,'xlim'),[flags.L4.EPSI_FLAGS.delta_epsi_too_large.threshold ylim(2)],'r')
set(gca,'yscale','log'); set(ax(axNum),'Ytick',[0.1,1,10,100]); set(ax(axNum),'Yticklabels',{'0.1','1','10','100'});
ylabel('\Delta \epsilon/\epsilon')
% grid minor
ax(axNum).YMinorGrid = 'off';
ax(axNum).XMinorGrid = 'off';
text(1,500,['Flag Mask = ',num2str(flags.L4.EPSI_FLAGS.delta_epsi_too_large.mask)])

axNum = axNum+1;
ax(axNum) = axes('Position',[ax0 y0-5*(axH+offset) axW axH]);
plot(t,squeeze(data.L4.REGRESSION_R2(:,opts.indZ,:)),'.-')
hold all
ylim = get(gca,'ylim');
fill_transparent(get(gca,'xlim'),[0 flags.L4.EPSI_FLAGS.Rsquared_too_low.threshold],'r')
ylabel('R^2')
text(1,0.2,['Flag Mask = ',num2str(flags.L4.EPSI_FLAGS.Rsquared_too_low.mask)])


axNum = axNum+1;
ax(axNum) = axes('Position',[ax0 y0-6*(axH+offset) axW 1*axH]);
% plot(ax(axNum),t,squeeze(data.L4.EPSI_FLAGS(:,opts.indZ,:)),'.')
% set(ax(axNum),'Ytick',[0,2,4,8,16,32,64,128])

plot(ax(axNum),t,squeeze(log2(data.L4.EPSI_FLAGS(:,opts.indZ,:))),'.')
set(ax(axNum),'Ytick',[0,1,2,3,4,5,6,7,8])
set(ax(axNum),'Yticklabels',{'0','2','4','8','16','32','64','128','256'})
% set(ax(axNum),'ylim',[0 32])
ylabel('Boolean Flag')
xlabel('Segment')


% axIn = axes('Position',[0.6 0.2 0.3 0.1]);
% plot(axIn,t,squeeze(data.L4.EPSI_FLAGS(:,opts.indZ,:)),'.')
% set(axIn,'Ytick',[32,64,128])
% set(axIn,'ylim',[32 128])
% xlabel(axIn,'segment')
% set(axIn,'xlim',[0 120])

linkaxes(ax,'x')
for aa = 1:6
    set(ax(aa),'Xticklabels',{})
end
% set(ax(axNum),'xlim',[0 120])

figDir = '/home/jmm000/work/ATOMIX/figures/presentation/';
saveas(gcf,[figDir,'flags2.png']);


