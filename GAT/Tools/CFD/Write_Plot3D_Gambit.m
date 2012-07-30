function Write_Plot3D_Gambit(filename,mesh,dim);
%
% function Write_Plot3D(filenname,mesh,dim)
% A function to write an asci plot3d file from Matlab

% Check to see if file exist already and delete if necessary
if exist(filename) == 2
    delete(filename);
end

% Open file
fid = fopen(filename,'w');

if dim == 2
    % Write header information
    fprintf(fid,' %d\n',mesh.n_blocks);
    for block = 1:mesh.n_blocks
        fprintf(fid,' %d %d',mesh.dims(block,:));
    end
    fprintf(fid,'\n');
    
    % Write coordinates
    for block = 1:mesh.n_blocks
        for j = 1:mesh.dims(block,2)
            for i = 1:mesh.dims(block,1)
                fprintf(fid,' %14.10f',mesh.block(block).x(i,j)*1000);
            end
        end
        for j = 1:mesh.dims(block,2)
            for i = 1:mesh.dims(block,1)
                fprintf(fid,' %14.10f',mesh.block(block).y(i,j)*1000);
            end
        end
        fprintf(fid,'\n');
    end
elseif dim == 3
    % Write header information
    fprintf(fid,' %d\n',mesh.n_blocks);
    for block = 1:mesh.n_blocks
        fprintf(fid,' %d %d %d',mesh.dims(block,:));
    end
    fprintf(fid,'\n');
    
    % Write coordinates
    for block = 1:mesh.n_blocks
        for k = 1:mesh.dims(block,3)
            for j = 1:mesh.dims(block,2)
                for i = 1:mesh.dims(block,1)
                    fprintf(fid,' %14.10f',mesh.block(block).x(i,j,k)*1000);
                end
            end
        end
        for k = 1:mesh.dims(block,3)
            for j = 1:mesh.dims(block,2)
                for i = 1:mesh.dims(block,1)
                    fprintf(fid,' %14.10f',mesh.block(block).y(i,j,k)*1000);
                end
            end
        end
        for k = 1:mesh.dims(block,3)
            for j = 1:mesh.dims(block,2)
                for i = 1:mesh.dims(block,1)
                    fprintf(fid,' %14.10f',-mesh.block(block).z(i,j,k)*1000);
                end
            end
        end
        fprintf(fid,'\n');
    end
end
% Close file
fclose(fid);