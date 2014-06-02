% Does a crude white balancing by linearly scaling each color channel.
clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
% clear;  % Erase all existing variables.
% workspace;  % Make sure the workspace panel is showing.
 format longg;
 format compact;
 fontSize = 15;
% % Read in a standard MATLAB gray scale demo image.
% folder = fullfile(matlabroot, '\toolbox\images\imdemos');
% button = menu('Use which demo image?', 'onion', 'Kids');
% % Assign the proper filename.
% if button == 1
% 	baseFileName = 'onion.png';
% elseif button == 2
% 	baseFileName = 'kids.tif';
% end
% % Read in a standard MATLAB color demo image.
% folder = fullfile(matlabroot, '\toolbox\images\imdemos');
% % Get the full filename, with path prepended.
% fullFileName = fullfile(folder, baseFileName);
% if ~exist(fullFileName, 'file')
% 	% Didn't find it there.  Check the search path for it.
% 	fullFileName = baseFileName; % No path this time.
% 	if ~exist(fullFileName, 'file')
% 		% Still didn't find it.  Alert user.
% 		errorMessage = sprintf('Error: %s does not exist.', fullFileName);
% 		uiwait(warndlg(errorMessage));
% 		return;
% 	end
% end
% [rgbImage colorMap] = imread(fullFileName);
% % Get the dimensions of the image.  numberOfColorBands should be = 3.
% [rows columns numberOfColorBands] = size(rgbImage);
% % If it's an indexed image (such as Kids),  turn it into an rgbImage;
% if numberOfColorBands == 1
% 	rgbImage = ind2rgb(rgbImage, colorMap); % Will be in the 0-1 range.
% 	rgbImage = uint8(255*rgbImage); % Convert to the 0-255 range.
% end
rgbImage = curIm;
% Display the original color image full screen

whiteCroppingRectangle = getColorROIs(rgbImage,'Mark white region and then double click outside box to continue.');
redCroppingRectangle = getColorROIs(rgbImage,'Mark red region and then double click outside box to continue.');
greenCroppingRectangle = getColorROIs(rgbImage,'Mark green region and then double click outside box to continue.');
blueCroppingRectangle = getColorROIs(rgbImage,'Mark blue region and then double click outside box to continue.');


% Crop out the ROI.
whitePortion = imcrop(rgbImage, whiteCroppingRectangle);
subplot(2, 4, 5);
imshow(whitePortion);
caption = sprintf('ROI.\nWe will Define this to be "White"');
title(caption, 'FontSize', fontSize);

% Extract the individual red, green, and blue color channels.
redPortion = imcrop(rgbImage, redCroppingRectangle);
greenPortion = imcrop(rgbImage, greenCroppingRectangle);
bluePortion = imcrop(rgbImage, blueCroppingRectangle);

redChannel = rgbImage(:, :, 1);
greenChannel = rgbImage(:, :, 2);
blueChannel = rgbImage(:, :, 3);

% redChannel = redPortion(:, :, 1);
% greenChannel = greenPortion(:, :, 2);
% blueChannel = bluePortion(:, :, 3);

redPortion = redPortion(:, :, 1);
greenPortion = greenPortion(:, :, 2);
bluePortion = bluePortion(:, :, 3);

% Get the means of each color channel
meanR = mean2(redChannel);
meanG = mean2(greenChannel);
meanB = mean2(blueChannel);


% meanOfColorChecker Values = (190 + 204 + 203) / 3
% red_new = redFullIm * mean / 190
% green_new = greenFullIm * mean / 204
% blue_new = blue * mean / 203

%% Show some stuff
% Display the color channels.
subplot(2, 4, 2);
imshow(redChannel);
title('Red Channel ROI', 'FontSize', fontSize);
subplot(2, 4, 3);
imshow(greenChannel);
title('Green Channel ROI', 'FontSize', fontSize);
subplot(2, 4, 4);
imshow(blueChannel);
title('Blue Channel ROI', 'FontSize', fontSize);

