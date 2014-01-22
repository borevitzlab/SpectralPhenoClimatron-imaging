function [dImg, imgCenter, ftype, btype, distortConst] = imgDistort ( imgpath )
    % This function needs to be implemented based on a database of distortion
    % constants that relate to make of camera, lens type and focal length.
    % Database needs to be maintained up to date with the used hardware.

    imgInfo = imfinfo(imgpath);

    imgCamModel = imgInfo.Model;

    %FIXME: this will probably break if we use another exiv format. Nikon,
    %       Stardot????
    % Matlab does not know about the Canon format so it puts the lens
    % information in an unknown place.
    imgCamLens = imgInfo.DigitalCamera.UnknownTags(6).Value;

    % FIXME: the distortion also depends on focal length.
    imgCamFocalLength = imgInfo.DigitalCamera.FocalLength;

    distortConst = 0;
    if ( strcmp(imgCamModel, 'Canon EOS 700D') ...
         && size( strfind(imgCamLens, 'EF-S18-55mm f/3.5-5.6 IS STM'),1) > 0 ...
         && imgCamFocalLength == 18 )
        distortConst = -0.025;

    else
        error( strcat( 'Could not find a distortion constant for ', ...
                    'camera: ', imgCamModel, ...
                    ',lens: ', imgCamLens, ...
                    'and focal length: ', imgCamFocalLength, '.' ) );

    end

    %FIXME: check the image path
    img = imread(imgpath);
    ftype = 4;
    btype = 'crop';
    imgCenter = [size(img, 1), size(img, 2)] / 2;
    dImg = lensdistort ( img, distortConst, ...
                'interpolation', 'nearest',...
                'padmethod', 'replicate', ...
                'ftype', ftype, ...
                'ImCenter', imgCenter, ...
                'bordertype', btype );
end
