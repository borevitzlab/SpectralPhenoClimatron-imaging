%% Saves pot images with correct names from plant DB
%Requirements:
% 'potsRaw' data which is created in 'processAll'
% 'loadPlantDB' must be run to load the excel data into "plantsDB"
% 'expInfo' and curCamNum must exist

saveClean = 0; %Images with background
saveRaw = 1; %Images with background removed

if saveClean
    rootSavePathClean = fullfile(rootPath, [expInfo.loc, '-' expInfo.camList.chambLoc{curCamNum}],expInfo.camList.name{curCamNum},'~potsAll\clean\')
    mkdir(rootSavePathClean);
end
if saveRaw
    rootSavePathRaw = fullfile(rootPath, [expInfo.loc, '-' expInfo.camList.chambLoc{curCamNum}],expInfo.camList.name{curCamNum},'~potsAll\orig\')
mkdir(rootSavePathRaw);
end;


fullCamName = expInfo.camList.name{curCamNum}; %Name of camera like 'CAN05'
rootSavePathClean
rootSavePathRaw
input('Ready to save cropped images. Any images with matching names in the save folders will be overwritten.\n(Press ENTER to continue or crtl^C to quit)');

for rowNum = 1:numSamples
    curRow = plantDB(rowNum,:);
    %If data from the current DB row is for the current camera then save the pot images:
    %--> previous code: if curRow{dbCamIDCol}==curCamNum %Column 8 in the DB is camNum; curCamNum is set when processAll is run
    if strcmp(curRow(dbCamIDCol),fullCamName)
        curPot = getPotNum(curRow{trayPosCol});
        accName = curRow{ascCol};
        chNum = str2num(curRow{chNumCol}); %Col6 is Chamber
        %Now loop through each day for this pot and save the images
        %Skip empty pots
        for curImNum = 1:length(potsRaw)
            if sum(size(potsRaw{curImNum})) > 0
                if curPot >160, potName = curPot-10;else potName = curPot;end
                %Add leading zeros for the filenames
                strPotNum = ['P' sprintf('%03d',curPot)]; %This is a nonnumeric with leading 0's
                strCurImNum = sprintf('%03d',curImNum);
                strChNum = ['CH' sprintf('%02d',chNum)];
                saveName = [accName,'_',strChNum,'-',strPotNum,'-',strCurImNum ,'.jpg'];
                % disp(['Saving file: ' saveName]);
                imsavepath=[rootSavePathClean saveName];
                imsavepathraw=[rootSavePathRaw saveName];
                if saveRaw == 1
                    curImRaw = potsRaw{curImNum}{potName};
                    imwrite(curImRaw,imsavepathraw);
                end
            end
            if saveClean == 1
                curIm = pots{curImNum}{potName};
                imwrite(curIm,imsavepath);
            end
        end
    end
    if mod(rowNum,20) == 0
        disp(['Now on image ' num2str(rowNum) ' of ' num2str(numSamples)])
    end
end
