%% Loads the plant DB file that has all the experiment information
%  *Excel file can have any number of columns but columns must include:
%    'PlantName'
%    'ExperimentID'
%    'TrayPosition'
%    'Chamber'
%    'CamID'
% *Column name is not case sensitive but if the name exists in more than one
% *column the first column will be chosen.
% 
% 'setPathVars' must have been run prior ot this to set "rootPath"
% 'expInfo; must exist


% How load excel data:
%[~,~,raw]=xlsread('C:\Users\Tim Brown\Documents\ANU\Projects\SpectralPhenoclimatron\Process images\Matlab\TimCode\BVZ0012AllForExportNoDash.xlsx')
%[~,~,raw]=xlsread('C:\Users\Tim Brown\Documents\ANU\Projects\SpectralPhenoclimatron\Process images\Matlab\TimCode\BVZ0012AllForExportNoDash.xlsx');
% To access a give value as a number use: raw(r),{c} where r is ROW# and c is column#

dataFileName = [expInfo.expID '_plantDB.xlsx']
rootDataPath = [rootPath '_DATA\' dataFileName]

%% Load excel data:
[~,~,plantDBRaw]=xlsread(rootDataPath);
%%raw = raw(1:696,:);


hasHeaders = 1
if hasHeaders == 1
    startRow = 2
    numSamples = length(plantDBRaw)-1; %Total number of rows in DB
else
    startRow = 1;
    numSamples = length(plantDBRaw); %Total number of rows in DB
end

header = plantDBRaw(1,:);

ascCol = getColFromHead(header,'PlantName');
expIDCol = getColFromHead(header,'ExperimentID');
trayPosCol = getColFromHead(header,'TrayPosition');
chNumCol = getColFromHead(header,'Chamber');
dbCamIDCol = getColFromHead(header,'CamID');

%Save just the columns we need to make it easier to manage
plantDB = [plantDBRaw(startRow:numSamples,ascCol),plantDBRaw(startRow:numSamples,expIDCol), ...
    plantDBRaw(startRow:numSamples,trayPosCol),plantDBRaw(startRow:numSamples,chNumCol), ...
    plantDBRaw(startRow:numSamples,dbCamIDCol)];

clear plantDBRaw;

%If there are underscores in accession names, replace with dashes
%Also replace any other chars that can't be in a filename with a dash
for i = 1:length(plantDB)
    plantDB{i,1}(strfind(plantDB{i,1},'_')) = '-';
    plantDB{i,1}(strfind(plantDB{i,1},'\')) = '-';
    plantDB{i,1}(strfind(plantDB{i,1},'/')) = '-';
    plantDB{i,1}(strfind(plantDB{i,1},':')) = '-';
    plantDB{i,1}(strfind(plantDB{i,1},'-')) = '-';
end
        
%Reset column indices to match new DB
ascCol = 1;
expIDCol = 2;
trayPosCol = 3;
chNumCol = 4;
dbCamIDCol = 5;

