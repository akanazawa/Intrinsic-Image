function convertData(DIR, fpath, npath)

depth_file = fullpath(DIR, 'depth.txt');
normal_file = fullpath(DIR, 'normal.txt');

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

imwrite(c, fpath, 'png');
save(npath, 'n');
save(fullpath(DIR, 'depth.mat'), 'd');
