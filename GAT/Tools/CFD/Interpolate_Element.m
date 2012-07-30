function [output,bar] = Interpolate_Element(coordinates,variable,target,element);
%
% [output,bar] = Interpolate_Element(coordinates,variable,element)
%
% Interpolate Element - A function to linearly interpolate a given function
% across a 2D or 3D-finite element.  This is done using Laplacian Shape Fuctions.
% 
% output - the value of the given variable at the target coordinates.
% coordinates - the coordinates of the element nodes (x,y,z).  Because piramids
%               and prisms only have one axis of symetry, some special formating
%               is required (see the relevant case for more detail).  On all other
%               elements, if formating is required it is checked.
% variable - the nodal variable values
% target - the target coordinates (x,y,z)
% element - the type of element; supported elemets are:
%           3-node triangle
%           4-node quadrilateral
%           4-node tetrahedron
%           5-node square based pyramid
%           6-node triangular prism
%           8-node hexadedron
% NB: If you are adding a new element type and the maping is non-linear, you will
% need to edit Map_Element.

% Turn off warnings
warning off

switch lower(element)
case {'triangle' 'tri'}
    % Calculate x_bar, y_bar for target coordinates 
    Real_World = [(target(1)-coordinates(1,1)); ...
                    (target(2)-coordinates(1,2))];
    
    Mapping_Matrix = [(coordinates(2,1)-coordinates(1,1)) (coordinates(3,1)-coordinates(1,1)); ...
                        (coordinates(2,2)-coordinates(1,2)) (coordinates(3,2)-coordinates(1,2))];
    
    % This is linear so just invert matrix
    bar = inv(Mapping_Matrix)*Real_World;
    
    % Setup shape functions
    N = zeros(1,3);
    N(1) = 1-bar(1)-bar(2);
    N(2) = bar(1);
    N(3) = bar(2);
    
    % Interpolate the variables
    [n_nodes,n_parameters] = size(variable);
    for p = 1:n_parameters
        output(p) = N*variable(:,p);
    end
    
case {'quadrilateral' 'quad'}
    % Sort the node-coordinate numbering to match our base element
    [sort_y,i_y] = sort(coordinates(:,2));
    order = zeros(1,4);
    % 1st node is the smaller x-value of the two smallest y-values
    [m,i] = min(coordinates(i_y(1:2),1));
    order(1) = i_y(i);
    % 2nd node is the larger x-value of the two smallest y-values
    [m,i] = max(coordinates(i_y(1:2),1));
    order(2) = i_y(i);
    % 3rd node is the larger x-value of the two largest y-values
    [m,i] = max(coordinates(i_y(3:4),1));
    order(3) = i_y(i+2);
    % 4th node is the smaller x-value of the two largest y-values
    [m,i] = min(coordinates(i_y(3:4),1));
    order(4) = i_y(i+2);
    
    coordinates = coordinates(order,:);
    variable = variable(order);
    
    % Calculate x_bar, y_bar for target coordinates    
    Real_World = [4*target(1)-sum(coordinates(:,1)); ...
                  4*target(2)-sum(coordinates(:,2))];
    
    Mapping_Matrix = [(coordinates(2,1)+coordinates(3,1)-coordinates(4,1)-coordinates(1,1)) ...
                        (coordinates(3,1)+coordinates(4,1)-coordinates(2,1)-coordinates(1,1)) ...
                        (coordinates(1,1)-coordinates(2,1)+coordinates(3,1)-coordinates(4,1)); ...
                      (coordinates(2,2)+coordinates(3,2)-coordinates(4,2)-coordinates(1,2)) ...
                        (coordinates(3,2)+coordinates(4,2)-coordinates(2,2)-coordinates(1,2)) ...
                        (coordinates(1,2)-coordinates(2,2)+coordinates(3,2)-coordinates(4,2))];
    
    % This is non-linear so solve approximately         
    bar = Map_Element(Real_World,Mapping_Matrix,'quad');
    
    % Setup shape functions
    N = zeros(1,4);
    N(1) = 0.25*(1-bar(1))*(1-bar(2));
    N(2) = 0.25*(1+bar(1))*(1-bar(2));
    N(3) = 0.25*(1+bar(1))*(1+bar(2));
    N(4) = 0.25*(1-bar(1))*(1+bar(2));
    
    % Interpolate the variables
    [n_nodes,n_parameters] = size(variable);
    for p = 1:n_parameters
        output(p) = N*variable(:,p);
    end

