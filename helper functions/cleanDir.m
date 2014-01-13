%% Returns a cell array containing a windows folder list without the ".' or ".." folder names in it
% Also omits folders that start with "_". This lets us put other folders
% like "_DATA" in the dir root without crashing the automatic parsing code
function [dirlist] = cleanDir(filePath)

list = dir(filePath);
dirlist={list([list.isdir]).name};
dirlist=dirlist(~(strcmp('.',dirlist)|strcmp('..',dirlist))); %OMIT '.' and '..'
dirlist = dirlist(find(cellfun(@isempty,regexp(dirlist,'_')))); %OMIT folders with "_"
end

