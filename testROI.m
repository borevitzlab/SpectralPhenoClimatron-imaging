
ccr = imcrop(I3, roiPosition);

rNorms = getColorCheckerInfo(ccr);
gNorms = getColorCheckerInfo(ccr);
bNorms = getColorCheckerInfo(ccr);
bkNorms = getColorCheckerInfo(ccr)

re = imcrop(ccr(:,:,1),rNorms);
Red = mean(mean(re))

gr = imcrop(ccr(:,:,2),gNorms);
Green = mean(mean(gr))

bl = imcrop(ccr(:,:,3),bNorms);
Blue= mean(mean(bl))

bk = imcrop(ccr,bkNorms);
Black = mean(mean(mean((bk))))
BlackRatio = Black/255

normed2 = I3;
r2 = double(normed2(:,:,1)) * ((mean(mean(bk(:,:,1))))/255);
g2 = double(normed2(:,:,2)) * ((mean(mean(bk(:,:,2))))/255);
b2  = double(normed2(:,:,3)) * ((mean(mean(bk(:,:,3))))/255);
normed2(:,:,1) = r2;
normed2(:,:,2) = g2;
normed2(:,:,3) = b2;
imshow(normed2);

figure
imshow(I3)

normed2 = double(I3(1:3)) ./ double(min(I3(1:3)));

normed2 =  uint8(255*mat2gray(I3));

normed(:,:,1:3) = I3(:,:,1:3).*BlackRatio;%1;(Red/255);
normed(:,:,2) = I3(:,:,2)./1;%(Green/255);
normed(:,:,3) = I3(:,:,3)./1;(Blue/255);

--> Need to build an image sized array of the avg values
Then for each pixel
normed = I3;
normed(:,:,1) = I3(:,:,1)./1;(Red/255);
normed(:,:,2) = I3(:,:,2)./1;%(Green/255);
normed(:,:,3) = I3(:,:,3)./1;(Blue/255);
figure
imshow(normed);

