%% This is run after configProject
% Processes all the images in the folder

skipLoadSteps = 0
if skipLoadSteps == 0
    clear all
    %% Set root paths and variables
    setPathVars
    result = input('The display dialog will open. Make sure to select BOTH the camera config file and "expInfo" file.\n');
    disp('Loading workspace')
    cd(rootSavePath);
    [filenames,filepath] = uigetfile('*.mat','Select the config file for your dataset and the expInfo file for the experiment.','MultiSelect', 'on')
    loadpath = fullfile(filepath,filenames(1));
    uiopen(loadpath{1},'false');
    loadpath = fullfile(filepath,filenames(2));
    uiopen(loadpath{1},'false');
    disp('Workspace Loaded');
    who
    
    %% Let's get started
    input('Ready to continue?\n(Press crtl^C to quit)');
    timeSinceStart = 0;
    avgProcTime = [];
    disp('Doing initial processing')
    
    %% Cameras/imagesets are run 1 at a time (for now)
    curCamNum = input('Which camera do you want to run (1-5)')
    
    curCamSet = expInfo.camList.config(curCamNum)
    % Set unwarp amount based on image type (value is determined by trial and error)
    imageType = curCamSet.camType
    totalRotation = curCamSet.rotation
    imCenter = curCamSet.imCenter
    imCropCoords = curCamSet.imCropCoords
    unwarpAmt = curCamSet.unwarpAmt
    
    %nFiles = length(curCamSet.files)
    %files = curCamSet.files;
    files = expInfo.camList.files{curCamNum};
    
    %Get path to folder holding files
    imFolderPath = fileparts(curCamSet.masterImPath);
    
    startFileNum = 1; curCamSet.startImNum
    endFileNum = curCamSet.endImNum
    nFiles = (endFileNum-startFileNum) + 1 %This is just the files being processed
    
    %% Unwarp, rotate crop
    clear plants
end %of skip section

startFileNum = 1
for i=startFileNum:endFileNum
    tic
    % Load image file
    imName = files{i};
    disp(['Loading image: ' num2str(i) ' of ' num2str(nFiles)]);
    disp(['Filename: ' imName]);
    fullfilename = fullfile(imFolderPath, files{i});
    tic
    if exist(fullfilename,'file')
        curIm=imread(fullfilename);
    else
        continue
    end
    toc
    colorAudit = 1; %This lets us plot total color present in each image - helps with detemining thresholds for background removal
    if colorAudit == 1
        sumR(i) = sum(sum(sum(curIm(:,:,1))));
        sumG(i) = sum(sum(sum(curIm(:,:,2))));
        sumB(i) = sum(sum(sum(curIm(:,:,3))));
     % continue;
    end
    
    tic
    % Unwarp:
    disp('Unwarping');
    if unwarpAmt ~= 0
        curIm1 = unwarp(curIm,imCenter,unwarpAmt);
    else %skip unwarp
        curIm1 = curIm;
    end
    toc
    tic
    % Rotate image
    if totalRotation ~= 0
        curIm2 = imrotate(curIm1, totalRotation);
    else
        curIm2 = curIm1;
    end
    toc
    tic
    % Crop to all trays (crops out chamber edges)
    if sum(sum(imCropCoords)) > 0 %Don't crop if no values are set
        curIm3 = cropIm(curIm2,imCropCoords);
    else
        curIm3 = curIm2;
    end
    toc
    %% Save image to chamber data:
    chamber{i,1} = curIm3
    toc
%    reportTime
end

%% Quit here to just load the images w/o removing backgrounds
input(['Images loaded and pre-processed, do you want to continue with background removal? \n', ...
    'Press Ctrl+C to quit or anything else to continue\n']);

%% Load excel file with plant and pot information 
loadPlantDB

%% Crop to pots
% Pots (with background) are stored in the 'potsRaw' cell array of size 'numImages'
% Each index in potsRaw contains cell arrays of all pots in that image
% To access a pot image: imshow(potsRaw{imnum}{potnum})

disp('Cropping pots...')

clear pots;
clear allPots;
clear potsRaw;
allPots = {};

