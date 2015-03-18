function img = drawLines(img, thetaList_rad, rhoList)

xx = 1:size(msk,2);

for i = 1:length(thetaList_rad)
    tt = thetaList_rad(i);
    ct = cos(tt); st = sin(tt);
    yy = -ct/st * xx + rhoList(i)/st;
    img(yy, xx) = 255;
    %plot(xx,yy,'--','LineWidth',1,'Color',col);
end

    
    
end