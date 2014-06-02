
function [info] = findObjectInfo(im)

im=im2bw(im);
out=bwconvhull(im);
center=regionprops(out,'Centroid');

cents = center.Centroid;

info.xCent = cents(1)
info.yCent = cents(2)

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


