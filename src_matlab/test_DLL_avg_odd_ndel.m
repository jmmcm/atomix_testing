%% test_DLL_avg_odd_ndel.m
%
% Test averaging options for odd bin separations
%
% Justine McMillan
% 2023-01-14

clear
mname = mfilename('fullpath');

%% load Brian's data
dirName = 'D:/ATOMIX/Data/RDIWH600_CANDYFLOSS_bedframe/Downloaded/BDS_M1aC_RM7p5';
matFile = dir([dirName '/*mat']);
matFileBDS = [dirName '/' matFile.name];

bds = load(matFileBDS);

%% load my data
dataSet = 'RDIWH600_CANDYFLOSS_bedframe';
processID = 'JMM_M1aC_RM7p5'; % To get flags and processing info
[dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet);
matFileJMM = [dataDir,dataFileRoot,'_',processID,'.mat'];

jmm = load(matFileJMM);

%%
data(1) = bds.data;
data(2) = jmm.data;
names = {'BDS_M1aC','JMM_M1aC'}

[NT,NZ,NB,NS] = size(data(1).L2.R_VEL_DETRENDED);
NR = length(data(1).L3.R_DEL);

%% Plot an example

if 1
    nDel = 5; % Even will be the same, odd will be different
    
    indT = 246;
    indZ = 11;
    indB = 1;
    
    if mod(nDel,2) == 0
        binL1 = indZ - nDel/2;
        binU1 = indZ + nDel/2;
        binL2 = [];
        binU2 = [];
    else
        binL1 = indZ - ceil(nDel/2);
        binU1 = indZ + floor(nDel/2);
        binL2 = indZ - floor(nDel/2);
        binU2 = indZ + ceil(nDel/2);
    end
    
    % Get flagged velocities (i.e. the ones saved in my file)
    vL1 = squeeze(data(2).L2.R_VEL_DETRENDED(indT,binL1,indB,:));
    vU1 = squeeze(data(2).L2.R_VEL_DETRENDED(indT,binU1,indB,:));
    vL2 = squeeze(data(2).L2.R_VEL_DETRENDED(indT,binL2,indB,:));
    vU2 = squeeze(data(2).L2.R_VEL_DETRENDED(indT,binU2,indB,:));
    
    % Caclulate DLL
    DeltaLoSq = (vU2 - vL2).^2;
    DeltaHiSq = (vU1 - vL1).^2;
    DLL.bds = data(1).L3.DLL(indT,indZ,indB,nDel-1);
    
    nDeltaLoSq = sum(~isnan(DeltaLoSq))
    nDeltaHiSq = sum(~isnan(DeltaHiSq))
    nSumDeltaSq = sum(~isnan(DeltaLoSq'+DeltaHiSq'))
    
    DLL.calcBDS = 0.5*(nanmean(DeltaLoSq'+DeltaHiSq')); % BDS method (this one agrees with the file and is what is plotted)
