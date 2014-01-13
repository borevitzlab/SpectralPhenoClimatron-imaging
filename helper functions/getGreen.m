
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matlab gcc color image processing code 
% This code was written by:
% Tim Brown, TimeScience LLC
% http://www.time-science.com
% tim@time-science.com
%
% This code is licensed under a 
% Creative Commons Attribution-ShareAlike 3.0 Unported License
% Under the following conditions:
%  Attribution — You must attribute this work to Tim Brown, http://www.time-science.com (with link).
%  Share Alike — If you alter, transform, or build upon this work, you may  
%  distribute the resulting work only under the same or similar license to this one.
% More license information at: http://creativecommons.org/licenses/by-sa/3.0/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all

%% Initial Settings  --  USER SHOULD EDIT THESE

%Path to Images:
%% DONE
%% TODO

%% CURRENT
%imFolderPath = 'F:\ProjectData\RioMesa\TetracamData\ProcessedToTif\OrchardG1CamSideTif\1400'
%rootSaveName = 'OrchardG1CamSide_1400'
imFolderPath = 'C:\Users\Tim Brown\Documents\ANU\Projects\SpectralPhenoclimatron\Process images\TimCode\images\GC02-NC011AllNoon\'
rootSaveName = 'test'

imFilefilter = '*.jpg';

%% Location for Saving:
savePath = 'C:\Users\Tim Brown\Documents\ANU\Projects\SpectralPhenoclimatron\Process images\TimCode\Output\'
txtSaveNameAll = [rootSaveName '_OutputAll.txt']
csvSaveNameCleaned = [rootSaveName '_OutputCleaned.csv']
matSaveName = [rootSaveName '_Workspace.mat']
fullSavePathTxt = [savePath txtSaveNameAll];
fullSavePathCSVCleaned = [savePath csvSaveNameCleaned];
fullSavePathMAT = [savePath matSaveName];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MAIN CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check that variables are usable

% Make sure filepaths have a trailing slash:
if imFolderPath(length(imFolderPath)) ~= '\', imFolderPath = [imFolderPath,'\'], end

%Make sure savePath folder exists or create it
if (exist(savePath) ~= 7)
    result=input(['  The Save Path: ', savePath, ' does not exist, do you want to create the folder? \nTYPE:\n   "1" + ENTER to create folder \n   Type anything else to quit\n']);
    if result == 1, [result, messg, messID] = mkdir(savePath);  end
    if result ~= 1
        beep
        disp(['Error creating Save folder: ',messg])
        disp('Please check the save folder path and try again.')
    else
        disp('Save folder created successfully.')
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Initialize some variables
files=dir([imFolderPath,imFilefilter]);
nFiles=length(files);

if nFiles < 1, beep, disp('No Files found, make sure the file path is accurate. NOTE: file paths should end in "\"'),end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Process file dates
%Entrada images have a TimeScience filename based on File Creation Date
%Default format: Tetracam1pic_2008_06_29_10_00_00_00.jpg"
%NOTE that last time numeric values in the filename are for seconds and milliseconds and
%should usually be == "00"
for i=1:nFiles
    filename = files(i).name;
    
    %Report what file we're on if there are a lot of them
    if mod(i,50) == 0 | i == 1
        ['Now on File ', num2str(i), ' of ', num2str(nFiles), '. Filename: ', filename]
    end    
    [doy(i) yr(i)]=getDOYfromTSName(filename); 
end

nFiles=length(files);

[num2str(nFiles) ' files found.']
% Main image processing
disp(['Now processing all ', num2str(nFiles), ' images. This may take a while...'])
%%roiDim=(x2-x1+1)*(y2-y1+1);

totTime = 0;
%Create list of dark images


timeSinceStart = 0;
avgProcTime = [];

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now do the real image processing

%Clear offset values:
offvals = [];

