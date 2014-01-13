function [filelist] = loadFileList(timeFilter,imFolderPath,useNoon)
fileslist = [];
if useNoon == 1 %Here we filter by TimeFilter; otherwise we filter by hour
    clear filelist
    disp('Filtering for just noon images') %We filter on 12:00 & 12:10 since there's a bug in the TimeManager that rounds timestamps incorrectly and often misses the top of the hour; we pick the search that returns the most files
    %Load file lists and see which has more files
    imFilefilter='.jpg';
    files1=dir([imFolderPath,timeFilter.imTimeFilter1,imFilefilter]);
    tempnames1 = struct2cell(files1);
    filecount1 = length(tempnames1(1,:));
    filelist = tempnames1(1,:);
    
% %     files2=dir([imFolderPath,timeFilter.imTimeFilter2,imFilefilter]);
% %     tempnames2 = struct2cell(files2);
% %     filecount2 = length(tempnames2(1,:));
% %     if filecount1>filecount2
% %         filelist = tempnames1(1,:);
% %     elseif filecount2>filecount1
% %         filelist = tempnames2(1,:);
% %     else
% %         filelist = tempnames1(1,:);
% %     end
else
    clear filelist
    %This loads all jpg images in the folder
    imFilefilter='*.jpg';
    files=dir([imFolderPath,imFilefilter]);
    %Now omit the files not withing the selected time period
    numFiles = length(files);
    index = 1;
    for curFileNum = 1:numFiles
        curFile = strsplit(files(curFileNum).name,'_');
        if (str2num(curFile{5}) > timeFilter.startHr) & (str2num(curFile{5}) < timeFilter.endHr)        %Index 5 is hour
            if (str2num(curFile{3}) >= timeFilter.startMonth) & (str2num(curFile{3}) <= timeFilter.endMonth)        %Index 5 is hour
                if (str2num(curFile{4}) >= timeFilter.startDay) & (str2num(curFile{4}) <= timeFilter.endDay)        %Index 5 is hour
                    filelist{index} = files(curFileNum).name;
                    index = index+1;
                end
            end
        end
    end
    if length(filelist)==0
        beep
        disp(['No files found that match search criteria. Check start/end dates and times in "configProject".']);
    end
end