function output = VisualG(struct,parameters,input,varargin);
%
% output = VisualG(struct,parameters,input,[surface_group,plane])
% A function to return the value of the parameters specified in 'parameters'
% at the coordinates specified by 'input' by interpolation of a hydra solution
% If the number of parameters is n and the number of input points is m, then
% output will have dimensions nxm.
% Struct is the structure returned by Open_VisualG
% If surface_group and plane are defined, the value of the parameters at the
% at the specified point on the surface defined by 'surface_group' and projected
% onto the plane defined by 'plane' is given

% 3D interpolation
if nargin == 3 | nargin == 4
    
    % Check to see how coordinates have been specified
    if naragin == 4
        if strcmp(varargin{1},'xrt')
            temp = input;
            temp(:,3) = temp(:,3)*pi/180;
            input(:,2) = temp(:,2).*cos(temp(:,3));
            input(:,3) = temp(:,2).*sin(temp(:,3));
            clear temp;
        end
    end
    
    % Start of Interpolation ------------------------------------------------------------------------------------------------------
    [input_m,input_n] = size(input);
    
    % Loop over the coordinates needed
    for inputs = 1:input_m
        % Find the nearest node
        nearest_node = Find_Nearest_Node(input(inputs,1),input(inputs,2),input(inputs,3),struct.coordinates.data(:,1),struct.coordinates.data(:,2),struct.coordinates.data(:,3),1);
        found = 1;
        
        % Check if we have any hex elements
        for n = 1:length(nearest_node)
            if ~isempty(findstr(struct.element_types,'h')) & found
                target_cell = find(struct.hex.node' == nearest_node(n));
                target_cell = ceil(target_cell./8);
                if ~isempty(target_cell)
                    for i = 1:length(target_cell)
                        target = [input(inputs,1) input(inputs,2) input(inputs,3)];
                        % Sort nodes
                        nodes = [struct.hex.node(target_cell(i),:)' struct.coordinates.data(struct.hex.node(target_cell(i),:),:)];
                        order = Arrange_Nodes(nodes,struct.edges.data,'hex');
                        [output(inputs,:),bar] = Interpolate_Element(struct.coordinates.data(struct.hex.node(target_cell(i),order),:),struct.variables.data(struct.hex.node(target_cell(i),order),parameters),target,'hex');
                        if max(abs(bar)) <= 1
                            found = 0;
                            break
                        end
                    end
                end
            end
            
            % Check if we have any tet elemets
            if ~isempty(findstr(struct.element_types,'t')) & found
                target_cell = find(struct.tet.node' == nearest_node(n));
                target_cell = ceil(target_cell./4);
                if ~isempty(target_cell)
                    for i = 1:length(target_cell)
                        target = [input(inputs,1) input(inputs,2) input(inputs,3)];
                        [output(inputs,:),bar] = Interpolate_Element(struct.coordinates.data(struct.tet.node(target_cell(i),:),:),struct.variables.data(struct.tet.node(target_cell(i),:),parameters),target,'tet');
                        if max(bar) <= 1 & min(bar) >= 0
                            found = 0;
                            break
                        end
                    end
                end
            end
            
            % Check if we have any pri elemets
            if ~isempty(findstr(struct.element_types,'p')) & found
                target_cell = find(struct.pri.node' == nearest_node(n));
                target_cell = ceil(target_cell./6);
                if ~isempty(target_cell)
                    for i = 1:length(target_cell)
                        target = [input(inputs,1) input(inputs,2) input(inputs,3)];
                        % Sort nodes
                        nodes = [struct.pri.node(target_cell(i),:)' struct.coordinates.data(struct.pri.node(target_cell(i),:),:)];
                        order = Arrange_Nodes(nodes,struct.edges.data,'prism');
                        [output(inputs,:),bar] = Interpolate_Element(struct.coordinates.data(struct.pri.node(target_cell(i),order),:),struct.variables.data(struct.pri.node(target_cell(i),order),parameters),target,'prism');
                        if max(abs(bar(1:2))) <= 1 & bar(3) >=0 & bar(3)<=1
                            found = 0;
                            break
                        end
                    end
                end
            end
            
            % Check if we have any pyr elemets
            if ~isempty(findstr(struct.element_types,'s')) & found
                target_cell = find(struct.pyr.node' == nearest_node(n));
                target_cell = ceil(target_cell./5);
                if ~isempty(target_cell)
                    for i = 1:length(target_cell)
                        target = [input(inputs,1) input(inputs,2) input(inputs,3)];
                        % Sort nodes
                        nodes = [struct.pyr.node(:,target_cell(i)) struct.coordinates.data(struct.pyr.node(:,target_cell(i)),:)];
                        order = Arrange_Nodes(nodes,struct.edges.data,'piramid');
                        [output(inputs,:),bar] = Interpolate_Element(struct.coordinates.data(struct.pyr.node(target_cell(i),order),:),struct.variables.data(struct.pyr.node(target_cell(i),order),parameters),target,'piramid');
                        if max(bar) <= 1 & min(bar) >=0
                            found = 0;
                            break
                        end
                    end
                end
            end
        end
    end
    
% 2D surface interpolation
elseif nargin == 5

    surface_group = varargin{1};
    plane = varargin{2};
    
    % Setup plane
    if strcmp(plane,'xy')
        plane = [1 2];
    elseif strcmp(plane,'xz')
        plane = [1 3];
    elseif strcmp(plane,'yz')
        plane = [2 3];
    elseif strcmp(plane,'xr')
        plane = 1;
        radius = sqrt(struct.coordinates.data(struct.surface(surface_group).nodes,2).^2+struct.coordinates.data(struct.surface(surface_group).nodes,3).^2);
    else
        error('Unkown plane')
    end
    
    % Start of Interpolation ------------------------------------------------------------------------------------------------------
    [input_m,input_n] = size(input);
    
    % Loop over the coordinates needed
    for inputs = 1:input_m
        % Find the nearest node on the target surface
        if length(plane) == 2
            nearest_node = Find_Nearest_Node(input(inputs,1),input(inputs,2),struct.coordinates.data(struct.surface(surface_group).nodes,plane(1)),struct.coordinates.data(struct.surface(surface_group).nodes,plane(2)),1);
        else
            nearest_node = Find_Nearest_Node(input(inputs,1),input(inputs,2),struct.coordinates.data(struct.surface(surface_group).nodes,plane(1)),radius,1);
        nearest_node = struct.surface(surface_group).nodes(nearest_node); % Convert back to flow node numbers
        found = 1;
            
        % For each of the nodes
        for n = 1:length(nearest_node)
            % Check if we have any tri elemets
            if ~isempty(findstr(struct.bnd_element_types,'t')) & found
                target_cell = find(struct.surface(surface_group).tri' == nearest_node(n));
                target_cell = ceil(target_cell./3);
                if ~isempty(target_cell)
                    for i = 1:length(target_cell)
                        target = [input(inputs,1) input(inputs,2)];
                        [output(inputs,:),bar] = Interpolate_Element(struct.coordinates.data(struct.surface(surface_group).tri(target_cell(i),:),plane),struct.variables.data(struct.surface(surface_group).tri(target_cell(i),:),parameters),target,'tri');
                        if max(bar) <= 1 & min(bar) >= 0
                            found = 0;
                            break
                        end
                    end
                end
            end
        
            % Check if we have any quad elements
            if ~isempty(findstr(struct.bnd_element_types,'q')) & found
                target_cell = find(struct.surface(surface_group).quad' == nearest_node(n));
                target_cell = ceil(target_cell./4);
                if ~isempty(target_cell)
                    for i = 1:length(target_cell)
                        target = [input(inputs,1) input(inputs,2)];
                        % Sort nodes
                        nodes = [struct.surface(surface_group).quad(target_cell(i),:)' struct.coordinates.data(struct.surface(surface_group).quad(target_cell(i),:),:)];
                        order = Arrange_Nodes(nodes,struct.edges.data,'quad');
                        [output(inputs,:),bar] = Interpolate_Element(struct.coordinates.data(struct.surface(surface_group).quad(target_cell(i),order),:),struct.variables.data(struct.surface(surface_group).quad(target_cell(i),order),parameters),target,'quad');
                        if max(abs(bar)) <= 1
                            found = 0;
                            break
                        end
                    end
                end
            end    
        end
    end
% Don't know what this is!
else
    error('Incorrect number of input arguments');
end