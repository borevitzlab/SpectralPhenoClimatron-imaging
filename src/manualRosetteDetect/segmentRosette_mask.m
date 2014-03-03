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

% Segment Rossets in image based on the previous mask.
function [subimg, imgRange] = segmentRosette_mask ( imgR, img, mask )
    % true when we are satified with the mask
    foundRosette = false;

    imgRange = imgR;

    % 1. Calculate the maximum growth in any direction.
    maxGrowth = min ( [ imgR.yFrom imgR.xFrom ...
                        abs(size(img,2) - imgR.xTo) ...
                        abs(size(img,1) - imgR.yTo) ] );
    maxGrowth = maxGrowth - mod(maxGrowth,5); % Next multiple of 5 down.
    if ( maxGrowth > 100 ) % Only look at part of the image
        maxGrowth = 100;
    elseif ( maxGrowth < 5 )
        err = MException( 'segmentRosette_sqr:InvalidMaxGrowth', ...
                          'maxGrowth var was calculated to be less than 5' );
        throw(err);
    end

    for ( i = 5:5:maxGrowth )
        imgRange = struct ( 'yFrom', imgR.yFrom-i, 'yTo', imgR.yTo+i, ...
                            'xFrom', imgR.xFrom-i, 'xTo', imgR.xTo+i );

        % Dilate (swells the original mask) and put mask in dilmask.
        % se is twice i (aprox) so dilation almost reaches size(dilmask)
        dilmask = zeros( size(mask) + (i*2) );
        dilmask( i:i+size(mask,1)-1, ...
                 i:i+size(mask,2)-1) = mask;
        se = strel('square', (2*i)-1);
        dilmask = imdilate(dilmask, se);

        % Get image corresponding to dilmask's size.
        dilimg = img ( imgRange.yFrom:imgRange.yTo, ...
                       imgRange.xFrom:imgRange.xTo, ...
                       : );

        % Convert to ExG
        dilimg = double(dilimg);
        dilimg = 2*dilimg(:,:,2) - dilimg(:,:,1) - dilimg(:,:,3);

        % find coordinates and values where the plant should have grown to.
        [r, c] = find(dilmask == 1);
        v = dilimg( sub2ind( size(dilimg), r, c)) ;

        % Calculate new segmentation for pixels in vertcat(r,c).
        % Should be similar to mask (depends on growth and movement of plant)
        v_km = getKMeansVecMask(v, [0 1], 0.01, 10);
        subimg = zeros( size(dilmask) );
        subimg(sub2ind(size(subimg), r(v_km), c(v_km))) = 1;

        % Remove noise and bring close connected components together.
        subimg = imclose(subimg, strel('disk', 3) );

        % If the perimeter coordinates of dilmask in new mask are 0, we stop.
        % Otherwise it means that there has been more growth and we need to
        % dilate a bit more.
        perimImg = bwperim(dilmask);
        [r, c] = find(perimImg == 1); % coordiantes of the perimeter.
        if ( sum ( subimg( sub2ind(size(subimg), r, c) ) ) == 0 )
            % We found a good mask. no 'plant pixels' touching the perimter.
            foundRosette = true;
            break;
        end
    end

    if ( ~foundRosette )
        % Means that we did not find rosette.
        err = MException( 'segmentRosette_mask:RosetteNotFound', ...
                          'Could not find a good separation');
        throw(err);
    end

    % Recalculate enclosing square.
    cc = bwconncomp(subimg, 4);
    pixList = regionprops(cc, 'PixelList');
    pl = vertcat(pixList.PixelList);
    yFrom = min(min(pl(:,2))) - 1;
    yTo = max(max(pl(:,2))) + 1;
    xFrom = min(min(pl(:,1))) - 1;
    xTo = max(max(pl(:,1))) + 1;
    subimg = subimg ( yFrom:yTo, xFrom:xTo );
    imgRange = struct ( 'yFrom', imgRange.yFrom + yFrom - 1, ...
                        'yTo', imgRange.yFrom + yTo - 1, ...
                        'xFrom', imgRange.xFrom + xFrom - 1, ...
                        'xTo', imgRange.xFrom + xTo - 1);
end

