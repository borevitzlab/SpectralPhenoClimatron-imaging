function [plants1,omitted] = removeBack(curIm,greenthresh,bluethresh,show_result)
 %curIm=I3;
 %threshScalar = 1;

if nargin < 2
   greenthresh = 130;
   show_result = 0;
elseif  nargin < 3
   bluethresh = 150;
   show_result = 0;
elseif  nargin < 4
   show_result = 0;  
end

plants1 = curIm;
greens = plants1(:,:,2)<greenthresh;
greens  = greens *255;
greens =im2uint8(greens );
plants2(:,:,1)=plants1(:,:,1)-greens ;
plants2(:,:,2)=plants1(:,:,2)-greens ;
plants2(:,:,3)=plants1(:,:,3)-greens ;

blues = plants2(:,:,3)>bluethresh;
blues = blues*255;
%plants2=plants;
blues=im2uint8(blues);
clear plants3;
p3(:,:,1)=plants2(:,:,1)-blues;
p3(:,:,2)=plants2(:,:,2)-blues;
p3(:,:,3)=plants2(:,:,3)-blues;

%Now grab the original pixels back from the start image
pGood = p3./p3;
p4 = curIm .* pGood;

BW=im2bw(p4, 0.5);
BW2 = bwareaopen(BW, 50);

BW2=im2uint8(BW2); 
BW2=BW2./BW2; %Convert to logical array (1s and 0s)
plants1(:,:,1)=curIm(:,:,1).*BW2;
plants1(:,:,2)=curIm(:,:,2).*BW2;
plants1(:,:,3)=curIm(:,:,3).*BW2;

if show_result
    
    imshow(plants1);
end

return
% Stuff after here didn't work any better in the first draft

% % red = curIm(:,:,1);
% % blue = curIm(:,:,2);
% % green = curIm(:,:,3);
% % 
% % imWoBlue = green-blue;
% % 
% % I = imWoBlue;
% % level = graythresh(I) * threshScalar;
% % BW = im2bw(I,level);
% % 
% % %imshow(BW)
% % 
% % %Convert the logical BW array to an image:
% % BW1 =im2uint8(BW);
% % BW1=BW1./BW1;
% % 
% % %Reassemble the image, for each color, remove the thresholded values
% % background(:,:,1)=curIm(:,:,1).*BW1;
% % background(:,:,2)=curIm(:,:,2).*BW1;
% % background(:,:,3)=curIm(:,:,3).*BW1;
% % 
% % omitted=background;
% % omit = ~(background);
% % omit =im2uint8(omit);
% % omit=omit./omit;
% % 
% % 
% % %Zero out any values in the "omitted array"
% % myplants = curIm.* omit ;
% % 
% % 
% % dothisseciton = 0;
% % if dothisseciton == 1
% %     a=zeros(size(plants));
% % 
% %     red = plants(:,:,1);
% %     blue = plants(:,:,2);
% %     green = plants(:,:,3);
% % 
% %     new = green - (red);
% %     new=(new./new).*red;
% % 
% %     morebackground(:,:,1)=plants(:,:,1).*new;
% %     morebackground(:,:,2)=plants(:,:,2).*new;
% %     morebackground(:,:,3)=plants(:,:,3).*new;
% % 
% %     plants = plants - morebackground;
% %     imshow(plants)
% % end
% % 
% % 
% % myplants = curIm;
% % 
% % %All things with lots of blue probably aren't plant so remove that...
% % blueThresh = mean(myplants(myplants(:,:,3) > 0));
% % redThresh = mean(myplants(myplants(:,:,1) > 0));
% % blueThresh = mean(myplants(myplants(:,:,2) > 0));
% % 
% % %Zero out anything over the mean blue value:
% % plants1 = myplants;
% % plants1((myplants(:,:,:) < blueThresh)) = 0;
% % %imshow(plants1)
% % 
% % level = graythresh(plants1) * threshScalar;
% % BW = im2bw(plants1,level);
% % 
% % %Convert the logical BW array to an image:
% % BW1 =im2uint8(~BW);
% % BW1=BW1./BW1;
% % 
% % plants2=plants1;
% % %Reassemble the image, for each color, remove the thresholded values
% % plants2(:,:,1)=curIm(:,:,1).*BW1;
% % plants2(:,:,2)=curIm(:,:,2).*BW1;
% % plants2(:,:,3)=curIm(:,:,3).*BW1;
% % 
% % plants = curIm - plants2;
% % if show_result
% %     imshow(plants);
% % end
%imshow(lost1)

% % end
% % %Get layers for full image
% % blue=(curIm(:,:,1)); 
% % red=(curIm(:,:,1));
% % green=(curIm(:,:,2));
% % 
% % new = green - (blue);
% % imshow(new)
% % new=(new./new).*blue;
% % imshow(new)
% % 
% % %Threshold image:
% % thresh=10;
% % curIm  = curIm-thresh;
% % imshow(curIm);
% % %Now add back the amount subtracted for just the pixels that still have
% % % values
% % 
% % %Matrix of places with values
% % goodvals=(curIm ./curIm ).*thresh;
% % curIm  = curIm +goodvals;
% % imshow(curIm);
