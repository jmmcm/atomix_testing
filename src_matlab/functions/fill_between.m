function h=fill_between(xVals,yVals,color)
%%function fill_between_x(xVals,yVals,color)
% This function creates a transparent colored region on a plot between two 
% lines. 
% Inputs:
%  xVals = matrix (2xN) of x values
%  yVals = matrix (2xN) of yvalues
%  color = [r g b], color of region
%
% E.g.
% h = fill_between([0 1 2 ; 2 5 6],[0 1 2 ; 0 1 2],'g')
%
% Justine McMillan
% Jan 18, 2023

x = [xVals(1,:) fliplr(xVals(2,:))];
y = [yVals(1,:) fliplr(yVals(2,:))];

alpha = 0.25; %transparency 
h=patch(x,y,color,...
        'edgecolor','none','facealpha',alpha);
    
    