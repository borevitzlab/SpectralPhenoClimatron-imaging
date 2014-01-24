function coordinates = detectLattice ( lat, latImg )
    % lat: binary matrix that represents the lattice that is the tray in an
    % image. Each matrix cell is a pot; 1 means pot present, 0 means no pot in
    % that position.
    % img : Path to the image containing the lattice.
    % coordinates : Are the coordinates for all the intersecting points of the
    % latice. There will be (n+1)X(m+1) coordinates where n and m are the
    % dimension sizes for lat.

    % Constant used to avoid devide by zero errors.
    global divByZeroConst;
    divByZeroConst = 10^-10;

    %FIXME: check the input argument
    latNumRows = size(lat, 1);
    latNumHLns = latNumRows + 1;

    latNumCols = size(lat, 2);
    latNumVLns = latNumCols + 1;

    % Number of coordinates needed to create a lattice for lat
    numCoor = latNumHLns*latNumVLns;

    % Check to see if its a matrix of numeric values with 3 dims.
    if ( ~isnumeric(latImg) || size(size(latImg),2) ~= 3 )
        error ( 'detectLattice expects a 3D numeric matrix' );
    end

    latImg = rgb2gray ( latImg );

    % Try to remove noise. Like the one in the soil.
    blured = imfilter ( latImg, fspecial('gaussian', 10), 'replicate' );

    [hlns, vlns] = getLines ( blured, 0.1 );

    hlnsGroups = groupLines ( hlns, latNumHLns );
    vlnsGroups = groupLines ( vlns, latNumVLns );

    hlnsGroups = calcRepresentantLines ( hlnsGroups, size(img) );
    vlnsGroups = calcRepresentantLines ( vlnsGroups, size(img) );

    coordinates = calcLatticeIntersections ( hlnsGroups, vlnsGroups );

    drawLines( [hlns, vlns], img );


end

function latInt = calcLatticeIntersections ( hlnsGroups, vlnsGroups )
    global divByZeroConst;
    latInt = [];
    for ( h = 1:size(hlnsGroups,2) )
        for ( v = 1:size(vlnsGroups,2) )
            c0 = hlnsGroups(h).groupLn.c;
            m0 = hlnsGroups(h).groupLn.slope;
            c1 = vlnsGroups(v).groupLn.c;
            m1 = vlnsGroups(v).groupLn.slope;

            % Intersections
            xint = (c1-c0)/ ( (m0-m1) + divByZeroConst );
            yint = (c0*m1 - c1*m0)/ ( (m1-m0) + divByZeroConst );

            latInt = vertcat ( latInt, [ xint, yint ] );
        end
    end
end

