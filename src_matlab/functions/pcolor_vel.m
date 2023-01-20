function [fig,ax] = pcolor_vel(MTIME,Z_DIST,R_VEL,PRES,options)
% Plot velocity from each beam
%
% Todo:
% - improve plot if data are irredularly spaced
%
% Justine McMillan
% Apr 15, 2022

if ~isfield(options,'tUnits'); options.tUnits = 'days'; end
if ~isfield(options,'cLim'); 
    cMin = min(min(min(R_VEL)));
    cMax = max(max(max(R_VEL)));
    options.cLim = [cMin cMax]; 
end

switch options.tUnits
    case 'days'
        t = MTIME - MTIME(1);
    case 'hours'
        t = (MTIME - MTIME(1))*24;
    otherwise
        error('tUnits must be days or hours')
end

if ~isempty(PRES)
    flgPres = 1;
else
    flgPres = 0;
end

[NT,NZ,NB] = size(R_VEL);
nPlots = NB+flgPres;

fig = figure;clf

nP = 0;
if flgPres
    nP = nP + 1;
    ax(nP) = subplot(nPlots,1,nP);
    plot(t,PRES)
    colorbar
    
end

for bb = 1:NB
    nP = nP + 1;
    ax(nP) = subplot(nPlots,1,nP);
    pcolor(t,Z_DIST,squeeze(R_VEL(:,:,bb))')
    caxis(options.cLim)
    shading flat; colorbar
    ylabel('Z\_DIST [m]')
end
xlabel(ax(end),['rel time [',options.tUnits,']'])
linkaxes(ax,'x')