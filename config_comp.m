%%%%%%%%%%%%%%%%%%%%
% CONFIGURATION file holding settings for intrinsic image
% decomposition and segmentation for comparing the results to
% reproduce experiments
%
% March 31 2012 AK
%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%
% Directory settings
%%%%%%%%%%%%%%%%%%%%

imgDir = 'data/images/';
outDir = 'data/results/';

%%%%%%%%%%%%%%%%%%%%
% Library settings
%%%%%%%%%%%%%%%%%%%%
addpath('BSR/grouping/lib/');
addpath(genpath('nips11intrinsic/'));

%%g%%%%%%%%%%%%%%%%%%
% Intrinsic image parameters
%%%%%%%%%%%%%%%%%%%%
 param = struct();
 param.energyThresh    = 1e-3;
 param.maxIterations   = 250;
 param.minimizeMaxIter = 1000;
 param.sumConstraint   = 1;
 param.reflectanceInit = 'mixed'; % 'ones', 'normI', 'mixed'
 param.startFac        = 0.3;     % only valid for 'mixed'
 param.c_R             = 0;%1;
 param.k               = 150;
 param.kMeansRestarts  = 4;
 param.clusteringInit  = 'RhatR'; % 'RhatR', 'chromaticity', 'normI'
 param.c_smooth        = 0;%0.001;
 param.c_cret          = 1;%0.01;
 param.thresholdGray   = 0.075;
 param.thresholdColor  = 1;

 %%%%%%%%%%%%%%%%%%%%
 % Retinex
 %%%%%%%%%%%%%%%%%%%%
 param.nIterations = 5;
