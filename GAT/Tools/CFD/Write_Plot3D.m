function Write_Plot3D(filename,mesh);
%
% function Write_Plot3D(filenname,mesh)
% A function to write an asci plot3d file from Matlab

% Check to see if file exist already and delete if necessary
if exist(filename) == 2
    delete(filename);
end

% Open file
fid = fopen(filename,'w');

% Write header information
fprintf(fid,' %d\n',mesh.n_blocks);
for block = 1:mesh.n_blocks
    fprintf(fid,' %d %d %d',mesh.dims(block,:));
end
fprintf(fid,'\n');

% Write coordinates
for block = 1:mesh.n_blocks
    for k = 1:mesh.dims(block,3)
        fprintf(fid,'%14.10f %14.10f',mesh.block(block).x(:,:,k));
    end
    for k = 1:mesh.dims(block,3)
        fprintf(fid,'%14.10f %14.10f',mesh.block(block).z(:,:,k));
    end
    for k = 1:mesh.dims(block,3)
        fprintf(fid,'%14.10f %14.10f',mesh.block(block).y(:,:,k));
    end
    fprintf(fid,'\n');
end

% Close file
fclose(fid);