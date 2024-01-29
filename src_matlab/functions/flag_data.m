function dataQC = flag_data(data,flags,threshold)
%
% Replace data with a NaN everywhere that the flag is greater than the
% specified threshold.
%
% Justine McMillan
% Mar 31, 2023

mask = ones(size(flags));
mask(flags>threshold) = NaN;
dataQC = data.*mask;
