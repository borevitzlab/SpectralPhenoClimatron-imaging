
%% Load workspace or create new one
result = input('Do you want to load an existing workspace or start a new project?\n Press "L" to load workspace, anthing else to continue.\n','s');
if result == 'l' | 'L'
    disp('Loading workspace')
    defaultWorkPath = 'C:\Users\Tim Brown\Documents\ANU\Projects\SpectralPhenoclimatron\Process images\TimCode\_workspaces';
    if exist(defaultWorkPath,'dir') %Switch to the defaultWorkPath if it exists
        cd(defaultWorkPath);
    end
    uiopen('*.mat')
    disp('Workspace Loaded')
    who
    return
    % Exit here if user loads an existing workspace
end

clear all
%% Set default path variables
setPathVars


%% Parses through root path and get all project info
expInfo = getProjectInfo(rootPath);


%% Collect file list data for each camera (filter by time if needed):
% NOTE: Run this section manually to load a new set of images for all cameras (i.e. noon or
% different dates) 

% Time filter parameters
timeFilter.imTimeFilter1 = '*_12_00_00_00';
timeFilter.imTimeFilter2 = '*_12_10_00_00';
timeFilter.startHr = 10;
timeFilter.endHr = 15;
timeFilter.startDay = 0;
timeFilter.endDay = 31;
timeFilter.startMonth = 8;
timeFilter.endMonth = 9;

useNoon = 1; %Set useNoon = 1 to omit non-Noon images
for curCam = 1:expInfo.numCams
    imFolderPath = fullfile(expInfo.camList.path{curCam}, pathToFullIms);
    imFolderPath = imFolderPath{1};%convert back to char array from cell
    
   filelist = loadFileList(timeFilter, imFolderPath,useNoon); %This code loads the file list for each cam
   
    %Save filelist to expInfo
    nFiles = length(filelist);
    disp([' ' num2str(nFiles) ' files found for camera ' expInfo.camList.name{curCam} '.']);
    expInfo.camList.files{curCam} = filelist;
    expInfo.camList.nFiles{curCam}=nFiles;
    if nFiles < 1, beep, disp('No Files found for camera expInfo.camList.name{curCam}, make sure the file path is accurate. NOTE: file paths should end in "\"');,end;
end 

disp(['Data found from ', num2str(expInfo.numCams), ' cameras.']);

cont = input('\nHit enter to continue, anything else to quit\n');
if ~isempty(cont)
    return
end
'here'
%% Set default settings for each camera
if expInfo.numCams > 1
%     input(['You will now identify where the trays and pots are for each camera.\n\n' ...
% 	'There is data available from ' num2str(expInfo.numCams) ' cameras' ...
% 	'\nEnter "-1" when you are finished or to continue.']);
%	camNum = 1;
camNum = 1;
%input(['Please pick a number between 1 and ' num2str(expInfo.numCams) ' or Ctrl^C to quit.\n'...
%    'Enter "-1" when you are finished or to continue.\n']);
while (camNum >0)
            camNum = input(['Please pick a number between 1 and ' ...
                num2str(expInfo.numCams) ' or Ctrl^C to quit.\nEnter "-1" ' ...
                'when you are finished or to continue.\n']);
        if camNum > 0
     %THIS IS THE MAIN FUNCTION THAT CREATES CAM CONFIG DATA:
            createEachCamConfig
        end
    end
else %For only 1 camera, just do this once:
    camNum = 1;
    createEachCamConfig;
end
disp('Cam config complete, please run "processAll.m"')


%% SAVE the full experiment info from the expInfo struct
savenameExpInfo = [date datestr(now,'-hh') 'H' datestr(now,'mm'),'_',expInfo.expID,'-expInfo-settings.mat'];
%Save the current data
result = input(['Press 1 to save current settings:\n'],'s')
if result == '1'
    pathName = uigetdir(rootSavePath,'Choose save location.')
    savepathConfig = fullfile(pathName,savenameExpInfo)
    save(savepathConfig, 'expInfo')
end

return
%RETURN
%END

%% leftover code:

TopLeft X340
Y83
2805
1563

curIm = I3;

%get out layers for a crop region
blue=(curIm(y1:y2,x1:x2,1));
red=(curIm(y1:y2,x1:x2,1));
green=(curIm(y1:y2,x1:x2,2));

%Get layers for full image
blue=(curIm(:,:,1));
red=(curIm(:,:,1));
green=(curIm(:,:,2));



new = green - (red);
imshow(new)
new=(new./new).*red;




imshow(curIm, [])
title('Original Image');

% Compute the thresholds
thresh = multithresh(curIm,2);

% Apply the thresholds to obtain segmented image
seg_I = imquantize(curIm,thresh);

% Show the various segments in the segmented image in color
RGB = label2rgb(seg_I);
figure, imshow(RGB)
title('Segmented Image');