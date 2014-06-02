function [dirList] = getDirList(dirName)

%First get the folder list 
dirData = dir(dirName);      %# Get the data for the current directory
dirIndex = [dirData.isdir];  %# Find the index for directories
dirList = {dirData(~dirIndex).name}';  %'# Get a list of the files
subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
validIndex = ~ismember(subDirs,{'.','..',});  %# Find index of subdirectories that are not '.' or '..'
dirList = subDirs(validIndex)';

index = 1;
for i = 1:length(dirList)
    newDirs = dirList;
    if newDirs{i}(1,1) ~= '_' %Skip folder name if it starts with "_"
        dataDirs{index} = newDirs{i};
        index = index + 1; %need to increment only for existing folders to prevent empty cells
    end    
end 
dirList = dataDirs
end


