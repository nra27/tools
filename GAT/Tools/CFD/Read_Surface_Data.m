function data = Read_Surface_Data(file_root);
%
% data = Read_Flow_and_Grid_Data(file_root)
%
% This function reads the grid data file and the flow files,
% strips the surface node data and pairs it
% up with the flow data.  The stucture of data is:
%
% data
%   +- surface_groups: cell array of names
%   |
%   +- group(i): the ith group
%       +- type: the type of the surface
%       +- coordinates: the (x,y,z) coordinates of the nodes in the group
%       +- flow: the flow data (rho,uvw,p,nu)
%       +- wall_heat_flux: the wall heat flux
%       +- surface_node_numbers: the surface node numbers for this group
%       +- flow_node_numbers: the bulk node numbers for this group

% Initialise ADF parameters
D = ADFI_Declarations;
[D,error_return] = ADF_Set_Error_State(1,D);

Handles.dlgbox = figure('units','points','position',[40 40 200 70],'windowstyle','normal',...
        'name','Adiabatic Wall Temperature','buttondownfcn',[],'visible','on','resize','off',...
        'menubar','none','colormap',[],'numbertitle','off','doublebuffer','on');
Handles.axes = axes('position',[0.1 0.35 0.8 0.2],'box','on','xtick',[],'ytick',[],'xlim',[0 1],'ylim',[0 1]);
Handles.line = line([-1 -1],[0.5 0.5]);
set(Handles.line,'color','b','linewidth',14);
set(Handles.line,'xdata',[-1 2]);

% Open Grid file
filename = ['../input/' file_root '.grid.1.adf'];
Handles.title = title('Reading Grid File');
pause(0.02);
[D,grid.root.ID,error_return] = ADF_Database_Open(filename,'READ_ONLY','NATIVE',D);

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
    while ~strcmp(grid.surface_groups.data(i,j),' ')
        name(j) = grid.surface_groups.data(i,j);
        j = j+1;
    end
    while strcmp(grid.surface_groups.data(i,j),' ');
        j = j+1;
    end
    data.surface_groups{i} = name;
    data.group(i).type = grid.surface_groups.data(i,j);
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

% Sort surface nodes into groups
set(Handles.title,'string','Sorting surface node grid data');
set(Handles.line,'xdata',[0 0]);
pause(0.02);
for i = 1:grid.surface_groups.dim_vals(2)
    set(Handles.line,'xdata',[0 i/grid.surface_groups.dim_vals(2)]);
    pause(0.02);
    data.group(i).surface_node_numbers = find(grid.bnd_node_group.data == i)';
    data.group(i).flow_node_numbers = grid.bnd_node_node.data(data.group(i).surface_node_numbers)';
    data.group(i).coordinates = grid.coordinates.data(data.group(i).flow_node_numbers,:);
end

% Close Grid file
[D,error_return] = ADF_Database_Close(grid.root.ID,D);

% Open Solution file
Handles.title = title('Reading Solution File');
pause(0.02);
set(Handles.line,'xdata',[-1 2]);

filename = [file_root '.flow.adf'];
[D,solution.root.ID,error_return] = ADF_Database_Open(filename,'READ_ONLY','NATIVE',D);

% Read data
set(Handles.title,'string','Reading Node: flow');
pause(0.02);
[D,solution.flow.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'flow',D);
[D,solution.flow.dim_vals,error_return] = ADF_Get_Dimension_Values(solution.flow.ID,D);
[D,solution.flow.data,error_return] = ADF_Read_All_Data(solution.flow.ID,D);
solution.flow.data = Strip_to_Array(solution.flow.data,solution.flow.dim_vals(1));

set(Handles.title,'string','Reading Node: wall heat flux');
pause(0.02);
[D,solution.wall_heat_flux.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'wall heat flux',D);
[D,solution.wall_heat_flux.data,error_return] = ADF_Read_All_Data(solution.wall_heat_flux.ID,D);

% Close Solution file
[D,error_return] = ADF_Database_Close(solution.root.ID,D);

% Sort surface nodes into groups
set(Handles.title,'string','Sorting surface node flow data');
set(Handles.line,'xdata',[0 0]);
pause(0.02);
for i = 1:grid.surface_groups.dim_vals(2)
    set(Handles.line,'xdata',[0 i/grid.surface_groups.dim_vals(2)]);
    pause(0.02);
    data.group(i).flow = solution.flow.data(data.group(i).flow_node_numbers,:);
    data.group(i).wall_heat_flux = solution.wall_heat_flux.data(data.group(i).surface_node_numbers)';
end

pause(1);
close(Handles.dlgbox);