function [R, L, N, S] = estimateS(I, r, N)%fpath, rpath, npath)
%%%%%%%%%%%%%%%%%%%%
% estimateS.m
%  given I, R, minimizes I = R*max(N*S, 0)
%  First assuming single light source, solve for S: ||I|| = (sum_i^N
%  r.*N)*S
% input:
%   - I: original image in [0, 1]
%   - r: initial aalbedo estimates
%   - N: m x n x 3 matrix of normals
% output:
%   - S: estimated light sources 
%   - R: refle
%%%%%%%%%%%%%%%%%%%%
assert(all(size(I) == size(N)))

[m, n, d] = size(I);
I2 = reshape(I, [m*n, d]); % stacked
N2 = reshape(N, [m*n, d]);

I_norm = sqrt(sum(I2.^2, 2));
chromaticity = bsxfun(@rdivide, I2, I_norm);

A2 = N2;
if numel(size(r)) == 2
    A = bsxfun(@times, r(:), N2);
    S = A\I_norm;
else
    b2 = I2./reshape(r, [m*n, d]);
    b2(isnan(b2)) = 0;
    S = A2\b2;
    S = mean(S, 2);
end
% minimize whatever s1+s2+s3 s.t. Ax = b and -N*x <= [0..0]
%S1 = linprog([-1,-1,-1], -N2, zeros(m*n, 1), A, I_norm);
% solve 1/2*||Ax-b||^2 s.t. -N*x <= [0..0]
%S2 = lsqlin(A, I_norm, N2, zeros(m*n, 1)); % 3 x 1

%using delta prior
% S3 = A\I_norm;

S = 3*(S./norm(S));

%%%%%%%%%% now reestimate R using L = N_i*S
Lhat = max(N2*S, 0); % m*n x 1
rhat = bsxfun(@rdivide, I2, Lhat);

if numel(size(r)) == 2,
    Lret = reshape(mean(I, 3)./r, [m n]);
else
    Lret = mean(I./r, 3);
end
Lret(isnan(Lret)) = 0;
rhat(isnan(rhat)) = 0;
rhat(isinf(rhat)) = 0;
%% normalize albedo? 
% R_norm = sqrt(sum(R.^2, 2));
% R = bsxfun(@rdivide, R, R_norm);
R = reshape(rhat, [m n d]);

%%plot
sfigure; subplot(231); imagesc(I); title('original'); axis off image;

subplot(232); imshow(r); title('c-retinex albedo');
subplot(233); imshow(Lret, []); title('c-retinex shading');

subplot(234); sphere; light('Position', S); shading interp;
title('estimated light source');

subplot(235); imshow(R, []); title('estimated albedo with normal');
L = reshape(Lhat, [m n]);
subplot(236); imshow(L, []); title('estimated shading with normal');

sfigure; imagesc(abs(N)./max(max(max(abs(N))))); title('estimated surface normals');

