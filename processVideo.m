warning('off','images:imshow:magnificationMustBeFitForDockedFigure')
%%
bak = imread('test.bkgnd.png');
msk = ~zim2bw(bak);
msk_tight = imdilate(msk, strel('square',25));



%%
input_video = fullfile('./data', 'test1.avi');
disp('Opening video...')
vob = VideoReader(input_video); %A warning about being unable to read the number of frames is due to variable frame rate (normal)
frame = vob.read(inf); %Reads to end, takes a while, but now vob knows the number of frames
vidHeight = vob.Height;
vidWidth = vob.Width;

%%
writerObj = VideoWriter('processed.avi');
writerObj.FrameRate = 6;
open(writerObj);
tau = 0.05 * 3 / writerObj.FrameRate;
xx = 0:100:vob.Width;

makeVid = false;
nFrames = 100*30;
k0 = 50*30;
bk_downsample = 30 / writerObj.FrameRate; 

t = 0;
thetaHat = 20;
xsecHat = [1000, 400] ; %[vob.Width , vob.Height]/2;

if makeVid
    figure('visible', 'off'); clf;
    set(gcf,'Renderer','zbuffer');
else
    figuren('test'); clf; 
%     figure('visible', 'off'); clf;
%     set(gcf,'Renderer','zbuffer');
end


t2slope = @(t) tand(90 - t);
s2theta = @(s) 90 - atand(s); 

hHist = [];
tHist = [];
for k = k0:bk_downsample:(nFrames+k0)    
    if k > 2600
        break
    end
    t = t + bk_downsample/30;
    tHist(end+1) = t;
    img = gread(vob, k);    
    imshow(img); hold on;
    try
        [thetaList_rad, rhoList, xsecHatNew, allTheta_rad, allRho] = ...
            findLines(img, thetaHat, msk, msk_tight, xsecHat);
        newTheta = mean(abs(thetaList_rad))*180/pi;
        oldSearch = thetaHat;
        slopeFilt = t2slope(thetaHat) + tau*(t2slope(newTheta) - t2slope(thetaHat));
        thetaHat =  thetaHat + 2*tau*(newTheta - thetaHat); %s2theta(slopeFilt);
        zHat = theta2z(thetaList_rad);
                title(sprintf('Altitude = %.1fft [theta = %.1fdeg search near %.1f -> %.1f]', ...
            zHat, newTheta, oldSearch, thetaHat ));
        col = 'red';
    catch
       col = 'blue'; 
    end
    hHist(end+1) = zHat;

        if true
      for i = 1:length(allTheta_rad)
        tt = allTheta_rad(i);
        ct = cos(tt); st = sin(tt);
        yy = -ct/st * xx + allRho(i)/st;
        plot(xx,yy,'--','LineWidth',1,'Color','green');
      end   
        end
    
    for i = 1:length(thetaList_rad)
        tt = thetaList_rad(i);
        ct = cos(tt); st = sin(tt);
        yy = -ct/st * xx + rhoList(i)/st;
        plot(xx,yy,'-','LineWidth',1,'Color',col);
    end

    plot([xsecHat(1), xsecHat(1)+50*sind(180-thetaHat)],...
         [xsecHat(2), xsecHat(2)+50*cosd(180-thetaHat)], '-', 'MarkerSize', 10, 'Color', 'red');
     plot(xsecHat(1), xsecHat(2), 'x', 'MarkerSize', 10, 'Color', 'red');
         delete(findall(gcf,'Tag','altTag'));
     annotation('textbox', [0.4,0.3,0.1,0.1],'Color','red',...
           'String', sprintf('Altitude = %05.2fft', zHat),...
           'Tag', 'altTag');
    hold off;
    if makeVid
        frame = getframe;
        writeVideo(writerObj,frame);
    end
    xsecHat = xsecHat + clip(0.05*(xsecHatNew-xsecHat), -100, 100);
end

close(writerObj);
%%
figuren('hHist'); plot(tHist, hHist, 'x--')
grid on
ylim([0, 200]);
xlabel('time(s)')
ylabel('altitude(ft)');
