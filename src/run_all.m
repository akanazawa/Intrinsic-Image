% take a picture with kinnect, save depth and normal file
DIR = 'data/0506123/'
fpath = fullpath(DIR, 'rgb.png');

% write the RGB to a PNG file
saveRGB(DIR, fpath);

% 3. in shell call the python script = write R.png
system(sprintf('python ../MIT-intrinsic/retinex_aj.py %s %s',...
               fpath,DIR));

npath = fullpath(DIR, 'normal.txt');
path = fullpath(DIR, 'R.png');

% 4. estimate S
estiamteS(fpath, rpath, npath)

