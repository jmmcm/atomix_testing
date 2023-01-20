% Test effect of different detrending methods on velocity time series.
%
% TODO: Extend to test effect on epsilon?
%
% Justine McMillan
% Mar 11, 2022
clear 

load ../../GP_sample/output/GP130620BPb_level1.mat % Replace with netcdf file to test
load ../../GP_sample/output/GP130620BPb_level2.mat
%% Options


indB = 1;
indZ = 34; % for plot
indEns = 257; % 257 = lots of nans, 253 = few nans (for indZ = 34)
indT = remove_nans(lev2.N_PROFILE(indEns,:)); % raw time indices


options.applyFlags = 1;
options.offsetSlope=100;
options.offsetYint=0.4;

%% Apply detrending
NZ = length(lev1.Z_DIST);
NT = length(indT);
NM = 3; % Number of methods


    
% Get data for segment
time = lev1.TIME(indT);
timeRel = time - lev1.TIME(indT(1)); % Used for offset

vel = lev1.R_VEL(indT,:,indB);
velFlags = lev1.R_VEL_FLAGS(indT,:,indB);

% Apply flags
if options.applyFlags
    velFlags(velFlags>0) = NaN;
    velFlags = velFlags+1;
    velQC = vel.*velFlags;
else
    velQC = vel;
end

% Add offset for testing
offset = options.offsetSlope*timeRel*ones(1,NZ)+options.offsetYint; % Enhance slope and offset
vel = vel+offset;
velQC = velQC+offset;



% Detrend
velDT = NaN*ones(NT,NZ,NM);

% Method 1: Apply flags after detrending
velDT(:,:,1) = detrend(vel,'linear').*velFlags; 

% Method 2: Polyfit with my function
velDT(:,:,2) = detrend_with_NaNs(velQC(:,:),time,struct('method','Poly1D'));

% Method 3: Regression after removing nans
[velDT(:,:,3),P] = detrend_with_NaNs(velQC(:,:),time,struct('method','Regress1D'));



% Plot
figure(1),clf
timePlot = timeRel*24*60;

subplot(211)
lgdstr = {};
plot(timePlot,vel(:,indZ))
lgdstr{end+1} = 'Raw';
hold all
plot(timePlot,velQC(:,indZ)) 
lgdstr{end+1} = 'QC';
for mm = 1:NM
    p(mm)=plot(timePlot,velDT(:,indZ,mm),'-','Marker','o'); % detrended data
    lgdstr{end+1} = ['Detrend',num2str(mm)];
    plot(timePlot,velQC(:,indZ)-velDT(:,indZ,mm),'-','color',get(p(mm),'color'))
    lgdstr{end+1} = ['Trend',num2str(mm)];

end
plot(get(gca,'xlim'),[0 0],'--k')
legend(lgdstr)
title([num2str(sum(isnan(velQC(:,indZ)))),' nans'])

subplot(212)
lgdstr = {};
for mm = 1:NM
    plot(timePlot,velDT(:,indZ,mm)-velDT(:,indZ,1),'color',get(p(mm),'color'))
    if mm == 1; hold all; end
    lgdstr{end+1} = ['Detrend',num2str(mm),' - Detrend1'];
end
xlabel('time [ min ]')
legend(lgdstr)


