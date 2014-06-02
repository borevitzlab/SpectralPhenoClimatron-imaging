function [croppingRectangle] = getColorROIs(rgbImage, titleText)

 format longg;
 format compact;
 fontSize = 15;

imshow(rgbImage);
set(gcf,'Position',get(0,'Screensize'))
title(titleText, 'FontSize', fontSize);

% Enlarge figure to full screen.
%set(gcf, 'units','normalized','outerposition', [0 0 1 1]);

% Have user specify the area they want to define as neutral colored (white  or gray).
promptMessage = sprintf('Drag out a box over the ROI you want to be neutral colored.\nDouble-click inside of it to finish it.');
titleBarCaption = 'Continue?';
button = questdlg(promptMessage, titleBarCaption, 'Draw', 'Cancel', 'Draw');
if strcmpi(button, 'Cancel')
	return;
end
hBox = imrect;
roiPosition = wait(hBox);	% Wait for user to double-click
roiPosition % Display in command window.
% Get box coordinates so we can crop a portion out of the full sized image.
xCoords = [roiPosition(1), roiPosition(1)+roiPosition(3), roiPosition(1)+roiPosition(3), roiPosition(1), roiPosition(1)];
yCoords = [roiPosition(2), roiPosition(2), roiPosition(2)+roiPosition(4), roiPosition(2)+roiPosition(4), roiPosition(2)];
croppingRectangle = roiPosition;
% Display (shrink) the original color image in the upper left.
subplot(2, 4, 1);
imshow(rgbImage);
title('Original Color Image', 'FontSize', fontSize);
