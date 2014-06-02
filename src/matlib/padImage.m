%% Returns a square image padded to the size of padImSize
% padImSize must be bigger then curIm dimensions

function [paddedIm] = padImage(curIm,padImSize)


    %create the blank image that is size correctly
    imgSize=size(curIm);
    finalSize=padImSize; %This is the size of the square image
    padImg=zeros(finalSize,finalSize,3);
    padImg = uint8(padImg);
    padImg(1:imgSize(1),1:imgSize(2),1) = curIm(:,:,1);
    padImg(1:imgSize(1),1:imgSize(2),2) = curIm(:,:,2);
    padImg(1:imgSize(1),1:imgSize(2),3) = curIm(:,:,3);
    paddedIm = padImg;
end

%%
% % This might center it, couldn't get code working
% % padImg(finalSize/2+(1:imgSize(1))-floor(imgSize(1)/2),...
% %     finalSize/2+(1:imgSize(2))-floor(imgSize(2)/2))=curIm;
% % 
% %     This centers the CurIm in the black large image
% %     padImg(finalSize/2+(1:imgSize(1))-floor(imgSize(1)/2), finalSize/2+(1:imgSize(2))-floor(imgSize(2)/2),1) = curIm(:,:,1);
% %     padImg(finalSize/2+(1:imgSize(1))-floor(imgSize(1)/2), finalSize/2+(1:imgSize(2))-floor(imgSize(2)/2),2) = curIm(:,:,2);
% %     padImg(finalSize/2+(1:imgSize(1))-floor(imgSize(1)/2), finalSize/2+(1:imgSize(2))-floor(imgSize(2)/2),3) = curIm(:,:,3);
% %     
