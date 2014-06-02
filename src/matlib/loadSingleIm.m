
[tempimname, tempimpath] = uigetfile('*.jpg');
filetoload = fullfile(tempimpath, tempimname);
curIm = imread(filetoload);
disp('curIm loaded')