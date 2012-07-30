%
% function [nearest_node_number,dist] = FindNEAREST(probe,grid_data)
%
% Function to find the nearest node to a point probe
%
% Point probe must of the form [x,y,z]
%
% NRA 12-10-05
%

function [nearest_node] = FindNEAREST_red(probe,grid_data,red_index)

% Find vector
dist_vect = ((probe(1)-grid_data.coordinates(red_index,1)).^2 + (probe(2)-grid_data.coordinates(red_index,2)).^2 + (probe(3)-grid_data.coordinates(red_index,3)).^2);

% Find the nearest ADF node
temp_node = find(dist_vect == min(dist_vect));

nearest_node = red_index(temp_node);
