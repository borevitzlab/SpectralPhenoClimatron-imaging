curIm = imread('C:\Users\Tim Brown\Documents\ANU\Projects\SpectralPhenoclimatron\Process images\images\GC02-NC011AllNoon\NCRIS-GC02-1-BZ0012-BVZNC01_2013_03_12_12_00_00_00.jpg');


imshow(curIm)

I = rgb2gray(curIm);
hold on, title('Original Image');

mask = false(size(I));
mask(509:655,797:951) = true;

% Display the initial contour on the original image in blue.
contour(mask,[0 0],'b');

bw = activecontour(I, mask, 50);
  
% Display the final contour on the original image in red.
contour(bw,[0 0],'r'); 
legend('Initial Contour','Final Contour');
  
% Display segmented image.
figure, imshow(bw)
title('Segmented Image');
