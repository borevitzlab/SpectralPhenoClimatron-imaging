%function [plants1] = removeBackDSLR(curIm,blueRedSum,bluethresh,show_result)
function [plants] = removeBackDSLR(curIm) %,whichToRun,show_result)

a=size(curIm);
h=a(:,1);
w=a(:,2);
numPx = h*w;

%-->CAN01-<--
% First, segment by high blue values to get rid of background
% blue seems to be consistently higher on non leaves for all types of images
% Remove high blue
clear plants1
BW1= curIm(:,:,3)>230;
BW1= BW1*255;
BW1=im2uint8(BW1);
plants1(:,:,1)=imsubtract(curIm(:,:,1),BW1);
plants1(:,:,2)=imsubtract(curIm(:,:,2),BW1);
plants1(:,:,3)=imsubtract(curIm(:,:,3),BW1);
%imshow(plants1)

%Remove Low Red
clear plants2
BW2= plants1(:,:,1)>210;
BW2= BW2*255;
BW2=im2uint8(BW2);
plants2(:,:,1)=imsubtract(plants1(:,:,1),BW2);
plants2(:,:,2)=imsubtract(plants1(:,:,2),BW2);
plants2(:,:,3)=imsubtract(plants1(:,:,3),BW2);
%imshow(plants2)

%Remove Low green
clear plants3
BW3= plants2(:,:,2)<160;
BW3= BW3*255;
BW3=im2uint8(BW3);
plants3(:,:,1)=imsubtract(plants2(:,:,1),BW3);
plants3(:,:,2)=imsubtract(plants2(:,:,2),BW3);
plants3(:,:,3)=imsubtract(plants2(:,:,3),BW3);
%imshow(plants3)


skip =1;
if skip ==0
%Remove small pixels
clear plants4
    BW=im2bw(plants3);
    BW2 = bwareaopen(BW, 10);
%   BW2= BW2*500;
%   BW2=im2uint8(BW2); 
    BW3 = imfill(BW2,'holes');
    BW3=im2uint8(BW3); 
    plants4(:,:,1)=plants3(:,:,1).*BW3;
    plants4(:,:,2)=plants3(:,:,2).*BW3;
    plants4(:,:,3)=plants3(:,:,3).*BW3;
    pGood = im2uint8(plants4./plants4);
else
    pGood = im2uint8(plants3./plants3);
end
%% Return the final image with the background removed
    plants = curIm .* pGood;
 %   imshow(plants)

return



%% Pre Sept 2013 code - this worked so don't delete:
%curIm=I3;
 %threshScalar = 1;

%% whichToRun values are stores as part of the camera config in expInfo for each camera
% To skip sizeThresh, set it to zero, all others must be toggled off/on

% whichToRun.doBlue =1
% whichToRun.blueThresh = 195
% whichToRun.doGreen =1
% whichToRun.greenThresh=95
% whichToRun.doRed = 0
% whichToRun.redThresh =0
% whichToRun.sizeThresh = 10
%% Check user inputs

% % % 
% if nargin < 2
% %   blueRedSum = 200;
%    bluethresh = 240;
%    show_result = 0;
% elseif  nargin < 3
%    bluethresh = 240;
%    show_result = 0;
% else
if  nargin < 3
   show_result = 0;  
end


%% Not required but helpful for debugging
clear plants1;
clear plants2;
clear plants3;
clear plants4;
%%


%% Run each of the threshold steps
if  whichToRun.doBlue
    %Remove Blue threshold
    BW1= curIm(:,:,3)>whichToRun.blueThresh;
    BW1= BW1*255;
    BW1=im2uint8(BW1);
    plants1(:,:,1)=imsubtract(curIm(:,:,1),BW1);
    plants1(:,:,2)=imsubtract(curIm(:,:,2),BW1);
    plants1(:,:,3)=imsubtract(curIm(:,:,3),BW1);
else %If we skip the step then pass the previous image on to the next step
    plants1 = curIm;
end

if whichToRun.doGreen
    %Remove Green threshold
    BW2= plants1(:,:,2)<whichToRun.greenThresh;
    BW2= BW2*255;
    BW2=im2uint8(BW2);
    plants2(:,:,1)=plants1(:,:,1)-BW2;
    plants2(:,:,2)=plants1(:,:,2)-BW2;
    plants2(:,:,3)=plants1(:,:,3)-BW2;
%    figure
%     imshow(plants2)
%     title('plants2')
else
    plants2 = plants1;
end
% % 
% % if whichToRun.doPixels
% %     BW3 = bwareaopen(im2bw(plants2), 2);
% %     BW3= ~BW3*255;
% %     BW3=im2uint8(BW3);
% %     plants3(:,:,1)=plants2(:,:,1)-BW3;
% %     plants3(:,:,2)=plants2(:,:,2)-BW3;
% %     plants3(:,:,3)=plants2(:,:,3)-BW3;
% % else
% %     plants3 = plants2
% % end
% % 
% % figure
% % imshow(plants3)

if whichToRun.doRed
    BW3= plants2(:,:,1)>whichToRun.redThresh;
    BW3= BW3*500;
    BW3=im2uint8(BW3);
    plants3(:,:,1)=plants2(:,:,1)-BW3;
    plants3(:,:,2)=plants2(:,:,2)-BW3;
    plants3(:,:,3)=plants2(:,:,3)-BW3;
else
    plants3 = plants2;
end
%figure 
%imshow(plants3)
%title('plants3')

%%NOTE that if sizeThresh = 0 then the holes also won't get filled
if whichToRun.sizeThresh > 0
    BW=im2bw(plants3);
    BW2 = bwareaopen(BW, whichToRun.sizeThresh);
%    BW2= BW2*500;
%    BW2=im2uint8(BW2); 
    BW3 = imfill(BW2,'holes');
    BW3=im2uint8(BW3); 
    plants4(:,:,1)=plants3(:,:,1).*BW3;
    plants4(:,:,2)=plants3(:,:,2).*BW3;
    plants4(:,:,3)=plants3(:,:,3).*BW3;
else
    plants4 = plants3;
end



%% Now grab the original pixels back from the start image
pGood = im2uint8(plants4./plants4);

%% Return the final image with the background removed
plants = curIm .* pGood;

if show_result 
    figure
    imshow(plants);
end

return

% % 
% % %%%%%%%%%%%%%%%%%%%%%%%%
% % %% pre jun 18 code:
% % BW1=(curIm(:,:,1)-curIm(:,:,2)>0);
% % BW1= BW1*255;
% % BW1=im2uint8(BW1);
% % plants1(:,:,1)=curIm(:,:,1)-BW1;
% % plants1(:,:,2)=curIm(:,:,2)-BW1;
% % plants1(:,:,3)=curIm(:,:,3)-BW1;
% % 
% % BW2=(plants1(:,:,1)+plants1(:,:,2)<blueRedSum);
% % BW2= BW2*255;
% % BW2=im2uint8(BW2);
% % plants2(:,:,1)=plants1(:,:,1)-BW2;
% % plants2(:,:,2)=plants1(:,:,2)-BW2;
% % plants2(:,:,3)=plants1(:,:,3)-BW2;
% % 
% % blues = plants2(:,:,3)>bluethresh;
% % blues = blues*255;
% % %plants2=plants;
% % blues=im2uint8(blues);
% % clear p3
% % p3(:,:,1)=plants2(:,:,1)-blues;
% % p3(:,:,2)=plants2(:,:,2)-blues;
% % p3(:,:,3)=plants2(:,:,3)-blues;
% % %%%%%%%%%%%%%%%%%%%%%%%%

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
