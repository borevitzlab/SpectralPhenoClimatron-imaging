function [reds greens blues diffs infos] = summarizeData(potsArray)

% filepath = 'C:\Users\Tim Brown\Documents\ANU\Projects\SpectralPhenoclimatron\Process images\TimCode\images\output\'
% for i = 1:15
%     imwrite(pots{i}{2,4},[filepath, num2str(i), '.jpg'])
% end

nDays = length(potsArray)
%result = input('Hit 1 to save images.\n')
result = 0;
if result ==1
     filepath = 'C:\Users\Tim Brown\Documents\ANU\Projects\SpectralPhenoclimatron\Process images\TimCode\images\output\'
     for curDay = 1:nDays
         imwrite(potsArray{curDay}{2,4},[filepath, num2str(curDay), '.jpg'])
     end
end

% POTS format:
% Pots{ImageNumber}{TrayNumber,PotNum}(x,y,RGB)

potCount = length(potsArray{1})
% trayCount = size(potsArray{1});
% trayCount = trayCount(1)

clear reds;
clear blues;
clear greens;
for curDay = 1:nDays
    curPlant = 1;
%     for curTray = 1:trayCount
%         curTray
        for potNum = 1:potCount
            %For now collect data in two formats:
            curIm = potsArray{curDay}{potNum};
            reds(curDay,curPlant) = sum(sum(potsArray{curDay}{potNum}(:,:,1)));
            greens(curDay,curPlant) = sum(sum(potsArray{curDay}{potNum}(:,:,2)));
            blues(curDay,curPlant) = sum(sum(potsArray{curDay}{potNum}(:,:,3)));

            diffs = reds./greens;
            red1(potNum,curDay) = sum(sum(potsArray{curDay}{potNum}(:,:,1)));
            green1(potNum,curDay) = sum(sum(potsArray{curDay}{potNum}(:,:,2)));
            blue1(potNum,curDay) = sum(sum(potsArray{curDay}{potNum}(:,:,3)));
            curPlant = curPlant + 1;
            
            infos(curDay,curPlant) = getImageInfo(curIm);
            if potNum == 10
                disp('end loop')
                curDay
                potNum
                infos(curDay,curPlant)
                imshow(curIm)        
            end
            
        end
%     end
end
return
hold on
subplot(2,1,1), plot(greens)
subplot(2,1,2), plot(diffs)
plot(reds,'r')
%plot(blues,'b')
