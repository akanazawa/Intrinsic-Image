function [estR, estL] = im2reflectance(imPath, outPath, parameter)
%%%%%%%%%%
% driver for computing intrinsic image using NIPS '11
% 
%
% 29 March 2012 AK
%%%%%%%%%%

I = im2double(imread(imPath));
cut = 3/(2^16-1);
I(I < cut) = cut;
[m, n, d] = size(I);
% make I into m*n by d and normalize
img.mask = ones(m,n);
img.diffuse = trimToMask(I, img.mask);
img.norm = sum(img.diffuse, 2);
img.normedDiffuse = bsxfun(@rdivide, img.diffuse, img.norm); 
img.sz = size(img.mask);

% init the diff operators
opts = struct();
[opts.filterH, opts.filterV] = create4connected_L1(m, n, img.mask);
opts.laplacian = create4connected(m, n, img.mask);

% initialize the energy term stack
opts.energyStack = {};
opts.energyWeights = {};

% we would like to optimize this
r = initializeR(img, parameter);

% the different energy terms stacked upon each other
if (parameter.c_R ~= 0)
    reflectanceWeights = ones(size(img.mask));
    fprintf('starting cluster term\n');
    tic
    opts.energyStack{end+1} =...
        ClusterTerm(img, parameter, opts, r);
    opts.energyWeights{end+1} = parameter.c_R;
    toc
    fprintf('done clusterTerm\n');
end


if (parameter.c_smooth ~= 0)
    opts.energyStack{end+1} =...
        SmoothTerm(img, opts);
    opts.energyWeights{end+1} = parameter.c_smooth;
end

if (parameter.c_cret ~= 0)
    opts.energyStack{end+1} = DiffTerm(img, parameter, opts);
    opts.energyWeights{end+1} = parameter.c_cret;
end

%  result.sse = zeros(0, 0);
lastEnergy = Inf;
energy = Inf;
for i=1:parameter.maxIterations
    fprintf('iteration %d lastE=%g E=%g\n', i, lastEnergy, energy)
    lastEnergy = energy;
    % optimize r given split
    r = minimize(r, @objective, ...
                 struct('length', parameter.minimizeMaxIter, 'verbosity', 1), ...
                 img, parameter, opts);

    energy = objective(r, img, parameter, opts);
    diffEnergy = lastEnergy - energy;
    assert(diffEnergy >= 0);

    % update the terms after the minimization step
    for i=1:numel(opts.energyStack)
        term = opts.energyStack{i};
        opts.energyStack{i} = term.update(term, r);
    end

    estR = insertIntoMask(bsxfun(@times, img.normedDiffuse, r), ...
                                    img.mask);
    estL = insertIntoMask(img.norm./r, img.mask);
    sfigure(13);
    suptitle(sprintf('at iteration %d', i));
    subplot(2, 2, 1);
    imshow(insertIntoMask(r, img.mask), []);
    subplot(2, 2, 3);
    image(getNormalized(estR)); title('estimated reflectance')
    subplot(2, 2, 4);
    image(getNormalized(repmat(estL, [1, 1, 3])));
    title('estimated shading')
    %    drawnow;

    % result.sse(end+1) = lmse(img.reflectance, img.shading, ...
    %                          estR, estL, 20);
    % fprintf('SSE %f\n', result.sse(end));

    energy = objective(r, img, parameter, opts);
    diffEnergy = lastEnergy - energy;
    assert(diffEnergy >= 0);
    fprintf('E   %f\n', energy);

    if diffEnergy < parameter.energyThresh
        break;
    end
end

estR = r;
fprintf('END of decomposition (\# iteration=%d)', i);

save(outPath,'estR');

function [f, df] = objective(r, img, parameter, opts)
  if any(vec(r <= 0))
    error('r not positiv');
  end

  f = 0;
  df = zeros(size(r));

  for i=1:numel(opts.energyStack)
    term = opts.energyStack{i};
    [E, dE] = term.getEnergy(term, r);
    f = f + E * opts.energyWeights{i};
    df = df + dE * opts.energyWeights{i};
  end

  % project the gradient back such that mean(r) does not change
  if parameter.sumConstraint
    df = df - mean(df(:));
  end

function [r] = initializeR(img, parameter)
  switch parameter.reflectanceInit
  case 'normI'
    r = img.norm;

  case 'ones'
    r = ones(size(img.diffuse, 1), 1);

  case 'mixed'
    r = parameter.startFac * 3*ones(size(img.diffuse, 1), 1);
    r = r + (1-parameter.startFac) * img.norm;

  otherwise
    error('unknown reflectanceInit');
  end

  if parameter.sumConstraint
    r = r./sum(r(:));
    r = r.*numel(r);
  end

  assert(~any(isnan(r(:))))
  assert(all(r(:)>=0));
