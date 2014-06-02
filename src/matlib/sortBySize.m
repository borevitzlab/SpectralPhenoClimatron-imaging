
sortDay = [(1:totPots)',greens(8,:)'];
greenBySize = sortrows(sortDay,2);

nFrames = 1 ; %This determines how many times each frame gets duplicated which is an easy way to make the movie longer without FPS issues
%% Get largest pot size so images can be sized correctly
maxWid = 0;
maxHgt = 0;
for curTray = 1:trayCount
    dims = size(pots{1}{curTray});
    curTrayPotWid = dims(1);
    curTrayPotHgt = dims(2);
    if curTrayPotWid > maxWid
        maxWid = curTrayPotWid;
    end
    if curTrayPotHgt > maxHgt
        maxHgt = curTrayPotHgt;
    end
end

fullDims = max([maxHgt,maxWid]);

% Reassemble image using same dimensions as chamber
potsW = 16;
potsH = 10;

%Size of final image is going to be (potsw * fullDims) X (potsH * fullDims)
%finalIm = ones((potsW * fullDims),(potsH * fullDims),3);

finalIm = [];
curX = 1;
curY = 1;
potNum =1;
imageRow  = [];
curFrame = 1;
clear mov;
%Now add the pot data to the full image
for curDay = 1:10%nFiles
    finalIm = [];
    curX = 1;
    curY = 1;
    potNum =1;
    imageRow  = [];
    for curPotH = 1:potsH
        for curPotW = 1:potsW
            curPotIndex = greenBySize(potNum); %This is the lis of potnums soreted by size
            curIm = allPots{curPotIndex,curDay};
            curIm = padImage(curIm,fullDims);
            imageRow = [imageRow,curIm];
            potNum = potNum + 1;
        end
        finalIm = [finalIm;imageRow];
        imageRow=[];
    end
   imshow(finalIm,'Border','tight')
  axis tight
    %set(gca, 'nextplot','replacechildren', 'Visible','off');
    for i = 1:nFrames
%        disp(['CurFrame: ' num2str(curFrame)]);
%        mov(curFrame) = im2frame(finalIm)
         mov(curFrame) = getframe(gca);
        curFrame = curFrame + 1;
    end
%    close(gcf)
end

return

%% Make movie
for curDay = 1:10
    
    curIm = pots{curDay}{trayNum,potNum};
    curIm = padImage(curIm,fullDims);
    
    imshow(padImg);
    
    
    imHolder = imadd(curIm,imHolder);
    
    imshow(curIm,'Border','tight')
    axis tight
    %set(gca, 'nextplot','replacechildren', 'Visible','off');
    mov(curDay) = getframe(gca);
    close(gcf)
    
end
movie(mov,1)
return




% To taclulate what tray a pot is in:
tray = floor(potNum/20) + 1