%     DLL.calcBDS = 0.5*(nanmean(nansum([DeltaLoSq';DeltaHiSq']))); % BDS method (just trying this method)
    
    DLL.jmm = data(2).L3.DLL(indT,indZ,indB,nDel-1);
    DLL.calcJMM = 0.5*(nanmean(DeltaLoSq)+nanmean(DeltaHiSq)); % JMM method
    
    %%
    figure(1),clf
    set(gcf,'Position',[100 100 1000 400])
    ax1 = subplot(1,2,1)
    p1 = semilogy(data(1).L4.EPSI(:,indZ,indB),'linewidth',2);
    hold all
    p2 = semilogy(data(2).L4.EPSI(:,indZ,indB),'linewidth',2);
    plot(indT*[1 1],get(gca,'ylim'),'--k')
    legend(clean_string(names{1}),clean_string(names{2}),'location','southeast')
    ylabel('\epsilon [W/kg]')
    title(['indT = ',num2str(indT),', indZ = ',num2str(indZ)])
    ylim([1e-9 1e-5])
    xlim(indT+[-50 50])
    xlabel('N\_SEGMENT')
    
    ax2 = subplot(1,2,2);
    dr = data(1).L3.R_DEL(indB,2) - data(1).L3.R_DEL(indB,1);
    indR = find(data(1).L3.R_DEL(indB,:)<data(1).L4.R_MAX(indT,indZ,indB));
    plot(data(1).L3.R_DEL(indB,indR)/dr,squeeze(data(1).L3.DLL(indT,indZ,indB,indR)),'o',...
        'color',get(p1,'color'),'linewidth',2)
    hold all
    plot(data(2).L3.R_DEL(indB,indR)/dr,squeeze(data(2).L3.DLL(indT,indZ,indB,indR)),'s',...
        'color',get(p2,'color'),'linewidth',2,'Markersize',12)
    ylabel('D_{LL} [m^2 s^{-2}]')
    xlabel('\delta [bins]')
    legend(clean_string(names{1}),clean_string(names{2}),'location','southeast')
    try
        plot(data(1).L3.R_DEL(indB,nDel-1)/dr,data(1).L3.DLL(indT,indZ,indB,nDel-1),...
            '^','markersize',15,'linewidth',2)
    end
    try
        plot(data(2).L3.R_DEL(indB,nDel-1)/dr,data(2).L3.DLL(indT,indZ,indB,nDel-1),...
            'v','markersize',15,'linewidth',2)
    end
    add_fig_info(mname,[dataSet],struct())
    
    %%
    figure(2),clf
    set(gcf,'Position',[100 100 900 600])
    subplot(411)
    pos = get(gca,'Position');
    plot([vL1+0.4 vU1+0.3 vL2+0.1 vU2+0.0])
    legend( ['v_{',num2str(binL1),'}+0.4'],...
        ['v_{',num2str(binU1),'}+0.3'],...
        ['v_{',num2str(binL2),'}+0.1'],...
        ['v_{',num2str(binU2),'}+0.0'],...
        'location','eastoutside')
    set(gca,'Position',[pos(1)-0.05 pos(2) 0.57 pos(4)])
    ylabel('[m/s]')
    ylim([-0.1 0.5])
    
    subplot(412)
    pos = get(gca,'Position');
    plot([DeltaLoSq DeltaHiSq])
    hold all
    plot(get(gca,'xlim'),nanmean(DeltaLoSq)+nanmean(DeltaHiSq)*[1 1],'-')
    legend(['\Delta_{lo}^2 = (v_{',num2str(binU2),'} - v_{',num2str(binL2),'})^2 (<> = ',num2str(nanmean(DeltaLoSq)),'), N = ',num2str(nDeltaLoSq)],...
        ['\Delta_{hi}^2 = (v_{',num2str(binU1),'} - v_{',num2str(binL1),'})^2 (<> = ',num2str(nanmean(DeltaHiSq)),'), N = ',num2str(nDeltaHiSq)],...
        ['<\Delta_{lo}^2>+<\Delta_{hi}^2> = ',num2str(nanmean(DeltaLoSq)+nanmean(DeltaHiSq))]',...
        'location','eastoutside')
    set(gca,'Position',[pos(1)-0.05 pos(2) 0.57 pos(4)])
    
    ylabel('[m^2/s^2]')
    annotation('textbox', [0.08, 0.61, 0, 0.1], 'String', 'JMM Method','FitBoxToText', 'on','Linestyle','none','Fontweight','bold');
    
    subplot(413)
    pos = get(gca,'Position');
    
    plot(DeltaLoSq+DeltaHiSq)
    hold all
    plot(get(gca,'xlim'),nanmean(DeltaLoSq+DeltaHiSq)*[1 1],'-')
    legend(['  \Delta_{lo}^2 + \Delta_{hi}^2, N = ',num2str(nSumDeltaSq)],...
        ['< \Delta_{lo}^2 + \Delta_{hi}^2 > = ',num2str(nanmean(DeltaLoSq  +DeltaHiSq)) ],...
        'location','eastoutside')
    set(gca,'Position',[pos(1)-0.05 pos(2) 0.57 pos(4)])
    
    xlabel('N\_SAMPLE')
    ylabel('[m^2/s^2]')
    annotation('textbox', [0.08, 0.39, 0, 0.1], 'String', 'BDS Method','FitBoxToText', 'on','Linestyle','none','Fontweight','bold');
    
    
    
    textStr = {
        '===CHECK===',...
        ['2 x JMM =  <\Delta_{lo}>+<\Delta_{hi}>  = ',num2str(2*DLL.jmm)],...
        ['2 x BDS =  <\Delta_{lo}  +  \Delta_{hi}>   = ',num2str(2*DLL.bds)],...
        };
    annotation('textbox', [0.3, 0.2, 0, 0], 'String', textStr, 'FitBoxToText', 'on');
    add_fig_info(mname,[dataSet],struct())
    
    DLL
end

%% Get statistics on different methods
indT = 100;
indB = 2;
vp = squeeze(data(2).L2.R_VEL_DETRENDED(indT,:,indB,:));
DLLfileBDS = squeeze(data(1).L3.DLL(indT,:,indB,:));
DLLfileJMM = squeeze(data(2).L3.DLL(indT,:,indB,:));

n = [1:NZ]';
delta = 2:NR+1;
binUlo = n*ones(1,NR)+ones(NZ,1)*floor(delta/2);
binLlo = n*ones(1,NR)-ones(NZ,1)*ceil(delta/2);
binUhi = n*ones(1,NR)+ones(NZ,1)*ceil(delta/2);
binLhi = n*ones(1,NR)-ones(NZ,1)*floor(delta/2);

