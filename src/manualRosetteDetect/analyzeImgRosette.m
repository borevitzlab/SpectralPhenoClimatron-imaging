% Copyright (C) 2014 Joel Granados <joel.granados@gmail.com>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
function [retRos, retImg] = analyzeImgRosette ( rosettes, img )

    retImg = img;
    for ( i = 1:size(rosettes,2) )
        % Replicate the rosettes. update if findSegmentedRosette is successful
        retRos(i).xdata = rosettes(i).xdata;
        retRos(i).ydata = rosettes(i).ydata;
        retRos(i).color = rosettes(i).color;
        retRos(i).linewidth = rosettes(i).linewidth;
        retRos(i).userdata = rosettes(i).userdata;
        retRos(i).subimg = rosettes(i).subimg;
        retRos(i).imgRange = rosettes(i).imgRange;

        try
            [subimg, imgRange] = findSegmentedRosette(rosettes(i).imgRange,...
                                                      img);
            retRos(i).subimg = subimg;
            retRos(i).imgRange = imgRange;
        catch
            warning ( strcat ( 'Could not segment square : (', ...
                      num2str(rosettes(i).imgRange.yFrom), ',', ...
                      num2str(rosettes(i).imgRange.xFrom), '), (', ...
                      num2str(rosettes(i).imgRange.yTo), ',', ...
                      num2str(rosettes(i).imgRange.xTo), ')' ) );
            continue;
        end

        % Give a red hue to the detected rosette.
        [r c] = find(retRos(i).subimg ==1);
        r = int64(r + retRos(i).imgRange.yFrom - 1);
        c = int64(c + retRos(i).imgRange.xFrom - 1);
        d = int64(ones(size(c,1), 1));
        retImg ( sub2ind( size(retImg), r, c, d ) ) = 255;
    end

end
