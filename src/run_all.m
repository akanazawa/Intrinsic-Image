% take a picture with kinnect, save depth and normal file
DIR = '../data/pcd_data/frame001';
DIR = '../data/pcd_data/bed';
% write the RGB to a PNG file
convertData(DIR);

% 3. in shell call the python script = write R.png
system(sprintf('python ../MIT-intrinsic/retinex_aj.py %s %s',...
               fpath,DIR));

% 4. estimate S
fpath = fullfile(DIR, 'img.png');
npath = fullfile(DIR, 'normal.mat');
rpath = fullfile(DIR, 'R.png');
dpath = fullfile(DIR, 'depth.mat');
I = im2double(imread(fpath));
r = im2double(imread(rpath));
N = load(npath);
N = N.n;
[R, L, N] = estimateS(I, r, N);
albedoPath = fullfile(DIR, 'Rfinal.png') 
imwrite(R, albedoPath, 'png');
%imwrite(L, fullfile(DIR, 'Lfinal.png'));

I = im2double(imread(fpath)); % m x n x 3
r = im2double(imread(rpath)); % m x n
[m n d] = size(I);
I2 = reshape(I, [m*n, d]); % stacked
I_norm = sqrt(sum(I2.^2, 2));
chromaticity = bsxfun(@rdivide, I2, I_norm);
Rret = reshape(bsxfun(@times, r(:), chromaticity), [m n d]);

addpath(genpath('../edison/'));


[fim0 labels0 modes0 regSize0] = edison_wrapper(I, @RGB2Luv, 'SpatialBandWidth', 15, 'MinimumRegionArea', 75);  
fim0 = Luv2RGB(fim0);
[fim1 labels1 modes1 regSize1] = edison_wrapper(Rret, @RGB2Luv, 'SpatialBandWidth', 15, 'MinimumRegionArea', 75);  
fim1 = Luv2RGB(fim1);

% R2 = reshape(R, [m*n, d]);
% R2_norm = sqrt(sum(R2.^2, 2));
% R2 = bsxfun(@rdivide, R2, R2_norm);
% Runit = reshape(R2, [m n d]);

[fim labels modes regSize] = edison_wrapper(Runit, @RGB2Luv, 'SpatialBandWidth', 15, 'MinimumRegionArea', 75);  
fim = Luv2RGB(fim);

sfigure; subplot(221); imagesc(fim0); axis off image;
title('segmentation on original');
subplot(222); imagesc(fim1);axis off image;
title('segmentation on color-retinex');
subplot(223); imagesc(fim);axis off image;
title('segmentation on our reflectance');
