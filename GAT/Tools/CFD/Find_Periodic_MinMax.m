function [min_theta,max_theta] = Find_Periodic_MinMax(x,r,surface_data,flow_data);
%
% [min_theta,max_theta] = Find_Periodic_MinMax(surface_data,flow_data,x,r)
%
% A function to return the minimum and maximum values of theta in a domain,
% for a given axial and radial position.

number_of_surface_groups = length(surface_data.surface_groups);

% Get group number for periodic surfaces
for i = 1:number_of_surface_groups
	if strcmp(surface_data.group(i).type,'u')
		upper.index = i;
	elseif strcmp(surface_data.group(i).type,'l')
		lower.index = i;
	end
end

% Get periodic group coordinates
upper.coordinates = flow_data.coordinates(surface_data.group(upper.index).surface_node_numbers,:);
lower.coordinates = flow_data.coordinates(surface_data.group(lower.index).surface_node_numbers,:);

% Get theta values
upper.theta = Find_Missing_Coordinate(x,r,upper.coordinates(:,1),upper.coordinates(:,4),upper.coordinates(:,5));
lower.theta = Find_Missing_Coordinate(x,r,lower.coordinates(:,1),lower.coordinates(:,4),lower.coordinates(:,5));

% Sort theta values
min_theta = min(upper.theta,lower.theta);
max_theta = max(upper.theta,lower.theta);