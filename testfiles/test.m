% % 
% % 
% % %Count red values to determin red thresholding
% % redcount1 = sum(sum(sum(curIm1(:,:,1))))
% % redcount2 = sum(sum(sum(curIm2(:,:,1))))
% % 
% % 
% % %% Histograms:
% % hreds = hist(reds,1:255);
% % for i = 1:255
% %     vals = reds(i,:);
% %     redcount(i) = sum(vals);
% % end
% % redcount = redcount';
% % plot(1:255, redcount)
% % 
% % hblues = hist(blues,1:255);
% % for i = 1:255
% %     vals = blues(i,:);
% %     bluecount(i) = sum(vals);
% % end
% % bluecount = bluecount';
% % plot(1:255, bluecount)
% % 
% % 
% % %% Histograms:
% % hgreens = hist(greens,1:255);
% % for i = 1:255
% %     vals = greens(i,:);
% %     greencount(i) = sum(vals);
% % end
% % greencount = greencount';
% % plot(1:255, greencount,'g')
% % hold on
% % plot(1:255, bluecount,'b')
% % plot(1:255, redcount,'r')
% % 
% % 
% % % Get number of pixels per layer
 a=size(curIm1)
 h=a(:,1)
 w=a(:,2)
 numPx = h*w

clear plants1
clear plants2
clear plants3
clear plants4

% First, segment by high blue values to get rid of background
% blue seems to be consistently higher on non leaves for all types of images
%Remove high blue
curIm = curIm1;
BW1= curIm(:,:,3)>230;
BW1= BW1*255;
BW1=im2uint8(BW1);
plants1(:,:,1)=imsubtract(curIm(:,:,1),BW1);
plants1(:,:,2)=imsubtract(curIm(:,:,2),BW1);
plants1(:,:,3)=imsubtract(curIm(:,:,3),BW1);
imshow(plants1)

%Remove High Red
BW2= plants1(:,:,1)>210;
BW2= BW2*255;
BW2=im2uint8(BW2);
plants2(:,:,1)=imsubtract(plants1(:,:,1),BW2);
plants2(:,:,2)=imsubtract(plants1(:,:,2),BW2);
plants2(:,:,3)=imsubtract(plants1(:,:,3),BW2);
imshow(plants2)

%Remove Low green
BW3= plants2(:,:,2)<160;
BW3= BW3*255;
BW3=im2uint8(BW3);
plants3(:,:,1)=imsubtract(plants2(:,:,1),BW3);
plants3(:,:,2)=imsubtract(plants2(:,:,2),BW3);
plants3(:,:,3)=imsubtract(plants2(:,:,3),BW3);
imshow(plants3)

%Remove small pixels
    BW=im2bw(plants3);
    BW2 = bwareaopen(BW, 50);
%    BW2= BW2*500;
%    BW2=im2uint8(BW2); 
    BW3 = imfill(BW2,'holes');
    BW3=im2uint8(BW3); 
    plants4(:,:,1)=plants3(:,:,1).*BW3;
    plants4(:,:,2)=plants3(:,:,2).*BW3;
    plants4(:,:,3)=plants3(:,:,3).*BW3;
pGood = im2uint8(plants4./plants4);
%% Return the final image with the background removed
    finalim = curIm .* pGood;
    imshow(finalim)

% % %% This doesn't work yet:
%Sum all pixels:
% % reds=single(reshape(plants3(:,:,1),w*h,1));
% % greens=single(reshape(plants3(:,:,2),w*h,1));
% % blues=single(reshape(plants3(:,:,3),w*h,1));
% % sums = (reds + blues + greens);
% % sums = sums/norm(sums);
% % newim = reshape(sums,h,w);
% % BW1= newim<250;
% % BW1= BW1*255;
% % BW1=im2uint8(BW1);
% % plants4(:,:,1)=imsubtract(plants3(:,:,1),BW1);
% % plants4(:,:,2)=imsubtract(plants3(:,:,2),BW1);
% % plants4(:,:,3)=imsubtract(plants3(:,:,3),BW1);
% % imshow(plants4)
% % 
% % subplot(1,5,1), imshow(curIm1)
% % subplot(1,5,2), imshow(plants1)
% % subplot(1,5,3), imshow(plants2)
% % subplot(1,5,4), imshow(plants3)
% % subplot(1,5,5), imshow(plants4)


