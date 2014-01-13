%% findObjectInfo finds the center of plant, smallest enclosing circle and ratio (compactness)
% returns data in the "info" struct
function [plantinfo] = getImageInfo(curIm)

bwIm=im2bw(curIm);

%% Find center of object:

%Fill in blank areas so regionprops only detects one area:
out=bwconvhull(bwIm);

props=regionprops(out);
if isempty(props) %No plant (Need to catch this error and handle this case better)
    plantinfo.xCent = 0;
    plantinfo.yCent = 0;
    plantinfo.rstArea = 0;
    plantinfo.rstArea2 = 0;
    plantinfo.rstPerim = 0;
    plantinfo.edge = 0;
    plantinfo.radius = 0;
    plantinfo.circArea = 0;
    plantinfo.fillRatio = 0;
    return
end
cents = props.Centroid;
corners=regionprops(out,'Extrema');

xCent = cents(1);
yCent = cents(2);

plantinfo.xCent = xCent ;
plantinfo.yCent = yCent ;
plantinfo.rstArea = bwarea(bwIm);
%NOTE--> I'll leave both in for now to test the difference
plantinfo.rstArea2 = sum(sum(sum(bwIm)));
plantinfo.rstPerim = bwperim(bwIm);

%Get edge outline
plantinfo.edge = edge(curIm(:,:,2),'canny', [0.1 0.2], 1);

%Find farthest point from the center point
xCorns = corners.Extrema(:,1);
yCorns = corners.Extrema(:,2);

%This is the distance of the center from the corners
dist= sqrt((xCorns-xCent).^2 + (yCorns-yCent).^2);

%This is the farthest distance from the center to a corner
plantinfo.radius = max(dist);
plantinfo.circArea = pi * (plantinfo.radius)^2;
plantinfo.fillRatio = plantinfo.rstArea/plantinfo.circArea;

end
%
% return
%
% % create a test matrix
% a=rand(6,8)>.8
% a = im2bw(curIm);
% imshow(a)
%
% b = find(a==1);
% [x,y]=ind2sub(size(a),b);
%
% [Xc,Yc, R]=smallestEnclosingCircle(x,y)
% hold on
% plot(Yc,Xc,'ro')
% plot(Xc,Yc,'bo')
%
%
% return
%
% %Testing substrate for Caroline
% lightone = imread('light1.JPG');
% darkone = imread('dark1.JPG');
% imshow(lightone);
% figure
% imshow(darkone)
% red= light1(:,:,1);
% green = light1(:,:,2);
% blue = light1(:,:,3);


