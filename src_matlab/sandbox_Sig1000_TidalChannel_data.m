% Convert beam velocities to ENU and calculate Signed Speed
%
% Justine McMillan
% Oct 10, 2024

clear

d = load('~/DATA/atomix/NortekSig1000_TidalChannel/Downloaded/NSL/burstData_L1format.mat');

data.L1 = rmfield(d,'Config');
data.L1.TIME = datenum(data.L1.TIME);
data.L1.Z_DIST = data.L1.Z_DIST';

% Calculate raw ENU
V1 = data.L1.R_VEL(:,:,1);
V2 = data.L1.R_VEL(:,:,2);
V3 = data.L1.R_VEL(:,:,3);
V4 = data.L1.R_VEL(:,:,4);
hdg = data.L1.HEADING;
pitch = data.L1.PITCH;
roll = data.L1.ROLL;

options = struct('figure',0);
ENUraw = NaN*ones(length(data.L1.TIME),length(data.L1.Z_DIST),4);
XYZraw = NaN*ones(length(data.L1.TIME),length(data.L1.Z_DIST),3);
for zz = 1:length(data.L1.Z_DIST)
    disp(['Computing ENU velocities. Bin ',num2str(zz),' of ',num2str(length(data.L1.Z_DIST))])
    [ENUraw(:,zz,1),ENUraw(:,zz,2),ENUraw(:,zz,3),ENUraw(:,zz,4),...
        XYZraw(:,zz,1),XYZraw(:,zz,2),XYZraw(:,zz,3)] = AD2CP_coordTransform(V1(:,zz),V2(:,zz),V3(:,zz),V4(:,zz),hdg,pitch,roll,options);
end

% Calculate average ENU (TODO: Read these in from metafile)
ensLength = 300; % [s]
freqApprox = 1/(data.L1.TIME(2)-data.L1.TIME(1))/24/3600; % [Hz]

[ind_start, ind_end] = get_ens_inds(data.L1.TIME*24*3600,ensLength,freqApprox);
NT = length(ind_start);
NZ = length(data.L1.Z_DIST);

Anc.TIME = NaN*ones(NT,1);
Anc.ENU = NaN*ones(NT,NZ,4);

for nn = 1:NT
    nPtsSegment = ind_end(nn) - ind_start(nn) + 1;
    Anc.TIME(nn) = mean(data.L1.TIME(ind_start(nn):ind_end(nn)));
    Anc.PRES(nn) = mean(data.L1.PRES(ind_start(nn):ind_end(nn)));
    Anc.HEADING(nn) = mean(data.L1.HEADING(ind_start(nn):ind_end(nn)));
    Anc.PITCH(nn) = mean(data.L1.PITCH(ind_start(nn):ind_end(nn)));
    Anc.ROLL(nn) = mean(data.L1.ROLL(ind_start(nn):ind_end(nn)));
    Anc.ENU(nn,:,:) = nanmean(ENUraw(ind_start(nn):ind_end(nn),:,:),1);
    Anc.XYZ(nn,:,:) = nanmean(XYZraw(ind_start(nn):ind_end(nn),:,:),1);
    Anc.R_VEL(nn,:,:) = nanmean(data.L1.R_VEL(ind_start(nn):ind_end(nn),:,:),1);
    Anc.ABSIC(nn,:,:) = nanmean(data.L1.ABSIC(ind_start(nn):ind_end(nn),:,:),1);
    Anc.CORR(nn,:,:) = nanmean(data.L1.CORR(ind_start(nn):ind_end(nn),:,:),1);
end
Anc.Z_DIST = data.L1.Z_DIST;

% Signed speed and direction
velDirMagN = get_DirFromN(Anc.ENU(:,:,1),Anc.ENU(:,:,2));
spd = sqrt(Anc.ENU(:,:,1).^2+Anc.ENU(:,:,2).^2);
Anc.SIGNED_SPD = sign_speed(Anc.ENU(:,:,1),Anc.ENU(:,:,2),spd,velDirMagN,0);

