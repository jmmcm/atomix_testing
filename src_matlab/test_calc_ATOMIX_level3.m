%% test_calc_ATOMIX_level3.m
%
% Call to calc_level3_ATOMIX to calculate DLL for the variety of
% methods for one timestamp, on bin and one height above bottom. 
% 
% Good script for simple comparison of methods for different processing
% parameters.
%
% Justine McMillan
% Jan 1, 2023

clear
set(0,'defaultLineLinewidth',2)

matFileFull = 'D:/ATOMIX/Data/RDIWH600_CANDYFLOSS_bedframe/RDIWH600_CANDYFLOSS_bedframe_JMM_M1aC_RM7p5.mat';

load(matFileFull)



%% my calc
optionsLev3.order = 2;
optionsLev3.rMax = 7.5; 
optionsLev3.dr = (data.L1.Z_DIST(2) - data.L1.Z_DIST(1))/cosd(data.L1.THETA(1)); % Assumes all bins are the same size and all beam angles are the same
optionsLev3.nbinMax = floor(optionsLev3.rMax./optionsLev3.dr); % Max number of bins to use
optionsLev3.flagFile = fileInfo.flagFile;

methods = {'method 1','false';
           'method 2','false';
           'method 1','true';
           'method 2','true';
           'MGP','false'};
       
for mm = 1:length(methods)
    
    optionsLev3.diffMethod = methods{mm,1};
    optionsLev3.dllAvg = str2num(methods{mm,2});
    lev3(mm) = calc_level3_ATOMIX(data.L2,optionsLev3)
end    
%%
indZ = 4;
indB = 1;
indT = 1;

markers = {'.','o','s','^','v'};
figure(1),clf
c = 0
for pp = 1:5
    c = c +1;
    p(c) = plot(lev3(pp).R_DEL(indB,:)/optionsLev3.dr,squeeze(lev3(pp).DLL(indT,indZ,indB,:)),markers{pp},'markersize',10,'DisplayName',[methods{pp,1},' ', methods{pp,2}]);
    if c == 1; hold all; end
    
    r_del = lev3(pp).R_DEL(indB,:);
    dll = squeeze(lev3(pp).DLL(indT,indZ,indB,:));
    dll_n = squeeze(lev3(pp).DLL_N(indT,indZ,indB,:));
    dll_flags = squeeze(lev3(pp).DLL_FLAGS(indT,indZ,indB,:));
    binL = squeeze(lev3(pp).BIN_L(indT,indZ,indB,:));
    binU = squeeze(lev3(pp).BIN_U(indT,indZ,indB,:));
    [methods{pp,1},' ', methods{pp,2}]
    [r_del' r_del'/optionsLev3.dr binU-binL binL binU dll dll_n dll_flags]
end
legend(p)

