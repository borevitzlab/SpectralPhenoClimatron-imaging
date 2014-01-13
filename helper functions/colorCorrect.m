


imPath =  'C:\Users\Tim Brown\Documents\ANU\Projects\SpectralPhenoclimatron\Process images\TimCode\images\GC02-CN650D-01\GC02-CN650D-01_2013_03_21_17_40_00_00.jpg'
curIm = imread(imPath);

%Split out the channels
reds = curIm(:,:,1);
greens = curIm(:,:,2);
blues = curIm(:,:,3);

meanR=255
meanG=148
meanB=255
%meanR = mean2(redChannel);
%meanG = mean2(greenChannel);
%meanB = mean2(blueChannel);

% specify the desired mean.
desiredMean = mean([meanR, meanG, meanB])

% Linearly scale the image in the cropped ROI.
correctionFactorR = desiredMean / meanR;
correctionFactorG = desiredMean / meanG;
correctionFactorB = desiredMean / meanB;
reds = uint8(single(reds) * correctionFactorR);
greens = uint8(single(greens) * correctionFactorG);
blues = uint8(single(blues) * correctionFactorB);
% Recombine into an RGB image
% Recombine separate color channels into a single, true color RGB image.
correctedRgbImage = cat(3, reds, greens, blues);