%% Plots
figure(1),clf
ax(1) = subplot(5,1,1);
pcolor(Anc.R_VEL(:,:,1)'); shading flat; colorbar; caxis([-1.5 1.5])
colormap(ax(1),cmocean('balance'))
title('Beam 1')

ax(2) = subplot(5,1,2);
pcolor(Anc.R_VEL(:,:,2)'); shading flat; colorbar; caxis([-1.5 1.5])
colormap(ax(2),cmocean('balance'))
title('Beam 2')

ax(3) = subplot(5,1,3);
pcolor(Anc.R_VEL(:,:,3)'); shading flat; colorbar; caxis([-1.5 1.5])
colormap(ax(3),cmocean('balance'))
title('Beam 3')

ax(4) = subplot(5,1,4);
pcolor(Anc.R_VEL(:,:,4)'); shading flat; colorbar; caxis([-1.5 1.5])
colormap(ax(4),cmocean('balance'))
title('Beam 4')

ax(5) = subplot(5,1,5);
pcolor(Anc.R_VEL(:,:,5)'); shading flat; colorbar; caxis([-1.5 1.5])
colormap(ax(5),cmocean('balance'))
title('Beam 5')

figure(2),clf
ax(1) = subplot(4,1,1);
pcolor(Anc.XYZ(:,:,1)'); shading flat; colorbar; caxis([-1.5 1.5])
colormap(ax(1),cmocean('balance'))
title('X')

ax(2) = subplot(4,1,2);
pcolor(Anc.XYZ(:,:,2)'); shading flat; colorbar; caxis([-1.5 1.5])
colormap(ax(2),cmocean('balance'))
title('Y')

ax(3) = subplot(4,1,3);
pcolor(Anc.XYZ(:,:,3)'); shading flat; colorbar; caxis([-0.5 0.5])
colormap(ax(3),cmocean('balance'))
title('Z')

ax(4) = subplot(4,1,4);
pcolor(Anc.R_VEL(:,:,5)'); shading flat; colorbar; caxis([-0.5 0.5])
colormap(ax(4),cmocean('balance'))
title('Beam 5')

% 
figure(3),clf
ax(1) = subplot(4,1,1);
pcolor(Anc.ENU(:,:,1)'); shading flat; colorbar; caxis([-1.5 1.5])
colormap(ax(1),cmocean('balance'))
title('E')

ax(2) = subplot(4,1,2);
pcolor(Anc.ENU(:,:,2)'); shading flat; colorbar; caxis([-1.5 1.5])
colormap(ax(2),cmocean('balance'))
title('N')

ax(3) = subplot(4,1,3);
pcolor(Anc.ENU(:,:,3)'); shading flat; colorbar; caxis([-0.5 0.5])
colormap(ax(3),cmocean('balance'))
title('U')

ax(4) = subplot(4,1,4);
pcolor(Anc.ENU(:,:,4)'); shading flat; colorbar; caxis([-0.5 0.5])
colormap(ax(4),cmocean('balance'))
title('Err')

% 
figure(4),clf
ax(1) = subplot(4,1,1);
pcolor(Anc.ENU(:,:,1)'); shading flat; colorbar; caxis([-1.5 1.5])
colormap(ax(1),cmocean('balance'))
title('E')

ax(2) = subplot(4,1,2);
pcolor(Anc.ENU(:,:,2)'); shading flat; colorbar; caxis([-1.5 1.5])
colormap(ax(2),cmocean('balance'))
title('N')

ax(3) = subplot(4,1,3);
pcolor(spd'); shading flat; colorbar; caxis([0 1])
colormap(ax(3),cmocean('speed'))
title('Speed')

ax(4) = subplot(4,1,4);
pcolor(velDirMagN'); shading flat; colorbar; %caxis([-1.5 1.5])
colormap(ax(4),cmocean('phase'))
title('dirN')
xlabel('ind_T')
for ii = 1:4
    ylabel(ax(ii),'ind_Z')
end
% 
figure(5),clf
ax(1) = subplot(5,1,1);
plot(Anc.TIME - Anc.TIME(1),Anc.PRES)
ylabel('PRES')
ax(2) = subplot(5,1,2);
plot(Anc.TIME - Anc.TIME(1),Anc.ENU(:,10,1))
hold all
plot(Anc.TIME - Anc.TIME(1),Anc.ENU(:,20,1))
ylabel('E')
ax(3) = subplot(5,1,3);
plot(Anc.TIME - Anc.TIME(1),Anc.ENU(:,10,2))
hold all
plot(Anc.TIME - Anc.TIME(1),Anc.ENU(:,20,2))
ylabel('N')
ax(4) = subplot(5,1,4);
plot(Anc.TIME - Anc.TIME(1),spd(:,10))
hold all
plot(Anc.TIME - Anc.TIME(1),spd(:,20))
ylabel('Speed')
ax(5) = subplot(5,1,5);
plot(Anc.TIME - Anc.TIME(1),velDirMagN(:,10))
hold all
plot(Anc.TIME - Anc.TIME(1),velDirMagN(:,20))
ylabel('Dir')

% 
figure(6),clf
ax(1) = subplot(4,1,1);
plot(Anc.TIME - Anc.TIME(1),Anc.PRES)
ylabel('PRES')
ax(2) = subplot(4,1,2);
plot(Anc.TIME - Anc.TIME(1),Anc.HEADING)
ylabel('Heading')
ax(3) = subplot(4,1,3);
plot(Anc.TIME - Anc.TIME(1),Anc.PITCH)
ylabel('Pitch')
ax(4) = subplot(4,1,4);
plot(Anc.TIME - Anc.TIME(1),Anc.ROLL)
ylabel('Roll')

%% 
figure(7),clf
tRef = (Anc.TIME - datenum(2019,7,9))*24;
for ii = 1:5
    ax(ii) = subplot(5,1,ii);
    pcolor(tRef,Anc.Z_DIST,Anc.ABSIC(:,:,ii)'); shading flat; colorbar
    colormap(ax(ii),cmocean('amp'))
    hold all
    p1 = plot(tRef,Anc.PRES,'c');
    p2 = plot(tRef,Anc.PRES*0.75,'--c');
    title(['Amp - Beam ' num2str(ii)])
    ylabel('z [m]')
end
legend([p1 p2],'P','0.75*P')
xlabel('hours since Jul 9, 2019')

%% Nan above surface
fieldIn = zeros(length(Anc.TIME),length(Anc.Z_DIST));
[fieldOut, ~] = nan_AboveSurf(fieldIn,Anc.Z_DIST,Anc.PRES,0.75);
nanMat = isnan(fieldOut); % ones where out of water, zeros elsewhere
nanMat = repmat(nanMat,1,1,length(data.L1.N_BEAM)); % Make the same size as R_VEL