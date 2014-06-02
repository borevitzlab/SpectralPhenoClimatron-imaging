%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matlab NDVI color image processing code 
% This code was written by:
% Tim Brown, TimeScience LLC
% http://www.time-science.com
% tim@time-science.com
%
% This code is licensed under a 
% Creative Commons Attribution-ShareAlike 3.0 Unported License
% Under the following conditions:
%  Attribution — You must attribute this work to Tim Brown, http://www.time-science.com (with link).
%  Share Alike — If you alter, transform, or build upon this work, you may  
%  distribute the resulting work only under the same or similar license to this one.
% More license information at: http://creativecommons.org/licenses/by-sa/3.0/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [doy, yr, mo, da, hr, mn, tsname] = parseTimeScienceFilename(filename)
% Returns a 'day of year' value from a TimeScience filename
% NOTES: 
%   *TimeScience filename format requires an imageset name prior to the date. 
%   *All values in name must be seperated by underscores "_"
%   *Filename format: "myimageset_yyyy_mm_dd_hh_min_sec_subsec.jpg"
%   *When naming, set all unused values (e.g. 'subsecond' to '00')
%   *Filename example:
%     --> Date: June 29, 2011 at 01:15:25 PM yields filename:
%     -->  Tetracam1pic_2011_06_29_13_15_25_00.jpg
%   *Only Year, Month and Day values are used to calculate DOY.
%   * "tsname" is the TimeStream name and is a string; all other values
%      returned are numbers.

   %Get indices of where each underscore is
    splits = (regexp(filename, '_'));
    %There should be 7 data values, if there aren't, then name isn't formatted correctly so warn user and quit
    if length(splits) ~= 7
        disp(['The file name: "', filename, '" is not formatted correctly.'])
        disp('The correct format should be "Cameraname_YYYY_MM_DD_HH_SS_MS.jpg" (e.g. "Tetracam1pic_2008_06_29_10_00_00_00.jpg").')
        disp('Make sure there are no jpg files in your folder with bad names and then run this program again. File processing canceled')
        beep
        return
    end
    
    yr = str2num(filename(splits(1)+1: splits(1)+4));
    mo = str2num(filename(splits(2)+1: splits(2)+2));
    da = str2num(filename(splits(3)+1: splits(3)+2));
    hr = str2num(filename(splits(4)+1: splits(4)+2));
    mn = str2num(filename(splits(5)+1: splits(5)+2));
    leapcheck=yr/4;     % Calculate Julian day
    if leapcheck-floor(leapcheck)>0
        modays=[0,31,59,90,120,151,181,212,243,273,304,334];
    else
        modays=[0,31,60,91,121,152,182,213,244,274,305,335];
    end
    doy = modays(mo)+da;
tsname = filename(1:splits(1)-1);
    
end % getDOYfromTSName

