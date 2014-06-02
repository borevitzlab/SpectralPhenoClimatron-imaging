function [x,y] = getROI(newim, numCoords,txt)
if nargin < 3
    txt = [];
end

imshow(newim);
iminfo  = size(newim); %This gives us width and height of image
imhgt = iminfo(1);
imwid = iminfo(2);
if length(txt) == 0
    txt = 'Click on the TopLeft of the ROI and then the BottomRight and then close the figure. If more then one ROI is being selected the image will open multiple times.'
end

title(txt);
[x,y] = ginput(numCoords);

for i = 1:numCoords
    if x(i)<= 0
        x(i) = 1
    end
    if y(i) <= 0
        y(i) = 1
    end
    if x(i) > imwid
        x(i) = imwid
    end
    if y(i) > imhgt
        y(i) = imhgt
    end
end
'New ROI:'
x=round(x);
y=round(y);

%Close the figure when done
delete(gcf)
end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
