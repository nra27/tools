function Extract_Boundary_Nodes(grid_file);
%
% Extract_Boundary_Nodes(grid_file);
%
% A Hydra post-processing tool to find the node one off
% the boundary.

% ADF parameters
D = ADFI_Declarations;
[D,error_return] = ADF_Set_Error_State(1,D);

% Open dialog box
Handles.dlgbox = figure('units','points','position',[40 40 200 70],'windowstyle','normal',...
        'name','Extract Boundary Nodes','buttondownfcn',[],'visible','on','resize','off',...
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
	surface_data.group(i).partner_nodes = surface_data.group(i).flow_node_numbers*0;
end

% Close Grid file
[D,error_return] = ADF_Database_Close(grid.root.ID,D);

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
	
	% Get number of boundary nodes on each group
	boundary_nodes = surface_data.group(tg).flow_node_numbers;
	num_boundary_nodes = length(boundary_nodes);
	Node = zeros(1,num_boundary_nodes);

	for ib = 1:num_boundary_nodes
		% For each boundary node, find the edges it is on
		end_1 = find(edge_nodes(:,1) == boundary_nodes(ib));
		end_2 = find(edge_nodes(:,2) == boundary_nodes(ib));
		
		partner_nodes = [edge_nodes(end_1,2);edge_nodes(end_2,1)];
		
		free_nodes = [];
		for ip = 1:length(partner_nodes)
			% Check to see if the partner node is free
			if isempty(find(boundary_nodes == partner_nodes(ip)))
				free_nodes(end+1) = partner_nodes(ip);
			end
		end
	
		% Calculate the temperature
		if isempty(free_nodes)
			Node(ib) = 0;
		else
			Node(ib) = free_nodes(1);
		end
		
		% Update progess bar
		if ib/num_boundary_nodes > lim
  	    	set(Handles.line2,'xdata',[0 lim]);
        	lim = lim+0.001;
			pause(0.02);
		end
	end

	% Insert Taw in qdot data.
	surface_data.group(tg).partner_nodes = Node';
	clear Node;
	set(Handles.line,'xdata',[0 ig/length(viscous_groups)]);
end

% Reassemble wall heat flux array
figure(Handles.dlgbox);
clf;
Handles.axes = axes('position',[0.1 0.35 0.8 0.2],'box','on','xtick',[],'ytick',[],'xlim',[0 1],'ylim',[0 1]);
Handles.line = line([-1 -1],[0.5 0.5]);
set(Handles.line,'color','b','linewidth',14);
set(Handles.line,'xdata',[-1 2]);
Handles.title = title('Saving Boundary Node Data');
pause(0.02);

for i = 1:length(surface_data.surface_groups);
	if strcmp(surface_data.group(i).type,'v')
		Boundary_Nodes(surface_data.group(i).surface_node_numbers) = surface_data.group(i).partner_nodes;
	else
		Boundary_Nodes(surface_data.group(i).surface_node_numbers) = 0;
	end
end

% Save
save(gird_file,'Boundary_Nodes');

set(Handles.title,'string','All done!');

% Close dlgbox
close(Handles.dlgbox);