% Important assumptions
% 1) We assume that the mean intersection points of all the group will give us
%    good approximation of where the real line is supposed to cross.
% 2) We assume that the median of all the slopes of the lines is a good
%    approximation.
%
% retLnsG: is the same lnsGroups structure but with additional values
%          representing the new found line.
% imgSize: We use this to make sure that all calcs are within the image.
%
% Steps:
% 1) Calculate slope and c for all lines
% 2) Calc slope median of group lines
% 3) Calculate the mean of the totality of line intersections.
% 4) Deduce c of the representant line.
function retLnsG = calcRepresentantLines ( lnsGroups, imgSize )
    retLnsG = lnsGroups;

    % 1) Calculate slope and c for all lines.
    for ( lg = 1:size(retLnsG, 2) )
        slopeMeds = [];
        for ( l = 1:size(retLnsG(lg).lines, 2) )
            m = retLnsG(lg).lines(l).point1 ...
                - retLnsG(lg).lines(l).point2;
            m = m(2) / m(1);
            c = retLnsG(lg).lines(l).point2(2) ...
                    - ( m * retLnsG(lg).lines(l).point2(1) );
            retLnsG(lg).lines(l).m = m;
            retLnsG(lg).lines(l).c = c;

            slopeMeds(l) = m;
        end

        % 2) Calc slope median of group lines
        lineSlope = median(slopeMeds);
        retLnsG(lg).groupLn.slope = lineSlope;

        % 3) Calculate the mean of the totality of line intersections.
        lineInt = calcGroupIntersections ( retLnsG(lg).lines, imgSize );
        retLnsG(lg).groupLn.intersect = lineInt;

        % 4) Deduce c of the representant line.
        retLnsG(lg).groupLn.c = lineInt.Y - (lineSlope*lineInt.X);

        %FIXME: Should we calculate the img border crossings?
    end

    % Calculate the mean intersection points between each group of lines.
    function intMeans = calcGroupIntersections ( glines, imgSize )
        global divByZeroConst;
        k = 1;
        intMeans.X = 0;
        intMeans.Y = 0;
        intscts = [];

        if ( size(glines,2) < 1 )
            error ( 'Unknown error calculating line means.');

        elseif ( size(glines,2) == 1 )
            % Don't calc intersects if its just one line.
            intMeans.X = ( glines(1).point1(1) + glines(1).point2(1) ) / 2;
            intMeans.Y = ( glines(1).point1(2) + glines(1).point2(2) ) / 2;
            return;
        end

        % Calc line combination indeces
        %FIXME: returns empty mat when only one line
        lnCmbInd = uint8 ( combnk(1:size(glines,2),2) );

        for ( i = 1:size(lnCmbInd,1) )
            c0 = glines( lnCmbInd(i,1) ).c;
            m0 = glines( lnCmbInd(i,1) ).m;
            c1 = glines( lnCmbInd(i,2) ).c;
            m1 = glines( lnCmbInd(i,2) ).m;

            % Intersections
            xint = (c1-c0)/( (m0-m1) + divByZeroConst );
            yint = (c0*m1 - c1*m0)/ ( (m1-m0) + divByZeroConst );

            if ( xint < imgSize(2) && xint > 0 ...
                 && yint < imgSize(1) && yint > 0 )
                intscts = vertcat ( intscts, [ xint, yint ] );

            else
                % This is painful: We can't simply ignore the lines that
                % do not intersect because we could end up with situations
                % where there are no intersects. To address this, we
                % create two lines from the opposing points of the two
                % non-intersecting lines. These new lines WILL intersect.
                intscts = vertcat ( intscts, ...
                        getAlternativeIntersect ( glines(lnCmbInd(i,1)), ...
                                                  glines(lnCmbInd(i,2)) ) );
            end
        end

        intMeans.X = mean(intscts(:,1));
        intMeans.Y = mean(intscts(:,2));

    end

    function altIntsct = getAlternativeIntersect ( line1, line2 )
        global divByZeroConst;

        % Dist from point 1 of line one to point 1 of line 2
        dist1121 = sqrt ( (line1.point1(2) - line2.point1(2))^2 ...
                          + (line1.point1(1) - line2.point1(1))^2 );

        % Dist from point 1 of line one to point 2 of line 2
        dist1122 = sqrt ( (line1.point1(2) - line2.point2(2))^2 ...
                          + (line1.point1(1) - line2.point2(1))^2 );

        % Define the four points of the two 'new' lines.
        if ( dist1121 > dist1122 )
            tmpLine1.point1 = line1.point1;
            tmpLine1.point2 = line2.point1;
            tmpLine2.point1 = line1.point2;
            tmpLine2.point2 = line2.point2;

        elseif ( dist1121 < dist1122 )
            tmpLine1.point1 = line1.point1;
            tmpLine1.point2 = line2.point2;
            tmpLine2.point1 = line1.point2;
            tmpLine2.point2 = line2.point1;

        else
            error('Could not calculate an intersection for line group');
        end

        % Calc slope and c for the two 'new' lines.
        % slope = (y1-y2)/(x1-x2); c = y - m*x;
        % Multiply by 10^-10 to avoid division by 0
        m0 = tmpLine1.point1 - tmpLine1.point2;
        m0 = m0(2) / ( m0(1) + divByZeroConst );
        c0 = tmpLine1.point2(2) - m0 * tmpLine1.point2(1);

        m1 = tmpLine2.point1 - tmpLine2.point2;
        m1 = m1(2) / ( m1(1) + divByZeroConst );
        c1 = tmpLine2.point2(2) - m1 * tmpLine2.point2(1);

        % Intersections
        xint = (c1-c0)/ ( (m0-m1) + divByZeroConst );
        yint = (c0*m1 - c1*m0)/ ( (m1-m0) + divByZeroConst );

        altIntsct = [xint, yint];
    end
