function struct = Open_VisualG(gridfile,flowfile);
%
% struct = Open_VisualG(gridfile,flowfile)
%
% A function to open the required files and return an array suitable for
% use with VisualG.

% Set up ADF space
D = ADFI_Declarations;
[D,error_return] = ADF_Set_Error_State(1,D);

% Open files
[D,grid.ID,error_return] = ADF_Database_Open(gridfile,'READ_ONLY','NATIVE',D);
[D,flow.ID,error_return] = ADF_Database_Open(flowfile,'READ_ONLY','NATIVE',D);

% Check the element types in the mesh
[D,struct.element_types,struct.bnd_element_types,error_return] = Catalogue_Elements(grid.ID,D);

% Read in Element-->Node pointers
if ~isempty(findstr(struct.element_types,'h'))
    [D,hex.ID,error_return] = ADF_Get_Node_ID(grid.ID,'hex-->node',D);
    [D,hex.n_dims,error_return] = ADF_Get_Dimension_Values(hex.ID,D);
    [D,struct.hex.node,error_return] = ADF_Read_All_Data(hex.ID,D);
    struct.hex.node = Strip_to_Array(struct.hex.node,hex.n_dims(1));
end
if ~isempty(findstr(struct.element_types,'p'))
    [D,pri.ID,error_return] = ADF_Get_Node_ID(grid.ID,'pri-->node',D);
    [D,pri.n_dims,error_return] = ADF_Get_Dimension_Values(pri.ID,D);
    [D,struct.pri.node,error_return] = ADF_Read_All_Data(pri.ID,D);
    struct.pri.node = Strip_to_Array(struct.pri.node,pri.n_dims(1));
end
if ~isempty(findstr(struct.element_types,'s'))
    [D,pyr.ID,error_return] = ADF_Get_Node_ID(grid.ID,'pyr-->node',D);
    [D,pyr.n_dims,error_return] = ADF_Get_Dimension_Values(pyr.ID,D);
    [D,struct.pyr.node,error_return] = ADF_Read_All_Data(pyr.ID,D);
    struct.pyr.node = Strip_to_Array(struct.pyr.node,pyr.n_dims(1));
end
if ~isempty(findstr(struct.element_types,'t'))
    [D,tet.ID,error_return] = ADF_Get_Node_ID(grid.ID,'tet-->node',D);
    [D,tet.n_dims,error_return] = ADF_Get_Dimension_Values(tet.ID,D);
    [D,struct.tet.node,error_return] = ADF_Read_All_Data(tet.ID,D);
    struct.tet.node = Strip_to_Array(struct.tet.node,tet.n_dims(1));
end

% Read in edges
[D,edges.ID,error_return] = ADF_Get_Node_ID(grid.ID,'edge-->node',D);
[D,edges.dims,error_return] = ADF_Get_Dimension_Values(edges.ID,D);
[D,struct.edges.data,error_return] = ADF_Read_All_Data(edges.ID,D);
struct.edges.data = Strip_to_Array(struct.edges.data,edges.dims(1));

% Read in flow solution
[D,variables.ID,error_return] = ADF_Get_Node_ID(flow.ID,'flow',D);
[D,variables.dims,error_return] = ADF_Get_Dimension_Values(variables.ID,D);
[D,struct.variables.data,error_return] = ADF_Read_All_Data(variables.ID,D);
struct.variables.data = Strip_to_Array(struct.variables.data,variables.dims(1));

% Read in heat transfer
[D,bnd_node_group.ID,error_return] = ADF_Get_Node_ID(grid.ID,'bnd_node-->group',D);
[D,bnd_node_group.data,error_return] = ADF_Read_All_Data(bnd_node_group.ID,D);
[D,bnd_node_node.ID,error_return] = ADF_Get_Node_ID(grid.ID,'bnd_node-->node',D);
[D,bnd_node_node.data,error_return] = ADF_Read_All_Data(bnd_node_node.ID,D);

[D,qdot.ID,error_return] = ADF_Get_Node_ID(flow.ID,'wall heat flux',D);
[D,qdot.dims,error_return] = ADF_Get_Dimension_Values(qdot.ID,D);
[D,qdot.data,error_return] = ADF_Read_All_Data(qdot.ID,D);

struct.variables.data(bnd_node_node.data,end+1) = qdot.data;

