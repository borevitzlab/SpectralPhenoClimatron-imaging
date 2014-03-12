% Annotation.  An annotation creation tool for images.
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

function [area, circleC, circleR, circleRcm] = leafscanimg ( imgpath )
    if ( exist(imgpath) == 0 )
        err = MException ( 'leafscan:ImgPathNotFound', ...
                           strcat ( 'Could not find file ', ...
                                    imgpath ) );
        throw(err);
    end

    img = rgb2gray(imread(imgpath));

    CC = {};

    % Rectangle where we do our analysis. (should be the back lit rect)
    yfrom = 1;
    yto = size(img, 1);
    xfrom = 1;
    xto = size(img, 2);

    % 0.5, and 0.05 are arbitrary
    for (i = 0.5:0.05:1)

        % apply threshold
        bwimg = im2bw(img, i);

        % Try to find back lit section
        [yfrom, yto, xfrom, xto] =  largestCCEnclosingRect ( bwimg, 4 );
        bwimg = bwimg( yfrom:yto, xfrom:xto );

        % Get rid of noise. 5 is size of structuring element.
        bwimg = imclose(bwimg, ones(5));

        % bwconncomp works when white is foreground
        bwimg = abs(bwimg - 1);
        bwimg = imclearborder(bwimg);

        % connectivity is 4.
        cc = bwconncomp(bwimg, 4);

        % Save the highest threshold that created only two connected components.
        if ( size(CC,1) == 0 ...
             || ( cc.NumObjects >= 2 && cc.NumObjects < CC.NumObjects ) )
            CC = cc;
            CC.yfrom = yfrom;
            CC.yto = yto;
            CC.xfrom = xfrom;
            CC.xto = xto;
            CC.NumObjects = cc.NumObjects;
        end
    end

    if ( size(CC, 1) == 0 )
        err = MException( 'leafscan:TooFewObjects', ...
                            'Could not find two distinct objects');
        throw(err);
    end

    % Calculate the centroids of each connected component
    centroids = regionprops(CC,'Centroid');
    areas = regionprops(CC, 'Area');
    pixels = regionprops(CC, 'PixelList');

    % The square and the leaf are the two largest CC.
    [~, ind] = sort([areas.Area], 'descend');
    sqrInd = ind(1);
    leafInd = ind(2);

    % The square is the one with the smallest distance from 1,size(img,1).
    dist_sqr = pdist( [1 size(bwimg,1); centroids(sqrInd).Centroid] );
    dist_leaf = pdist( [1 size(bwimg,1); centroids(leafInd).Centroid] );

    if (dist_sqr > dist_leaf) % the square is the other
        tmpInd = sqrInd;
        sqrInd = leafInd;
        leafInd = tmpInd;
    end

    square = {};
    leaf = {};
    square.pixArea = areas(sqrInd).Area;
    square.pixSide = sqrt(square.pixArea);
    square.cmArea = 4;
    square.cmSide = 2;

    leaf.pixArea = areas(leafInd).Area;
    leaf.pixels = pixels(leafInd).PixelList;

    % Calculate area proportion (square is (2cm)^2)
    pixRatioArea = square.cmArea/square.pixArea;
    leaf.cmArea = pixRatioArea * leaf.pixArea;

    % Calcualate linear proportion (square side is 2cm)
    pixRatioLine = square.cmSide/square.pixSide;

    % Calculate Enclosing circle for leaf
    [leaf.circleC, leaf.circleR] = minboundcircle ( leaf.pixels(:,1), ...
                                                    leaf.pixels(:,2) );
    leaf.circleRcm = leaf.circleR * pixRatioLine;
    leaf.circleC(1) = leaf.circleC(1) + CC.xfrom;
    leaf.circleC(2) = leaf.circleC(2) + CC.yfrom;

    area = leaf.cmArea;
    circleC = leaf.circleC;
    circleR = leaf.circleR;
    circleRcm = leaf.circleRcm;

end

% Returns the from/to indeces that we need to crop out the largest connected
% component. This basically describes a rectangle.
function [yfrom, yto, xfrom, xto] = largestCCEnclosingRect ( img, connectivity )

    % We have an aggressive close as we want to get rid of as much noise as
    % possible. This wont affect area calcs as we only use this closed image
    % to identify the lit part.
    img = imclose(img, ones(11));

    % Find connected component
    cc = bwconncomp(img, connectivity);

    if ( cc.NumObjects > 0 )
        % Find the index of the larges connected component
        areas = regionprops(cc, 'Area');
        [C, I]= max([areas.Area]);

        % Return bounding box of largest connected component
        bb = regionprops(cc, 'BoundingBox');
        rect = int64(bb(I).BoundingBox);
    elseif ( cc.NumObjects == 0 )
        rect = int64([1 1 size(img,2) size(img,1)]);
    end

    yfrom = rect(2);
    yto = rect(2)+rect(4)-1; %-1 because Matlab starts index at 1
    xfrom = rect(1);
    xto = rect(1)+rect(3)-1;
end
