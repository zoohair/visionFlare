rescale = @(im) (im - min(im(:)))/(max(im(:)) - min(im(:)));
gread = @(v, kth)  rescale(double(rgb2ind(read(v,kth),gray)));
zim2bw = @(im) im2bw(im,graythresh(im));