% Let's compute and display the histograms.
[pixelCount grayLevels] = imhist(redChannel);
subplot(2, 4, 6); 
bar(pixelCount);
grid on;
caption = sprintf('Histogram of original Red ROI.\nMean Red = %.1f', meanR);
title(caption, 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.
% Let's compute and display the histograms.
[pixelCount grayLevels] = imhist(greenChannel);
subplot(2, 4, 7); 
bar(pixelCount);
grid on;
caption = sprintf('Histogram of original Green ROI.\nMean Green = %.1f', meanR);
title(caption, 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.
% Let's compute and display the histograms.
[pixelCount grayLevels] = imhist(blueChannel);
subplot(2, 4, 8); 
bar(pixelCount);
grid on;
caption = sprintf('Histogram of original Blue ROI.\nMean Blue = %.1f', meanR);
title(caption, 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.
%%

% specify the desired mean.
desiredMean = mean([meanR, meanG, meanB])
message = sprintf('Red mean = %.1f\nGreen mean = %.1f\nBlue mean = %.1f\nWe will make all of these means %.1f',...
	meanR, meanG, meanB, desiredMean);
uiwait(helpdlg(message));

% Linearly scale the image in the cropped ROI.
correctionFactorR = desiredMean / meanR;
correctionFactorG = desiredMean / meanG;
correctionFactorB = desiredMean / meanB;

redChannel = uint8(single(redChannel) * correctionFactorR);
greenChannel = uint8(single(greenChannel) * correctionFactorG);
blueChannel = uint8(single(blueChannel) * correctionFactorB);
% Recombine into an RGB image
% Recombine separate color channels into a single, true color RGB image.
correctedRgbImage = cat(3, redChannel, greenChannel, blueChannel);
figure;
% Display the original color image.
subplot(2, 4, 5);
imshow(correctedRgbImage);
title('Color-Corrected ROI', 'FontSize', fontSize);
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
% Display the color channels.
subplot(2, 4, 2);
imshow(redChannel);
title('Corrected Red Channel ROI', 'FontSize', fontSize);
subplot(2, 4, 3);
imshow(greenChannel);
title('Corrected Green Channel ROI', 'FontSize', fontSize);
subplot(2, 4, 4);
imshow(blueChannel);
title('Corrected Blue Channel ROI', 'FontSize', fontSize);
% Let's compute and display the histograms of the corrected image.
[pixelCount grayLevels] = imhist(redChannel);
subplot(2, 4, 6); 
bar(pixelCount);
grid on;
caption = sprintf('Histogram of Corrected Red ROI.\nMean Red = %.1f', meanR);
title(caption, 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.
% Let's compute and display the histograms.
[pixelCount grayLevels] = imhist(greenChannel);
subplot(2, 4, 7); 
bar(pixelCount);
grid on;
caption = sprintf('Histogram of Corrected Green ROI.\nMean Green = %.1f', meanR);
title(caption, 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.
% Let's compute and display the histograms.
[pixelCount grayLevels] = imhist(blueChannel);
subplot(2, 4, 8); 
bar(pixelCount);
grid on;
caption = sprintf('Histogram of Corrected Blue ROI.\nMean Blue = %.1f', meanR);
title(caption, 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.
% Get the means of the corrected ROI for each color channel.
meanR = mean2(redChannel);
meanG = mean2(greenChannel);
meanB = mean2(blueChannel);
correctedMean = mean([meanR, meanG, meanB])
message = sprintf('Now, the\nCorrected Red mean = %.1f\nCorrected Green mean = %.1f\nCorrected Blue mean = %.1f\n(Differences are due to clipping.)\nWe now apply it to the whole image',...
	meanR, meanG, meanB);
uiwait(helpdlg(message));
% Now correct the original image.
% Extract the individual red, green, and blue color channels.
redChannel = rgbImage(:, :, 1);
greenChannel = rgbImage(:, :, 2);
blueChannel = rgbImage(:, :, 3);
% Linearly scale the full-sized color channel images
redChannelC = uint8(single(redChannel) * correctionFactorR);
greenChannelC = uint8(single(greenChannel) * correctionFactorG);
blueChannelC = uint8(single(blueChannel) * correctionFactorB);
% Recombine separate color channels into a single, true color RGB image.
correctedRGBImage = cat(3, redChannelC, greenChannelC, blueChannelC);
subplot(2, 4, 1);
imshow(correctedRGBImage);
title('Corrected Full-size Image', 'FontSize', fontSize);
message = sprintf('Done with the demo.\nPlease flicker between the two figures');
uiwait(helpdlg(message));

