function [ax,ph] = plot_pcolor(ax,data,options)
% Plot a pcolor of an ATOMIX variable
%
% Justine McMillan
% July 14, 2022
% Note: if data.x and data.y are vectors, then data.values should have 
%       shape [length(Y),length(X)]. Matrix will be transposed before
%       plotting
% 
% e.g. Usage
% options = struct();
% ax = subplot(121);
% data.x = L4.TIME;      
% data.y = L4.Z_DIST;  
% data.values = L4.EPSI(:,:,1);
% data.var = 'EPSI';

%% Options
if isfield(options,'tUnits')
    switch options.tUnits
        case 'relDays'
            data.x = data.x - data.x(1);
        case 'relHours'
            data.x = (data.x - data.x(1))*24;
        case 'yd'
            dateVec = datevec(data.x(1));
            if options.xlabel == 1
                options.xlabel = ['year day ' ,num2str(dateVec(1))];
            end
            data.x = get_yd(data.x);
        otherwise
            error([options.tUnits ' is not valid for tUnits'])
    end
end

%% variable specific options
% TODO: Make inout option
switch data.var
    case 'EPSI'
        cmap = cmocean('Thermal');
    case 'EPSIratio'
         cmap = cmocean('Balance');
%         cmap = cmocean('oxy');
    case 'SPD'
        cmap = cmocean('Speed');
    case 'DIR'
        cmap = cmocean('phase');
    otherwise
        cmap = cmocean('Thermal');
        
end

%% Transpose if necessary
[NRx,NCx] = size(data.x);
[NRz,NCz] = size(data.values);

if NCx == 1 || NRx == 1
    if NCz ~= length(data.x)
        data.values = data.values';
        warning('Matrix transposed to match x, y dimensions')
    end
end

%% plot pcolor
pcolor(ax,data.x,data.y,data.values)
shading flat
colormap(ax,cmap)
axPos = get(ax,'Position');
c = colorbar('Position',[axPos(1)+axPos(3)+0.02,axPos(2),0.02,axPos(4)]);

if isfield(options,'clim')
   caxis(options.clim)
end
if isfield(options,'ylabel')
    ylabel(options.ylabel)
end
if isfield(options,'xlabel')
    xlabel(options.xlabel)
end
if isfield(options,'clabel')
    ylabel(c,options.clabel)
else
    ylabel(c,clean_string(data.var))
end

