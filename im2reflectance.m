function [estR, estL] = im2reflectance(imgFile, outFile, intrinsic_param)
%%%%%%%%%%
% driver for computing intrinsic image using NIPS '11
% 
%
% 29 March 2012 AK
%%%%%%%%%%



save(outFile,'estR');