for i=1:nFiles
    tic
    % Load image file
    % ['Loading image number ', num2str(i)']
    imName = files(i).name;
    ['Now on file: ' num2str(i) ' of ' num2str(nFiles) ', Filename: ' imName]
    
    curIm=imread([imFolderPath, files(i).name]);
    
    % Get White value offset averages:
    if doOff > 0
        %Normalize using the current image's normalization ROI:
        xOff1 = offsets(i,2);
        yOff1 = offsets(i,3);
        xOff2 = offsets(i,4);
        yOff2 = offsets(i,5);
        
        % If values are -1 then we skip normalization for that image
        if xOff1 > 0
            blueOff=double(curIm(yOff1:yOff2,xOff1:xOff2,1))+1; %Adding 1 avoids "divide by zero" issues
            redOff=double(curIm(yOff1:yOff2,xOff1:xOff2,2))+1;
            greenOff=double(curIm(yOff1:yOff2,xOff1:xOff2,3))+1;
        else
            %Setting these == 1 results in no normalization so regular gcc
            %values are calculated
            blueOff = 1;
            redOff = 1;
            greenOff = 1
        end
        
        offsetblue = mean(mean(blueOff));
        offsetRed = mean(mean(redOff));
        offsetGreen = mean(mean(greenOff));
        offvals(i,:) = [doy(i), offsetblue, offsetRed, offsetGreen];
        % Average of white reference area for 10/27/2010, (blue, R, G): 186, 172, 152
        % Prenormalization single pixel value in 10/27/2010 image, (blue, R, G): 132, 40, 52
        % Postnormalization single pixel value for same pixel, (blue, R, G): 0.71, 0.23, 0.34
    end
    
    % Add 1 instead ro remove NaN values
    %Load only the crop region:
    blue=(curIm(y1:y2,x1:x2,1)); %Adding 1 avoids "divide by zero" issues
    red=(curIm(y1:y2,x1:x2,1));
    green=(curIm(y1:y2,x1:x2,2));
    
    
    %Remove background:
    thresh=100;
    greenclean = green-thresh;
    imshow(greenclean);
    %Now add back the amount subtracted for just the pixels that still have
    %values
    %Matrix of places with values
    goodvals=(greenclean./greenclean).*thresh
    greenclean = greenclean+goodvals;
    imshow(greenclean);
    
    %%This loads all the data without any cropping:
    %blue = double(curIm(:,:,1)) + 1; %Adding 1 avoids "divide by zero" issues
    %red = double(curIm(:,:,2))+ 1 ;
    
    %Now calculate gcc:
    
    if doOff > 0 %If we are offsetting then normalize the image values by the white offsets:
        %Now calculate gcc:
        bluenorm = blue./offsetblue;
        rednorm = red./offsetRed;
        gccNorm =  (bluenorm - rednorm)./(bluenorm + rednorm) ;
        finalgccnorm = mean(mean(gccNorm));
    end
    
    gcc = (blue - red) ./ (blue + red);
    finalgcc = mean(mean(gcc));
    
    %Save the data
    allgcc(i,1) = doy(i);
    allgcc(i,2) = finalgcc;
    %Also save normalized gcc if it is being calculated:
    if doOff > 0, allgcc(i,3) = finalgccnorm; end
    
    procTime = toc;
    avgProcTime = [avgProcTime;procTime];
    
    timeSinceStart = timeSinceStart + procTime;
    ['Processing time: ' num2str(round(procTime * 100)/100) ' seconds (this image); AvgTime per image:' num2str(round(mean(avgProcTime)*100)/100) ' secs; ' num2str(round((timeSinceStart))) ' second since start. Time Left: ' num2str(round(mean(avgProcTime) * (nFiles-i))), ' seconds'] 
end

['Total time to process ' num2str(i) ' images: ' num2str(timeSinceStart) ' seconds.']
['Now cleaning Data']

%% Clean Data
'Cleaning data'

cleangcc

numExcluded = length(allgcc) - length(cleanedgcc)
[num2str(numExcluded) ' of ' num2str(length(allgcc)) ' values excluded.']
%['Excluding ' num2str(numExcluded) ' values that are more than ' num2str(excludeThresh)  ' different from preceeding value']


%% Plot data:
plotOn = 0;
if plotOn == 1
    plot(goodND2(:,1), goodND2(:,2),'r',goodND2(:,1), goodND2(:,2),'r.');
    hold on
    plot(allgcc(:,1),allgcc(:,2),'k',allgcc(:,1),allgcc(:,2),'k.');
    axis([min(allgcc(:,1)) max(allgcc(:,1)) 0 0.8]);
    hold on
    plot(goodND2(:,1), goodND2(:,2),'g',goodND2(:,1), goodND2(:,2),'g.');
    plot(goodND3(:,1), goodND3(:,2),'g',goodND3(:,1), goodND3(:,2),'r.');
end

% Add lines where the months are
minval = min(allgcc(:,2));
maxval = 0.8;
%List of start days for each month
leapcheck=yr(1)/4;
if leapcheck-floor(leapcheck)>0
    modays=[0,31,59,90,120,151,181,212,243,273,304,334];
else
    modays=[0,31,60,91,121,152,182,213,244,274,305,335];
end
molines = [modays;zeros(1,length(modays));ones(1,length(modays))];
months = {'Jan' 'Feb'  'Mar' 'Apr' 'May' 'June' 'July' 'Aug' 'Sept' 'Oct' 'Nov' 'Dec'};
for i = 1:length(molines)
    x = molines(1,i);
    
    plot([x,x],[minval,maxval],'g:');
    if modays(i) >= (min(allgcc(:,1))-20) && modays(i) < (max(allgcc(:,1))-10) %Only plot names of months for months that are on the graph
        text(modays(i)+15,maxval*.95,months(i));
    end
end

axis([min(allgcc(:,1)) max(allgcc(:,1)) minval maxval]);
xlabel('DOY')
ylabel('gcc')
legend hide

warning('ON')


%% Save data
%Note that since "finalData" is created in "cleandata.m" we need to add the
%normalized data to it for saving
if doOff>0
    finalData = [finalData; [-99,-99]; [allgcc(:,1), allgcc(:,3)]]
end

% NOTE: "finalData" is created in the "cleandata.m" file and holds the final data for saving:

% Ask user if they want to save the data
clear saveme
saveme = input('TYPE:\n   "1" + ENTER to save the data \n   Type anything else to quit\n ');

if saveme == 1
    %Save the full matlab workspace
    save(fullSavePathTxt, 'finalData', '-ascii', '-tabs')
    save(fullSavePathMAT)
    %Save the Data to an excel file:
    %  savegcc
end

txtSaveNameAll
x1
x2
y1
y2


return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Code for testing and to process a single image:

%Using the BW luminance image:
%imName = 'D:\Timescience\Projects\Entrada\Data\Tetracam\Processed\Output\processed1\Orchard1_2008_06_21_11_00_00_00_gcc.tif'
clear all
imName = 'D:\Timescience\Projects\Entrada\Data\Tetracam\Processed\Output\test\Orchard1_2008_06_22_11_00_00_00.tif'
imName = 'D:\Timescience\Projects\Entrada\Data\Tetracam\Processed\Output\R127-0-0.bmp'
%imName = 'D:\Timescience\Projects\Entrada\Data\Tetracam\Processed\Output\R127-G127-0.bmp'
testim = imread(imName);
blue = double(testim(:,:,3)); %Adding 1 avoids "divide by zero" issues
red = double(testim(:,:,2)) ;
%image(testim);  %View image
iminfo = size(testim) %This gives us width and height of image
gcc = (blue - red) ./ (blue + red);
%This returns a bunch of NaN values where we divided by 0 so we need to pull thos out and
%replace them with zeros:
a=find(isnan(gcc)==1);
gcc(a) = 0;
finalgcc = mean(mean(gcc))


%% Processing from the gcc scaled image:
%http://chesapeake.towson.edu/data/all_gcc.asp
%Scaled gcc = 100(gcc + 1) --> These are the -1 to 1 values
% ==> sgcc = 100gcc + 100
% So to get the gcc from luminence:
% (sgcc / 100) - 1 = gcc
%clear all
imName = 'D:\Timescience\Projects\Entrada\Data\Tetracam\Processed\Output\test\Orchard1_2008_06_22_11_00_00_00_gcc.tif'
im = imread(imName);
sgcc = double(im(:,:,1));
sgcc = sgcc - 127;
gcc = (sgcc / 254);
meangcc = mean(mean(gcc))
gcc(1:10,1:10)

%% Histograms:
reds = hist(red,1:255);
for i = 1:255
    vals = reds(i,:);
    redcount(i) = sum(vals);
end
redcount = redcount';
plot(1:255, redcount)

blues = hist(blue,1:255);
for i = 1:255
    vals = blues(i,:);
    bluecount(i) = sum(vals);
end
bluecount = bluecount';
plot(1:255, bluecount)

