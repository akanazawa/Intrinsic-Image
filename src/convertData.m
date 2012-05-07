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

d = zeros(480, 640, 3);
n = zeros(480, 640, 3);

d(:,:,1) = inpaint_nans(d_nan(:,:,1),2);
d(:,:,2) = inpaint_nans(d_nan(:,:,2),2);
d(:,:,3) = inpaint_nans(d_nan(:,:,3),2);

n(:,:,1) = inpaint_nans(n_nan(:,:,1),2);
n(:,:,2) = inpaint_nans(n_nan(:,:,2),2);
n(:,:,3) = inpaint_nans(n_nan(:,:,3),2);

c = uint8(zeros(480, 640, 3));
c(:,:,1) = uint8(bitand(bitshift(c_pack, -16), uint32(255)))';
c(:,:,2) = uint8(bitand(bitshift(c_pack, -8), uint32(255)))';
c(:,:,3) = uint8(bitand(c_pack, uint32(255)))';

[m n d] = size(c);
c = c(51:end-50, 51:end-50, :);
n = n(51:end-50, 51:end-50, :);
d = d(51:end-50, 51:end-50, :);

imwrite(c, fullfile(DIR, 'img.png'), 'png');
save(fullfile(DIR, 'normal.mat'), 'n');
save(fullfile(DIR, 'depth.mat'), 'd');
