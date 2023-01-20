clear
dataSet = 'RDIWH600_CANDYFLOSS_bedframe';

processIDs = {'BDS01','JMM01'};
[dataFileRoot,dataDir,metaDir] = get_data_paths(dataSet);


data1 = load([dataDir dataFileRoot '_' processIDs{1}]);
data2 = load([dataDir dataFileRoot '_' processIDs{2}]);

xlimits = [1e-8 1e-4];
ylimits = [1e-8 1e-4];

figure(1),clf
ax1 = subplot(1,2,1);
opts = struct('limits',[1e-10 1e-4],'ratios',[2 5]);
plot_EPSI_scatter(ax1,data1.data.L4.EPSI(:),data2.data.L4.EPSI(:),opts)

ax2 = subplot(1,2,2);
opts = struct('limits',[1e-10 1e-4],'ratios',[2 5],'type','density');
plot_EPSI_scatter(ax2,data1.data.L4.EPSI(:),data2.data.L4.EPSI(:),opts)