end


% Important assumptions:
% 1) Lines describing the same edge in the image will have similar bin value
% (rho). The rho value is the bin number in the accumulator structure of the
% hough transform.
%
% 2) We try to find as many lines as the user tells us. This might be an
% optimistic assumption as there might be more lines in the image that the
% user is not aware of.
%
% 3) We assume equally spaced pots. This should ideally give us line rho
% centers that are more or less equally spaced.
%
% A note on clustering. I decided not to use k-means clustering because it was
% giving me centers that were too close together.
%
% lines: lines as returned by houghlines
% numExpGroups: number of expected groups in which to group the lines.
% lnsGroups: A struct array with each offset containing a list of the lines in
%            each group, Can potentially eliminate negaticve or positive rho
%            lines if it sees that there are not enough groups.
%
% Steps:
% 1) Get rho values
% 2) Separate the positive rhos from the negative.
% 3) Detect a high difference between consecutive sorted rhos.
%    This points us to the groups.
% 4) Put each line in its respective group.
% 5) Return the best fit, positives or negatives.
function lnsGroups = groupLines ( lines, numExpGroups )

    % 1) Get rho values
    % Each line in houghlines has a theta (slope) and a rho (bin).
    for (i = 1:size(lines,2))
        rhos(i)=lines(i).rho;
    end

    % 2) Separate the positive rhos from the negative.
    % Index 1 is positive rhos, 2 is negative rhos
    subRhos(1).ind = rhos>=0;
    subRhos(1).empty = 1;
    subRhos(2).ind = rhos<0;
    subRhos(2).empty = 1;

    for ( i = 1:2 )
        % Ignore if there are no rho values.
        if ( sum(subRhos(i).ind) <=0 )
            continue;
        end

        % 3) Detect a high difference between consecutive sorted rhos.
        % rhos with a sign(+-). abs to avoid unexpected differences
        sRhos = abs( rhos( subRhos(i).ind ) );

        % sorted signed rhos and index. ssRhosInd is to keep track of lines.
        [ssRhos, ssRhosInd] = sort(sRhos);

        % Diffed ssRhos. Big differences mean a change to another group.
        % This is painful: notice the when diffing we lose one element
        % len(dssRhos) < len(ssRhos). We have to address this when we are
        % selecting lines for groups.
        dssRhos = diff(ssRhos);

        % We sort them to easily identify the bigger ones.
        potentials = sort(dssRhos, 2, 'descend');

        % * Forefit, if we don't have enough good potentials.
        % * For numExpGroups groups we need numExpGroups-1 potentials.
        % * quantile(dssRhos, [.75]) is the first quartil.
        % * Groups are separated when diff values are 'big'. Potential values
        %   are greater than the first quartil.
        % FIXME: The first quartil might still allow values that are too
        %        low, would the wisker value be better?
        if ( sum ( potentials > quantile(dssRhos, [.75]) ) < numExpGroups-1 )
            continue;
        end

        % A 1 in offset n in grpChange means that the (n+1) line represents a
        % change of group.
        grpChange = dssRhos >= potentials(numExpGroups-1);
        [lGroups, numDetGroups] = createGroupStruct ( grpChange );

        % 4) Put each line in its respective group.
        sLns = lines( subRhos(i).ind );
        sLns = sLns(ssRhosInd); % sorted signed lines.
        for ( numDetGroup = 1:numDetGroups )
            subRhos(i).lnsGroups(numDetGroup).lines = ...
                    sLns(lGroups == numDetGroup);
        end

        subRhos(i).empty = 0;
    end

    % 5) Return the best fit, positives or negatives.
    %FIXME: What if they both have empty == 0????
    if ( ~subRhos(1).empty )
        lnsGroups = subRhos(1).lnsGroups;
    elseif (~subRhos(2).empty )
        lnsGroups = subRhos(2).lnsGroups;
    else
        error('Could not find a valid grouping for lattice lines');
    end


    % Helper functions for groupLines
    function [lGroups, numDetGroups] = createGroupStruct ( grpChange )
        % Struct containing groups. It is one element bigger than grpChange
        lGroups = zeros(1,length(grpChange)+1);
        lGroups(1) = 1; % First element is always from group 1.
        G = 1;
        for (j = 1:length(grpChange))
            if (grpChange(j) == 1)
                G = G + 1;
            end
            lGroups(j+1) = G;
        end

        % number of detected groups
        numDetGroups = max ( lGroups );
    end
