%
% function [nearest_node_number,dist] = FindNEAREST(probe,grid_data)
%
% Function to find the nearest node to a point probe
%
% Point probe must of the form [x,y,z]
%
% NRA 12-10-05
%

function [nearest_node] = FindNEAREST(probe,grid_data)

% Find vector
dist_vect = ((probe(1)-grid_data.coordinates(:,1)).^2 + (probe(2)-grid_data.coordinates(:,2)).^2 + (probe(3)-grid_data.coordinates(:,3)).^2);

% Find the nearest ADF node
nearest_node = find(dist_vect == min(dist_vect));
