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

function showleafscanimg ( imgpath )
    % Calcualte area, circle center and circle radius
    try
        [a c r R] = leafscanimg ( imgpath );
    catch err
        disp ( strcat ( 'Could not find leaf automatically for ', imgpath ) );
        throw(err);
    end

    % No need to check imgpath, leafscanimg would have caught any error.
    img = imread(imgpath);
    imshow(img);
    rectangle ( 'Position', [c(1)-r c(2)-r 2*r 2*r], 'Curvature', [1 1] );
end
