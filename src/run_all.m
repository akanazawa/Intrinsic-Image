% take a picture with kinnect, save depth and normal file
DIR = '../data/pcd_data/frame006';
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

estimateS(fpath, rpath, npath);