return

labIm3 = makelab(plants3);

L3= labIm3(:, :, 1);  % Extract the L image.
A3= labIm3(:, :, 2);  % Extract the L image.
B3= labIm3(:, :, 2);  % Extract the L image.

subplot(3,1,1), imshow(L3)
hold on

subplot(3,1,2), imshow(A3)
subplot(3,1,3), imshow(B3)


BWL3 = im2bw(L3, graythresh(L3));
BWL31 = im2bw(L3, 0.6);

imshow(BWL31)

BWA = im2bw(A1, graythresh(A1));
BWB = im2bw(B1, graythresh(B1));

BWL = im2bw(r2, graythresh(L1));
BWL = im2bw(L1, 0.5);
BWA = im2bw(A1, graythresh(A1));
BWB = im2bw(B1, graythresh(B1));


subplot(3,1,1), imshow(BWL)
hold on
subplot(3,1,2), imshow(BWA)
subplot(3,1,3), imshow(BWB)


%%%%%%%%%%%%%5
curIm1 = imread('C:\a_data\TimeStreams\Borevitz\BVZ0018\BVZ00018-NCRIS-GC04L\~fullres\corrected\BVZ00018-NCRIS-GC04L~fullres_2013_08_06_14_45_00_00.jpg');
labIm1 = makelab(curIm1);

curIm2 = imread('C:\a_data\TimeStreams\Borevitz\BVZ0018\BVZ00018-NCRIS-GC04L\~fullres\corrected\BVZ00018-NCRIS-GC04L~fullres_2013_08_06_16_55_00_00.jpg');
labIm2 = makelab(curIm2);

L1= labIm1(:, :, 1);  % Extract the L image.
A1= labIm1(:, :, 2);  % Extract the L image.
B1= labIm1(:, :, 2);  % Extract the L image.

L2= labIm2(:, :, 1);  % Extract the L image.
A2= labIm2(:, :, 2);  % Extract the L image.
B2= labIm2(:, :, 2);  % Extract the L image.

subplot(3,2,1), imshow(L1)
hold on
subplot(3,2,3), imshow(A1)
subplot(3,2,5), imshow(B1)

subplot(3,2,2), imshow(L1)
hold on
subplot(3,2,4), imshow(A1)
subplot(3,2,6), imshow(B1)

figure
imshow(curIm1)
r1=curIm1(:,:,1);
g1=curIm1(:,:,2);
b1=curIm1(:,:,3);

figure
imshow(curIm2)
r2=curIm2(:,:,1);
g2=curIm2(:,:,2);
b2=curIm2(:,:,3);

BWL = im2bw(L1, graythresh(L1));
BWL = im2bw(L1, 0.5);
BWA = im2bw(A1, graythresh(A1));
BWB = im2bw(B1, graythresh(B1));

BWL = im2bw(r2, graythresh(L1));
BWL = im2bw(L1, 0.5);
BWA = im2bw(A1, graythresh(A1));
BWB = im2bw(B1, graythresh(B1));


subplot(3,1,1), imshow(BWL)
hold on
subplot(3,1,2), imshow(BWA)
subplot(3,1,3), imshow(BWB)



%NOTES
%(1) Thresholding on the LabL image pulls out the plants well but leaves the edges of the pots
%     - need to remove the basic background (pot edges and walls) and then do the lab thresholding

return

for i = 1:nFiles
    
    
    r(i) = sum(sum(chamber{i,1}(:,:,1)))
    g(i) = sum(sum(chamber{i,1}(:,:,2)));
    b(i) = sum(sum(chamber{i,1}(:,:,3)));
end

figure
hold on
plot(r,'r'),plot(g,'g'),plot(b,'b')
return
close

