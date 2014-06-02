dataDrive = getDataDrive
rootSavePath = [dataDrive 'Users\Tim Brown\Documents\ANU\Projects\SpectralPhenoclimatron\Process images\Matlab\TimCode\config'];
rootSavePath = 'E:\a_processes\matlab_code\TimCode\config\'
rootPath = [dataDrive 'a_data\timestreams\Borevitz\BVZ0012\'];
rootPath = [dataDrive 'a_data\TimeStreams\Borevitz\BVZ0012\'];
rootPath = [dataDrive 'a_data\TimeStreams\Borevitz\BVZ0018\'];
disp(['Current Root Path: "' rootPath '"'])

%% Get path to experiment
result = input('\nPress "L" to choose a different experiment folder or hit Enter to keep the current path\n','s');
if result == 'L' | 'l'
    newroot = uigetdir('','Select Experiment Directory (don"t go below root path to ExpID)');
    if newroot ~= 0
        rootPath = newroot;
    end
    rootPath
end
% Make sure rootPath has a trailing slash
%if rootPath(length(rootPath)) ~= '\', rootPath = [rootPath,'\'], end

%This should be standardized to work for all projects:
%pathToFullIms = '\~fullres\orig\full\' %(Note: Need to standardize trailing slashes in file paths):
pathToFullIms = '~fullres\orig\'

