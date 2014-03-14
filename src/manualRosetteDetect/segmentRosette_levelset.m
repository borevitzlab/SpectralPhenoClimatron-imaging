
% Arguments
% Img is a feature image. NxMxD matrix.
% contMask is the contour mask. NxM logical matrix
function [retMask, maskRange] = segmentRosette_levelset ( imgR, img, mask )
    % true when we are satified with the mask
    foundRosette = false;

    maskRange = imgR;

    % 1. Calculate the maximum growth in any direction.
    growth = min ( [ imgR.yFrom imgR.xFrom ...
                        abs(size(img,2) - imgR.xTo) ...
                        abs(size(img,1) - imgR.yTo) ] );
    growth = growth - mod(growth,5); % Next multiple of 5 down.
    if ( growth > 30 ) % Assume growth is max 30 pixels in any dir.
        growth = 30;
    elseif ( growth < 5 )
        err = MException( 'segmentRosette_levelset:InvalidMaxGrowth', ...
                          'growth var was calculated to be less than 5' );
        throw(err);
    end

    % 2. Analyze increasing masks
    maskRange = struct ( 'yFrom', imgR.yFrom-growth, 'yTo', imgR.yTo+growth, ...
                        'xFrom', imgR.xFrom-growth, 'xTo', imgR.xTo+growth );

    % 3. Dilate original mask.
    % Swells the original mask and puts mask in dilmask.
    % se is twice i (aprox) so dilation almost reaches size(dilmask)
    dilmask = zeros( size(mask) + (growth*2) );
    dilmask( growth:growth+size(mask,1)-1, ...
             growth:growth+size(mask,2)-1) = mask;
    se = strel('square', growth);
    dilmask = imdilate(dilmask, se);

    % Get features from image of dilmask's size.
    F = getFeatures ( img ( int64(maskRange.yFrom:maskRange.yTo), ...
                            int64(maskRange.xFrom:maskRange.xTo), ...
                            : ) );

    retMask = activeContours ( F, dilmask );

    % 6. Remove noise and bring close connected components together.
    retMask = imclose(retMask, strel('disk', 3) );


    % 8. Recalculate enclosing square.
    cc = bwconncomp(retMask, 4);
    pixList = regionprops(cc, 'PixelList');
    pl = vertcat(pixList.PixelList);
    yFrom = min(min(pl(:,2)));
    yTo = max(max(pl(:,2)));
    xFrom = min(min(pl(:,1)));
    xTo = max(max(pl(:,1)));
    retMask = retMask ( yFrom:yTo, xFrom:xTo );
    maskRange = struct ( 'yFrom', maskRange.yFrom + yFrom, ...
                        'yTo', maskRange.yFrom + yTo, ...
                        'xFrom', maskRange.xFrom + xFrom, ...
                        'xTo', maskRange.xFrom + xTo);
end

function mask = activeContours ( Img, contMask )

    [ImgRows, ImgCols, numDims] = size(Img);

    % Tunning params, They are equal for now.
    lambda.pos = ones(1, numDims);
    lambda.neg = ones(1, numDims);

    I = Img;
    Img = reshape ( Img, size(Img,1)*size(Img,2), numDims );
    Img = double(Img);

    contMask = (contMask > 0) - (contMask <= 0);

    prevContMask = zeros(size(contMask));
    %FIXME: 30 should be a method argument.
    for ( j = 1:30 )
        if ( j > 1 && isequal(prevContMask, contMask) )
            break;
        end

        % Indeces
        ind.pos = reshape ( contMask >  0, prod(size(contMask)), 1 );
        ind.neg = reshape ( contMask <= 0, prod(size(contMask)), 1 );

        % Means in and out of the contour
        means.pos = mean(Img(ind.pos,:));
        means.neg = mean(Img(ind.neg,:));

        % Calc + term in Euler Lagrange eq d0/dt (Chan 2000, pg.139)
        term.pos = repmat(lambda.pos, ImgRows*ImgCols, 1) ...
                   .* (Img - repmat(means.pos, ImgRows*ImgCols, 1)).^2;
        term.pos = sum(term.pos, 2) / numDims;
        term.pos = reshape ( term.pos, ImgRows, ImgCols );

        % Calc - term in Euler Lagrange eq d0/dt (Chan 2000, pg.139)
        term.neg = repmat(lambda.neg, ImgRows*ImgCols, 1) ...
                   .* (Img - repmat(means.neg, ImgRows*ImgCols, 1)).^2;
        term.neg = sum(term.neg, 2) / numDims;
        term.neg = reshape ( term.neg, ImgRows, ImgCols );


        [ux, uy] = gradient(contMask);
        contMask = contMask + ((-term.pos + term.neg) .* sqrt(ux.^2 + uy.^2));

        Sigma = 1.5;
        KernelSize = 2 * round(2 * Sigma) + 1;
        G = fspecial('gaussian', KernelSize, Sigma);
        contMask = (contMask >= 0) - (contMask < 0);
        contMask = conv2(contMask, G, 'same');
    end

    mask = zeros(size(contMask));
    mask = contMask>=0;
end

% For now we ignore the "Mu*div: term in Chan 2000, pg.139
% Chan, T.F., Sandberg, B.Y., Vese, L.A., 2000. Active contours without edges
% for vector- valued images. Journal of Visual Communication and Image
% Representation 11 (2), 130–141.
