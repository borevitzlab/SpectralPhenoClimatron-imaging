
%% Pick image set and number of keyframe image to use for setting up default processing values for each camera
cont=camNum ;
while ~isempty(cont)
    curCamName = expInfo.camList.name{cont};
    curChName = expInfo.camList.chambLoc{cont};
    curCamType = expInfo.camList.camType{camNum};
    cont = input(['Current Camera: ' curCamName ' in chamber ' curChName '. Cam type: ' num2str(curCamType) ...
        ' (1=DSLR,2=NC5)\nPress return to continue or enter a different chamber number.\n']);
end

%% Get path to images:
imFolderPath = fullfile(expInfo.camList.path{camNum}, pathToFullIms);
imFolderPath = imFolderPath{1};%convert back to char array from cell

disp(['Path to images is: ' imFolderPath])

curCamSet.number = camNum;
curCamSet.files = expInfo.camList.files{camNum};

%% Pick start and end images
nFiles = length(curCamSet.files);
if useNoon == 1
    pickStartIm = input('\nDo you want to select a starting image?\nHit Enter for Yes or anything else for No.\n');
    if isempty(pickStartIm)
        result = 1;
        while ~isempty(result)
            result = input(['Enter an image number from 1 to ' num2str(nFiles)  ' for the START image. \n' ...
                'The image will load so you can view it. Enter another number to select a different image.\n' ...
                'Hit Enter when finished and your last image will be the start image.\n']);
            if ~isempty(result)
                startIm = imread(fullfile(imFolderPath,curCamSet.files{result}));
                imshow(imrotate(startIm,180));
                title(curCamSet.files{result});
                curCamSet.startImNum = result
            end
        end
    else
        curCamSet.startImNum = 1;
    end
else
    curCamSet.startImNum = 1;
end

if useNoon == 1
    pickEndIm = input('Do you want to select a END image?\nHit Enter for Yes or anything else for No.');
    if isempty(pickEndIm)
        result = 1;
        while ~isempty(result)
            result = input(['Enter an image number from ' num2str(curCamSet.startImNum) + 1 ' to ' num2str(nFiles)  ' for the END image. \n' ...
                'The image will load so you can view it\n' ...
                'Enter another number to select a different image.\n' ...
                'Hit Enter when finished and your last image will be the start image.\n']);
            if ~isempty(result)
                curCamSet.endImNum = result;
                endIm = imread(fullfile(imFolderPath,curCamSet.files{result}));
                imshow(imrotate(endIm,180));
                title(curCamSet.files{result});
            end
        end
    else
        curCamSet.endImNum = length(curCamSet.files);
    end
else
    curCamSet.endImNum = length(curCamSet.files);
end

selection = input(['Which file do you want to load as the master image?\nHit "Enter" to choose 1 and continue, "L" to' ...
    'load an image using a dialog box\n or enter an number from 1 to ', num2str(nFiles),'.\n'],'s');
masterImNum = 1; %By default load file one

%Check if number is within bounds; default to 1 on error
if (str2num(selection) > 0 & str2num(selection) < (nFiles + 1))
    masterImNum = str2num(selection)
elseif selection ==  'L'  %If the choose to select an image then filepath is set via the dialog box:"
    [filename filepath] =    uigetfile('*.jpg',imFolderPath)
end

curCamSet.masterImNum  = masterImNum %NOTE: This will not save correctly if the user picked their own image b/c we won't know the image number
curCamSet.masterImPath  = fullfile(imFolderPath,curCamSet.files{masterImNum})
curCamSet.camType = expInfo.camList.camType{camNum}
filetoload = curCamSet.masterImPath  ;

I =imread(filetoload);

%% Unwarp Image
% Let user choose center of image if the camera isn't centered

%doUnwarp = 1;
doUnwarp = input('Do these images need to be barrel corrected (unwarped)? Press "0" to skip or "1" to unwarp:\n')
if doUnwarp == 0;
    unwarpAmt = 0;
    imCenter = [0,0];
    I1 = I; %Create image to pass to next section