end

% Important assumptions:
% 1) The main assumption is that the pictures of the trays are taken so the tray
% borders are parallel to the image border. We allow a slight rotation of the
% camera of less than 5 degrees.
%
% 2) In general we assume that the trays take up most of the scene in the
% image. This is important when trying to make conjectures about the size
% of the lines and the distance between 'associated' lines. With this in
% mind we assume that the tray takes up at least 2/3 of the whole image.
%
% 3) We further assume that img is grayscale and
% has been already filtered with a gaussian.
%
% img: image of the tray
% cannyThreshold: The upper limit of the canny threshold, the lower limit is
% calculated to be 0.4*cannyThreshold. see `help edge` in matlab.
%
% Steps:
% 1) Calculate image edges
% 2) Create Hough temp vars for horizontal
% 3) Identify the hough peaks
% 4) Get the lines that are long.
% 5) repeat 2,3,4 for vertical lines.
function [horizontalLns, verticalLns] = getLines ( img, cannyThreshold )

    % 1) Calculate image edges
    if ~exist('cannyThreshold')
        cannyThreshold = 0.3; % a large threshold means fewer edges
    end
    edges = edge(img, 'canny', cannyThreshold);

    % 2) Create Hough temp vars for horizontal
    [H, T, R] = hough(edges, 'Theta', [-90:.1:-88, 88:.1:89.999]);

    % 3) Identify the hough peaks
    %
    % 90 is the number of peaks that should be detected and is arbitrary; in
    % general it should be bigger by a considerable amount than the number of
    % expected lines.
    %FIXME: calculate number of peaks based on number of lines (e.g. num*4)
    % We use threshold to increase the number of possible detectable peaks.
    P  = houghpeaks( H, 90, 'threshold', ceil(0.3*max(H(:))) );

    % 4) Get the lines that are long.
    %
    % FillGap: two 'associated' lines are merged if the distance between them
    % is less than FillGap. Consider the worst case where a line starts in one
    % end and finishes at the other. That distance will be 2/3 the size of the
    % horizontal dimension of the image ( size(edges,2) ).
    fillGap = size(edges,2)*(2/3);

    % 5) repeat 2,3,4 for vertical lines.
    %
    % MinLength: We can assume that lines less than 2/3 the size of the
    % horizontal dimension ( size(edges,2) ) are useless as lattice lines.
    % Merged lines shorter than MinLength are ignored.
    minLength = size(edges,2)*(2/3);

    horizontalLns = ...
        houghlines(edges,T,R,P,'FillGap',fillGap,'MinLength',minLength);

    % Vertical lines
    [H, T, R] = hough(edges, 'Theta', [-2:.1:2]);
    P  = houghpeaks( H, 90, 'threshold', ceil(0.3*max(H(:))) );

    % we now use the vertical dimension ( size(edges,1) ) for both minLength
    % and fillGap.
    fillGap = size(edges,1)*(2/3);
    minLength = size(edges,1)*(2/3);

    verticalLns = ...
        houghlines(edges,T,R,P,'FillGap',fillGap,'MinLength',minLength);
end

% Stole this from http://www.mathworks.se/help/images/ref/houghlines.html
function drawLines ( lines, img )
    figure, imshow(img), hold on;

    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
        % Plot beginnings and ends of lines
        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    end
end