potsPerTray = curCamSet.potRows * curCamSet.potCols
totalPots = potsPerTray * curCamSet.trayCount
trayCoords = curCamSet.trayCoords;
trayCount = curCamSet.trayCount

for curFileNum = startFileNum:endFileNum
    tic
    disp(['Now on file: ' num2str(curFileNum) ' of ' num2str(endFileNum)])
    % Pass the image without background:
    %cropPots(curIm,traysInfo,trayCount,potColCount,potRowCount)
    %Need to skip empty files (this happens if file list is loaded and then
    %images are removed from the folder
    if sum(size(chamber{curFileNum,1})) ==0, continue, end
    
    doClean = 0;
    if doClean == 1;
        pots{curFileNum}(1) = cropPots(chamber{curFileNum,2},trayCoords,trayCount,curCamSet.potCols,curCamSet.potRows);
        pots{curFileNum}(2) = cropPots(chamber{curFileNum,2},trayCoords,trayCount,curCamSet.potCols,curCamSet.potRows);
    end
    
    %Pots with backgrounds:
    potsRaw{curFileNum} = cropPots(chamber{curFileNum,1},trayCoords,trayCount,curCamSet.potCols,curCamSet.potRows);
    toc
%    reportTime
end

%Toggle if we do background removal on full images or just pots:
doPotsOrFull = 1 %1 for POTS, 0 for FULL images


%% Remove background for just pots
if doPotsOrFull == 1
    clear pots
    disp('Now Removing Pot Backgrounds')
    totPots = expInfo.camList.config(curCamNum).totPots;
    startPot = 1
    avgProcTime = 0;
    startTime = tic;
    for curPotNum = startPot:totPots %For each pot, we loop through all images
    tic
        for curImNum = startFileNum:endFileNum
            %disp(['Now on image file ' num2str(curImNum) ' and potNum ' num2str(curPotNum) ' of ' num2str(endFileNum) ' images / ' num2str(totPots) ' pots.'])
            if imageType == 1
                pots{curImNum}{curPotNum} = removeBackDSLR(potsRaw{curImNum}{curPotNum});%,expInfo.camList.whichToRun(curCamNum));
            else
                disp('IP back removal not configured yet')
                return
                %%chamber{i,2} = removeBackIP(chamber{i,1},130,150);
            end
        end
   disp(['Now on image file ' num2str(curImNum) ' of ' num2str(endFileNum-startFileNum) ' images with ' num2str(totPots) ' pots each.'])
   disp(reportTime(startTime,curImNum,(endFileNum - startFileNum)))
    end
end

return

    
    %% Remove background for full images
    disp('Now Removing Backgrounds')
    removeBack = 1
    if removeBack == 1
        for i = startFileNum:endFileNum
            tic
            disp(['Now on file: ' num2str(i) ' of ' num2str(endFileNum)])
            if imageType == 1
                chamber{i,2} = removeBackDSLR(chamber{i,1},allCamSettings(curCamNum));
            else
                chamber{i,2} = removeBackIP(chamber{i,1},130,150);
            end
            reportTime
        end
    end
    
    procTime = toc;
    timeSinceStart = timeSinceStart + procTime;
    outputTXT = ['Background removal completed in ', num2str(round(timeSinceStart)),' seconds\n\n'];
    fprintf(outputTXT)
    
    
    procTime = toc;
    timeSinceStart = timeSinceStart + procTime;
    outputTXT = ['Pot cropping completed in ', num2str(round(timeSinceStart)),' seconds\n\n'];
    fprintf(outputTXT)
    
    return
    
    %Quick process of data
    %% NOTE: should be adjusted to include the compactness and other calculations
    if doClean == 1
        [reds greens blues diffs plantinfo] = summarizeData(pots);
    end
    
    curCamNum
    savePotIms
    saveFullIms
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    %result = input('Press 1 to save workspace, press any other key to exit. ','s')
    result = 0;
    if result == '1'
        savename = [date datestr(now,'-hh-mm') '-workspace.mat']
        save(['C:\Users\Tim Brown\Documents\ANU\Projects\SpectralPhenoclimatron\Process images\TimCode\_workspaces\' savename])
    end
