function convertData(DIR)

depth_file = fullfile(DIR, 'frame.txt');
normal_file = fullfile(DIR, 'norms.txt');

d_nan = dlmread(depth_file);
n_nan = dlmread(normal_file);

c_pack = uint32(reshape(d_nan(:,4), [640 480]));
d_nan = reshape(d_nan(:,1:3), [640 480 3]);
n_nan = reshape(n_nan(:,1:3), [640 480 3]);

d_nan = permute(d_nan, [2 1 3]);
n_nan = permute(n_nan, [2 1 3]);

% Unpacking color values from 32-bit int
c = uint8(zeros(480, 640, 3));
c(:,:,1) = uint8(bitand(bitshift(c_pack, -16), uint32(255)))';
c(:,:,2) = uint8(bitand(bitshift(c_pack, -8), uint32(255)))';
c(:,:,3) = uint8(bitand(c_pack, uint32(255)))';

% Cropping by 50 pixels to be safe
% since normal and depth data at boundaries is missing
c = c(51:end-50, 51:end-50, :);
n_nan = n_nan(51:end-50, 51:end-50, :);
d_nan = d_nan(51:end-50, 51:end-50, :);

d = zeros(size(d_nan));
n = zeros(size(n_nan));

% Inpainting each channel of the depth
d(:,:,1) = inpaint_nans(d_nan(:,:,1),2);
d(:,:,2) = inpaint_nans(d_nan(:,:,2),2);
d(:,:,3) = inpaint_nans(d_nan(:,:,3),2);

% Inpainting each channel of the normals
n(:,:,1) = inpaint_nans(n_nan(:,:,1),2);
n(:,:,2) = inpaint_nans(n_nan(:,:,2),2);
n(:,:,3) = inpaint_nans(n_nan(:,:,3),2);

% Norm of the normals should be 1
n_norm = sqrt(sum(n.^2,3));
n(:,:,1) = n(:,:,1)./n_norm;
n(:,:,2) = n(:,:,2)./n_norm;
n(:,:,3) = n(:,:,3)./n_norm;

imwrite(c, fullfile(DIR, 'img.png'), 'png');
save(fullfile(DIR, 'normal.mat'), 'n');
save(fullfile(DIR, 'depth.mat'), 'd');
