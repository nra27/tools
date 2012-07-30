function Split_Blade(mesh_file,boundata_file);
%
% Split_Blade(mesh_file,boundata_file)
%
% A function to split the OGV into SS, PS and Tip.
% The SS/PS split is done on axial position.
% plot3d mesh.  No checks are done.


% Read mesh file
Mesh = Read_Plot3d(mesh_file);

% Read boundata file
boundata = Read_Boundata_File(boundata_file);

% Find blade surface
for i = 1:length(boundata)
    if strncmp(boundata(i).name,'MERGEOGV',8) & boundata(i).block1 == 2;
        boundata(i).name = 'MERGEOG1 ';
        boundata(i+1:end+1) = boundata(i:end);
        boundata(i+1).name = 'MERGEOG2 ';
        boundata(i+2:end+1) = boundata(i+1:end);
        break
    end
end

% Find leading edge and trailing edge
[le_x,le_i] = min(Mesh.block(2).x(:,1,1));
[te_x,te_i] = max(Mesh.block(2).x(:,1,1));

% Set new limits
boundata(i).dims(4:5) = [te_i,le_i];
boundata(i).dims(7:8) = [te_i,le_i];
boundata(i+1).dims(4:5) = [le_i,Mesh.dims(2,1)];
boundata(i+1).dims(7:8) = [le_i,Mesh.dims(2,1)];
boundata(i+2).dims(4:5) = [1,te_i];
boundata(i+2).dims(7:8) = [1,te_i];

% Save the files
Write_Boundata_File(boundata_file,boundata);