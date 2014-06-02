%% To save the came settings, do the following:

%% Find the current camera name/number here:
filetoload % Value created in "loadSingleIm.m"

%% Add the "whichToRun setting to the expInfo.camList:
expInfo.camList.whichToRun(##) = whichToRun

%Save expinfo
savenameExpInfo = [date datestr(now,'-hh') 'H' datestr(now,'mm'),'_',expInfo.expID,'-expInfo-settings.mat'];
pathName = uigetdir(rootSavePath,'Choose save location.')
savepathConfig = fullfile(pathName,savenameExpInfo)
save(savepathConfig, 'expInfo')



%% NOTE: Camera number in the file name is not the same as the index of the camera 
%        used to reference a specific camera in expInfo

%% Create a variable that holds just the cam settings so they can be saved:
allCamSettings = expInfo.camList.whichToRun
 % NOTE: the individual cam settings should have the camera name in them to
 % reduce chances for error
 
% Get the savepath for the expInfo file from "configProject.m"

%% NOTE: cam settings are a seperate file now to prevent accidental deletion of expInfo
% Filename for camera settings is:
camSettingsSaveName = [date datestr(now,'-hh') 'H' datestr(now,'mm') '-BVZ0012-camSettings.mat']
savepathConfig = fullfile(pathName,camSettingsSaveName)
save(savepathConfig, 'allCamSettings')

%% NOTE: If "pathame" isn't found, use the code below to set it or enter it manually
rootSavePath = 'C:\Users\Tim Brown\Documents\ANU\Projects\SpectralPhenoclimatron\Process images\Matlab\TimCode\config';
pathName = uigetdir(rootSavePath,'Choose save location.')


