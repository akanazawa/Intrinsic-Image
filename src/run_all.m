% take a picture with kinnect, save depth and normal file
DIR = '../data/pcd_data/frame001';
fpath = fullfile(DIR, 'img.png');
npath = fullfile(DIR, 'normal.mat');
% write the RGB to a PNG file
convertData(DIR, fpath, npath);

% 3. in shell call the python script = write R.png
system(sprintf('python ../MIT-intrinsic/retinex_aj.py %s %s',...
               fpath,DIR));


rpath = fullfile(DIR, 'R.png');

% 4. estimate S
estimateS(fpath, rpath, npath);

