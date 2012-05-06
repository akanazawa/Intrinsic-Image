function convertData(DIR, fpath, npath)

depth_file = fullpath(DIR, 'depth.txt');
normal_file = fullpath(DIR, 'normal.txt');
    
imwrite(c, fpath, 'png');
save(npath, 'n')
