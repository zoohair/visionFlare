warning('off','images:imshow:magnificationMustBeFitForDockedFigure')

%%
img = imread('data/snap-00002.tiff');
I= img;
%I = rgb2gray(img);
%figure(1); clf;
%I = imcrop(I);
%%
se = strel('square',3);
I2 = imdilate(I,se);
I2 = rgb2ind(I2,gray);
figure(1); clf
imshowpair(I,I2,'montage')

%%
I3 = im2bw(I2, graythresh(I2));
BW = edge(I3,'sobel');
figure(2); clf;
BW2 = bwareaopen(BW,50);
imshowpair(I3,BW2,'montage')

%%
[H,theta,rho] = hough(BW2,'RhoResolution',1,'Theta',-60  :.5:60);
figure(2); clf
% Display the Hough matrix.
offset = 0;
imshow(imadjust(mat2gray(H)),'XData',theta+offset,'YData',rho,...
      'InitialMagnification','fit');
title('Hough Transform of Gantrycrane Image');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
colormap(gray);

P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
x = theta(P(:,2));
y = rho(P(:,1));
for i = 1:length(x)
    plot(x(i)+offset,y(i),'s','color','red', 'LineWidth',8-i);
end

%%
figure(4); clf; imshow(BW2), hold on;
xx = 1:size(I2,2);
for i = 1:length(x)
    tt = x(i)*pi/180;
    ct = cos(tt); st = sin(tt);
    yy = -ct/st * xx + y(i)/st;
    plot(xx,yy,'--','LineWidth',2,'Color','red');
end
%%
lines = houghlines(BW2,theta,rho,P);%,'FillGap',5,'MinLength',7);
figure(5); clf; imshow(I2), hold on
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