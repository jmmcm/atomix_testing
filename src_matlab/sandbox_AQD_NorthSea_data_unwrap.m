clear
mname = mfilename('fullpath');

% Downloaded data (NetData struct)
load /home/jmm000/DATA/atomix/AQD_NorthSea_bedframe/AQD_NorthSea_bedframe_CEB_wrapped.mat

XYZ_VEL = data.L1.XYZ_VEL;
R_VEL = data.L1.R_VEL;
HEADING = data.L1.HEADING;
PITCH = data.L1.PITCH;
ROLL = data.L1.ROLL;
TIME = data.L1.TIME;

R_VEL_UNWRAPPED = zeros(size(R_VEL));
XYZ_VEL_UNWRAPPED = zeros(size(XYZ_VEL));
ENU = zeros(size(XYZ_VEL));
%%
NBURST = length(data.Ancillary.TIME);
NZ = length(data.Ancillary.Z_DIST);

%% Unwrap each burst
% TODO: Need to deal with segments where unwrapping changes sign of the
% data. Unwrap all depths at once and ensure averages are the same sign?

v1 = squeeze(R_VEL(:,:,1));
v2 = squeeze(R_VEL(:,:,2));
v3 = squeeze(R_VEL(:,:,3));

% Estimate ambiguity velocity
vAmb1=(-min(v1(:))+max(v1(:)))/2;
vAmb2=(-min(v2(:))+max(v2(:)))/2;
vAmb3=(-min(v3(:))+max(v3(:)))/2;
vAmb = max([vAmb1,vAmb2,vAmb3]);

tFilt = 30; %[seconds]
freq = 8;
binRef = 30;

disp('Unwrapping')
for tt = 1:NBURST%100:105
    disp(tt)
    
    indTbeg = (tt-1)*2048+1;
    indTend = tt*2048;
    indT = indTbeg:indTend;
    
    % Unwrap
    options.vAmb = vAmb;
    options.binRef = 30;
    R_VEL_UNWRAPPED(indT,:,:) = unwrap_nortek_aquadopp(R_VEL(indT,:,:),tFilt*freq,options);

    % pause
    
    
end


%% Plot each burst
if 0
    disp('Plotting')
    for tt = 1:NBURST
        disp(tt)
        indTbeg = (tt-1)*2048+1;
        indTend = tt*2048;
        indT = indTbeg:indTend;
        
        figure(1),clf
        for bb = 1:3
            ax(bb) = subplot(3,4,4*bb-3);
            pcolor(XYZ_VEL(indT,:,bb)'); shading flat; cb = colorbar;
            colormap(cmocean('balance'))
            
            ax(bb+3) = subplot(3,4,4*bb-2);
            pcolor(R_VEL(indT,:,bb)'); shading flat; cb = colorbar;
            colormap(cmocean('balance'))
            caxis(0.1*[-1 1])
            
            ax(bb+6) = subplot(3,4,4*bb-1);
            pcolor(R_VEL_UNWRAPPED(indT,:,bb)'); shading flat; cb = colorbar;
            colormap(cmocean('balance'))
            caxis(0.1*[-1 1])
            
            ax(bb+9) = subplot(3,4,4*bb);
            plot(R_VEL(indT,5,bb),'color',0.6*[1 1 1])
            hold all
            plot(R_VEL_UNWRAPPED(indT,5,bb),'k')
            
            
            %         ax(bb+6) = subplot(3,3,3*bb);
            %         pcolor(data.L1.R_VEL(indTbeg:indTend,:,bb)'); shading flat; colorbar
            %         colormap(cmocean('balance'))
            % %         caxis(0.1*[-1 1])
        end
        title(ax(1),['XYZ, indT = ' num2str(tt)])
        title(ax(4),['Beam, indT = ' num2str(tt)])
        title(ax(7),['Beam (unwrap), indT = ' num2str(tt)])
        title(ax(10),['Beam (unwrap), indT = ' num2str(tt),', bin 5'])
        
        add_fig_info(mname,'',struct())
        figDir = '/home/jmm000/work/ATOMIX/figures/AQD_NorthSea_bedframe/Unwrapping/';
        saveas(gcf,[figDir 'Burst_' num2str(tt,'%03d') '.png'])
    end
%     pause
end

% return
%% Convert back to XYZ
load('/home/jmm000/DATA/atomix/AQD_NorthSea_bedframe/Downloaded/CEB/NorthSea_AquaDopp_ATOMIX.mat','hdr','statusbit')
hdr.coord = 'BEAM';
for zz = 1:NZ
    [XYZ_VEL_UNWRAPPED(:,zz,:), ENU(:,zz,:)]=transformADV(squeeze(R_VEL_UNWRAPPED(:,zz,:)),hdr,...
        data.L1.HEADING,data.L1.PITCH,data.L1.ROLL,statusbit);
end

%% Plot result for each burst
for tt = 1:10%NBURST
    tt
    indTbeg = (tt-1)*2048+1;
    indTend = tt*2048;
    indT = indTbeg:indTend;
    
    figure
    for bb = 1:3
        ax(bb) = subplot(3,4,4*bb-3);
        pcolor(XYZ_VEL(indT,:,bb)'); shading flat; cb = colorbar;
        colormap(cmocean('balance'))
        
        ax(bb+3) = subplot(3,4,4*bb-2);
        pcolor(R_VEL(indT,:,bb)'); shading flat; cb = colorbar;
        colormap(cmocean('balance'))
        caxis(0.1*[-1 1])
        
        ax(bb+6) = subplot(3,4,4*bb-1);
        pcolor(R_VEL_UNWRAPPED(indT,:,bb)'); shading flat; cb = colorbar;
        colormap(cmocean('balance'))
        caxis(0.1*[-1 1])
        
        ax(bb+9) = subplot(3,4,4*bb);
        pcolor(XYZ_VEL_UNWRAPPED(indT,:,bb)'); shading flat; cb = colorbar;
        colormap(cmocean('balance'))
        
    end
    title(ax(1),['XYZ, indT = ' num2str(tt)])
    title(ax(4),['Beam, indT = ' num2str(tt)])
    title(ax(7),['Beam (unwrap), indT = ' num2str(tt)])
    title(ax(10),['XYZ (unwrap), indT = ' num2str(tt)])
end

%% Plot ENU
for tt = 1:10%NBURST
    tt
    indTbeg = (tt-1)*2048+1;
    indTend = tt*2048;
    indT = indTbeg:indTend;
    
    figure, clear ax
    for bb = 1:3
        ax(bb) = subplot(3,1,bb);
        pcolor(ENU(indT,:,bb)'); shading flat; cb = colorbar;
        colormap(cmocean('balance'))
        caxis(0.2*[-1 1])
        
    end
    title(ax(1),'E')
    title(ax(2),'N')
    title(ax(3),'U')
%     title(ax(4),['Beam, indT = ' num2str(tt)])
%     title(ax(7),['Beam (unwrap), indT = ' num2str(tt)])
%     title(ax(10),['XYZ (unwrap), indT = ' num2str(tt)])
end

%%
figure(100),clf
subplot(3,1,1)
pcolor(ENU(:,:,1)'); shading flat; colorbar
colormap(cmocean('balance'))
caxis(.2*[-1 1])

subplot(3,1,2)
pcolor(ENU(:,:,2)'); shading flat; colorbar
colormap(cmocean('balance'))
caxis(.2*[-1 1])

subplot(3,1,3)
pcolor(ENU(:,:,3)'); shading flat; colorbar
colormap(cmocean('balance'))
caxis(.02*[-1 1])