else
    inputCenter = input('Do you want to choose the image center for the Unwarp process? \n Press 1 for YES, any other key for no:  ')
    
    if inputCenter == 1
        %Put an X down the center to help user:
        img=I;
        a = size(img);
        yCenter = round(a(1)/2.1);
        xCenter = round(a(2)/2);
        img(:,2:xCenter:end,:) = 255;       %# Change every nth column to black
        img(2:yCenter:end,:,:) = 255;       %# Change every nth row to black
        imshow(img);
        [x,y] = getROI(img,1);
        imCenter = [x,y]
    else
        imCenter = [0,0]
    end
    close

    % Set actual unwarp values. 
    %  These are manually determined
    if curCamSet.camType == 1
        unwarpAmt = -0.05 % camType 1 = Canon 700D DSLR w/ 18mm lens 
    else
        unwarpAmt = -.175 % camType 0 = StaDot Necam SC5 w/ 4-12mm lens set at 4mm    
    end
% Do the actual unwarp    
    disp('Unwarping image...')    
    I1 = lensdistort(I,unwarpAmt,'interpolation','nearest','padmethod','replicate','ftype',4, 'ImCenter', imCenter);
end


%% Rotate image 
%    (set to 0 if image has already been rotated in pre-processing)

%Show image with grid on it
img = addLines(I1,40);
imshow(img);                  % Display the image

amtToRotate = 0.63;
totalRotation = 0; %180; % By default we want the back of the chamber at the top

tempIm = I1;
%Repeat rotation until complete; count total rotation amount:
while amtToRotate ~= 0,
    amtToRotate = input('Enter amount to rotate image. Use 180 to flip image. (Enter 0 when finished or to skip rotation. Use negative values to reverse rotation): ');
    imshow(addLines(tempIm,40,40));
    tempIm = imrotate(tempIm, amtToRotate);
    imshow(addLines(tempIm,40));
    totalRotation = totalRotation + amtToRotate;
    disp(num2str(totalRotation))
end
I2 = imrotate(I1, totalRotation);

% Do it all at once: I2 = imrotate(I1, 0.63);

%Report total rotation
totalRotation


%% Crop image
%Get image crop
inputROI = input('Do you want to Crop the main image? \n Press 1 for YES, any other key for no:  ');

%input the ROI area
if inputROI == 1
    [x,y] = getROI(I2,2,'Set crop area for main image:');
else
    x=[0,0];
    y=[0,0];
end
imCropCoords = [x,y];

%Crop image if it needs cropping:
if sum(imCropCoords) > 0
    I3 = I2(y(1):y(2),x(1):x(2),:);
else
    I3=I2;
end

imshow(I3,'Border','tight','InitialMagnification', 40);
movegui('east');
% Tray Selection
trayCount = input('How many trays? (Enter 0 for none) \n'  );


% List of xy coords of trays in order TopLeft X1Y1, Bottom Right X2Y2
if trayCount > 0
    trays = zeros(trayCount,4);
    for i = 1:trayCount
        [x,y] = getROI(I3,2,['Choose coordinates of tray ',num2str(i),':']);
        trays(i,1) = x(1);
        trays(i,2) = y(1);
        trays(i,3) = x(2);
        trays(i,4) = y(2);
    end
end

% Now get total number of pots
imshow(I3) %Show user the iamge
title('Input the number of pots');
clear pots

potCols = input('Enter columns pot count  (number of pots in Y/Vertical per tray: \n')
potRows = input('Enter rows pot count (number of pots in X/Horizontal per tray: \n')

totPots = potCols * potRows * trayCount

close %the figure

curCamSet.rotation = totalRotation;
curCamSet.imCropCoords= imCropCoords;
curCamSet.unwarpAmt = unwarpAmt;
curCamSet.imCenter = imCenter;
curCamSet.trayCount = trayCount;
curCamSet.trayCoords = trays;
curCamSet.potCols = potCols;
curCamSet.potRows = potRows;
curCamSet.totPots = totPots

expInfo.camList.config(camNum)=curCamSet;

curCamName = expInfo.camList.name(camNum)

savenameCurCam = [date datestr(now,'-hh') 'H' datestr(now,'mm'),'_',expInfo.expID,'-',curCamName{1},'-settings.mat'];
%Save the current data
result = input(['Press 1 to save current settings:\n'],'s')
if result == '1'
    pathName = uigetdir(rootSavePath,'Choose save location.')
    savepathCam = fullfile(pathName,savenameCurCam)
    save(savepathCam, 'curCamSet')
end
