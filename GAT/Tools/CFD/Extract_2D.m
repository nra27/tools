function new_mesh = Extract_2D;
%
% Extract_2D a function to extract the mid height plane from a padram
% plot3d mesh and write it in 2D format for Gambit

old_mesh = Read_Plot3D('mesh.plot3d');

% Check to see how many blocks we have
new_mesh.n_blocks = 5;
blocks = [1:5];
if old_mesh.n_blocks > 5
    blocks = [1 2 3 7:old_mesh.n_blocks];
end

% Pick the mid k-plane
k = round(old_mesh.dims(1,3)/2);

% Copy dims
new_mesh.dims = old_mesh.dims(blocks,1:2);

% Pick initial radius as leading edge
r = sqrt(old_mesh.block(blocks(1)).y(1,1,k)^2+old_mesh.block(blocks(1)).z(1,1,k)^2);

% Extract points in x-s form
for i = 1:5
    new_mesh.block(i).x = old_mesh.block(blocks(i)).x(:,:,k);
    new_mesh.block(i).y = r*atan2(old_mesh.block(blocks(i)).z(:,:,k),old_mesh.block(blocks(i)).y(:,:,k));
end

% Write out mesh
Write_Plot3D_Gambit('2D.unf',new_mesh,2);