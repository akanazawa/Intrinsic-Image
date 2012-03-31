function self = DiffTerm(img, parameter, opts)
  self = struct();

  self.estH = colorRetEstimator(img.I2, opts.filterH, ...
    parameter.thresholdGray, parameter.thresholdColor);
  self.estV = colorRetEstimator(img.I2, opts.filterV, ...
    parameter.thresholdGray, parameter.thresholdColor);

  self.laplacian = opts.laplacian;
  self.filterH = opts.filterH;
  self.filterV = opts.filterV;

  self.cretDerivativeTerm = self.filterH'*self.estH + self.filterV'*self.estV;

  self.getEnergy = @getEnergy;
  self.update = @update;
  self.putStats = @putStats;

function [E, dE] = getEnergy(self, r)
  logR = log(r+eps);
  filteredHR = self.filterH * logR;
  filteredVR = self.filterV * logR;

  laplacianR = self.laplacian * logR;

  % the last two terms are not necessary for the optimization
  %E = logR' * LR + 2*sum( (LhR .* self.r_x) + (LvR .* self.r_y) )...
    %+ sum(self.r_x.^2) + sum(self.r_y.^2);
  E = logR' * laplacianR - 2*sum((filteredHR.*self.estH) + (filteredVR.*self.estV));

  %dE =  2* LR + 2 * (opts.Lh' * r_x + opts.Lv' * r_y);
  dE =  2* laplacianR - 2 * self.cretDerivativeTerm;

  dE = (dE./r);

function self = update(self, R)

function stats = putStats(self, stats)

function [est] = colorRetEstimator(diffuse, op, thresholdGray, thresholdColor)
  cut = 3./(2^16 - 1);

  channels = size(diffuse, 2);

  diffuse(diffuse < cut) = cut;
  logDiffuse = log(diffuse);

  for i=1:channels
    responseOrig(:, i) = op * logDiffuse(:, i);
  end
  responseGray = projectGray(responseOrig);
  responseColor = projectColor(responseOrig);
  normedResponseColor = sqrt(sum(responseColor.^2, 2));

  logDiffuseGrayscale = log(mean(diffuse, 2));
  responseGrayscale = op * logDiffuseGrayscale;

  est = responseGrayscale .* ...
    double(normedResponseColor > thresholdColor ...
         | abs(responseGray(:, 1)) > thresholdGray);

function [p] = projectGray(e)
  p = repmat(mean(e, 2), [1, 3]);

function [p] = projectColor(e)
  p = e - projectGray(e);
