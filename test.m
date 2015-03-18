warning('off','images:imshow:magnificationMustBeFitForDockedFigure')

%%
img = imread('test.gray.png');
bak = imread('test.bkgnd.png');
%I = rgb2gray(img);
figuren('original'); clf;
imshowpair(img, bak,'montage')
center_xy = [size(img,2) , size(img,1)]/2;
%I = imcrop(I);
%%
Ifore = img;
msk = ~zim2bw(bak);
msk_tight = imdilate(msk, strel('square',25));
figuren('test'); clf; 
imshowpair(msk, msk_tight,'montage');
%%
av = mean(img(:));
Ifore(msk) = av;
figuren('background removed'); clf
imshow(Ifore);
I =  Ifore;
%%
se = strel('square',3);
I2 = I ; %imdilate(I,se);
figuren('dilated'); clf
imshowpair(I,I2,'montage')

%%
I3 = im2bw(I2, graythresh(I2));
IforEdge = I2;

BW = edge(IforEdge,'sobel');
BW(msk_tight) = 0;
BWforConv = bwareaopen(BW,50);
figuren('threshold and sobel'); clf;
imshowpair(BW,BWforConv,'montage')

%% Try convolution
%h = [-1, 2, -1]; h = repmat(h, 3, 1);
%BWforHough = BWforConv; %imfilter(BWforConv, h);
%figuren('Convolution');
%imshowpair(BWforConv, BWforHough, 'montage');
BWforHough= BWforConv;
%%
[H,theta,rho] = hough(I,'RhoResolution',1,'Theta',-50:1:50);
figuren('Hough Transform'); clf
% Display the Hough matrix.
offset = 0;
imshow(imadjust(mat2gray(H)),'XData',theta+offset,'YData',rho,...
      'InitialMagnification','fit');
title('Hough Transform');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
colormap(gray);

P = houghpeaks(H,20,'threshold',ceil(0.3*max(H(:))));
thetaList = theta(P(:,2))*pi/180;
rhoList = rho(P(:,1));
[i1 , i2, xsec] = findBestTheta(thetaList, rhoList, xsecHat);
for i = 1:length(thetaList)
    if(i == i1 || i == i2)
        col = 'red';
    else
        col = 'blue';
        continue
    end
    plot(180/pi*thetaList(i)+offset,rhoList(i),'s','color',col, 'LineWidth',1);
end

%%
lines = houghlines(BWforHough,theta,rho,P,'FillGap',50,'MinLength',50);
figuren('Hough Lines'); clf; imshow(I2), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end

%%
figuren('Best Lines'); clf; imshow(img), hold on;
xx = 1:size(I2,2);
for i = 1:length(thetaList)
    tt = thetaList(i);
    ct = cos(tt); st = sin(tt);
    yy = -ct/st * xx + rhoList(i)/st;
    if(i == i1 || i == i2)
        col = 'red';
    else
        col = 'blue';
        %continue;
    end
    plot(xx,yy,'--','LineWidth',1,'Color',col);
end
plot(xsec(1), xsec(2),'x', 'Color','Green', 'MarkerSize',20);