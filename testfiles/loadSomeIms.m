filepath = 'C:\Users\Tim Brown\Documents\ANU\Projects\SpectralPhenoclimatron\Process images\Matlab\images\testimages\CameraColorCheck\';
disp('Current filepath is:')
disp(filepath)
result = input('Press the letter "o" to choose an input folder or hit any other key to use the current folder.\n','s');
if result == 'o' | 'O' | 0
    imFolderPath=    uigetdir(filepath);
    disp(['New file path= ', filepath]);
end

loadfolder = 1;

%Load file list
%allFiles=dir([filepath,imTimeFilter,imFilefilter]);
allFiles=dir([filepath,'*.jpg']);
numFiles=length(allFiles);
if numFiles < 1, beep, disp('No Files found, make sure the file path is accurate. NOTE: file paths should end in "\"'),end

if loadfolder == 1

    for i=1:numFiles
        tic
        % Load image file
        % ['Loading image number ', num2str(i)']
        imName = allFiles(i).name;
        disp(['Now on file: ' num2str(i) ' of ' num2str(numFiles) ', Filename: ' imName])

        imFiles{i,1} = imread([filepath, allFiles(i).name]);
        %imFiles{i,2} = unwarp(curIm,totalRotation,imCenter,imCropCoords,unwarpAmt);
        %reportTime
    end
end