%% test_DLL_calc_BDS.m
%
% Test Brian's computation of DLL because I was getting different values
% when comparing method M1aC. Turns out his flagging of data at level2
% results in lower DLL values even for the same time series. 
%
% Justine McMillan
% Jan 12, 2023

clear
mname = mfilename('fullpath');

dataSet = 'RDIWH600_CANDYFLOSS_bedframe';
dirName = 'D:/ATOMIX/Data/RDIWH600_CANDYFLOSS_bedframe/Downloaded/RDIWH600_CANDYFLOSS_bedframe_BDS_M1aC_RM7p5';
matFile = dir([dirName '/*mat']);
matFileFull = [dirName '/' matFile.name];

load(matFileFull)

%%
indT = 246; % There is a difference
% indT = 423; % No difference

indB = 1;
indZ = 17;
indR = 5; % Choose odd number for bin centered on indZ

%%
dr = (data.L1.Z_DIST(2) - data.L1.Z_DIST(1))/cosd(data(1).L1.THETA(indB));
rDelAll =  data.L3.R_DEL(indB,:);
rDel = data.L3.R_DEL(indB,indR);
nDel = rDel/dr;

DLLfile = data.L3.DLL(indT,indZ,indB,indR);

%% 
binL = round(indZ - nDel/2);
binU = round(indZ + nDel/2);
vL = squeeze(data.L2.R_VEL_DETRENDED(indT,binL,indB,:));
vU = squeeze(data.L2.R_VEL_DETRENDED(indT,binU,indB,:));
DLLcalc = nanmean((vU-vL).^2);

% Apply flags
flags = squeeze(data.L2.R_VEL_DETRENDED_FLAGS(indT,binL,indB,:));
vLqc = squeeze(data.L2.R_VEL_DETRENDED(indT,binL,indB,:));
vLqc(flags>0) = NaN;

flags = squeeze(data.L2.R_VEL_DETRENDED_FLAGS(indT,binU,indB,:));
vUqc = squeeze(data.L2.R_VEL_DETRENDED(indT,binU,indB,:));
vUqc(flags>0) = NaN;

DLLcalcQC = nanmean((vUqc-vLqc).^2);



%%
figure(1),clf

subplot(311)
plot(vL)
hold all
plot(vLqc)
ylabel('vdt [m/s]')
xlabel('index')
legend('vL','vLqc')
title(['binL = ',num2str(binL)])

subplot(312)
plot(vU)
hold all
plot(vUqc)
ylabel('vdt [m/s]')
legend('vU','vUqc')

xlabel('index')
title(['binU = ',num2str(binU)])


info = {['indT = ',num2str(indT)],...
    ['indZ = ',num2str(indZ)],...
    ['nR\_DEL = ',num2str(rDel/dr),' bins'],...
       ['DLL_{calc} = ',num2str(DLLcalc,'%4.3e'),' m^2/s^2'],...
       ['DLL_{calcQC} = ',num2str(DLLcalcQC,'%4.3e'),' m^2/s^2'],...
           ['DLL_{file} = ',num2str(DLLfile,'%4.3e'),' m^2/s^2'],...
};

%subplot(313)
annotation('textbox', [0.7, 0.35, 0, 0], 'String', info, 'FitBoxToText', 'on','HorizontalAlignment', 'right');
add_fig_info(mname,[dataSet],struct())


