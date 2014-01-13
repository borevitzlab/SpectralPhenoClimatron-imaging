%%NOTE:  Need to have run "summarizeData" first

format bank

savepath = 'C:\Users\Tim Brown\Documents\ANU\Projects\SpectralPhenoclimatron\Process images\Matlab\Output\Gordonopen pots\CVI-Fluct-271\'
plantName = 'CVI-self'
%plantName = 'LER-self'
treatment = 'Fluctuating Light'
%treatment = 'Excess Light';
%treatment = 'Sufficient Light'
potName = 271
name = expInfo.camList.chambLoc(curCamNum)
filename = [ plantName '_' name{1} '-Pot' num2str(potName)]

%Each chamber side (per camera) only goes to 160 so we have to adjust pot number to match number in image
if potName >160, potNum = potName - 160; else potNum = potName;end

xmin = 1; ymin=1;
xmax = nFiles;
ymax = 4200000;% max(max(greens(1:nFiles,:))) %For now lets use max value for all plants so things scale well
areaRatio = [plantinfo(xmin:xmax,potNum).fillRatio]; %This is the list of all compactness measures accross time

nFrames = 30 ; %This determines how many times each frame gets duplicated which is an easy way to make the movie longer without FPS issues


    
    %%This is the code for plotting compactness
% %         figure;
% % %        axis tight
% %         [ax, h1,h2]=plotyy(1:numIms, reds(1:numIms,potNum),1:numIms, areaRatio(1:numIms));
% %         hold on
% %         set(ax,'nextplot','add');
% %         h3 =plot(1:numIms,greens(1:numIms,potNum),'g'); %Using numplots in the 3rd plotposition setting assures it gets in the correct location (i.e. last)
% %         axis tight
% %         xlabel('Day')
% %         title([plantName '   ' treatment]);
% %         set(h1,'Color','r')
% %         set(h2,'Color','k')
% %         
% %         %Resize figure so it saves correctly
% %         set(gca,'Units','normalized','Position',[0.15 0.15 0.75 0.75])
% %         
% %         %Fix axis colors:
% %         set(ax,'YColor','k') %This applies the change to both axes
% % 
% %         set(get(ax(1),'Ylabel'),'String','Green & Red Pixels')
% %         set(get(ax(2),'Ylabel'),'String','Compactness (Black)')
% % 
% %         set(ax(1),'xlim',([xmin,xmax]),'ylim',([ymin,ymax]));
% %         set(ax(2),'xlim',([xmin,xmax]),'ylim',([0,1]));
% %         set(ax(1),'YTick',[1:ymax/10:ymax])
% %         set(ax(2),'YTick',[0:0.1:1])
    return
end

%% Make a movie from a particular pot
doSingle = 1;
if doSingle == 1
    %    trayNum = 1
    clear mov1
    clear mov2

    mov1FrameIndex = 1;
    
    greenVidName = [fullfile([savepath filename '-greenpixels.avi'])]
    
    vid = avifile(greenVidName);
    
    %Choose between raw vs processed image
    useRaw = 1;
    
for curFile = 1:nFiles %nFiles is equivalent to days since we use noon images

        curImRaw = potsRaw{curFile}{potNum};
        curIm = pots{curFile}{potNum};

        figure;
        if useRaw == 1
            numPlots = 3;
            subplot(1,numPlots ,2)
            imshow(curImRaw,'Border','tight');
        else
            numPlots = 2
        end
        subplot(1,numPlots ,1), imshow(curIm,'Border','tight');
        title(plantName);
        axis tight
        
        subplot(1,numPlots,numPlots)
        [ax, h1,h2]=plotyy(1:curFile, reds(1:curFile,potNum),1:curFile, areaRatio(1:curFile));
        hold on
        set(ax,'nextplot','add');
        h3 =plot(1:curFile,greens(1:curFile,potNum),'g'); %Using numplots in the 3rd plotposition setting assures it gets in the correct location (i.e. last)
        axis tight
        xlabel('Day')
        set(h1,'Color','r')
        set(h2,'Color','k')
        
        %Fix axis colors:
        set(ax,'YColor','k') %This applies the change to both axes

        set(get(ax(1),'Ylabel'),'String','Green & Red Pixels')
        set(get(ax(2),'Ylabel'),'String','Compactness')

        set(ax(1),'xlim',([xmin,xmax]),'ylim',([ymin,ymax]));
        set(ax(2),'xlim',([xmin,xmax]),'ylim',([0,1]));
        set(ax(1),'YTick',[1:ymax/10:ymax])
        set(ax(2),'YTick',[0:0.1:1])

        set(gca,'nextplot','replacechildren');
        set(gcf,'Renderer','zbuffer');
        set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
        
        f = getframe(gcf); % <<< Added figure handle in function call
        
        for i = 1:nFrames
            vid = addframe(vid,f);
        end
        close(gcf)
        
        
    end
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
            imageRow = [imageRow,curIm];
            potNum = potNum + 1;
        end
        finalIm = [finalIm;imageRow];
        imageRow=[];
    end
    imshow(finalIm,'Border','tight')
    axis tight
    for i = 1:nFrames
        mov(curFrame) = getframe(gca);
        curFrame = curFrame + 1;
    end
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
