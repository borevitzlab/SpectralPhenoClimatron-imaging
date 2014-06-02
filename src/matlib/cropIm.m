function [croppedIm] = cropIm(inputImage,imCropCoords)
    %  (imCrop command is in form: imcrop(image,xStart,yStart, width, height)
    xStart = imCropCoords(1,1);
    yStart = imCropCoords(1,2);
    width = imCropCoords(2,1) - xStart;
    height = imCropCoords(2,2) - yStart;
    crops = [xStart,yStart, width, height];
    croppedIm= imcrop(inputImage,crops);
end