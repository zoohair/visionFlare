%Time-average the movement regions in a video as the first stage of a
%trajectory-learning algorithm
%Alexander Farley
%alexander.farley at utoronto.ca
%September 16 2011 
%Written and tested in Matlab R2011a
%------------------------------------------------------------------------------
%The purpose of this script is to average a video across all frames as a
%first stage of a trajectory-learning algorithm

input_video = fullfile('./data', 'test1.avi');
disp('Opening video...')


vob = VideoReader(input_video); %A warning about being unable to read the number of frames is due to variable frame rate (normal)
%frame = vob.read(inf); %Reads to end, takes a while, but now vob knows the number of frames
vidHeight = vob.Height;
vidWidth = vob.Width;
%nFrames = vob.NumberOfFrames;
%%

%% First-iteration background frame
nFrames = 50;
bk_downsample = 10; %The downsample factor for frame averaging

disp('Calculating background...');
k0 = 1000;
prev_frame = double(rgb2gray(read(vob, k)));
frame_delta = prev_frame*0;
for k = (k0+1):bk_downsample:(k0+nFrames)
    this_frame = double(rgb2gray(read(vob, k)));
    frame_delta = frame_delta + abs(this_frame - prev_frame);
    prev_frame = this_frame;
    disp(k/(nFrames)*100)
end

%background_frame = uint8(bk_downsample*background_frame/(nFrames));
background_frame = bk_downsample*frame_delta/(nFrames);

%%
figure(1); clf;
mask = im2bw(background_frame, graythresh(background_frame));
imshow(mask);
figure(2); clf;
imshow(frame_delta);
%imshow(background_frame)

%% Second-iteration background frame
%This section re-calculates the background frame while attempting to
%minimize the effect of moving objects in the calculation

background_frame2 = double(frame*0);
pixel_sample_density = im2bw(double(frame*0));
diff_frame = double(frame*0);
stream_frame = diff_frame(:,:,1);
bk_downsample = 10;


for k = 1:bk_downsample:nFrames
    diff_frame = imabsdiff(double(read(vob, k)), background_frame);
    diff_frame = 1-im2bw(uint8(diff_frame),.25);
    pixel_sample_density = pixel_sample_density + diff_frame;
    stream_frame = stream_frame + (1-diff_frame)/(nFrames/bk_downsample);
    nonmoving = double(read(vob, k));
    nonmoving(:,:,1) = nonmoving(:,:,1).*diff_frame;
    nonmoving(:,:,2) = nonmoving(:,:,2).*diff_frame;
    nonmoving(:,:,3) = nonmoving(:,:,3).*diff_frame;
    background_frame2 = background_frame2 + nonmoving;
    %pause
    disp(k/(nFrames)*100)
end

background_frame2(:,:,1) = background_frame2(:,:,1)./pixel_sample_density;
background_frame2(:,:,2) = background_frame2(:,:,2)./pixel_sample_density;
background_frame2(:,:,3) = background_frame2(:,:,3)./pixel_sample_density;

%%
figure(1)
hold on
imshow(uint8(background_frame2))
%%
figure(2); clf;
imshow(uint8(double(read(vob, k)) - background_frame))
%imshow(stream_frame)
