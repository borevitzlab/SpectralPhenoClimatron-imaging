function img = addLines(I, Hspacing,Vspacing)
if nargin <3
    Vspacing = Hspacing;
end
    img = I;
    img(:,1:Hspacing:end,:) = 255;       %# Change every nth column to black
    img(1:Vspacing:end,:,:) = 255;       %# Change every nth row to black
end