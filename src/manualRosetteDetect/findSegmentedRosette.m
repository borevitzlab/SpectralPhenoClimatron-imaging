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
function [subimg, imgOffset] = findSegmentedRosette ( lh, img )
   for ( i = 40:5:40 )

        % rosette center
        rc = uint32(round(lh));

        % get a subimg
        subimg = img( rc(2)-i:rc(2)+i , rc(1)-i:rc(1)+i , : );

        subimg = getKMeansMask ( subimg, [0 1], 0.01, 10 );
        imgOffset = [rc(2)-i rc(1)-i];
    end
end

% Classification with k=2.
%
% Important assumptions: Here we assume that individual plants make most part
% of the kimg. This will ensure that one of the means that k-means find is
% part of the plant green.
%
% kimg is a 3D matrix (rgb image).
% M is the starting means. [0 1] should be ok.
% convRatio is the convergence ratio. 0.01 should be ok.
% maxIter are the maximum number of iterations. 10 should be ok.
function retMask = getKMeansMask ( kimg, M, convRatio, maxIter )

    % convert to Excess Green 
    kimg = double(kimg);
    kimg = kimg(:,:,2)*2 - kimg(:,:,1) - kimg(:,:,3);

    % normalize subimg. Range will be [0,1]
    kimg = kimg + abs(min(min(kimg)));
    kimg = kimg/max(max(kimg));

    imgvec = reshape(kimg, 1, size(kimg,1)*size(kimg,2));
    retMask = getKMeansVecMask ( imgvec, M, convRatio, maxIter );
    retMask = reshape ( retMask, size(kimg,1), size(kimg,2) );

    function retVal = getKMeansVecMask ( vec, M, convRatio, maxIter )
        % keep track of the previous means.
        Mprev = M;

        % keep track of the nearness vectors.
        near21 = []; %pixels near to M(1)
        near22 = []; %pixels near to M(2)

        for ( i = 1:maxIter )
            % calculate the distances to both means.
            near21 = abs(vec - M(1)) < abs(vec - M(2));
            near22 = ~near21;

            % calculate new means
            M(1) = sum( vec( near21 ) ) / sum(near21);
            M(2) = sum( vec( near22 ) ) / sum(near22);

            if ( pdist([Mprev(1) Mprev(2): M(1) M(2)]) < convRatio )
                break;
            end

            Mprev = M;
        end

        % We are interested in the mean that is greater. In Excess green, green
        % gives that greater response.
        retVal = near22;
        if ( M(1) > M(2) )
            retVal = near21;
        end
    end
end
