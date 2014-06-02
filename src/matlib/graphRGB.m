%%%%%%%%%%%%%%%%%%
%load all images
camToLoad = 1
allIms = [];
for i = 1:length(expInfo.camList.files{camToLoad});
    disp(['Now loading image ' num2str(i)])
    loadpath = fullfile(expInfo.camList.path{camToLoad}, pathToFullIms,expInfo.camList.files{camToLoad}{i});
    allIms{i} = imread(loadpath{1});
end

for curIm = 1:length(allIms)
   % imshow(allIms{2});
    redCount(curIm) = sum(sum(allIms{curIm}(:,:,1)));
    greenCount(curIm) = sum(sum(allIms{curIm}(:,:,2)));
    blueCount(curIm) = sum(sum(allIms{curIm}(:,:,3)));
end

hold on
plot(redCount,'r')
plot(greenCount,'g')
plot(blueCount,'b')
title('Sum of all RGB pixels for a full day in GC02 (BVZ0012)')