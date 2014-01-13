% Takes an image with trayCount of trays in it and the tray coords set by the user in 'configProject'
% Returns the potData array that has all pots for the image cropped evenly based on potRow/Col count
% 'potData' holds pixel data for each pot, cropped from the curTray image data; 
% Pots are indexed from 1 to 320; left chamber is 1-160; rightchamber is 161-320
% Oredering and accuracy of individual pot numbers assumes that user set
% original tray coordinates in the correct order (i.e. left - right, bottom to top)

function [potData] = cropPots(curIm,traysInfo,trayCount,potColCount,potRowCount)

%disp(['REDO POT INDEXING TO START FROM BOTTOM!'])

debug = 0;
if debug == 1
    curIm = plants{1,2};
    traysInfo = trays;
    trayCount = trayCount;
    potColCount = potCols;
    potRowCount = potRows;
end
%Crop out each tray
i=1;
for i = 1:trayCount
    curTray = traysInfo(i,:);
    trayPx{i} = curIm(curTray(2):curTray(4),curTray(1):curTray(3),:);
    %imshow(trayPx{i});
end

%Get pot size for each tray
for i = 1:trayCount
    traySize = size(trayPx{i});
    trayHgt(i) = traySize(1);
    trayWid(i) = traySize(2);
    potHgt(i)= floor(trayHgt(i)/potRowCount)-1; %%NOTE!: Subtracted to fix bug - need to FIX!
    potWid(i) = floor(trayWid(i)/potColCount)-1;
end

curPotIndex = 1;
x = 1;
y = 1;
curTrayNum = 1;
clear pots;

potCoords = cell(trayCount,4); %This holds the x,y coords for each pot in each tray

% For each tray, loop through and cut out each pot and save it in the
% potData array

for curTrayNum = 1: trayCount
    curTray = trayPx{curTrayNum}; % Get pixels for current tray
%     imshow(curTray)
%     pause 
    curTrayNum;
    curPotHgt = potHgt(curTrayNum); % potHgt holds the calculated hgt values for pots in each tray
    curPotWid = potWid(curTrayNum); % potWid holds the calculated wid values for pots in each tray
   %Pots are indexed 1-160 
%    x=1;y=1;y2=curPotHgt; %Reset all variables to 1
    %Should be for the new numbering:
 x=1;y=(trayHgt(curTrayNum) - curPotHgt);y2=trayHgt(curTrayNum); %Start at bottom of tray

    for i = 1:potRowCount
        for j = 1:potColCount
            potCoords{curTrayNum} = [potCoords{curTrayNum};y,y2,x,x+curPotWid]; % record the coords for the current pot
            potData{curPotIndex}=curTray(y:y2,x:x+curPotWid,:); 
            %potData holds pixel data for each pot, cropped from the curTray image data; 
            %Pots are indexed from 1 to 320; left chamber is 1-160;rightchamber is 161-320
            curPotIndex = curPotIndex + 1;
            x = x + potWid(curTrayNum);
        end
        x=1;
      %  y = y + curPotHgt;
      %  y2 = y2+curPotHgt; % You have to increment both parts of the y value so the row moves down
     %Pot row move up from bottom of tray to top:
       y = y - curPotHgt;
       y2 = y2-curPotHgt; % You have to increment both parts of the y value so the row moves down
    end
end

