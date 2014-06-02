%% Use this to reload the config section of expInfo.camList
% (1) Open a MAT settings file with known good config info
% (2) Run this file
% (3) Open a MAT setting file with the good expInfo file that is missing config (or rerun the file loading code)
% (4) Re-save expInfo (code for this is at the end of "configProject.m")

for i = 1:expInfo.numCams
    cams(i) = expInfo.camList.config(i
end

useNoon = 0
for i = 1:5
    expInfo.camList.config(i).startImNum = 2
    if useNoon == 1
        endNum = 11
    else
        endNum = expInfo.camList.nFiles{i}
    end
    expInfo.camList.config(i).endImNum = endNum
%    expInfo.camList.config(i).endImNum = expInfo.camList.nFiles{i}
end
