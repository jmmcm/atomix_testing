% Convert beam velocities to ENU and calculate Signed Speed.
% Plot amplitude and compare it to the pressure to detect the surface. 
%
% Justine McMillan
% Oct 10, 2024

clear
mname = mfilename('fullpath');

flg.saveFigs = 1;
figPath = '~/work/ATOMIX/figures/NortekSig1000_TidalChannel_2019_Burst/Preprocessing/';

dataDir = '~/DATA/atomix/NortekSig1000_TidalChannel_2019_Burst/Downloaded/NSL/';
dataFile = 'burstData_L1format.mat';

%% Load data and format
d = load([dataDir dataFile]);

data.L1 = rmfield(d,'Config');
data.L1.TIME = datenum(data.L1.TIME);
data.L1.Z_DIST = data.L1.Z_DIST';

%% Calculate raw ENU
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

%% Calculate segment averages
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

%% Plot Beam Velocity
figure(1),clf
ax(1) = subplot(5,1,1);
pcolor(Anc.R_VEL(:,:,1)'); shading flat; colorbar; caxis([-1 1])
colormap(ax(1),cmocean('balance'))
title('Beam 1')

ax(2) = subplot(5,1,2);
pcolor(Anc.R_VEL(:,:,2)'); shading flat; colorbar; caxis([-1 1])
colormap(ax(2),cmocean('balance'))
title('Beam 2')

ax(3) = subplot(5,1,3);
pcolor(Anc.R_VEL(:,:,3)'); shading flat; colorbar; caxis([-1 1])
colormap(ax(3),cmocean('balance'))
title('Beam 3')

ax(4) = subplot(5,1,4);
pcolor(Anc.R_VEL(:,:,4)'); shading flat; colorbar; caxis([-1 1])
colormap(ax(4),cmocean('balance'))
title('Beam 4')

ax(5) = subplot(5,1,5);
pcolor(Anc.R_VEL(:,:,5)'); shading flat; colorbar; caxis([-1 1])
colormap(ax(5),cmocean('balance'))
title('Beam 5')

add_fig_info(mname,dataFile,struct())
if flg.saveFigs
    figName = [figPath,'VelBeam.png'];
    disp(['Saving: ',figName])
    saveas(gcf,figName);
end

%% Plot instrument velocities
figure(2),clf
ax(1) = subplot(4,1,1);
pcolor(Anc.XYZ(:,:,1)'); shading flat; colorbar; caxis([-1 1])
colormap(ax(1),cmocean('balance'))
title('X')

ax(2) = subplot(4,1,2);
pcolor(Anc.XYZ(:,:,2)'); shading flat; colorbar; caxis([-1 1])
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

add_fig_info(mname,dataFile,struct())
if flg.saveFigs
    figName = [figPath,'VelXYZ.png'];
    disp(['Saving: ',figName])
    saveas(gcf,figName);
end

%% Plot ENU velocities
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

add_fig_info(mname,dataFile,struct())
if flg.saveFigs
    figName = [figPath,'VelENU.png'];
    disp(['Saving: ',figName])
    saveas(gcf,figName);
end

%% Plot Speed and direction
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

add_fig_info(mname,dataFile,struct())
if flg.saveFigs
    figName = [figPath,'SpeedDir.png'];
    disp(['Saving: ',figName])
    saveas(gcf,figName);
end

%% Plot Pressure and velocities at select range bins
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

add_fig_info(mname,dataFile,struct())
if flg.saveFigs
    figName = [figPath,'SpeedDir_SelectBins.png'];
    disp(['Saving: ',figName])
    saveas(gcf,figName);
end

%% Plot attitude data
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

add_fig_info(mname,dataFile,struct())
if flg.saveFigs
    figName = [figPath,'Attitude.png'];
    disp(['Saving: ',figName])
    saveas(gcf,figName);
end

%% Plot amplitude data with pressure superimposed
figure(7),clf
tRef = (Anc.TIME - datenum(2019,7,9))*24;
for ii = 1:5
    ax(ii) = subplot(5,1,ii);
    pcolor(tRef,Anc.Z_DIST,Anc.ABSIC(:,:,ii)'); shading flat; colorbar
    colormap(ax(ii),cmocean('amp'))
    hold all
    p1 = plot(tRef,Anc.PRES,'w');
    p2 = plot(tRef,Anc.PRES*0.9,'c');
    p3 = plot(tRef,Anc.PRES*0.8,'y');
    p4 = plot(tRef,Anc.PRES*0.7,'g');
    title(['Amp - Beam ' num2str(ii)])
    ylabel('z [m]')
end
legend([p1 p2 p3 p4],'P','0.9*P','0.8*P','0.7*P')
xlabel('hours since Jul 9, 2019')

add_fig_info(mname,dataFile,struct())
if flg.saveFigs
    figName = [figPath,'Absic.png'];
    disp(['Saving: ',figName])
    saveas(gcf,figName);
end

%% Nan above surface
ratio = 0.65;
ratio5 = 0.7;
fieldIn = ones(length(Anc.TIME),length(Anc.Z_DIST));
[nanMask, ~] = nan_AboveSurf(fieldIn,Anc.Z_DIST,Anc.PRES,ratio);
[nanMask5, ~] = nan_AboveSurf(fieldIn,Anc.Z_DIST,Anc.PRES,ratio5);

Anc.ABSICqc(:,:,1) = Anc.ABSIC(:,:,1).*nanMask;
Anc.ABSICqc(:,:,2) = Anc.ABSIC(:,:,2).*nanMask;
Anc.ABSICqc(:,:,3) = Anc.ABSIC(:,:,3).*nanMask;
Anc.ABSICqc(:,:,4) = Anc.ABSIC(:,:,4).*nanMask;
Anc.ABSICqc(:,:,5) = Anc.ABSIC(:,:,5).*nanMask5;

Anc.R_VELqc(:,:,1) = Anc.R_VEL(:,:,1).*nanMask;
Anc.R_VELqc(:,:,2) = Anc.R_VEL(:,:,2).*nanMask;
Anc.R_VELqc(:,:,3) = Anc.R_VEL(:,:,3).*nanMask;
Anc.R_VELqc(:,:,4) = Anc.R_VEL(:,:,4).*nanMask;
Anc.R_VELqc(:,:,5) = Anc.R_VEL(:,:,5).*nanMask5;

Anc.ENUqc(:,:,1) = Anc.ENU(:,:,1).*nanMask;
Anc.ENUqc(:,:,2) = Anc.ENU(:,:,2).*nanMask;
Anc.ENUqc(:,:,3) = Anc.ENU(:,:,3).*nanMask;
spdqc = spd.*nanMask;
velDirMagNqc = velDirMagN.*nanMask;

%% Plot QC'd amp

figure(8),clf
tRef = (Anc.TIME - datenum(2019,7,9))*24;
for ii = 1:5
    ax(ii) = subplot(5,1,ii);
    pcolor(tRef,Anc.Z_DIST,Anc.ABSICqc(:,:,ii)'); shading flat; colorbar
    colormap(ax(ii),cmocean('amp'))
    hold all
    p1 = plot(tRef,Anc.PRES,'k');
    p2 = plot(tRef,Anc.PRES*ratio,'--c');
    p3 = plot(tRef,Anc.PRES*ratio5,'--y');
    if ii==5
        r = ratio5;
    else
        r = ratio;
    end
    title(['Amp - Beam ' num2str(ii) ' (threshold = ' num2str(r) ' x PRES)'])
    ylabel('z [m]')
end
legend([p1 p2 p3 p4],'P',[num2str(ratio) '*P'],[num2str(ratio5) '*P'])
xlabel('hours since Jul 9, 2019')


add_fig_info(mname,dataFile,struct())
if flg.saveFigs
    figName = [figPath,'Absic_Masked.png'];
    disp(['Saving: ',figName])
    saveas(gcf,figName);
end

%% Plot qc'd velocity
figure(9),clf
tRef = (Anc.TIME - datenum(2019,7,9))*24;
for ii = 1:5
    ax(ii) = subplot(5,1,ii);
    pcolor(tRef,Anc.Z_DIST,Anc.R_VELqc(:,:,ii)'); shading flat; colorbar
    colormap(ax(ii),cmocean('balance'))
    caxis([-1 1])
    hold all
    p1 = plot(tRef,Anc.PRES,'k');
    p2 = plot(tRef,Anc.PRES*ratio,'c');
    p3 = plot(tRef,Anc.PRES*ratio5,'g');
    if ii==5
        r = ratio5;
    else
        r = ratio;
    end
    title(['Vel - Beam ' num2str(ii) ' (threshold = ' num2str(r) ' x PRES)'])
    ylabel('z [m]')
end
legend([p1 p2 p3],'P',[num2str(ratio) '*P'],[num2str(ratio5) '*P'])
xlabel('hours since Jul 9, 2019')


add_fig_info(mname,dataFile,struct())
if flg.saveFigs
    figName = [figPath,'VelBeam_Masked.png'];
    disp(['Saving: ',figName])
    saveas(gcf,figName);
end

%% Plot QC'd ENU, speed and dir
figure(10),clf
ax(1) = subplot(4,1,1);
pcolor(Anc.ENUqc(:,:,1)'); shading flat; colorbar; caxis([-1.5 1.5])
colormap(ax(1),cmocean('balance'))
title('E')

ax(2) = subplot(4,1,2);
pcolor(Anc.ENUqc(:,:,2)'); shading flat; colorbar; caxis([-1.5 1.5])
colormap(ax(2),cmocean('balance'))
title('N')

ax(3) = subplot(4,1,3);
pcolor(spdqc'); shading flat; colorbar; caxis([0 1])
colormap(ax(3),cmocean('speed'))
title('Speed')

ax(4) = subplot(4,1,4);
pcolor(velDirMagNqc'); shading flat; colorbar; %caxis([-1.5 1.5])
colormap(ax(4),cmocean('phase'))
title('dirN')
xlabel('ind_T')
for ii = 1:4
    ylabel(ax(ii),'ind_Z')
end

add_fig_info(mname,dataFile,struct())
if flg.saveFigs
    figName = [figPath,'SpeedDir_masked.png'];
    disp(['Saving: ',figName])
    saveas(gcf,figName);
end

%% Plot subset of raw beam velocity
figure(11),clf
inds = 20000:40000;
for bb = 1:5
    ax(bb) = subplot(5,1,bb);
    plotData.var = 'R_VEL';
    opts.clim = [-1 1];
    opts.clabel = ['R\_VEL(:,:,' num2str(bb) ')'];
    plotData.x = get_yd(data.L1.TIME(inds));
    plotData.y = data.L1.Z_DIST;
    plotData.values = data.L1.R_VEL(inds,:,bb)';
    plot_pcolor(ax(bb),plotData,opts);
    if bb == 5
        thres = 0.7;
    else
        thres = 0.65;
    end
    hold all
    plot(plotData.x,data.L1.PRES(inds),'k')
    p = plot(plotData.x,thres*data.L1.PRES(inds),'color','k','DisplayName',[num2str(thres) 'x PRES']);
    ylabel('z [m]')
    legend(p)
    
end
linkaxes(ax)
title(ax(1),'Near surface raw beam velocities')
ylim([6 9])
xlabel('year day 2019')
add_fig_info(mname,dataFile,struct())
if flg.saveFigs
    figName = [figPath,'VelBeam_NearSurface.png'];
    disp(['Saving: ',figName])
    saveas(gcf,figName);
end
