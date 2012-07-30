function mesh = Read_Plot3D(filename);
%
% function mesh = Read_Plot3D(filenname)
% A function to read an asci plot3d file into Matlab

% Open file
fid = fopen(filename,'r');

% Read grid dimensions
mesh.n_blocks = fscanf(fid,'%d',1);
mesh.dims = fscanf(fid,'%d',[3 mesh.n_blocks])';

% Read in grid blocks
for i_block = 1:mesh.n_blocks
    for k = 1:mesh.dims(i_block,3)
        mesh.block(i_block).x(:,:,k) = fscanf(fid,'%f',[mesh.dims(i_block,1) mesh.dims(i_block,2)]);
    end
    for k = 1:mesh.dims(i_block,3)
        mesh.block(i_block).z(:,:,k) = fscanf(fid,'%f',[mesh.dims(i_block,1) mesh.dims(i_block,2)]);
    end
    for k = 1:mesh.dims(i_block,3)
        mesh.block(i_block).y(:,:,k) = fscanf(fid,'%f',[mesh.dims(i_block,1) mesh.dims(i_block,2)]);
    end
end

% Close file
fclose(fid);