clear

load ~/DATA/atomix/AQD_Windermere_bedframe/Downloaded/BDS_M1aA_RM2/AQD_Windermere_bedframe.mat
%%


cfg.beam_pattern = 'convex';
cfg.beam_angle = 20;

%% Convert to ENY
adcp.v1 = data.L1.R_VEL(:,



[velRaw.velEast,velRaw.velNorth,velRaw.velVert,velRaw.velError,...
            velRaw.velX,velRaw.velY,velRaw.velZ] = rdi_coordTransformFINAL(adcp,cfg);
