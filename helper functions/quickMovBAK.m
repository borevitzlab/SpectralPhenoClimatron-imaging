%%NOTE:  Need to have run "summarizeData" first

nFrames = 40 ; %This determines how many times each frame gets duplicated which is an easy way to make the movie longer without FPS issues

%% Make a quick movie from a particular pot
doSingle = 1;
if doSingle == 1
    %    trayNum = 1
    potName = 234 %Each chamber side (per camera) only goes to 160 so we have to adjust pot number to match number in image
    plantName = 'CVI-self'
    if potName >160
        potNum = potName - 160;
    else
        potNum = potName;
    end
    name = expInfo.camList.chambLoc(curCamNum)
    filename = [ plantName '_' name{1} '-Pot' num2str(potName)]
    clear mov1
    clear mov2
    xmin = 1; ymin=1;
    xmax = nFiles;
    ymax = max(max(greens(1:nFiles,:))) %For now lets use max value for all plants so things scale well
    
    mov1FrameIndex = 1;
    mov2FrameIndex = 1;
    
%    writerObj1 = VideoWriter([filename '-images.avi'],'Uncompressed AVI');
  %  writerObj1 = VideoWriter(['Pot-244-images.avi'],'Uncompressed AVI');
 %   writerObj2 = VideoWriter([filename '-Greenpixels.avi'],'Uncompressed AVI');
  greenVidName = [filename '-greenpixels.avi']
  %greenVidName = ['Pot-244-greenpixels.avi']
%     writerObj1.Quality=100
%     writerObj1.FrameRate=15;
%     writerObj2.Quality=100;
%     writerObj2.FrameRate=15;
% 
%     open(writerObj1);
%     open(writerObj2);
%     
    vid = avifile(greenVidName);
    
    for curFile = 1:nFiles %nFiles is equivalent to days since we use noon images
        curIm = pots{curFile}{potNum};
%         imshow(curIm,'Border','tight')
%         axis tight
%         set(gca,'nextplot','replacechildren');
%         set(gcf,'Renderer','zbuffer');
        
        subplot(1,2,1), imshow(curIm,'Border','tight');
        axis tight
        subplot(1,2,2), plot(1:curFile,greens(1:curFile,potNum));
        axis tight
        xlabel('Day')
        ylabel('Green Pixels')
        axis([xmin,xmax,ymin,ymax])

        set(gca,'nextplot','replacechildren');
        set(gcf,'Renderer','zbuffer');
        set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.

        f = getframe(gcf); % <<< Added figure handle in function call
        vid = addframe(vid,f);

        for i = 1:nFrames
            %  mov1(mov1FrameIndex) = getframe(gca);
            frame = getframe(gca);
            writeVideo(writerObj1,frame);
            mov1FrameIndex = mov1FrameIndex + 1;
        end
        close(gcf)

%         %Now plot green pixel data
%            figure
%            plot(1:curFile,greens(1:curFile,potNum));
%           %  set(f,'Renderer','zbuffer');
% 
%             axis tight
%             xlabel('Day')
%             ylabel('Green Pixels')
%         axis([xmin,xmax,ymin,ymax])
% %        set('nextplot','replacechildren');
%         
%         for i = 1:nFrames %Save the same frame a bunch of times to make movie longer
%             mov2(curFile) = getframe(gca);
%             frame2 = getframe(gca);
%             writeVideo(writerObj2,frame2);
%             mov2FrameIndex = mov2FrameIndex + 1;
%         end
%         close(gcf)

    end
    %    movie(mov1,1)
    %   movie(mov2,1)
    close(writerObj1)
   % movie2avi(mov2,greenVidName, 'compression', 'None')
    
   close(writerObj2)
   vid = close(vid);

    return
end



%% Make a movie of the whole dataset


totPots = curCamSet.totPots
sortDay = [(1:totPots)',greens(8,:)'];
greenBySize = sortrows(sortDay,2);


% Get largest pot size so images can be sized correctly
maxWid = 0;
maxHgt = 0;
for curPot = 1:totPots
    [xDim yDim,n] = size(allPots{curPot});
    xPots(curPot)=xDim;
    yPots(curPot)=yDim;
    if xDim > maxWid
        maxWid = xDim;
    end
    if yDim > maxHgt
        maxHgt = yDim;
    end
end

fullDims = max([maxHgt,maxWid])

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
            curPotIndex = greenBySize(potNum); %This is the lis of potnums sorted by size
            curIm = allPots{curPotIndex,curDay};
            [xWid yHgt,n]= size(curIm(:,:,1));
            xPad = abs(xWid - fullDims)+1;
            yPad = abs(yHgt - fullDims)+1;
            curIm = impad(curIm, yPad,xPad);
            
            %%Code to show min circle:
            edgeim = edge(curIm(:,:,2),'canny', [0.1 0.2], 1);
            info = findObjectInfo(curIm);
            circle([info.xCent,info.yCent],info.radius);
            plot(info.xCent,info.yCent,'ro');
            axis tight
            %%end of min circle code (not working)
            
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




% To caculate what tray a pot is in:
tray = floor(potNum/20) + 1


%% This doesn't work yet
%# save as AVI file, and open it using system video player
movie2avi(mov, 'myPeaks1.avi', 'compression','None', 'fps',10);
winopen('myPeaks1.avi')
