function average = Surface_Circumferential_Average(a,surface_data,flow_data,variable,surface);
%
% data = Surface_Circumferential_Average(a,surface_data,flow_data,variable,surface)
%
% A function to get the circumferential average at a given axial location.

% First of all convert flow data to r-theta
[M,N] = size(flow_data.coordinates);
if N == 3
	flow_data = Set_to_RTheta(flow_data);
end

flow_index = 0;

% Set for flow variable
number_of_flow_variables = length(flow_data.data_type);
for i = 1:number_of_flow_variables
	if strcmp(flow_data.data_type{i},variable)
		flow_index = i;
	end
end

% Set for surface group
number_of_surface_groups = length(surface_data.surface_groups);
for i = 1:number_of_surface_groups
	if strcmp(surface_data.surface_groups{i},surface)
		surface_index = i;
	end
end

flow_coordinates = flow_data.coordinates(surface_data.group(surface_index).flow_node_numbers,:);

% Next get indecies for radial slice
X_Big = a+0.5e-3;
X_Lil = a-0.5e-3;

Bigger = flow_coordinates(:,1) > X_Lil;
Smaller = flow_coordinates(:,1) < X_Big;

Slice = find(Bigger.*Smaller);

% Get the data for the circumferentail slice
data.coordinates = flow_coordinates(Slice,:);
Min_Theta = min(data.coordinates(:,5));
Max_Theta = max(data.coordinates(:,5));
r = mean(data.coordinates(:,4));

% Compose the theta array for search and convert to y,z
theta = linspace(Min_Theta,Max_Theta,20);
y = r*cos(theta);
z = r*sin(theta);

for i = 1:20
	index(i) = Find_Nearest_Node(a,y(i),z(i),flow_coordinates(:,1),flow_coordinates(:,2),flow_coordinates(:,3));
end

if flow_index ~= 0
	points = flow_data.flow(surface_data.group(surface_index).flow_node_numbers(index),flow_index);
else
	points = surface_data.group(surface_index).wall_heat_flux(index);
end

average = mean(points);