function toyexample()
%%%%%%%%%%%%%%%%%%%%
% Evaluating the system with synthesized images with gt
%
%
% I = R*L
% R = r I/||I|| % delta prior
% ||I|| = r*s
%%%%%%%%%%%%%%%%%%%%
fpath = '../data/toyexample/teapot.png';
npath = '../data/toyexample/normals.png';
rpath = '../data/toyexample/albedo.png';
cretpath = '../data/toyexample/R_cretinex.png';

I = im2double(imread(fpath));
cret = im2double(imread(cretpath));
%% ground truth
albedo = im2double(imread(rpath)); 
N = im2double(imread(npath));
[L, r] = getGtL(I, albedo, N);

%% estimates
[Rh, Lh, ~, S] = estimateS(I, cret, N);
score1 = scoreImage(L, albedo, Lh, Rh);
mseL = ssq_error(L, Lh);
%% estimates using the ground truth albedo initialization

[Rh2, Lh2, ~, S2] = estimateS(I, albedo, N);
score2 = scoreImage(L, albedo, Lh2, Rh2);
mseL2 = ssq_error(L, Lh2);
keyboard
sfigure; subplot(131); imagesc(albedo); title('albedo');
axis off image
subplot(132); imagesc(L);colormap(gray);  title('shading');
axis off image
subplot(133); imagesc(N); title('surface normals');
axis off image
suptitle('ground truth');

sfigure; subplot(131); imshow(Rh, []); title('albedo');
axis off image
subplot(132); imagesc(Lh);colormap(gray);  title('shading');
axis off image
subplot(133); sphere; light('Position', S); shading interp;
title('estimated light source'); axis equal 
suptitle('estimated output using C-Retinex as initialization');

sfigure; subplot(131); imshow(Rh2, []); title('albedo');
axis off image
subplot(132); imagesc(Lh2);colormap(gray);  title('shading');
axis off image
subplot(133); sphere; light('Position', S2); shading interp;
title('estimated light source'); axis equal 
suptitle('estimated output using ground truth as initialization');

sfigure; subplot(121); imagesc(cret); title('albedo');
axis off image; colormap(gray)
subplot(122); imagesc((mean(I, 3)./cret)); colormap(gray);  title('shading');
axis off image
suptitle('estimated output of color retinex');

end

function [L, r] =  getGtL(I, albedo, N)
[m, n, d] = size(I);
I2 = reshape(I, [m*n, d]); 
I_norm = sqrt(sum(I2.*I2, 2));
chromaticity = bsxfun(@rdivide, I2, I_norm);
chromaticity = reshape(chromaticity, [m n d]);

r = albedo./chromaticity;
r(isinf(r)) = 0;
r(isnan(r)) = 0;

L = I./albedo;
L(isnan(L)) = 0; 
L = mean(L, 3);

% reconstruction with the delta prior
I2 = bsxfun(@times, r.*chromaticity, L);
I2(isnan(I2)) = 0;
end

function score = local_error(gt, est, window)
    if numel(size(gt)) == 3, [m, n, ~] = size(gt); 
    else [m, n] = size(gt); end
    shift = floor(window/2);
    ssq = 0; total = 0;
    for i = 1:shift:(m-window)
        for j = 1:shift:(n-window)
            gt_ij = gt(i:i+window, j:j+window);
            est_ij = est(i:i+window, j:j+window);
            ssq = ssq + ssq_error(gt_ij, est_ij);
            total = total + sum(gt_ij(:).^2);
        end
    end
    score = ssq/total;
end

function e =  ssq_error(gt, est);
    if sum(est(:)) ~= 0,
        alpha = sum(sum(gt.*est))./sum(est(:).^2);
    else, alpha = 0; end
     e = sum(sum((gt - alpha.*est).^2));
end

function score = scoreImage(L, R, estL, estR)
    window = 20;
    score = 0.5*local_error(L, estL, 20) + ...
            0.5*local_error(R, estR, 20);
end