case {'tetrahedron' 'tet'}
    % Calculate x_bar, y_bar and z_bar for target coordinates 
    Real_World = [(target(1)-coordinates(1,1)); ...
                    (target(2)-coordinates(1,2)); ...
                    (target(3)-coordinates(1,3))];
    
    Mapping_Matrix = [(coordinates(2,1)-coordinates(1,1)) (coordinates(3,1)-coordinates(1,1)) (coordinates(4,1)-coordinates(1,1)); ...
                      (coordinates(2,2)-coordinates(1,2)) (coordinates(3,2)-coordinates(1,2)) (coordinates(4,2)-coordinates(1,2)); ...
                      (coordinates(2,3)-coordinates(1,3)) (coordinates(3,3)-coordinates(1,3)) (coordinates(4,3)-coordinates(1,3))];
    
    % This is linear so just invert the matrix          
    bar = inv(Mapping_Matrix)*Real_World;
    
    % Setup shape functions
    N = zeros(1,4);
    N(1) = 1-bar(1)-bar(2)-bar(3);
    N(2) = bar(1);
    N(3) = bar(2);
    N(4) = bar(3);
    
    % Interpolate the variables
    [n_nodes,n_parameters] = size(variable);
    for p = 1:n_parameters
        output(p) = N*variable(:,p);
    end
    
case 'piramid'
    % Sort the node-coordinate numbering to match our base element
    % The 'point' of the pyramid is assumed to be in position 5 in the
    % coordinate vector.
       
    % Calculate x_bar, y_bar and z_bar for target coordinates
    Real_World = [4*target(1)-sum(coordinates(1:4,1)); ...
                  4*target(2)-sum(coordinates(1:4,2)); ...
                  4*target(3)-sum(coordinates(1:4,3))];
          
    Mapping_Matrix = [(-coordinates(1,1)+coordinates(2,1)+coordinates(3,1)-coordinates(4,1)) (-coordinates(1,1)-coordinates(2,1)+coordinates(3,1)+coordinates(4,1)) ...
                        (-coordinates(1,1)-coordinates(2,1)-coordinates(3,1)-coordinates(4,1)+4*coordinates(5,1)) ...
                        (coordinates(1,1)-coordinates(2,1)+coordinates(3,1)-coordinates(4,1)) (coordinates(1,1)-coordinates(2,1)-coordinates(3,1)+coordinates(4,1)) ...
                        (coordinates(1,1)+coordinates(2,1)-coordinates(3,1)-coordinates(4,1)) (-coordinates(1,1)+coordinates(2,1)-coordinates(3,1)+coordinates(4,1)); ...
                      (-coordinates(1,2)+coordinates(2,2)+coordinates(3,2)-coordinates(4,2)) (-coordinates(1,2)-coordinates(2,2)+coordinates(3,2)+coordinates(4,2)) ...
                        (-coordinates(1,2)-coordinates(2,2)-coordinates(3,2)-coordinates(4,2)+4*coordinates(5,2)) ...
                        (coordinates(1,2)-coordinates(2,2)+coordinates(3,2)-coordinates(4,2)) (coordinates(1,2)-coordinates(2,2)-coordinates(3,2)+coordinates(4,2)) ...
                        (coordinates(1,2)+coordinates(2,2)-coordinates(3,2)-coordinates(4,2)) (-coordinates(1,2)+coordinates(2,2)-coordinates(3,2)+coordinates(4,2)); ...
                      (-coordinates(1,3)+coordinates(2,3)+coordinates(3,3)-coordinates(4,3)) (-coordinates(1,3)-coordinates(2,3)+coordinates(3,3)+coordinates(4,3)) ...
                        (-coordinates(1,3)-coordinates(2,3)-coordinates(3,3)-coordinates(4,3)+4*coordinates(5,3)) ...
                        (coordinates(1,3)-coordinates(2,3)+coordinates(3,3)-coordinates(4,3)) (coordinates(1,3)-coordinates(2,3)-coordinates(3,3)+coordinates(4,3)) ...
                        (coordinates(1,3)+coordinates(2,3)-coordinates(3,3)-coordinates(4,3)) (-coordinates(1,3)+coordinates(2,3)-coordinates(3,3)+coordinates(4,3))];
    
    % This is non-linear so solve approximately         
    bar = Map_Element(Real_World,Mapping_Matrix,'piramid');
    
    % Setup shape functions
    N = zeros(1,5);
    N(1) = 0.25*(1-bar(1))*(1-bar(2))*(1-bar(3));
    N(2) = 0.25*(1+bar(1))*(1-bar(2))*(1-bar(3));
    N(3) = 0.25*(1+bar(1))*(1+bar(2))*(1-bar(3));
    N(4) = 0.25*(1-bar(1))*(1+bar(2))*(1-bar(3));
    N(5) = bar(3);
    
    % Interpolate the variables
    [n_nodes,n_parameters] = size(variable);
    for p = 1:n_parameters
        output(p) = N*variable(:,p);
    end
    
