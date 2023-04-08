clear

orig = load('D:\ATOMIX\Data\RDI4beam_TidalChannel_GP130620BPb\RDI4beam_TidalChannel_GP130620BPb_JMM_20230116_JMM_M2aC_RM5_orig.mat');
new = load('D:\ATOMIX\Data\RDI4beam_TidalChannel_GP130620BPb\RDI4beam_TidalChannel_GP130620BPb_JMM_20230116_JMM_M2aC_RM5.mat'); 

indB = 1;
indZ = 10;
indT = 11;
dr = new.data.L3.R_DIST(2) - new.data.L3.R_DIST(1);

%% New data
eN = new.data.L4.EPSI(indT,indZ,indB);

rdelN = new.data.L3.R_DEL(indB,:);
dllN = squeeze(new.data.L3.DLL(indT,:,indB,:));
dll_flagsN = squeeze(new.data.L3.DLL_FLAGS(indT,:,indB,:));
dllN = flag_data(dllN,dll_flagsN,0);

% Get fit values (from DLL and method)
optionsL4 = new.metadataGroups.L4; 
optionsL4.dll_averaging = str2num(optionsL4.dll_averaging);
binL = new.data.L3.BIN_L;
binU = new.data.L3.BIN_U;
[rfitN,dfitN,rfitNa,dfitNa,indDll,binPairs] = get_DLL_fit_data(indZ,rdelN,dllN,binL,binU,dr,optionsL4);

% Get fit values (saved in file)
rfitN2 = new.data.L4.REGRESSION_R_DEL{indT,indZ,indB};
dfitN2 = new.data.L4.REGRESSION_DLL{indT,indZ,indB};

[epsiN,sigmaN,R2,Rinfo] = calc_eps_SF(rfitN,dfitN,struct('order',2,'Const',2.0,'figure',0,'sigmaN_v',0.0464));

a=[binL(indDll); binU(indDll);rfitNa;dfitNa;dll_flagsN(indDll)]'

%%
rfitO = orig.data.L3.R_DEL(indB,:);
dfitO = squeeze(orig.data.L3.DLL(indT,indZ,indB,:));
binLO = squeeze(orig.data.L3.BIN_L(indT,indZ,indB,:));
binUO = squeeze(orig.data.L3.BIN_U(indT,indZ,indB,:));


dll_flagsO = squeeze(orig.data.L3.DLL_FLAGS(indT,indZ,indB,:));

indGood = find(~isnan(dfitO));
rfitOg = rfitO(indGood);
dfitOg = dfitO(indGood);
eO = orig.data.L4.EPSI(indT,indZ,indB);

[epsiO,sigmaN,R2,Rinfo] = calc_eps_SF(rfitOg,dfitOg',struct('order',2,'Const',2.0,'figure',0,'sigmaN_v',0.0464));


b=[binLO'; binUO';rfitO;dfitO';dll_flagsO']'

%%
figure(1),clf
ax = subplot(1,1,1);
% plot_DLL_fit(ax,orig.data.L3,orig.data.L4,options)
plot(rfitO.^(2/3),dfitO,'o')
hold all
plot(rfitN.^(2/3),dfitN,'d','markersize',10)
plot(rfitN2.^(2/3),dfitN2,'.','markersize',10)



%% 
figure(2),clf
plot(new.data.L4.EPSI(:,indZ,indB)-orig.data.L4.EPSI(:,indZ,indB))
shading flat
colorbar


figure(3),clf
pcolor(new.data.L4.EPSI(:,:,indB)'-orig.data.L4.EPSI(:,:,indB)')
shading flat
colorbar

%%
plotoptions = new.metadataGroups.L4;
plotoptions.indT = 1;
plotoptions.indB = 1;
plotoptions.indZ = 10;
figure(4),clf
ax = subplot(1,3,1);
plot_DLL_fit(ax,new.data.L3,new.data.L4,plotoptions)
ax = subplot(1,3,2);
plotoptions.indB = 3;
plot_DLL_fit(ax,new.data.L3,new.data.L4,plotoptions)
ax = subplot(1,3,3);

plot_DLL_compare(new.data.L3,new.data.L4,new.data.L3,new.data.L4,plotoptions)