

rootPath = 'C:\a_data\TimeStreams\Borevitz\'
%rootSavePath = fullfile(rootPath,[expInfo.expID,'\', expInfo.loc '-' expInfo.camList.chambLoc{curCamNum}],expInfo.camList.name{curCamNum},'~fullres\cropclean\')
rootSavePathRaw = fullfile(rootPath,[expInfo.expID,'\', expInfo.loc '-' expInfo.camList.chambLoc{curCamNum}],expInfo.camList.name{curCamNum},'~fullres\crop\')
%mkdir(rootSavePath)
mkdir(rootSavePathRaw)

nFiles = expInfo.camList.nFiles{curCamNum};
for i = 1:nFiles
    curImRaw = chamber{i,1};
    filename = expInfo.camList.files{curCamNum}{i};
    imsavepathraw=[rootSavePathRaw filename];
	imwrite(curImRaw,imsavepathraw);            
    if mod(i,10) == 0
        disp(['Now on image ' num2str(i) ' of ' num2str(nFiles)])
    end
end
    