function Calculate_Recovery_Temp(grid_file,flow_file,Rc,omega);
%
% Calculate_Recovery_Temp(grid_file,flow_file,Rc,omega);
%
% A Hydra post-processing function to calculate the recovery
% temperature on the viscous walls.  Temperature is then written
% back into the wall-heat-flux variable.

% Set-up
% Non-dimensional parameters
rho_ref = 1.226;
p_ref = 101300;
u_ref = sqrt(p_ref/rho_ref);
q_ref = (p_ref^1.5)/(rho_ref^0.5);
gamma = 1.4;

% ADF parameters
D = ADFI_Declarations;
[D,error_return] = ADF_Set_Error_State(1,D);

% Open dialog box
Handles.dlgbox = figure('units','points','position',[40 40 200 70],'windowstyle','normal',...
        'name','Calculate Recovery Temperature','buttondownfcn',[],'visible','on','resize','off',...
        'menubar','none','colormap',[],'numbertitle','off','doublebuffer','on');
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
    while ~strcmp(grid.surface_groups.data(i,j),' ')
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
flow_data.coordinates = grid.coordinates.data;

set(Handles.title,'string','Reading Node: bnd node weights');
pause(0.02);
[D,grid.bnd_node_weights.ID,error_return] = ADF_Get_Node_ID(grid.root.ID,'bnd_node_weights',D);
[D,grid.bnd_node_weights.data,error_return] = ADF_Read_All_Data(grid.bnd_node_weights.ID,D);
[D,grid.bnd_node_weights.dim_vals,error_return] = ADF_Get_Dimension_Values(grid.bnd_node_weights.ID,D);
grid.bnd_node_weights.data = Strip_to_Array(grid.bnd_node_weights.data,grid.bnd_node_weights.dim_vals(1));

set(Handles.title,'string','Reading Node: edge --> node');
pause(0.02);
[D,grid.edge_node.ID,error_return] = ADF_Get_Node_ID(grid.root.ID,'edge-->node',D);
[D,grid.edge_node.data,error_return] = ADF_Read_All_Data(grid.edge_node.ID,D);
[D,grid.edge_node.dim_vals,error_return] = ADF_Get_Dimension_Values(grid.edge_node.ID,D);
edge_nodes = Strip_to_Array(grid.edge_node.data,grid.edge_node.dim_vals(1));

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

% Open Flow file
Handles.title = title('Reading Flow File');
set(Handles.line,'xdata',[-1 2]);
pause(0.02);

[D,solution.root.ID,error_return] = ADF_Database_Open(flow_file,'READ_ONLY','NATIVE',D);

% Read data
set(Handles.title,'string','Reading Node: flow');
pause(0.02);
[D,solution.flow.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'flow',D);
[D,solution.flow.dim_vals,error_return] = ADF_Get_Dimension_Values(solution.flow.ID,D);
[D,solution.flow.data,error_return] = ADF_Read_All_Data(solution.flow.ID,D);
solution.flow.data = Strip_to_Array(solution.flow.data,solution.flow.dim_vals(1));

% Bring back from non-dimensional form
solution.flow.data(:,1) = solution.flow.data(:,1)*rho_ref;
solution.flow.data(:,2:4) = solution.flow.data(:,2:4)*u_ref;
solution.flow.data(:,5) = solution.flow.data(:,5)*p_ref;

flow_data.data_type = {'density' 'u_velocity' 'v_velocity' 'w_velocity' 'pressure' 'spallart'};
flow_data.flow = solution.flow.data;

set(Handles.title,'string','Reading Node: wall heat flux');
pause(0.02);
[D,solution.wall_heat_flux.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'wall heat flux',D);
[D,solution.wall_heat_flux.data,error_return] = ADF_Read_All_Data(solution.wall_heat_flux.ID,D);

% Bring back from non-dimensional form
solution.wall_heat_flux.data = solution.wall_heat_flux.data*q_ref;

% Sort surface nodes into groups
set(Handles.title,'string','Sorting surface node flow data');
set(Handles.line,'xdata',[0 0]);
pause(0.02);
for i = 1:grid.surface_groups.dim_vals(2)
    set(Handles.line,'xdata',[0 i/grid.surface_groups.dim_vals(2)]);
    pause(0.02);
	surface_data.group(i).wall_heat_flux = solution.wall_heat_flux.data(surface_data.group(i).surface_node_numbers)';
end

% Close Solution file
[D,error_return] = ADF_Database_Close(solution.root.ID,D);
clear grid solution;

