function [unwarpedIm] = unwarp(curIm,imageCenter,unwarpAmt)

    % Unwarp Image 
    unwarpedIm = lensdistort(curIm,unwarpAmt,'interpolation','nearest','padmethod','replicate','ftype',4, 'ImCenter', imageCenter);
end
