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

% Segment Rossets in image based on a 'square' approach.
% Assumptions:
% The color distribution in the minimum square containing the rosette should
% have two peaks, one at rosette green and some other color (dirt). If the
% square contains other objects besides these two, there might be a
% miss-classification.
%
% Arguments:
% imgR is the image range and contains y{From,To} and x{From,To} effectively
%      describing a square inside the image.
% img is the original color image
%
% Steps:
% 1. Calculate the maximum growth in any direction.
% 2. Analyze increasing subsquares in the image.
% 3. Calculate a k-means (k=2) of the current subsquare.
% 4. Remove noise and bring close connected components together.
% 5. We stop when all sides of subimg are 0
% 6. Recalculate enclosing square.
function [subimg, imgRange] = segmentRosette_sqr ( imgR, img )
    % true when we are satified with the mask
    foundRosette = false;

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

     % 2. Analyze increasing subsquares in the image.
    for ( i = 5:5:maxGrowth )
        % 3. Calculate a k-means (k=2) of the current subsquare.
        imgRange = struct ( 'yFrom', imgR.yFrom-i, 'yTo', imgR.yTo+i, ...
                            'xFrom', imgR.xFrom-i, 'xTo', imgR.xTo+i );
        subimg = img( int64(imgRange.yFrom:imgRange.yTo) , ...
                      int64(imgRange.xFrom:imgRange.xTo) , : );

        subimg = getKMeansMask ( subimg, 0.01, 10 );

        % 4. Remove noise and bring close connected components together.
        se = strel('disk', 3); % struct element.
        subimg = imclose(subimg, se);

        % 5. We stop when all sides of subimg are 0
        if ( ( sum(subimg(:,1)) + sum(subimg(1,:))...
               + sum(subimg(size(subimg,1),:)) ...
               + sum(subimg(:,size(subimg,2))) ) == 0 )
            foundRosette = true;
            break;
        end
    end

    if ( ~foundRosette )
        % Means that we did not find rosette.
        err = MException( 'segmentRosette_sqr:RosetteNotFound', ...
                          'Could not find a good separation');
        throw(err);
    end

    % 6. Recalculate enclosing square.
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

% Classification with k=2.
%
% Important assumptions:
% Here we assume that individual plants make most part of the kimg. This will
% ensure that one of the means that k-means find is part of the plant green.
%
% Arguments:
% kimg is a 3D matrix (rgb image).
% convRatio is the convergence ratio. 0.01 should be ok.
% maxIter are the maximum number of iterations. 10 should be ok.
%
% Steps:
% 1. Convert To Excess Green
% 2. Separate pixels into two classes.
% 3. Return mask
function retMask = getKMeansMask ( kimg, convRatio, maxIter )

    % F(:,:,1) -> a* of lab (Green tends to low values)
    % F(:,:,2) -> b* of lab (Green tends to high values)
    % F(:,:,3) -> texture (Green tends to high values)
    % F(:,:,4) -> excess green (Green tends to high values)
    F = getFeatures(kimg);

    M = [0 0 0 0; 1 1 1 1];

    % 2. Separate pixels into two classes.
    imgvec = reshape(F, size(F,1)*size(F,2), size(F,3));
    retMask = getKMeansVecMask ( imgvec, M, convRatio, maxIter );

    % 3. Return mask
    retMask = reshape ( retMask, size(kimg,1), size(kimg,2) );
end
