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

function elements = parseFilename ( filename, re, varnames, sep )
    % filename: it will be stripped from path and extension
    % re: is the regular expression that will sparate the name. It will be
    %     used with the textscan function
    % varnames: the names of the variables for each element. Its an array of
    %           strings.
    % sep: is the separator for the textscan call.

    [p,n,e] = fileparts(filename);

    foundElems = textscan(n, re, 'Delimiter', sep);

    if (size(varnames, 2) ~= size(foundElems, 2) )
        error ( 'Error in parsing step' )
    end

    for ( i = 1:size(varnames, 2) )
        elements.(varnames{i}) = foundElems{i};
    end
end