case 'prism'
    % Sort the node-coordinate number to match our base element
    % The 'planes' of the prism are assumed to be in position 1:3
    % and 4:6 in the coordinate vector.
    
    % Calculate x_bar, y_bar and z_bar for target coordinates
    Real_World = [target(1)-coordinates(1,1); ...
                  target(2)-coordinates(1,2); ...
                  target(3)-coordinates(1,3)];
          
    Mapping_Matrix = [(-coordinates(1,1)+coordinates(2,1)) (-coordinates(1,1)+coordinates(3,1)) (-coordinates(1,1)+coordinates(4,1)) ...
                        (coordinates(1,1)-coordinates(2,1)-coordinates(4,1)+coordinates(5,1)) (coordinates(1,1)-coordinates(3,1)-coordinates(4,1)+coordinates(6,1)); ...
                      (-coordinates(1,2)+coordinates(2,2)) (-coordinates(1,2)+coordinates(3,2)) (-coordinates(1,2)+coordinates(4,2)) ...
                        (coordinates(1,2)-coordinates(2,2)-coordinates(4,2)+coordinates(5,2)) (coordinates(1,2)-coordinates(3,2)-coordinates(4,2)+coordinates(6,2)); ...
                      (-coordinates(1,3)+coordinates(2,3)) (-coordinates(1,3)+coordinates(3,3)) (-coordinates(1,3)+coordinates(4,3)) ...
                        (coordinates(1,3)-coordinates(2,3)-coordinates(4,3)+coordinates(5,3)) (coordinates(1,3)-coordinates(3,3)-coordinates(4,3)+coordinates(6,3))];
    
    % This is non-linear so solve approximately         
    bar = Map_Element(Real_World,Mapping_Matrix,'prism');
    
    % Setup shape functions
    N = zeros(1,6);
    N(1) = (1-bar(1)-bar(2))*(1-bar(3));
    N(2) = bar(1)*(1-bar(3));
    N(3) = bar(2)*(1-bar(3));
    N(4) = (1-bar(1)-bar(2))*bar(3);
    N(5) = bar(1)*bar(3);
    N(6) = bar(2)*bar(3);
    
    % Interpolate the variables
    [n_nodes,n_parameters] = size(variable);
    for p = 1:n_parameters
        output(p) = N*variable(:,p);
    end
                
