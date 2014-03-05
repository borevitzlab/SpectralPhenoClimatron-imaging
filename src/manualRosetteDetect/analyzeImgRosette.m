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
        % Replicate the rosettes. update if segmentRosette_sqr is successful
        retRos(i).xdata = rosettes(i).xdata;
        retRos(i).ydata = rosettes(i).ydata;
        retRos(i).color = rosettes(i).color;
        retRos(i).linewidth = rosettes(i).linewidth;
        retRos(i).center = rosettes(i).center;
        retRos(i).id = rosettes(i).id;
        retRos(i).subimg = rosettes(i).subimg;
        retRos(i).imgRange = rosettes(i).imgRange;

        if ( size(retRos(i).subimg, 1) == 0 )
            segmentFunc = ...
                @(imgRan, img, mask)segmentRosette_sqr(imgRan,img);
        else
            segmentFunc = ...
                @(imgRan, img, mask)segmentRosette_mask(imgRan,img,mask);
        end

        try
            [subimg, imgRange] = segmentFunc( rosettes(i).imgRange, ...
                                              img, ...
                                              rosettes(i).subimg );
            retRos(i).subimg = subimg;
            retRos(i).imgRange = imgRange;
            retRos(i).area = sum(sum(subimg));
        catch
            % The rosettes that have a subimg and have area = 0 are the ones
            % that could not be segmented. area=-1 means that it has not been
            % analyzed.
            retRos(i).area = 0;
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
