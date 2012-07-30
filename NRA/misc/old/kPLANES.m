%
% Wrapper for Gregs Resample_k_planes script
%
% It simply reads in and writes out the files etc
%
% function kPLANES(k_blade,k_start,k_tip,radius)

function kPLANES(k_blade,k_start,k_tip,radius)

% Read the Plot3D files
disp('Opening the Plot3d files')
boundata = Read_Boundata_File('p3d.boundata');
mesh = Read_Plot3D('mesh.plot3d');

% Resample the mesh
disp('Resampling the k-planes')
[new_mesh,new_boundata] = Resample_K_Planes(mesh,boundata,k_blade,k_start,k_tip,radius);

% Write the new Plot3D files
disp('Writing the new Plot3d files')
Write_Boundata_File('p3d.boundata',new_boundata)
Write_Plot3D('mesh.plot3d',new_mesh)