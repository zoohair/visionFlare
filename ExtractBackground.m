%This is a modified version of code posted by alexander.farley at utoronto.ca
%Zouhair Mahboubi
%------------------------------------------------------------------------------
%The purpose of this script is to average a video across all frames as a
%first stage of a trajectory-learning algorithm

input_video = fullfile('./data', 'test1.avi');
disp('Opening video...')
vob = VideoReader(input_video); %A warning about being unable to read the number of frames is due to variable frame rate (normal)
%frame = vob.read(inf); %Reads to end, takes a while, but now vob knows the number of frames
vidHeight = vob.Height;
vidWidth = vob.Width;

%% First-v background frame

nFrames = 1000;
k0 = 1000;
bk_downsample = 100; %The downsample factor for frame averaging

frame0 = gread(vob, k0) * 0;
background_frame = frame0;
disp('Calculating background...')

for k = k0:bk_downsample:(nFrames+k0)
    background_frame = background_frame + gread(vob, k);
    disp((k-k0)/(nFrames)*100)
end
%%
%background_frame = uint8(bk_downsample*background_frame/(nFrames));
background_frame = rescale(background_frame);

figure(1); clf;
imshow(background_frame)

%% Second-iteration background frame
%This section re-calculates the background frame while attempting to
%minimize the effect of moving objects in the calculation

background_frame2 = frame0;
pixel_sample_density = im2bw(frame0);
diff_frame = frame0;
stream_frame = diff_frame(:,:,1);
bk_downsample = 10;


%%
for k = k0:bk_downsample:(k0+500)%nFrames)
    this_frame = gread(vob,k);
    diff_frame = imabsdiff(this_frame, background_frame);
    diff_frame = 1-im2bw(diff_frame,graythresh(diff_frame));
    pixel_sample_density = pixel_sample_density + diff_frame;
    stream_frame = stream_frame + (1-diff_frame)/(nFrames/bk_downsample);
    nonmoving = this_frame .* diff_frame;
    background_frame2 = background_frame2 + nonmoving;
    %pause
    disp((k-k0)/(nFrames)*100)
end
%%
background_frame3 = (background_frame2./pixel_sample_density);

%%
figure(1); clf
hold on
imshow(edge(this_frame-background_frame3,'sobel'))
%imshow(stream_frame)
