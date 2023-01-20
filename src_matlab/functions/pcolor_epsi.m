function [fig,ax] = pcolor_epsi(MTIME,Z_DIST,EPSI,PRES,options)
% Plot dissipation from each beam
%
% Justine McMillan
% Apr 15, 2022

if ~isfield(options,'tUnits'); options.tUnits = 'days'; end
if ~isfield(options,'cLim'); 
    cMin = min(min(min(log10(EPSI))));
    cMax = max(max(max(log10(EPSI))));
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

[NT,NZ,NB] = size(EPSI);
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
    pcolor(t,Z_DIST,squeeze(log10(EPSI(:,:,bb)))')
    caxis(options.cLim)
    shading flat; c = colorbar;
    ylabel('Z\_DIST [m]')
    ylabel(c,['log10(\epsilon_',num2str(bb),')'])
end
xlabel(ax(end),['rel time [',options.tUnits,']'])
linkaxes(ax,'x')