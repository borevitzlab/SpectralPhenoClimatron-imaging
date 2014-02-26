function showleafscanimg ( imgpath )
    % Calcualte area, circle center and circle radius
    try
        [a c r] = leafscanimg ( imgpath );
    catch err
        disp ( strcat ( 'Could not find leaf automatically for ', imgpath ) );
        throw(err);
    end

    % No need to check imgpath, leafscanimg would have caught any error.
    img = imread(imgpath);
    imshow(img);
    rectangle ( 'Position', [c(1)-r c(2)-r 2*r 2*r], 'Curvature', [1 1] );
end
