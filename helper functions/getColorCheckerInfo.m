function [croppingRectangle] = getColorCheckerInfo(im)

figure, imshow(im);
title('(1) Click and drag to select the color checker. (2) double-click in the box you made. The figure will zoom in. (4) Select as close as you an to the colorchecker edges and double click in the box again')
hBox = imrect;
roiPosition = wait(hBox);	% Wait for user to double-click
roiPosition % Display in command window.

x1 = roiPosition(1);, x2=x1+roiPosition(3);
y1 = roiPosition(2);, y2=y1+roiPosition(4);
xlim([x1,x2]);
ylim([y1,y2]);


hBox = imrect;
roiPosition = wait(hBox);	% Wait for user to double-click
x1 = roiPosition(1);, x2=x1+roiPosition(3);
y1 = roiPosition(2);, y2=y1+roiPosition(4);
xlim([x1,x2]);
ylim([y1,y2]);
close
croppingRectangle = roiPosition;

%ccr = imcrop(I3, roiPosition);
%imshow(ccr);

end