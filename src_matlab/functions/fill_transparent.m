function fill_transparent(xlim,ylim,color)
%%function fill_transparent(xlim,ylim,color)
% This function creates a transparent colored region on a plot. Useful when
% looking at regions of data
% Inputs:
%  xlim = [xmin xmax], xlimits of region
%  ylim = [ymin ymax], ylimits of region
%  color = [r g b], color of region
%
% Justine McMillan
% Sept 27, 2011

xmin = xlim(1);
xmax = xlim(2);
ymin = ylim(1);
ymax = ylim(2);

alpha = 0.3; %transparency 
fill([xmin xmax xmax xmin],...
        [ymin ymin ymax ymax] ,color,...
        'edgecolor','none','facealpha',alpha,'HandleVisibility','off')