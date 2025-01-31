clear
mname = mfilename('fullpath');

% Wrapped data
load /home/jmm000/DATA/atomix/AQD_NorthSea_bedframe/AQD_NorthSea_bedframe_CEB_wrapped.mat
dataW = data;

% UnWrapped data
load /home/jmm000/DATA/atomix/AQD_NorthSea_bedframe/AQD_NorthSea_bedframe_CEB.mat
dataU = data;

%%
figure(1),clf
set(gcf,'Name','ENU')
for bb = 1:3
    ax(bb) = subplot(2,3,bb);
    pcolor(dataW.Ancillary.ENU(:,:,bb)'); shading flat; colorbar
    caxis(0.1*[-1 1])
    title('Wrapped')
end

for bb = 1:3
    ax(bb+3) = subplot(2,3,bb+3);
    pcolor(dataU.Ancillary.ENU(:,:,bb)'); shading flat; colorbar
    caxis(0.1*[-1 1])
    title('Unwrapped')
end

%%
figure(2),clf
set(gcf,'Name','XYZ')
for bb = 1:3
    ax(bb) = subplot(2,3,bb);
    pcolor(dataW.Ancillary.XYZ(:,:,bb)'); shading flat; colorbar
    caxis(0.1*[-1 1])
    title('Wrapped')
end

for bb = 1:3
    ax(bb+3) = subplot(2,3,bb+3);
    pcolor(dataU.Ancillary.XYZ(:,:,bb)'); shading flat; colorbar
    caxis(0.1*[-1 1])
    title('Unwrapped')
end

%% Beam
figure(3),clf
set(gcf,'Name','Beam')
for bb = 1:3
    ax(bb) = subplot(2,3,bb);
    pcolor(dataW.L1.R_VEL(:,:,bb)'); shading flat; colorbar
    caxis(0.1*[-1 1])
    title('Wrapped')
end

for bb = 1:3
    ax(bb+3) = subplot(2,3,bb+3);
    pcolor(dataU.L1.R_VEL(:,:,bb)'); shading flat; colorbar
    caxis(0.1*[-1 1])
    title('Unwrapped')
end

%% 
bin = 30
figure(4),clf
plot(dataW.L1.R_VEL(:,bin,3))
hold all
plot(dataU.L1.R_VEL(:,bin,3))
