myplant=allPots{20,8};
minrad = 48;
maxrad = 53;


BW = im2bw((myplant));

[H,T,R] = hough(BW);
imshow(H,[],'XData',T,'YData',R,...
            'InitialMagnification','fit');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;

P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
x = T(P(:,2)); y = R(P(:,1));
plot(x,y,'s','color','white');
% Find lines and plot them
lines = houghlines(BW,T,R,P,'FillGap',5,'MinLength',1);
figure, imshow(myplant), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end



return
myplant=allPots{20,8};
minrad = 48;
maxrad = 53;
[centers, radii] =imfindcircles(myplant,[minrad,maxrad],'sensitivity',1,'EdgeThreshold',.8);
imshow(myplant)
hold on
viscircles(centers,radii);

return

%Full size of image:
fullDims



% Create a logical image of a circle with specified
% diameter, center, and image size.
% First create the image.
imageSizeX = fullDims;
imageSizeY = fullDims;
[columnsInImage rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% Next create the circle in the image.
centerX = imageSizeX/2;
centerY = imageSizeX/2;
radius = imageSizeX/2;
circlePixels = (rowsInImage - centerY).^2 ...
    + (columnsInImage - centerX).^2 <= radius.^2;
% circlePixels is a 2D "logical" array.
% Now, display it.
image(circlePixels) ;
colormap([0 0 0; 1 1 1]);
title('Binary image of a circle');

testPlant = allPots{20,8};

circlePixels = im2unit8(circlePixels);
curPixels=testPlant(:,:,1);
curPixels(:,:,1) = curPixels(:,:,1).*circlePixels;
curPixels = curPixels.*circlePixels;

return
for i = 1:15
%    curday = greens(i,:);
    avgreens(i) = mean(greens(i,:));
    stdgreens(i) = std(greens(i,:));
end

for i = 1:15
%    curday = greens(i,:);
    avgreens05(i) = mean(greens05(i,:)) ;
    stdgreens05(i) = std(greens05(i,:)) ;
end

suag = avgreens + stdgreens
slag = avgreens - stdgreens
suag05 = avgreens05 + stdgreens05
slag05 = avgreens05 - stdgreens05

plot(avgreens,'b');
hold on
plot(avgreens05,'r');
plot(suag,'b:')
plot(slag,'b:')
plot(suag05,'r:')
plot(slag05,'r:')
return

 curIm=imread([imFolderPath, files(i).name]);
 curIm3 = unwarp(curIm,totalRotation,imCenter,imCropCoords,unwarpAmt);

    
testIm = I;
testIm2 = lensdistort(testIm,unwarpAmt,'interpolation','nearest','padmethod','replicate','ftype',4, 'ImCenter', imCenter);
testIm3 = imrotate(testIm2, totalRotation);

imshow(curIm2);
title('curIm2');
figure
imshow(curIm3)
title('curIm3');

figure
imshow(testIm2)
title('testIm2');
figure
imshow(testIm3)
title('testIm3');

return

curIm = I;
% This gets a lot: BW2=(I(:,:,1)-I(:,:,2)>0);

BW1=(I(:,:,1)-I(:,:,2)>0);
BW1= BW1*255;
BW1=im2uint8(BW1);
plants1(:,:,1)=curIm(:,:,1)-BW1;
plants1(:,:,2)=curIm(:,:,2)-BW1;
plants1(:,:,3)=curIm(:,:,3)-BW1;

BW2=(I(:,:,1)+I(:,:,2)<200);
BW2= BW2*255;
BW2=im2uint8(BW2);
plants2(:,:,1)=plants1(:,:,1)-BW2;
plants2(:,:,2)=plants1(:,:,2)-BW2;
plants2(:,:,3)=plants1(:,:,3)-BW2;



bluethresh = 240
blues = plants2(:,:,3)>bluethresh;
blues = blues*255;
%plants2=plants;
blues=im2uint8(blues);
clear p3
p3(:,:,1)=plants2(:,:,1)-blues;
p3(:,:,2)=plants2(:,:,2)-blues;
p3(:,:,3)=plants2(:,:,3)-blues;

imshow(p3,'Border','tight','InitialMagnification', 50)

% subplot(1,3,1), imshow(plants1,'Border','tight')
% subplot(1,3,2), imshow(plants2,'Border','tight')
% subplot(1,3,3), imshow(plants2,'Border','tight')

return


curIm = I;
unwarpVar = -.05;
%imCenter = [0,0]

%curIm2 = lensdistort(curIm,-0.175,'interpolation','nearest','padmethod','replicate','ftype',4, 'ImCenter', imCenter);
curIm2 = lensdistort(curIm,unwarpVar,'interpolation','nearest','padmethod','replicate','ftype',4);
imshow(curIm2)

return
curIm = plants{1,1};
    traysInfo = trays;
    trayCount = trayCount;
    potColCount = potCols;
    potRowCount = potRows;
i=1;
    curTray = traysInfo(i,:);
    trayPx = curIm(curTray(2):curTray(4),curTray(1):curTray(3),:);

% curTray
%    3     8   626   736
%    x1    y1  x2    y2

x1 =650
y1 =738
x2 =1240
y2 =1464

    trayPx = curIm(y1:y2,x1:x2,:);

% 
% x1 =curTray(1)
% y1 =curTray(2)
% x2 =curTray(3)
% y2 =curTray(4)

potWid = round((trayWid-1)/potCols) %subtracting 1 lets us round without going out of bounds (I think)
potHgt = round((trayHgt-1)/potRows)

potposX = x1:potWid:x2
potposY = y1:potWid:y2
return

for i = 1:20
    testPot{i} = imcrop(trayPx,[potposX(i),potposY(i),potWid,potHgt])
end


