%% Convert an RGB image into L*a*b* color space
% Code from here: http://www.mathworks.com.au/products/demos/image/color_seg_k/ipexhistology.html
function [labim] = makelab(rgbImage)
    tic
colorTransform = makecform('srgb2lab');
    labim = applycform(rgbImage, colorTransform);
    L= labim(:, :, 1);  % Extract the L image.
    A= labim(:, :, 2);  % Extract the A image.
    B= labim(:, :, 3);  % Extract the B image.
    ['conversion happened in ' num2str(toc) ' seconds']
end
