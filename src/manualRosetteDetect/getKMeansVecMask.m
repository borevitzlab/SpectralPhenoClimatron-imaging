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

% Execute the k-means algorithm
%
% Steps:
% 1. Create two groups: a)closest to M(1) and b) closest to M(2)
% 2. Calculate mean of each group.
% 3. End if change in mean is very small.
% 4. Return mask of the bigger mean.
function retVal = getKMeansVecMask ( vec, M, convRatio, maxIter )
    % keep track of the previous means.
    Mprev = M;

    % keep track of the nearness vectors.
    near21 = []; %pixels near to M(1)
    near22 = []; %pixels near to M(2)

    for ( i = 1:maxIter )
        % 1. Create two groups: a)closest to M(1) and b) closest to M(2)
        near21 = abs(vec - M(1)) < abs(vec - M(2));
        near22 = ~near21;

        % 2. Calculate mean of each group.
        M(1) = sum( vec( near21 ) ) / sum(near21);
        M(2) = sum( vec( near22 ) ) / sum(near22);

        % 3. End if change in mean is very small.
        if ( pdist([Mprev(1) Mprev(2): M(1) M(2)]) < convRatio )
            break;
        end

        Mprev = M;
    end

    % 4. Return mask of the bigger mean.
    retVal = near22;
    if ( M(1) > M(2) )
        retVal = near21;
    end
end

