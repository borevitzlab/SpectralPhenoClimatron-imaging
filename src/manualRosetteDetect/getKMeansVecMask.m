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
% Arguments:
% vec is a vector of NxD where D is the dimensions and N is the number of data
% M is 2xD vector represenging the two starting means.
% convRatio we stop when we reached a ratio less than this.
% maxIter are the maximum iterations.
%
% Steps:
% 1. Create two groups: a)closest to M(1) and b) closest to M(2)
% 2. Calculate mean of each group.
% 3. End if change in mean is very small.
% 4. Return mask of the bigger mean.
function retVal = getKMeansVecMask ( vec, M, convRatio, maxIter )
    % Check input
    if ( size(vec,2) ~= size(M,2) || size(M,1) ~= 2 )
        err = MException( 'getKMeansVecMask:DimError', ...
                          'Error in dimensions of input arguments.');
        throw(err);
    end

    % keep track of the previous means.
    Mprev = M;

    % keep track of the nearness vectors.
    near21 = []; %pixels near to M(1)

    for ( i = 1:maxIter )
        % 1. Create two groups: a)closest to M(1) and b) closest to M(2)
        D = (pdist2(vec, M));
        near21 = D(:,1) < D(:,2);

        % 2. Calculate mean of each group.
        M(1,:) = mean(vec(near21,:));
        M(2,:) = mean(vec(~near21,:));

        % 3. End if change in mean is very small.
        if ( min ( pdist([Mprev(1,:); M(1,:)]), ...
                   pdist([Mprev(2,:); M(2,:)]) ) < convRatio )
            break;
        end

        Mprev = M;
    end

    % 4. Return mask of the bigger mean.
    retVal = ~near21;
    if ( pdist([M(2,:); 0 0 0 0]) < pdist([M(1,:); 0 0 0 0]) )
        retVal = near21;
    end
end

