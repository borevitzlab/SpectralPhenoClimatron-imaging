function [outputTxt] = reportTime(startTime, curItem, numItems)
%% Run by Process time to report how long things are taking
%% User enters start time, time the current tiem has taken and total items

procTime = toc;
timeSinceStart = procTime-startTime;

avgProcTime = timeSinceStart / curItem;

outputTxt = [' Processing time for current image: ' num2str(round(procTime * 100)/100), ...
    ' sec. Avg. time per image: ' num2str(round(mean(avgProcTime)*100)/100), ...
    ' sec. ' num2str(round((timeSinceStart))) ' second since start. Est. Time Left: ', ...
    num2str(round(mean(avgProcTime) * numItems)), ' seconds.']
fprintf(outputTxt)
