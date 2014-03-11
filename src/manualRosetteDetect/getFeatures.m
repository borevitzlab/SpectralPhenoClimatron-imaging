function F = getFeatures(I)
    % EXTRACT_FEATURES Extract features of interest (a*, b*, texture and exg)
    % from image I. The RGB to L*a*b* colour space conversion is performed to
    % eliminate issues of non uniform illumination

    % Load system options
    options.Radius = 3;
    options.SigmaH = 4;
    options.SigmaL = 1;
    options.falloff = 1/50;

    % a* and b* colour components
    I_lab = rgb2lab(I);
    F(:,:,1) = I_lab(:,:,2);
    F(:,:,2) = I_lab(:,:,3);

    % The response of a pillbox filter is linearly combined with a DoG filter.
    % The filtered output F is defined as:
    F(:,:,3) = imfilter ( I_lab(:,:,2),...
                          fspecial('disk', options.Radius), ...
                          'replicate', 'conv' ) ...
               + imfilter( I_lab(:,:,1),...
                           fspecial('gaussian', ...
                                    2 * round(2 * options.SigmaH) + 1,...
                                    options.SigmaH) ...
                           - fspecial('gaussian', ...
                                      2 * round(2 * options.SigmaH) + 1, ...
                                      options.SigmaL), ...
                           'replicate', 'conv');
    % The response of the texture from blurring (TFB) filter is:
    F(:,:,3) = exp(-options.falloff*abs(F(:,:,3)));

    F(:,:,4) = double(I(:,:,2))*2 - double(I(:,:,1)) - double(I(:,:,3));
end
