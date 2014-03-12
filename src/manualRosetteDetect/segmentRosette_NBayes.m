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

% Important Assumptions:
% 1. We assume that the colors of consecutive images is similar.
% 2. We assume that the feature transformation result in values that are
%    different for foreground and background.
%
% Arguments:
% startR is the image range where prevMask fit in the previous image
% currImg is the curent image
% prevMask is the mask from previous image
% prevSubimg is the previous sub-image.
%
% Steps:
% 1. Calculate the maximum growth in any direction.
% 2. Analyze increasing masks
% 3. Calculate feature space
% 4. Collect Foreground and Background training vectors
% 5. Create data vector
% 6. Normalize the values with image maximum minimums.
% 7. Calculate mask with Bayesian model
% 8. Stop when 98% perimeter coordinates of dilated mask in retMask are 0
% 9. Recalculate enclosing square.
function [retMask, maskRange] = segmentRosette_NBayes (startR, currImg, ...
                                                        prevMask, prevSubimg)
    % true when we are satified with the mask
    foundRosette = false;

    maskRange = startR;

    % 1. Calculate the maximum growth in any direction.
    maxGrowth = min ( [ startR.yFrom startR.xFrom ...
                        abs(size(currImg,2) - startR.xTo) ...
                        abs(size(currImg,1) - startR.yTo) ] );
    maxGrowth = maxGrowth - mod(maxGrowth,5); % Next multiple of 5 down.
    if ( maxGrowth > 100 ) % Only look at part of the image
        maxGrowth = 100;
    elseif ( maxGrowth < 5 )
        err = MException( 'segmentRosette_NBayes:InvalidMaxGrowth', ...
                          'maxGrowth var was calculated to be less than 5' );
        throw(err);
    end

    % 2. Analyze increasing masks
    for ( i = 5:5:maxGrowth )

        % 3. Calculate feature space
        maskRange = struct ( 'yFrom', startR.yFrom-i, 'yTo', startR.yTo+i, ...
                             'xFrom', startR.xFrom-i, 'xTo', startR.xTo+i );
        currSubimg = currImg ( int64(maskRange.yFrom:maskRange.yTo), ...
                               int64(maskRange.xFrom:maskRange.xTo), : );
        FCurrSubimg = getFeatures ( currSubimg );
        FPrevSubimg = getFeatures ( prevSubimg );

        % 4. Collect Foreground and Background training vectors
        % Collect Foreground training pixels from prevSubimg
        [r, c] = find ( prevMask == 1 );
        d = double(ones(size(c,1), 1));
        prevFTrain = [];
        for ( j = 1:size(FPrevSubimg,3) )
            prevFTrain(:,j) = FPrevSubimg( sub2ind ( size(FPrevSubimg), ...
                                                     r, c, d*j ) );
        end

        % Collect Background training pixels from prevSubimg
        [r, c] = find ( prevMask == 0 );
        d = double(ones(size(c,1), 1));
        prevBTrain = [];
        for ( j = 1:size(FPrevSubimg,3) )
            prevBTrain(:,j) = FPrevSubimg( sub2ind ( size(FPrevSubimg), ...
                                                     r, c, d*j ) );
        end

        % Collect Foreground training pixels in currImg masked with prevMask
        F = getFeatures ( currImg ( int64(startR.yFrom:startR.yTo), ...
                                    int64(startR.xFrom:startR.xTo), : ) );
        [r, c] = find ( prevMask == 1 );
        d = double(ones(size(c,1), 1));
        currFTrain = [];
        for ( j = 1:size(F,3) )
            currFTrain(:,j) = F( sub2ind ( size(F), r, c, d*j ) );
        end

        % Puts prevMask in dilmask and swells the original mask.
        % se is twice i (aprox) so dilation almost reaches size(dilmask)
        dilmask = zeros( size(prevMask) + (i*2) );
        dilmask( i:i+size(prevMask,1)-1, ...
                 i:i+size(prevMask,2)-1) = prevMask;
        se = strel('square', (2*i)-1);
        dilmask = imdilate(dilmask, se);

        % Collect Background trainind pixels from currImg
        [r, c] = find ( dilmask == 0 );
        d = double(ones(size(c,1), 1));
        currBTrain = [];
        for ( j = 1:size(FCurrSubimg,3) )
            currBTrain(:,j) = FCurrSubimg( sub2ind ( size(FCurrSubimg),...
                                                     r, c, d*j ) );
        end

        % Create training vectors
        Ftrain = vertcat(prevFTrain, currFTrain);
        Btrain = vertcat(prevBTrain, currBTrain);

        % 5. Create data vector
        [r, c] = find ( dilmask == 1 );
        d = double(ones(size(c,1), 1));
        data = [];
        for ( j = 1:size(FCurrSubimg,3) )
            data(:,j) = FCurrSubimg( sub2ind ( size(FCurrSubimg), ...
                                               r, c, d*j ) );
        end

        % 6. Normalize the values with image maximum minimums.
        minPixVal = min( [min(min(FPrevSubimg)), min(min(FCurrSubimg))] );
        for ( j = 1:size(Ftrain,2) ) % Normalize all features
            Ftrain(:,j) = Ftrain(:,j) - minPixVal(j);
            Btrain(:,j) = Btrain(:,j) - minPixVal(j);
            data(:,j) = data(:,j) - minPixVal(j);

            Ftrain(:,j) = Ftrain(:,j)/max(max(Ftrain(:,j)));
            Btrain(:,j) = Btrain(:,j)/max(max(Btrain(:,j)));
            data(:,j) = data(:,j)/max(max(data(:,j)));
        end

        % 7. Calculate mask with Bayesian model
        Fprior = size(Ftrain, 1)/(size(Ftrain,1)+size(Btrain,1));
        Bprior = size(Btrain, 1)/(size(Ftrain,1)+size(Btrain,1));

        bmodel = getBayesModel ( Btrain, Ftrain, Bprior, Fprior, 50 );
        pixClass = getBayesClassify ( bmodel, data );

        retMask = zeros( size(dilmask) );
        retMask(sub2ind(size(retMask), r(pixClass), c(pixClass))) = 1;

        retMask = imclose(retMask, strel('disk', 3) );

        % 8. Stop when 98% perimeter coordinates of dilated mask in retMask are 0
        perimImg = bwperim(dilmask);
        [r, c] = find(perimImg == 1); % coordiantes of the perimeter.
        perim1 = sum ( retMask( sub2ind(size(retMask), r, c) ) );
        perimT = sum(sum(perimImg));
        if ( perim1/perimT < 0.02 )
            foundRosette = true;
            break;
        end
    end

    if ( ~foundRosette )
        % Means that we did not find rosette.
        err = MException( 'segmentRosette_NBayes:RosetteNotFound', ...
                          'Could not find a good separation');
        throw(err);
    end

    % 9. Recalculate enclosing square.
    cc = bwconncomp(retMask, 4);
    pixList = regionprops(cc, 'PixelList');
    pl = vertcat(pixList.PixelList);
    yFrom = min(min(pl(:,2)));
    yTo = max(max(pl(:,2)));
    xFrom = min(min(pl(:,1)));
    xTo = max(max(pl(:,1)));
    retMask = retMask ( yFrom:yTo, xFrom:xTo );
    maskRange = struct ( 'yFrom', maskRange.yFrom + yFrom - 1, ...
                         'yTo', maskRange.yFrom + yTo - 1, ...
                         'xFrom', maskRange.xFrom + xFrom - 1, ...
                         'xTo', maskRange.xFrom + xTo - 1 );
