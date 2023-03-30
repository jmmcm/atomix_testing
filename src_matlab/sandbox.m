clear

orig = load('D:\ATOMIX\Data\RDI4beam_TidalChannel_GP130620BPb\Downloaded\dJMM_M2uC_RM5\RDI4beam_TidalChannel_GP130620BPb_JMM_20230116.mat');
new = load('D:\ATOMIX\Data\RDI4beam_TidalChannel_GP130620BPb\RDI4beam_TidalChannel_GP130620BPb_JMM_20230116_JMM_M2uC_RM5.mat'); 

options.indB = 1;
options.indZ = 4;
options.indT = 1;

%% Put new into original format
dllN = squeeze(new.data.L3.DLL(options.indT,:,options.indB,:));
dll_flagsN = squeeze(new.data.L3.DLL_FLAGS(options.indT,:,options.indB,:));
dll_flagsNn = dll_flagsN;
dll_flagsN(dll_flagsN>0) = NaN;
dll_flagsN = dll_flagsN+1;
dllN = dllN.*dll_flagsN;

nBinMin = 2;
nBinMax = 9;
binL = squeeze(new.data.L3.BIN_L(options.indT,:,options.indB,:));
binU = squeeze(new.data.L3.BIN_U(options.indT,:,options.indB,:));
binPairs = get_DLL_fit_bin_pairs(nBinMin,nBinMax,'cloud',options.indZ,[1 50]);
indDll = get_DLL_fit_inds(binL,binU,binPairs);
[indDllRow,indDllCol] = ind2sub(size(dllN),indDll);

rfitN = new.data.L3.R_DEL(options.indB,indDllCol)
dfitN = dllN(indDll)
eN = new.data.L4.EPSI(options.indT,options.indZ,options.indB);

[epsiN,sigmaN,R2,Rinfo] = calc_eps_SF(rfitN,dfitN,struct('order',2,'Const',2.0,'figure',0,'sigmaN_v',0.0464));

a=[binL(indDll); binU(indDll);rfitN;dfitN;dll_flagsNn(indDll)]'

%%
rfitO = orig.data.L3.R_DEL(options.indB,:);
dfitO = squeeze(orig.data.L3.DLL(options.indT,options.indZ,options.indB,:));
binLO = squeeze(orig.data.L3.BIN_L(options.indT,options.indZ,options.indB,:));
binUO = squeeze(orig.data.L3.BIN_U(options.indT,options.indZ,options.indB,:));


dll_flagsO = squeeze(orig.data.L3.DLL_FLAGS(options.indT,options.indZ,options.indB,:));

indGood = find(~isnan(dfitO));
rfitOg = rfitO(indGood);
dfitOg = dfitO(indGood);
eO = orig.data.L4.EPSI(options.indT,options.indZ,options.indB);

[epsiO,sigmaN,R2,Rinfo] = calc_eps_SF(rfitOg,dfitOg',struct('order',2,'Const',2.0,'figure',0,'sigmaN_v',0.0464));


b=[binLO'; binUO';rfitO;dfitO';dll_flagsO']'

%%
figure(1),clf
ax = subplot(1,1,1);
% plot_DLL_fit(ax,orig.data.L3,orig.data.L4,options)
plot(rfitO.^(2/3),dfitO,'o')
hold all
plot(rfitN.^(2/3),dfitN,'d','markersize',10)


%% 
figure(2),clf
plot(new.data.L4.EPSI(:,options.indZ,options.indB)-orig.data.L4.EPSI(:,options.indZ,options.indB))
shading flat
colorbar


figure(3),clf
pcolor(new.data.L4.EPSI(:,:,options.indB)'-orig.data.L4.EPSI(:,:,options.indB)')
shading flat
colorbar