case {'hexahedron' 'hex'}          
    % Calculate x_bar, y_bar and z_bar for target coordinates
    Real_World = [8*target(1)-sum(coordinates(:,1)); ...
                  8*target(2)-sum(coordinates(:,2)); ...
                  8*target(3)-sum(coordinates(:,3))];
          
    Mapping_Matrix = [(-coordinates(1,1)+coordinates(2,1)+coordinates(3,1)-coordinates(4,1)-coordinates(5,1)+coordinates(6,1)+coordinates(7,1)-coordinates(8,1)) ...
                        (-coordinates(1,1)-coordinates(2,1)+coordinates(3,1)+coordinates(4,1)-coordinates(5,1)-coordinates(6,1)+coordinates(7,1)+coordinates(8,1)) ...
                        (-coordinates(1,1)-coordinates(2,1)-coordinates(3,1)-coordinates(4,1)+coordinates(5,1)+coordinates(6,1)+coordinates(7,1)+coordinates(8,1)) ...
                        (coordinates(1,1)-coordinates(2,1)+coordinates(3,1)-coordinates(4,1)+coordinates(5,1)-coordinates(6,1)+coordinates(7,1)-coordinates(8,1)) ...
                        (coordinates(1,1)-coordinates(2,1)-coordinates(3,1)+coordinates(4,1)-coordinates(5,1)+coordinates(6,1)+coordinates(7,1)-coordinates(8,1)) ...
                        (coordinates(1,1)+coordinates(2,1)-coordinates(3,1)-coordinates(4,1)-coordinates(5,1)-coordinates(6,1)+coordinates(7,1)+coordinates(8,1)) ...
                        (-coordinates(1,1)+coordinates(2,1)-coordinates(3,1)+coordinates(4,1)+coordinates(5,1)-coordinates(6,1)+coordinates(7,1)-coordinates(8,1)); ...
                      (-coordinates(1,2)+coordinates(2,2)+coordinates(3,2)-coordinates(4,2)-coordinates(5,2)+coordinates(6,2)+coordinates(7,2)-coordinates(8,2)) ...
                        (-coordinates(1,2)-coordinates(2,2)+coordinates(3,2)+coordinates(4,2)-coordinates(5,2)-coordinates(6,2)+coordinates(7,2)+coordinates(8,2)) ...
                        (-coordinates(1,2)-coordinates(2,2)-coordinates(3,2)-coordinates(4,2)+coordinates(5,2)+coordinates(6,2)+coordinates(7,2)+coordinates(8,2)) ...
                        (coordinates(1,2)-coordinates(2,2)+coordinates(3,2)-coordinates(4,2)+coordinates(5,2)-coordinates(6,2)+coordinates(7,2)-coordinates(8,2)) ...
                        (coordinates(1,2)-coordinates(2,2)-coordinates(3,2)+coordinates(4,2)-coordinates(5,2)+coordinates(6,2)+coordinates(7,2)-coordinates(8,2)) ...
                        (coordinates(1,2)+coordinates(2,2)-coordinates(3,2)-coordinates(4,2)-coordinates(5,2)-coordinates(6,2)+coordinates(7,2)+coordinates(8,2)) ...
                        (-coordinates(1,2)+coordinates(2,2)-coordinates(3,2)+coordinates(4,2)+coordinates(5,2)-coordinates(6,2)+coordinates(7,2)-coordinates(8,2)); ...
                      (-coordinates(1,3)+coordinates(2,3)+coordinates(3,3)-coordinates(4,3)-coordinates(5,3)+coordinates(6,3)+coordinates(7,3)-coordinates(8,3)) ...
                        (-coordinates(1,3)-coordinates(2,3)+coordinates(3,3)+coordinates(4,3)-coordinates(5,3)-coordinates(6,3)+coordinates(7,3)+coordinates(8,3)) ...
                        (-coordinates(1,3)-coordinates(2,3)-coordinates(3,3)-coordinates(4,3)+coordinates(5,3)+coordinates(6,3)+coordinates(7,3)+coordinates(8,3)) ...
                        (coordinates(1,3)-coordinates(2,3)+coordinates(3,3)-coordinates(4,3)+coordinates(5,3)-coordinates(6,3)+coordinates(7,3)-coordinates(8,3)) ...
                        (coordinates(1,3)-coordinates(2,3)-coordinates(3,3)+coordinates(4,3)-coordinates(5,3)+coordinates(6,3)+coordinates(7,3)-coordinates(8,3)) ...
                        (coordinates(1,3)+coordinates(2,3)-coordinates(3,3)-coordinates(4,3)-coordinates(5,3)-coordinates(6,3)+coordinates(7,3)+coordinates(8,3)) ...
                        (-coordinates(1,3)+coordinates(2,3)-coordinates(3,3)+coordinates(4,3)+coordinates(5,3)-coordinates(6,3)+coordinates(7,3)-coordinates(8,3))];
                        
    % This is non-linear so solve approximately         
    bar = Map_Element(Real_World,Mapping_Matrix,'hex');
    
    % Setup shape functions
    N = zeros(1,8);
    N(1) = 0.125*(1-bar(1))*(1-bar(2))*(1-bar(3));
    N(2) = 0.125*(1+bar(1))*(1-bar(2))*(1-bar(3));
    N(3) = 0.125*(1+bar(1))*(1+bar(2))*(1-bar(3));
    N(4) = 0.125*(1-bar(1))*(1+bar(2))*(1-bar(3));
    N(5) = 0.125*(1-bar(1))*(1-bar(2))*(1+bar(3));
    N(6) = 0.125*(1+bar(1))*(1-bar(2))*(1+bar(3));
    N(7) = 0.125*(1+bar(1))*(1+bar(2))*(1+bar(3));
    N(8) = 0.125*(1-bar(1))*(1+bar(2))*(1+bar(3));
    
    % Interpolate the variables
    [n_nodes,n_parameters] = size(variable);
    for p = 1:n_parameters
        output(p) = N*variable(:,p);
    end
    
otherwise
    error('This is not a supported element');
end

% Warning on
warning on