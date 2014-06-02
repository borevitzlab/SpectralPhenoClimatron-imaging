
curTrayNu = 4
potToShow = 8
potPx = pots{curTrayNu}(potToShow);
myIm = trayPx{curTrayNu};
clear figure
imshow(myIm);
potLocX = potCoords{curTrayNu}(potToShow,1) - (potWid(curTrayNu)/1.4) ;
potLocY = potCoords{curTrayNu}(potToShow,2) - (potHgt(curTrayNu)/1.2);
h1=text(potLocX,potLocY,num2str(potToShow));
set(h1,'FontSize',16,'Color','White');
figure
imshow(potPx);
