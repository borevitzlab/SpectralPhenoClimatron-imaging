function [ut, vt] = doTransformation (xt, yt, k, center, ftype, btype)
    % Converts the x-y coordinates to polar coordinates
    [theta,r] = cart2pol(xt,yt);
    % Calculate the maximum vector (image center to image corner) to be used
    % for normalization
    R = sqrt(center(1)^2 + center(2)^2);
    % Normalize the polar coordinate r to range between 0 and 1 
    r = r/R;
    % Aply the r-based transformation
    s = distortfun(r,k,ftype);
    % un-normalize s
    s2 = s * R;
    % Find a scaling parameter based on selected border type  
    brcor = bordercorrect(r,s,k, center, R, btype);

    s2 = s2 * brcor;

    % Convert back to cartesian coordinates
    [ut,vt] = pol2cart(theta,s2);

    %-------------------------------------------------------------------------
    % Nested function that pics the model type to be used
    function s = distortfun(r,k,fcnum)
        switch fcnum
        case(1)
            s = r.*(1./(1+k.*r));
        case(2)
            s = r.*(1./(1+k.*(r.^2)));
        case(3)
            s = r.*(1+k.*r);
        case(4)
            s = r.*(1+k.*(r.^2));
        end
    end

    %-------------------------------------------------------------------------
    % Nested function that creates a scaling parameter based on the
    % 'bordertype' selected
    function x = bordercorrect(r,s,k,center, R, btype)
        if k < 0
            if strcmp(btype, 'fit')
               x = r(1)/s(1); 
            end
            if strcmp(btype,'crop')
               x = 1/(1 + k*(min(center)/R)^2);
            end
        elseif k > 0
            if strcmp(btype, 'fit')
               x = 1/(1 + k*(min(center)/R)^2);
            end
            if strcmp(btype, 'crop')
               x = r(1)/s(1);
            end
        end
    end
end

