function Data = Get_ADF_1D_Surface_Data(surface_data,flow_data,coordinates,data_type,surface_group);
%
% Data = Get_ADF_1D_Surface_Data(grid_file,flow_file,coordinates,data_type,surface_group);
% A function to find the nearest data to the coordinates given.

number_of_flow_variables = length(flow_data.data_type);
for i = 1:number_of_flow_variables
	if strcmp(flow_data.data_type{i},data_type)
		flow_index = i;
	end
end

number_of_surface_groups = length(surface_data.surface_groups);
for i = 1:number_of_surface_groups
	if strcmp(surface_data.surface_groups{i},surface_group)
		surface_index = i;
	end
end

flow_coordinates = flow_data.coordinates(surface_data.group(surface_index).flow_node_numbers,:);


[number_of_data_points,n] = size(coordinates);

for i = 1:number_of_data_points
	index(i) = Find_Nearest_Node(coordinates(i,1),coordinates(i,2),coordinates(i,3),flow_coordinates(:,1),flow_coordinates(:,2),flow_coordinates(:,3));
end

if strcmp(data_type,'wall heat flux')
	Data = surface_data.group(surface_index).wall_heat_flux(index);
else
	Data = flow_data.flow(surface_data.group(surface_index).flow_node_numbers(index),flow_index);
end