% Calculate temperature and mach number
set(Handles.title,'string','Calculating flow temperature');
set(Handles.line,'xdata',[-1 2]);
pause(0.02);

flow_data = Calculate_Temperature(flow_data);
T = flow_data.flow(:,end);

set(Handles.title,'string','Calculating flow mach number');
set(Handles.line,'xdata',[-1 2]);
pause(0.02);

flow_data = Calculate_Mach_Number(flow_data,omega);
M = flow_data.flow(:,end);

clear flow_data

% Check which surface groups are viscous walls
viscous_groups = [];
for i = 1:length(surface_data.surface_groups);
	if strcmp(surface_data.group(i).type,'v')
		viscous_groups(end+1) = i;
	end
end

% If there are no viscous walls then return
if isempty(viscous_groups)
	return
end

% Set up dialogue box
set(Handles.title,'string','Extracting boundary layer nodes');
Handles.axes2 = axes('position',[0.1 0.1 0.8 0.2],'box','on','xtick',[],'ytick',[],'xlim',[0 1],'ylim',[0 1]);
Handles.line2 = line([-1 -1],[0.5 0.5]);
set(Handles.line2,'color','b','linewidth',14);
set(Handles.line2,'xdata',[-1 2]);
set(Handles.line,'xdata',[0 0]);
pause(0.02);

% Find stand off nodes for all viscous surfaces
% Outer loop (for each viscous surface)
for ig = 1:length(viscous_groups)
	set(Handles.line2,'xdata',[0 0]);
	pause(0.02);
	
	% Short cut for this group number
	tg = viscous_groups(ig);
	lim = 0.0009;
	
	% Get boundary nodes and number of edges (big and slow)
	boundary_nodes = surface_data.group(tg).flow_node_numbers;
	num_edges = length(edge_nodes);

	for ie = 1:num_edges
		% For each edge, find if the nodes are boundary nodes
		end_1 = find(boundary_nodes == edge_nodes(ie,1));
		end_2 = find(boundary_nodes == edge_nodes(ie,2));
		
		% Check to see what type of edge it is
		if isempty(end_1) & isempty(end_2)
			% Both nodes in flow - not boundary layer edge
			continue;
		elseif ~isempty(end_1) & isempty(end_2)
			% End 1 is a boundary node, node 2 is the boundary layer node
			flow_node = edge_nodes(ie,1);
			boundary_node = end_1;
		elseif isempty(end_1) & ~isempty(end_2)
			% End 2 is a boundary node, node 1 is the boundary layer node
			flow_node = edge_nodes(ie,2);
			boundary_node = end_2;
		else
			continue
		end
	
		% Reinsert Taw in qdot data.
		surface_data.group(tg).wall_heat_flux(boundary_node) = T(edge_nodes(flow_end,ie))*(1+Rc*0.5*(gamma-1)*(M(edge_nodes(flow_end,ie)^2)));
		
		% Update progess bar
		if ie/num_edges > lim
  	    	set(Handles.line2,'xdata',[0 lim]);
        	lim = lim+0.001;
			pause(0.02);
		end
	end

	% Update progress bar
	set(Handles.line,'xdata',[0 ig/length(viscous_groups)]);
end

% Reassemble wall heat flux array
figure(Handles.dlgbox);
clf;
Handles.axes = axes('position',[0.1 0.35 0.8 0.2],'box','on','xtick',[],'ytick',[],'xlim',[0 1],'ylim',[0 1]);
Handles.line = line([-1 -1],[0.5 0.5]);
set(Handles.line,'color','b','linewidth',14);
set(Handles.line,'xdata',[-1 2]);
Handles.title = title('Saving Flow File');
pause(0.02);

for i = 1:length(surface_data.surface_groups);
	if strcmp(surface_data.group(i).type,'v')
		Qdot_data(surface_data.group(i).surface_node_numbers) = surface_data.group(i).wall_heat_flux;
	else
		Qdot_data(surface_data.group(i).surface_node_numbers) = 0;
	end
end

% Non-dimensionalise
Qdot_data = Qdot_data/q_ref;

% Open flow file
[D,root.ID,error_return] = ADF_Database_Open(flow_file,'OLD','NATIVE',D);

% Move to wall heat flux node
[D,whf.ID,error_return] = ADF_Get_Node_ID(root.ID,'wall heat flux',D);

% Write Adiabatic wall temperature scalled by heat-flux
[D,error_return] = ADF_Write_All_Data(whf.ID,Qdot_data,D);

% Close the database
[D,error_return] = ADF_Database_Close(root.ID,D);

set(Handles.title,'string','All done!');

% Close dlgbox
close(Handles.dlgbox);