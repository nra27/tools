function [surface_data,coordinates] = Read_ADF_Grid(grid_file);

%
% Modified from Read_ADF_Data by NRA 21-10-2007 to just open the grid file
%
% [surface_data,flow_data] = Read_ADF_Grid(grid_file);
%
% This function reads the grid data file
% strips the surface node data and pairs it
% up with the flow data.  The stucture of data is:
%
% surface_data
%   +- surface_groups: cell array of names
%   |
%   +- group(i): the ith group
%       +- type: the type of the surface
%       +- surface_node_numbers: the surface node numbers for this group
%       +- flow_node_numbers: the bulk node numbers for this group
%       +- node_areas: the nodal areas for this group
%		+- node_normals: the i,j,k unit vector of the node normal
%
% flow_data
%   +- 
%   +- coordinates: the (x,y,z) coordinates of the nodes in the domain

% Non dimensional parameters
rho_ref = 1.226;
p_ref = 101300;
u_ref = sqrt(p_ref/rho_ref);
q_ref = -p_ref^1.5/rho_ref^0.5;

% Initialise ADF parameters
D = ADFI_Declarations;
[D,error_return] = ADF_Set_Error_State(1,D);

Handles.dlgbox = figure('units','points','position',[40 40 200 70],'windowstyle','normal',...
        'name','Read HYDRA ADF Data','buttondownfcn',[],'visible','on','resize','off',...
        'menubar','none','colormap',[],'numbertitle','off','doublebuffer','on','Tag','nozoom');
Handles.axes = axes('position',[0.1 0.35 0.8 0.2],'box','on','xtick',[],'ytick',[],'xlim',[0 1],'ylim',[0 1]);
Handles.line = line([-1 -1],[0.5 0.5]);
set(Handles.line,'color','b','linewidth',14);
set(Handles.line,'xdata',[-1 2]);

% Open Grid file
Handles.title = title('Reading Grid File');
pause(0.02);
[D,grid.root.ID,error_return] = ADF_Database_Open(grid_file,'READ_ONLY','NATIVE',D);

% Get surface group data
set(Handles.title,'string','Reading Node: surface groups');
pause(0.02);
[D,grid.surface_groups.ID,error_return] = ADF_Get_Node_ID(grid.root.ID,'surface_groups',D);
[D,grid.surface_groups.dim_vals,error_return] = ADF_Get_Dimension_Values(grid.surface_groups.ID,D);
[D,grid.surface_groups.data,error_return] = ADF_Read_All_Data(grid.surface_groups.ID,D);

grid.surface_groups.data = Strip_to_Array(grid.surface_groups.data,grid.surface_groups.dim_vals(1));
grid.surface_groups.data = char(grid.surface_groups.data);

set(Handles.title,'string','Sorting Group Names');
pause(0.02);
for i = 1:grid.surface_groups.dim_vals(2)
    j = 1;
    while ~strcmp(grid.surface_groups.data(i,[j j+1]),'  ')
        name(j) = grid.surface_groups.data(i,j);
        j = j+1;
    end
    while strcmp(grid.surface_groups.data(i,j),' ');
        j = j+1;
    end
    surface_data.surface_groups{i} = name;
    surface_data.group(i).type = grid.surface_groups.data(i,j);
    clear name
end

% Read surface node data
set(Handles.title,'string','Reading Node: bnd node-->group');
pause(0.02);
[D,grid.bnd_node_group.ID,error_return] = ADF_Get_Node_ID(grid.root.ID,'bnd_node-->group',D);
[D,grid.bnd_node_group.data,error_return] = ADF_Read_All_Data(grid.bnd_node_group.ID,D);

set(Handles.title,'string','Reading Node: bnd node-->node');
pause(0.02);
[D,grid.bnd_node_node.ID,error_return] = ADF_Get_Node_ID(grid.root.ID,'bnd_node-->node',D);
[D,grid.bnd_node_node.data,error_return] = ADF_Read_All_Data(grid.bnd_node_node.ID,D);

set(Handles.title,'string','Reading Node: node coordinates');
pause(0.02);
[D,grid.coordinates.ID,error_return] = ADF_Get_Node_ID(grid.root.ID,'node_coordinates',D);
[D,grid.coordinates.data,error_return] = ADF_Read_All_Data(grid.coordinates.ID,D);
[D,grid.coordinates.dim_vals,error_return] = ADF_Get_Dimension_Values(grid.coordinates.ID,D);
grid.coordinates.data = Strip_to_Array(grid.coordinates.data,grid.coordinates.dim_vals(1));
coordinates = grid.coordinates.data;

set(Handles.title,'string','Reading Node: bnd node weights');
pause(0.02);
[D,grid.bnd_node_weights.ID,error_return] = ADF_Get_Node_ID(grid.root.ID,'bnd_node_weights',D);
[D,grid.bnd_node_weights.data,error_return] = ADF_Read_All_Data(grid.bnd_node_weights.ID,D);
[D,grid.bnd_node_weights.dim_vals,error_return] = ADF_Get_Dimension_Values(grid.bnd_node_weights.ID,D);
grid.bnd_node_weights.data = Strip_to_Array(grid.bnd_node_weights.data,grid.bnd_node_weights.dim_vals(1));

set(Handles.title,'string','Reading Node: bnd node normal');
pause(0.02);
[D,grid.bnd_node_normal.ID,error_return] = ADF_Get_Node_ID(grid.root.ID,'bnd_node_normal',D);
[D,grid.bnd_node_normal.data,error_return] = ADF_Read_All_Data(grid.bnd_node_normal.ID,D);
[D,grid.bnd_node_normal.dim_vals,error_return] = ADF_Get_Dimension_Values(grid.bnd_node_normal.ID,D);
grid.bnd_node_normal.data = Strip_to_Array(grid.bnd_node_normal.data,grid.bnd_node_normal.dim_vals(1));

% Create surface node area
grid.node_area = sqrt(sum((grid.bnd_node_weights.data.^2),2));

% Sort surface nodes into groups
set(Handles.title,'string','Sorting surface node grid data');
set(Handles.line,'xdata',[0 0]);
pause(0.02);
for i = 1:grid.surface_groups.dim_vals(2)
    set(Handles.line,'xdata',[0 i/grid.surface_groups.dim_vals(2)]);
    pause(0.02);
    surface_data.group(i).surface_node_numbers = find(grid.bnd_node_group.data == i)';
    surface_data.group(i).flow_node_numbers = grid.bnd_node_node.data(surface_data.group(i).surface_node_numbers)';
end

% Close Grid file
[D,error_return] = ADF_Database_Close(grid.root.ID,D);



