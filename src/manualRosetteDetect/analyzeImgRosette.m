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
        retRos(i).mask = rosettes(i).mask;
        retRos(i).subimg = rosettes(i).subimg;
        retRos(i).imgRange = rosettes(i).imgRange;

        if ( size(retRos(i).mask, 1) == 0 || size(retRos(i).subimg, 1) == 0 )
            segmentFunc = ...
                @(imgRan, img, prevmask, previmg) ...
                    segmentRosette_sqr(imgRan,img);
        else
            segmentFunc = ...
                @(imgRan, img, mask)segmentRosette_levelset(imgRan,img,mask);
        end

        try
            [mask, imgRange] = segmentFunc( rosettes(i).imgRange, ...
                                              img, ...
                                              rosettes(i).mask, ...
                                              rosettes(i).subimg);
            retRos(i).imgRange = imgRange;
            retRos(i).area = sum(sum(mask));
            retRos(i).gcc = calc_gcc(imgRange, img, mask);
            retRos(i).exg = calc_exg(imgRange, img, mask);
            retRos(i).diam = calc_diameter(mask);
            retRos(i).mask = mask;
            retRos(i).subimg = img( int64(imgRange.yFrom:imgRange.yTo), ...
                                    int64(imgRange.xFrom:imgRange.xTo), : );
        catch err
            if ( strncmp(err.identifier, 'segmentRosette', 14) == 1)
                % The rosettes having mask and area = NaN could not be
                % segmented. area=-1 have not been analyzed.
                retRos(i).area = NaN;
                retRos(i).gcc = NaN;
                retRos(i).exg = NaN;
                retRos(i).diam = NaN;
                continue;
            else
                rethrow(err);
            end
        end

        % Give a red hue to the detected rosette.
        [r c] = find(retRos(i).mask ==1);
        r = int64(r + retRos(i).imgRange.yFrom - 1);
        c = int64(c + retRos(i).imgRange.xFrom - 1);
        d = int64(ones(size(c,1), 1));
        retImg ( sub2ind( size(retImg), r, c, d ) ) = 255;
    end

end

function retVal = calc_gcc ( imgRange, img, mask )
    [r c] = find(mask ==1);
    r = int64(r + imgRange.yFrom - 1);
    c = int64(c + imgRange.xFrom - 1);
    d = int64(ones(size(c,1), 1));
    R = double(img(sub2ind(size(img), r, c, d)));
    d(:) = 2;
    G = double(img(sub2ind(size(img), r, c, d)));
    d(:) = 3;
    B = double(img(sub2ind(size(img), r, c, d)));

    %FIXME: How do we calculate gcc? would meadian be better?
    %retVal = median(G./(R+G+B));
    %retVal = median(G)/(median(R)+median(G)+median(B));
    retVal = mean(G)/(mean(R)+mean(G)+mean(B));
    %retVal = mean(G./(R+G+B));
end

function retVal = calc_exg ( imgRange, img, mask )
    [r c] = find(mask ==1);
    r = int64(r + imgRange.yFrom - 1);
    c = int64(c + imgRange.xFrom - 1);
    d = int64(ones(size(c,1), 1));
    R = double(img(sub2ind(size(img), r, c, d)));
    d(:) = 2;
    G = double(img(sub2ind(size(img), r, c, d)));
    d(:) = 3;
    B = double(img(sub2ind(size(img), r, c, d)));

    %FIXME: How do we calculate gcc? would meadian be better?
    %retVal = median(2*G-R-B);
    %retVal = 2*median(G)-median(R)+median(B);
    retVal = mean(2*G-R-B);
end

function retVal = calc_diameter ( mask )
    % r-> row, c-> column
    [r c] = find(mask ==1);
    r = double(r);
    c = double(c);
    % C-> center, R-> radius
    [C, R] = minboundcircle (c, r);
    retVal = 2*R;
end
