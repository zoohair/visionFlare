function [thetas_rad, rhos, xsec, thetaList_rad, rhoList] = findLines(img, thetaHat_deg, msk, msk_tight, xsecHat)

%we'll search +/- 20 deg around the thetaHat
theta_width = 30;
thetaRange_deg = thetaHat_deg + [-theta_width:1:theta_width];
thetaRange_deg = clip(unique(sort([-thetaRange_deg, thetaRange_deg])), -90, 89.9);

I = img;
av = mean(I(:));
I(msk) = av;


se = strel('square',3);
I = imdilate(I,se);

I = edge(I,'sobel');
I(msk_tight) = 0;
I = bwareaopen(I,20);



[H,Htheta_deg,Hrho] = hough(I,'RhoResolution',1,'Theta',thetaRange_deg);

P = houghpeaks(H,20,'threshold',ceil(0.3*max(H(:))));
thetaList_rad = Htheta_deg(P(:,2))*pi/180;
rhoList = Hrho(P(:,1));
[i1 , i2, xsec] = findBestTheta(thetaList_rad, rhoList, xsecHat);

thetas_rad = thetaList_rad([i1, i2]);
rhos = rhoList([i1, i2]);



end