DeltaLoSq  = NaN*ones(NZ,NR,NS);
DeltaHiSq  = NaN*ones(NZ,NR,NS);
sumDeltaSq = NaN*ones(NZ,NR,NS);
nDeltaLoSq = NaN*ones(NZ,NR);
nDeltaHiSq = NaN*ones(NZ,NR);
nSumDeltaSq = NaN*ones(NZ,NR);

DLLcalcBDS = NaN*ones(NZ,NR);
DLLcalcJMM = NaN*ones(NZ,NR);
for zz = 1:NZ
    
    % DeltaLo and DeltaHi
    indGoodLo = find(binLlo(zz,:)>0 & binUlo(zz,:)<=NZ);
    DeltaLoSq(zz,indGoodLo,:) = (vp(binUlo(zz,indGoodLo),:) - vp(binLlo(zz,indGoodLo),:)).^2;
    indGoodHi = find(binLhi(zz,:)>0 & binUhi(zz,:)<=NZ);
    DeltaHiSq(zz,indGoodHi,:) = (vp(binUhi(zz,indGoodHi),:) - vp(binLhi(zz,indGoodHi),:)).^2;
    sumDeltaSq(zz,:,:) = DeltaLoSq(zz,:,:) + DeltaHiSq(zz,:,:);
    
    % Number of points
    nDeltaLoSq(zz,:) = sum(~isnan(DeltaLoSq(zz,:,:)),3);
    nDeltaHiSq(zz,:) = sum(~isnan(DeltaHiSq(zz,:,:)),3);
    nSumDeltaSq(zz,:) = sum(~isnan(sumDeltaSq(zz,:,:)),3);
    
    % DLL
    DLLcalcBDS(zz,:) = 0.5*nanmean(sumDeltaSq(zz,:,:),3);
    DLLcalcJMM(zz,:) = 0.5*(nanmean(DeltaLoSq(zz,:,:),3) + nanmean(DeltaHiSq(zz,:,:),3));

end

diffBDS = DLLfileBDS - DLLcalcBDS;
diffJMM = DLLfileJMM - DLLcalcJMM(:,1:length(data(2).L3.R_DEL));

if nansum(abs(diffBDS))>1e-6
    error('BDS DLL values do not agree with those in file')
end
if nansum(abs(diffJMM))>1e-6
    error('JMM DLL values do not agree with those in file')
end

indDelEven = 1:2:NR;
indDelOdd = 2:2:NR;

%% plot
figure(3),clf
axmin = min([min(DLLcalcBDS(:)),min(DLLcalcJMM(:))])*0.9;
axmax = max([max(DLLcalcBDS(:)),max(DLLcalcJMM(:))])*1.1;

subplot(221)
plot(DLLcalcBDS(:,indDelEven),DLLcalcJMM(:,indDelEven),'.')
hold all
plot([axmin axmax],[axmin axmax],'k')
plot([axmin axmax],[axmin axmax],'k')

xlabel('DLL BDS [m^2/s^2]')
ylabel('DLL JMM [m^2/s^2]')
xlim([axmin axmax])
ylim([axmin axmax])
title('\delta is even')



subplot(222)
plot(DLLcalcBDS(:,indDelOdd),DLLcalcJMM(:,indDelOdd),'.')
hold all
plot([axmin axmax],[axmin axmax],'k')

xlabel('DLL BDS [m^2/s^2]')
ylabel('DLL JMM [m^2/s^2]')
xlim([axmin axmax])
ylim([axmin axmax])
title('\delta is odd')

subplot(223)
plot([0:300],[0:300],'k')
hold all
plot(nSumDeltaSq(:,indDelEven),nDeltaLoSq(:,indDelEven),'r.')
plot(nSumDeltaSq(:,indDelEven),nDeltaHiSq(:,indDelEven),'b.')
legend('1:1','\Delta_{lo}^2','\Delta_{hi}^2','location','southeast')
xlabel('N for (\Delta_{lo}^2 + \Delta_{hi}^2) calc')
ylabel('N for (\Delta_{lo}^2) and (\Delta_{hi}^2) calc')

subplot(224)
plot([0:300],[0:300],'k')
hold all
plot(nSumDeltaSq(:,indDelOdd),nDeltaLoSq(:,indDelOdd),'r.')
plot(nSumDeltaSq(:,indDelOdd),nDeltaHiSq(:,indDelOdd),'b.')
legend('1:1','\Delta_{lo}^2','\Delta_{hi}^2','location','southeast')
xlabel('N for (\Delta_{lo}^2 + \Delta_{hi}^2) calc')
ylabel('N for (\Delta_{lo}^2) and (\Delta_{hi}^2) calc')

add_fig_info(mname,[dataSet,...
        ' ( indT = ',num2str(indT),', ',...
        ',  indB = ',num2str(indB),' )'],struct())


