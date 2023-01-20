function a = text_rel_figure(x,y,text)
% function text_rel_figure(x,y,text)
% 
% Add text where (x,y) are relative to figure axes
%
% Justine McMillan
% 2023-01-17

annotation('textbox', [x, y, 0, 0], 'String', text, 'FitBoxToText', 'on','VerticalAlignment', 'middle');
