clear

dirName = 'D:/ATOMIX/Data/RDIWH600_CANDYFLOSS_bedframe/Downloaded/RDIWH600_CANDYFLOSS_bedframe_BDS_M1aC_RM7p5';
matFile = dir([dirName '/*mat']);
matFileFull = [dirName '/' matFile.name];

load(matFileFull)

%%
indT = 1;
indB = 1;
zz = 10;

vp = squeeze(data.L2.R_VEL_DETRENDED(indT,:,indB,:));
r = data.L2.Z_DIST/cosd(data.L2.THETA(indB));
dr = r(2) - r(1);

%% MG calc
%[DLL,delR] = structure_function_MG(vp,r);

%% my calc
rmax = 4.5;
options.nbinMax = floor(rmax/dr)
options.diffMethod = 'method 2';
options.methodMultDll = 'None';

switch options.diffMethod
    
	case 'method 1' %classical method, i.e. 'central diff'
        binPairs = nchoosek([1:max(options.nbinMax)],2);
        
        % Get centered values
        binMean = mean(binPairs,2);
        expMean = (options.nbinMax+1)/2;
        ind = find(binMean > expMean-1 & binMean < expMean+1);
        binPairs = binPairs(ind,:);
        
        % Sort by separation (just for viewing purposes)
        %[~,indSort] = sort(binPairs(:,2)-binPairs(:,1)); 
        %binPairs = binPairs(indSort,:);
        
        % Turn averaging on for non-unique r values TODO: This averaging not the same as on the wiki
        options.dllAvg = true; 
	case 'method 2' %JMM method, i.e. 'forward diff' (all possible separations) 
        binPairs = nchoosek([1:max(options.nbinMax)],2); %%CHANGE: Added plus one here
       
    otherwise
        methods = {'method 1','method 2'};
        disp([options.diffMethod,' not valid. Options for diffMethod:'])
        for m = methods; disp([' - ',m{:}]); end
        error('options.diffMethod not valid...Quitting')
end
% Remove 1 bin separation
ind = find(binPairs(:,2) - binPairs(:,1) >= 2);
binPairs = binPairs(ind,:);

% Get range bins to use
NZ = 40;
nrmax = min([2*zz-1,options.nbinMax,2*(NZ-zz)+1]); % How many bins to use
nz_R0 = floor(nrmax/2); % number of bins from centre
indZ = zz-nz_R0:zz+nz_R0;


% Get velocity timeseries for range bins
vp = reshape(data.L2.R_VEL_DETRENDED(indT,indZ,indB,:),[length(indZ),300])';

% Calculate SF parameters (i.e. r_del and DLL)
[r_del,dll,dll_n,binPairsOut] = calc_DLL_DLLL(vp,binPairs,dr,options);

binL = indZ(1)+binPairsOut(:,1)-1;
binU = indZ(1)+binPairsOut(:,2)-1;
[r_del' r_del'/dr dll' dll_n' binPairsOut binL binU]

%%
zz = 38
options.nbinMax = 5;
nBinMaxHalf = floor((options.nbinMax+1)/2); % number of bins from centre


binPairs = nchoosek([-nBinMaxHalf:0, 1:nBinMaxHalf],2);
binMean = mean(binPairs,2);
ind = find(binMean > -1 & binMean < 1);
binPairs1 = binPairs(ind,:);
[~,indSort] = sort(binPairs1(:,2)-binPairs1(:,1)); 
binPairs1 = binPairs1(indSort,:);
ind = find(binPairs1(:,2) - binPairs1(:,1)<=options.nbinMax); % Trim (necessary if nbinMax is odd)
binPairs1 = binPairs1(ind,:);


[binPairs1+zz (binPairs1(:,2) - binPairs1(:,1))]


% Calculate SF parameters (i.e. r_del and DLL)
binsToBot = (zz-1)
binsToTop = (NZ-zz)
nrmax = min([2*binsToBot,options.nbinMax,2*binsToTop]) % How many bins to use
ind = find((binPairs1(:,2) - binPairs1(:,1)) <= nrmax);
binPairsIn1 = binPairs1(ind,:)+zz
disp('1')
[binPairsIn1 (binPairsIn1(:,2) - binPairsIn1(:,1))]


% Get velocity timeseries for range bins
vp = reshape(data.L2.R_VEL_DETRENDED(indT,:,indB,:),[40,300])';

[r_del,dll,dll_n,binPairsOut] = calc_DLL_DLLL(vp,binPairsIn1,dr,options);
[r_del' r_del'/dr dll' dll_n' binPairsOut]


binPairs2 = nchoosek([-nBinMaxHalf:0, 1:nBinMaxHalf],2);
ind = find(binPairs2(:,2) - binPairs2(:,1)<=options.nbinMax); % Trim (necessary if nbinMax is odd)
binPairs2 = binPairs2(ind,:);
[~,indSort] = sort(binPairs2(:,2)-binPairs2(:,1)); 
binPairs2 = binPairs2(indSort,:);
binPairs2 = binPairs2+zz;


binsToBot = (zz-1);
minBin = max([1,zz-binsToTop,zz-nBinMaxHalf]);
maxBin = min([zz+nBinMaxHalf,40,zz+binsToBot]);
binsToTop = (NZ-zz);
nrmax = min([2*binsToBot,options.nbinMax,2*binsToTop]); % How many bins to use
ind = find((binPairs2(:,1)>=minBin) & (binPairs2(:,2)<=maxBin));
disp('2')
binPairsIn2 = binPairs2(ind,:);
[binPairsIn2 (binPairsIn2(:,2) - binPairsIn2(:,1))]

% Get velocity timeseries for range bins
vp = reshape(data.L2.R_VEL_DETRENDED(indT,:,indB,:),[40,300])';

[r_del2,dll2,dll_n2,binPairsOut2] = calc_DLL_DLLL(vp,binPairsIn2,dr,options);
[r_del2' r_del2'/dr dll2' dll_n2' binPairsOut2]

%%
figure(1),clf
plot(r_del/dr,dll,'.')
hold all
plot(r_del2/dr,dll2,'o')
