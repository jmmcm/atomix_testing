%% test_DLL_calc_JMM
%
% Simplification of calc_level3_ATOMIX to calculate DLL for the variety of
% methods for one timestamp, on bin and one height above bottom. 
% 
% Good script for checking binPairs
% 
% Also compares result to Maricarmen G. Paris code
%
% Justine McMillan
% Jan 1, 2023

clear
set(0,'defaultLineLinewidth',2)

dirName = 'D:/ATOMIX/Data/RDIWH600_CANDYFLOSS_bedframe/Downloaded/RDIWH600_CANDYFLOSS_bedframe_BDS_M1aC_RM7p5';
matFile = dir([dirName '/*mat']);
matFileFull = [dirName '/' matFile.name];

load(matFileFull)

%%
indT = 1;
indB = 1;
zz = 3;

r = data.L2.Z_DIST/cosd(data.L2.THETA(indB));
dr = r(2) - r(1);

%% my calc
rmax = 3;
options.nbinMax = floor(rmax/dr)

methods = {'method 1','None';
           'method 2','None';
           'method 1','Average';
           'method 2','Average';
           'MGP','None'};
       
%% Debugging section (parts of calc_level3_ATOMIX)
for mm = 1:length(methods)
    
    options.diffMethod = methods{mm,1};
    options.methodMultDll = methods{mm,2};
    
    nBinMax = options.nbinMax;
    nBinMaxHalf = floor((nBinMax+1)/2); % number of bins from centre for centered schemes
    
    
    switch options.diffMethod
        case 'method 1' %classical method, i.e. 'central diff'
            binPairsAll = nchoosek([-nBinMaxHalf:0, 1:nBinMaxHalf],2);
            
            % Get centered values
            binMean = mean(binPairsAll,2);
            expMean = (options.nbinMax+1)/2;
            ind = find(binMean > -1 & binMean < 1);
            binPairsRel = binPairsAll(ind,:);
        case 'method 2' %JMM method, i.e. 'forward diff' (all possible separations)
            binPairsAll = nchoosek([-nBinMaxHalf:0, 1:nBinMaxHalf],2);
            binPairsRel = binPairsAll;
        case 'MGP' %Maricarmen Guerra Paris, Jim Thomson
            binPairsAll = nchoosek([-options.nbinMax:0, 1:options.nbinMax],2);
            ind = find( (binPairsAll(:,1) == 0) | (binPairsAll(:,2) == 0));
            binPairsRel = binPairsAll(ind,:);
        otherwise
            methods = {'method 1','method 2'};
            disp([options.diffMethod,' not valid. Options for diffMethod:'])
            for m = methods; disp([' - ',m{:}]); end
            error('options.diffMethod not valid...Quitting')
    end
    binDiff = binPairsRel(:,2) - binPairsRel(:,1);
    % Remove 1 bin separation (TODO: REMOVE) and bin pairs that exceed max specified separation (necessary if nbinMax is odd)
%     indKeep = find((binDiff >= 2) & (binDiff <= options.nbinMax));
    indKeep = find((binDiff <= options.nbinMax));

    binPairsRel = binPairsRel(indKeep,:);
    
    % Sort by separation (just for viewing purposes)
    [~,indSort] = sort(binPairsRel(:,2)-binPairsRel(:,1));
    binPairsRel = binPairsRel(indSort,:);
    
    % [binPairsRel binPairsRel(:,2)-binPairsRel(:,1)]
    
    % Get range bins to use
    NZ = 40;
    
    binPairs = binPairsRel + zz;
    
    binsToBot = (zz-1);
    binsToTop = (NZ-zz);
    binsFromC = max(abs(binPairsRel(:))); % from center (either 0.5*nBinMax or nBinMax, depending on method)
    
    minBin = max([1, zz-binsToTop,zz-binsFromC]);
    maxBin = min([NZ,zz+binsToBot,zz+binsFromC]);
    
    indBins = find((binPairs(:,1)>=minBin) & (binPairs(:,2)<=maxBin));
    binPairsIn = binPairs(indBins,:);
    [binPairsIn (binPairsIn(:,2) - binPairsIn(:,1))]
    
    
    % Get velocity timeseries for range bins
    vp = reshape(data.L2.R_VEL_DETRENDED(indT,:,indB,:),[NZ,300])';
    
    % Calculate SF parameters (i.e. r_del and DLL)
    [r_del,dll,dll_n,binPairsOut] = calc_DLL_DLLL(vp,binPairsIn,dr,options);
    
    binL = binPairsOut(:,1);
    binU = binPairsOut(:,2);
    summary = [r_del' r_del'/dr dll' dll_n' binL binU];
    
    out(mm).r_del = r_del;
    out(mm).dll = dll;
    out(mm).summary = summary;
    
end

%%
figure(1),clf
p(1) = plot(out(1).r_del/dr,out(1).dll,'.','markersize',10,'DisplayName',[methods{1,1},' ', methods{1,2}]);
hold all
p(2) = plot(out(2).r_del/dr,out(2).dll,'o','markersize',10,'DisplayName',[methods{2,1},' ', methods{2,2}]);
p(3) = plot(out(3).r_del/dr,out(3).dll,'^','markersize',10,'DisplayName',[methods{3,1},' ', methods{3,2}]);
p(4) = plot(out(4).r_del/dr,out(4).dll,'v','markersize',10,'DisplayName',[methods{4,1},' ', methods{4,2}]);
p(5) = plot(out(5).r_del/dr,out(5).dll,'v','markersize',10,'DisplayName',[methods{5,1},' ', methods{5,2}]);

legend(p)
out.summary

%% MGP calc
vp = squeeze(data.L2.R_VEL_DETRENDED(indT,:,indB,:));
[DLLmg,delRmg] = structure_function_MG(vp,r);



figure(2),clf

indR = find(abs(delRmg(zz,:))<rmax)
p2(1) = plot(abs(delRmg(zz,indR))/dr,DLLmg(zz,indR),'.','DisplayName','Maricarmen');
hold all
p2(2) = plot(out(1).r_del/dr,out(1).dll,'o','markersize',10,'DisplayName',[methods{1,1},' ', methods{1,2}]);
p2(3) = plot(out(2).r_del/dr,out(2).dll,'s','markersize',10,'DisplayName',[methods{2,1},' ', methods{2,2}]);
p2(4) = plot(out(5).r_del/dr,out(5).dll,'^','markersize',10,'DisplayName',[methods{5,1},' ', methods{5,2}]);

legend(p2)