function R = im2retinex(imPath, outPath, parameter)

% assuming image as 3 RGB color
I = imread(imPath);
R = zeros(size(I));
for i = [1:3]
    Ic = double(I(:, :, i));
    lIc = log(Ic + 1)./log(256); % logarithmic image in range [0,1]
    R(:, :, i) = chanel2retinex99(lIc, parameter.nIterations);
end

save(outPath, 'R');
