function [S, R, I] = estimateS(fpath, rpath, npath)
%%%%%%%%%%%%%%%%%%%%
% estimateS.m
%  given I, R, minimizes I = R*max(N*S, 0)
%  First assuming single light source, solve for S: ||I|| = (sum_i^N
%  r.*N)*S
% input:
%   - fpath: path to the img file
%   - rpath: path to the initial estimate of r from retinex
%   - npath: path to the text file with normals
%
% output:
%   - S: estimated light sources 
%   - R: refle
%%%%%%%%%%%%%%%%%%%%

I = im2double(imread(fpath)); % m x n x 3
r = im2double(imread(rpath)); % m x n
N = load(npath); % m x n x 3
N = N.n;
assert(all(size(I) == size(N)))

[m, n, d] = size(I);
I2 = reshape(I, [m*n, d]); % stacked
N2 = reshape(N, [m*n, d]);

I_norm = sum(I2.^2, 2);
chromaticity = bsxfun(@rdivide, I2, I_norm);
A = bsxfun(@times, r(:), N2);

% minimize whatever s1+s2+s3 s.t. Ax = b and -N*x <= [0..0]
%S1 = linprog([-1,-1,-1], -N2, zeros(m*n, 1), A, I_norm);

% solve 1/2*||Ax-b||^2 s.t. -N*x <= [0..0]
%S2 = lsqlin(A, I_norm, N2, zeros(m*n, 1)); % 3 x 1
S3 = A\I_norm;
S = S3;
%%%%%%%%%% now reestimate R using L = N_i*S
Lhat = max(N2*S, 0); % m*n x 1
rhat = I_norm./Lhat;
rhat(find(rhat==Inf)) = 0;
R0 = reshape(bsxfun(@times, rhat, chromaticity), [m n d]);
R = bsxfun(@rdivide, I, reshape(Lhat, [m n]));

%%plot
sfigure; subplot(231); imagesc(I); title('original'); axis off image;
Rret = reshape(bsxfun(@times, r(:), chromaticity), [m n d]);
%Lret = I./Rret; % this is color
%Lret = reshape(I_norm./r(:), [m n]);
Lret = reshape(mean(I, 3)./r, [m n]);
%subplot(232); imshow(Rret, []); title('c-retinex albedo');
subplot(232); imshow(r); title('c-retinex albedo intensity');
subplot(233); imshow(Lret, []); title('c-retinex shading');

subplot(234); sphere; light('Position', S); shading interp;
title('estimated light source');

subplot(235); imshow(R); title('albedo with normal');
%subplot(232); imshow(reshape(rhat, [m n])); title('albedo intensity');
L = reshape(Lhat, [m n]);
subplot(236); imshow(L, []); title('shading with normal');
keyboard