end

% Important assumptions
% 1) We assume all dimensions are normalized (range of [0,1])
%
% Arguments:
% Bpix are the background pixels. Vector NxD: D is dimensions
% Fpix are the foreground pixels. Vector MxD: D is dimensions
% Bprior is the prior value for background
% Fprior is the prior value for foreground
% numBins is the number of bins
function bmodel = getBayesModel ( Bpix, Fpix, Bprior, Fprior, numBins )

    % Check input
    if ( size(Bpix,2) ~= size(Fpix,2) )
        err = MException( 'segmentRosette_NBayes:DimError', ...
                          'Error in dimensions of input arguments.');
        throw(err);
    end

    % We bin the values
    B = 0:1/numBins:1;
    B(1) = -Inf;
    B(end) = Inf;
    binBpix = histc(Bpix, B);
    binBpix = binBpix(1:end-1, :);
    binBpix = binBpix ./ size(Bpix,1);
    binBpix = binBpix + 10^-10;

    binFpix = histc(Fpix, B);
    binFpix = binFpix(1:end-1, :);
    binFpix = binFpix ./ size(Fpix,1);
    binFpix = binFpix + 10^-10;

    bmodel.Bprior = Bprior;
    bmodel.Fprior = Fprior;
    bmodel.binBpix = binBpix;
    bmodel.binFpix = binFpix;
    bmodel.B = B;
    bmodel.numDim = size(Bpix,2);
end

function retVal = getBayesClassify ( model, data )

    % Check input
    if ( size(data,2) ~= model.numDim )
        err = MException( 'getBayesClassify:DimError', ...
                          'Error in dimensions of input arguments.');
        throw(err);
    end

    [~, ind] = histc(data, model.B);

    % Accum the probability of each dimension value given the pixel being in
    % foreground.
    Fprob = model.binFpix(ind(:,1),1);
    for ( i = 2:size(model.numDim) )
        Fprob = Fprob .* model.binFpix(ind(:,i),i);
    end
    Fprob = Fprob * model.Fprior;

    % Accum the probability of each dimension value given the pixel being in
    % background.
    Bprob = model.binBpix(ind(:,1),1);
    for ( i = 2:size(model.numDim) )
        Bprob = Bprob .* model.binBpix(ind(:,i),i);
    end
    Bprob = Bprob * model.Bprior;

    retVal = Fprob > Bprob;
end