imshow(removeBackDSLR(chamber{i,1},200,20))


return
filepath = 'C:\Users\Tim Brown\Documents\ANU\Projects\SpectralPhenoclimatron\Process images\Matlab\images\testimages\CameraColorCheck'
loadfolder = 1;

%Load file list
allFiles=dir([imFolderPath,imTimeFilter,imFilefilter]);
numFiles=length(allFiles);
if nFiles < 1, beep, disp('No Files found, make sure the file path is accurate. NOTE: file paths should end in "\"'),end

if loadfolder == 1

    for i=1:nFiles
        tic
        % Load image file
        % ['Loading image number ', num2str(i)']
        imName = allFiles(i).name;
        disp(['Now on file: ' num2str(i) ' of ' num2str(numFiles) ', Filename: ' imName])

        imFiles{i,1} = imread([imFolderPath, allFiles(i).name]);
        %imFiles{i,2} = unwarp(curIm,totalRotation,imCenter,imCropCoords,unwarpAmt);
        %reportTime
    end
end

return

imPath =  'C:\Users\Tim Brown\Documents\ANU\Projects\SpectralPhenoclimatron\Process images\TimCode\images\GC02-CN650D-01\GC02-CN650D-01_2013_03_21_17_40_00_00.jpg'
curIm = imread(imPath);


%plants = removeBack(I3);

plants = curIm;
greenthresh = 130;
greens = plants(:,:,2)<greenthresh;
greens  = greens *255;
greens =im2uint8(greens );
plants2(:,:,1)=plants(:,:,1)-greens ;
plants2(:,:,2)=plants(:,:,2)-greens ;
plants2(:,:,3)=plants(:,:,3)-greens ;

bluethresh = 140;
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
goodPx = I3 .* pGood;

imshow(goodPx);
return


%% After here is currently unused

reds = plants3(:,:,1);
greens = plants3(:,:,2);

%% NOTE this is actual backwards from what I meant to do but it seems to work
%   I planed to do red-green, but red-blue seems to work very well...

r = im2single(reds-blues)*10;
r2 = im2uint8(r./r);
r3= (rats2~=255);
r3 = im2uint8(r3*255);
clear p4;
p4(:,:,1) = plants3(:,:,1) - r3;
p4(:,:,2) = plants3(:,:,2) - r3;
p4(:,:,3) = plants3(:,:,3) - r3;

return

reds = p4(:,:,1);
greens = p4(:,:,2);

r4 = im2single(reds./greens)*1000;%*100;
r5 = r4>9;
r5 = im2uint8(r5*255);
clear p5;
p5(:,:,1) = p4(:,:,1) - r5;
p5(:,:,2) = p4(:,:,2) - r5;
p5(:,:,3) = p4(:,:,3) - r5;

figure
imshow(r5);
figure
imshow(p5);

return

  I = imread('testim.jpg');
curIm = I;

r = curIm(:,:,1);
b = curIm(:,:,2);
g = curIm(:,:,3);

a = 100000;
d = 0.9 * (50000 - a)/50000
d=-7

BW1 = ((g-r) + 0.4)*(1-d)+((g-(r.*b))+0.4).*d;
imshow(BW1)
BW1=BW1.*255;
BW1=im2uint8(BW1);
leaves = curIm;
leaves(:,:,1)=curIm(:,:,1)-BW1;
leaves(:,:,2)=curIm(:,:,2)-BW1;
leaves(:,:,3)=curIm(:,:,3)-BW1;
imshow(leaves);

return
background = background./background;
%leaves=curIm*(~background);
imshow(background);
return
forground = ~background;



%Convert the logical BW array to an image:
BW1 =im2uint8(~BW);
BW1=BW1./BW1;

plants2=plants1;
%Reassemble the image, for each color, remove the thresholded values
plants2(:,:,1)=curIm(:,:,1).*BW1;
plants2(:,:,2)=curIm(:,:,2).*BW1;
plants2(:,:,3)=curIm(:,:,3).*BW1;
imshow(plants2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