% Read in coordinates
[D,coordinates.ID,error_return] = ADF_Get_Node_ID(grid.ID,'node_coordinates',D);
[D,coordinates.dims,error_return] = ADF_Get_Dimension_Values(coordinates.ID,D);
[D,struct.coordinates.data,error_return] = ADF_Read_All_Data(coordinates.ID,D);
struct.coordinates.data = Strip_to_Array(struct.coordinates.data,coordinates.dims(1));

% Set to R-theta
%struct.coordinates.data(:,4) = sqrt(struct.coordinates.data(:,2).^2+struct.coordinates.data(:,3).^2);
%struct.coordinates.data(:,5) = atan2(struct.coordinates.data(:,3),struct.coordinates.data(:,2));

% Read in surfaces
[D,surface_groups.ID,error_return] = ADF_Get_Node_ID(grid.ID,'surface_groups',D);
[D,surface_groups.dims,error_return] = ADF_Get_Dimension_Values(surface_groups.ID,D);
[D,surface_groups.data,error_return] = ADF_Read_All_Data(surface_groups.ID,D);

surface_groups.data = Strip_to_Array(surface_groups.data,surface_groups.dims(1));
surface_groups.data = char(surface_groups.data);

for i = 1:surface_groups.dims(2)
    j = 1;
    while ~strcmp(surface_groups.data(i,j),' ')
        name(j) = surface_groups.data(i,j);
        j = j+1;
    end
    while strcmp(surface_groups.data(i,j),' ');
        j = j+1;
    end
    struct.surface_names{i} = name;
    struct.surface(i).type = surface_groups.data(i,j);
    clear name
end

if ~isempty(findstr(struct.bnd_element_types,'t')) 
    [D,bnd_tri_group.ID,error_return] = ADF_Get_Node_ID(grid.ID,'bnd_tri-->group',D);
    [D,bnd_tri_group.data,error_return] = ADF_Read_All_Data(bnd_tri_group.ID,D);
    [D,bnd_tri_nodes.ID,error_return] = ADF_Get_Node_ID(grid.ID,'bnd_tri-->node',D);
    [D,bnd_tri_nodes.data,error_return] = ADF_Read_All_Data(bnd_tri_nodes.ID,D);
    bnd_tri_nodes.data = Strip_to_Array(bnd_tri_nodes.data,3);
end

if ~isempty(findstr(struct.bnd_element_types,'q')) 
    [D,bnd_quad_group.ID,error_return] = ADF_Get_Node_ID(grid.ID,'bnd_quad-->group',D);
    [D,bnd_quad_group.data,error_return] = ADF_Read_All_Data(bnd_quad_group.ID,D);
    [D,bnd_quad_nodes.ID,error_return] = ADF_Get_Node_ID(grid.ID,'bnd_quad-->node',D);
    [D,bnd_quad_nodes.data,error_return] = ADF_Read_All_Data(bnd_quad_nodes.ID,D);
    bnd_quad_nodes.data = Strip_to_Array(bnd_quad_nodes.data,4);
end

for i = 1:surface_groups.dims(2)
    struct.surface(i).nodes = bnd_node_node.data(find(bnd_node_group.data == i));
    if ~isempty(findstr(struct.bnd_element_types,'t')) 
        struct.surface(i).tri = bnd_tri_nodes.data(find(bnd_tri_group.data == i),:);
    end
    if ~isempty(findstr(struct.bnd_element_types,'q'))
        struct.surface(i).quad = bnd_quad_nodes.data(find(bnd_quad_group.data == i),:);
    end
end

% Close files
[D,error_return] = ADF_Database_Close(grid.ID,D);
[D,error_return] = ADF_Database_Close(flow.ID,D);
clear D
pack

% Calcuate Non-dimensionals
rho_ref = 1.226;
p_ref = 101300;
u_ref = sqrt(p_ref/rho_ref);
q_ref = p_ref^1.5/rho_ref^0.5;

struct.variables.data(:,1) = struct.variables.data(:,1)*rho_ref;
struct.variables.data(:,2:4) = struct.variables.data(:,2:4)*u_ref;
struct.variables.data(:,5) = struct.variables.data(:,5)*p_ref;
struct.variables.data(:,end) = struct.variables.data(:,end)*q_ref;