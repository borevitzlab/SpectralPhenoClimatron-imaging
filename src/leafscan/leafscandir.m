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

function leafscandir(lpath)
    %FIXME : validate path
    if ( exist(lpath) ~= 7 )
        error ( strcat('path ', lpath, 'is not a directory') );
    end

    % Put the csv file with all the results in leafscanresults.csv
    resultfile = fullfile(lpath, 'leafscanresults.csv' );
    [fd,syserrmsg]=fopen(resultfile,'wt');
    fprintf(fd, strcat( '# Result of leafscan of path', lpath, '\n') );
    fprintf(fd, strcat('#Columns: filename,PlantID,',...
                        'ExperimentName,Area(cm^2),',...
                        'CircleCenter(x,y),Radius(pix),Radius(cm)\n') );

    filelist = dir(lpath);
    for ( i = 1:size(filelist, 1) )
        tmp = regexp(filelist(i).name,   '.*\.[jpg|JPG|jpeg|JPEG]');
        if ( size(tmp, 1) == 0 )
            continue;
        end

        imgpath = fullfile(lpath, filelist(i).name);

        nameElems = parseFilename( filelist(i).name, ...
                            '%s%s%s%s', ...
                            {'exname', 'cnum', 'cpos', 'pid'}, ...
                            '_');

        try
            % a->area(cm), c->center(pix), r->radius(pix), R->radius(cm)
            [a, c, r, R] = leafscanimg(imgpath);
            disp ( imgpath );
        catch err
            fprintf(fd, '%s,%s,%s:could not find leaf automatically\n', ...
                        filelist(i).name, ...
                        nameElems.pid{1}, ...
                        nameElems.exname{1} );
            disp( strcat ( 'Error in ', imgpath ) );
            continue;
        end

        fprintf ( fd, '%s,%s,%s,%s,%d,%d,%s,%s\n', ...
            filelist(i).name, ...
            char(nameElems.pid{1}), ...
            char(nameElems.exname{1}), ...
            a, c(1), c(2), r, R );

    end
    fclose(fd);
end

