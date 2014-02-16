function [area, circleC, circleR] = leafscanimg ( imgpath )

    %FIXME: Make sure we check path
    img = rgb2gray(imread(imgpath));

    CC = {};
    % 0.5, and 0.05 are arbitrary
    for (i = 0.5:0.05:1)

        % apply threshold
        bwimg = im2bw(img, i);

        % Get rid of noise. 5 is size of structuring element.
        bwimg = imclose(bwimg, ones(5));

        % bwconncomp works when white is foreground
        bwimg = abs(bwimg - 1);

        % connectivity is 4.
        cc = bwconncomp(bwimg, 4);

        % Save the highest threshold that created only two connected components.
        if ( cc.NumObjects == 2 )
            CC = cc;
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

    % The square is the one with the smallest distance from 1,size(img,1).
    square = {};
    leaf = {};
    dist_1 = pdist( [1 size(bwimg,1); centroids(1).Centroid] );
    dist_2 = pdist( [1 size(bwimg,1); centroids(2).Centroid] );

    sqrInd = 1;
    leafInd = 2;
    if (dist_1 > dist_2)
        sqrInd = 2;
        leafInd = 1;
    end

    %square.idxList = CC.PixelIdxList{sqrInd};
    square.pixArea = areas(sqrInd).Area;
    % square.pixels = pixels(sqrInd).PixelList;
    square.cmArea = 4;

    %leaf.idxList = CC.PixelIdxList{leafInd};
    leaf.pixArea = areas(leafInd).Area;
    leaf.pixels = pixels(leafInd).PixelList;

    % Calculate area proportion (square is 2cm^2)
    pixProportion = square.cmArea/square.pixArea;
    leaf.cmArea = pixProportion * leaf.pixArea;

    % Calculate Enclosing circle for leaf
    [leaf.circleC, leaf.circleR] = minboundcircle ( leaf.pixels(:,1), ...
                                                    leaf.pixels(:,2) );

    area = leaf.cmArea;
    circleC = leaf.circleC;
    circleR = leaf.circleR;

end
