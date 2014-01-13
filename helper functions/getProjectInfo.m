function [expInfo]=getProjectInfo(rootPath)

dataDirs = getDirList(rootPath);
chList = [];
expInfo = [];
disp(['NOTES:']);
disp([' *Omit non-data folders from project by putting "_" at the start of the folder name or "getProjectInfo" will fail']);
disp([' *Folder path for projects should be of the form: BVZ0018\NCRIS-GC04L\~fullres...']);
disp([' *Set path to actual images ("pathToFullIms") in "configProject"']);

%Omit folders beginning with "_"
% This should be done automatically in "dataDirs"
    
for i = 1:length(dataDirs)
    if ~isempty(dataDirs{i}) & ~isempty(strfind(dataDirs{i},'-'))   %Skip empty dirs
        if dataDirs{i}(1,1) ~= '_' %Skip folder name if it starts with "_"
            a = strsplit(dataDirs{i},'-')
            chList(i) = str2num(a{2}(4));
            chInfo.name = a{2}; 
            expInfo.chamber(i) = chInfo;
        end    
    end
end

% Find experiment name & Location
details = strsplit(rootPath,'\');
expInfo.expID = details{length(details)-1}; %If path doesn't conform then just the the EXPID here: 'Setting expID to BVZ0018' %If we aren't doing a bunch of cameras we have to do this

details = strsplit(dataDirs{1},'-');
expInfo.loc = details{1}; %Find location (Usually "NCRIS" or "CEF" for now)
expInfo.numChambers = length((unique(chList)));
expInfo.numChamberSides = length(dataDirs);
%a =  getCamList(rootPath,dataDirs) %This duplicates the cam listings under chamber but mnakes it easier to access cameras directly if we need their info

expInfo.camList = getCamList(rootPath,dataDirs);


length(dataDirs)
camCount = 0;
for curCh = 1:expInfo.numChamberSides
    curPath = fullfile(rootPath,dataDirs(curCh));
    curCamList = cleanDir(curPath{1});
    numCams = length(curCamList);
    for cCam = 1:numCams
        camList(cCam).name = curCamList{cCam};
        %disp(['Cam Name: ' camList(cCam).name]);
        camList(cCam).camPath = fullfile(curPath,camList(cCam).name);
        camList(cCam).chambLoc{cCam}= dataDirs{curCh};
        camList(cCam).camType = getCamType(camList(cCam).name);
        camCount = camCount + 1;
    end
    expInfo.chamber(curCh).fullpath = curPath;
    expInfo.chamber(curCh).cams = camList;
end

expInfo.numCams = camCount;


%% Loop through the sub dirs and return the cam names
    function [camList] = getCamList(rPath,dDirs)
        camList=[];
        index = 1;
        for cdr = 1:length(dDirs)
            curDir = fullfile(rPath,dDirs(cdr));
            subDir = cleanDir(curDir{1});  %# Get a list of the subdirectories
            for j = 1:length(subDir)
                % if isempty(strfind(subDir(j).name,'.')) %Skip the empty paths with "." in them
                camList.name{index} = subDir{j};
                camList.path{index} = fullfile(rPath,dDirs(cdr),camList.name{index});
                temp = strsplit(curDir{1},'-'); %Split the file path out - the last part one the right of the "-" is the chamber location of the camera
                camList.chambLoc{index}= temp{2};
                result = getCamType(camList.name{index});
                if result == -1
                    disp(['Error parsing directory: "', camList.name{index}, '" in path: ', curDir{:}])
                    disp('Camera Type not recognized. Current recognized camera types are "CAN" and "NC5"')
                    disp('SubFolder under EXPID folder should only be camera names like "CAN08')
                    disp('To omit a folder add a "_" to the front like "_data"')
                    input('Ctrl^C to quit and check directory structure.')
                    return
                else
                    camList.camType{index}=result;
                end
            %  % NOT YET IMPLEMENTED  camList.chIndex  %Index of the chamber here: expInfo.chamber(index) So we can access chamber info quickly
                index = index + 1;
                % end
            end
        end
    end

    function [camType] = getCamType(camName)
        %returns 1 for DSLR and 2 for Netcam
        % This assumes that a camera names starts with CAN for the DSLR and
        % NC5 for the netcam 5 - This will need to be improved on as we
        % expand camer types and lenses, etc
        camType = [];
        if camName(1:3) == 'CAN'
            camType = 1;
        elseif camName(1:3) == 'NC5'
            camType = 2;
        else
            camType = -1
        end
%        if isempty(camType),
%            input(['Error parsing directory: ' subDir])
%        end
    end


return

%% Stuff below is being saved but is not in use...

%Get Camera Name list from the sub folders
camList = getCamList(rootPath,dataDirs);
expInfo.numCams = length(camList.name);


for curCam = 1:expInfo.numCams
    % expInfo.chamber(curCham,1)  %left side of chamber
    % expInfo.chamber(curCham,2)  %Right side of chamber
    curCamInfo.name = camList.name{curCam}
    curCamInfo.path= camList.path{curCam}
    curCamInfo.chambLoc= camList.chambLoc{curCam}
    curCamInfo.camType= camList.camType{curCam}
    
    expInfo.camInfo(curCam) = curCamInfo;
    
end




end