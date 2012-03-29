function [I,R,S,C,mask] = mitLoad(imname)

imdir = [getDataDir(),imname,'/'];


% we load the diffuse and not the original image as in the MIT code!
I = imread([imdir,'diffuse.png']); 
R = imread([imdir,'reflectance.png']);
S = imread([imdir,'shading.png']);
C = imread([imdir,'specular.png']);
mask = imread([imdir,'mask.png']);

I = double(I);
R = double(R);
S = double(S);
C = double(C);
mask = double(mask);

I = I./(2^16-1);
R = R./(2^16-1);
S = S./(2^16-1);
C = C./(2^16-1);
mask(mask>0) = 1;
