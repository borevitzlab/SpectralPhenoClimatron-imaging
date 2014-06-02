%% Gets pot number from a tray/pot position like "09A3"
% [potNum,trayNum,chSide] = getPotNum(trayPotNum,isOldTrayLayout)
%  potNum is a number from 1 - 320
%  trayNum is a number from 1 - 16
%  chSide = L or R
%  --> isOldTrayLayout not yet implmented so this only works with EPXIDs
%  after ~BVZ0016
% Assumptions: 
% *All trays have 20 slots
% *We assume tray nunber starts on bottom left and goes right with tray 5 on
%  the top left of the left side of the chamber, and tray 9 on the bottom
%  left of the right side of the chamber. 
% *By default pots are counted A-D (along the bottome) and 1-5 (bottom to
%  top, starting on the left) 
% *If "isOldTrayLayout" = 1 then we assume pot position goes A-E and 1-4
% *Chamber position in the current code is determined by how the user marks
%  tray positions in "configProject.m"

function [potNum,trayNum,chSide] = getPotNum(trayPotNum,isOldTrayLayout)

% "trayPotNum" consists of 4 chars, left 2 are tray number, right 2 are position
% If tray number is >8 then we assume the tray is on the right side of the
% chamber and the pot number is >160

%Make sure trayPotNum is CHAR not CELL:
if iscell(trayPotNum), trayPotNum = trayPotNum{1},end;

trayNum = str2double(trayPotNum(1:2));

if trayNum>8,chSide = 'R',else,chSide = 'L',end

colLetter = trayPotNum(3)
switch colLetter
    case 'A'
        colVal = 1;
    case 'B'
        colVal = 2;
    case 'C'
        colVal = 3;
    case 'D'
        colVal = 4;
end

trayPotPos = ((str2double(trayPotNum(4)) - 1) * 4 ) +  colVal;
potNum = ((trayNum-1) * 20) + trayPotPos;


% if exist isOldTrayLayout
% end

end