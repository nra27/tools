%
% [frames] = bin2frames(filename,horz_window,vert_window)
%
% NB set the caxis by hand!
%
% nra April 2012
%

function [frames] = bin2frames(filename,horz_window,vert_window)

fid = fopen(filename);

%
% Find the size of the image array

dummy = fread(fid,6,'ubit16');
M = dummy(5)*dummy(3);

%
% Pre-allocate 

frames = zeros(length(horz_window),length(vert_window),dummy(1));

%
% Loop through the frames

for i = 1:dummy(1)
    
    %
    % Strip out the pixel data
    
    data = fread(fid,M,'ubit16=>ubit16');
    tmp = reshape(data,dummy(5),dummy(3));
    frames(:,:,i) = tmp(horz_window,vert_window);
     
    %
    % Preview frames
    
    contourf(frames(:,:,i)',10)
    shading flat
    axis equal
    axis off
    %caxis([15000 30000])
    colorbar
    title(['Frame No. ' num2str(i)])
    % Small pause to make sure the figure gets updated
    pause(0.0000001) 
    
end

fclose(fid)
