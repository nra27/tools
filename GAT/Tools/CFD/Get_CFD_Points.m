function coordinates = Get_CFD_Points(struct,varargin);
%
% coordinates = Get_CFD_Points(struct)
% A function to return a 144x8 array of coordinates
% crossing the casing of a CFD solution for use in
% Open_VisualG

% Setup x-values
le_x = 0.05358028;
te_x = 0.075901888;
c_ax = te_x-le_x;
pers = [-20 -8 7 21 35 50 64 79];
ax = le_x+pers/100*c_ax;

if nargin > 1
    icasing = varargin{1};
else
    % Find the correct boundary groups
    for i = 1:length(struct.surface)
        if strcmp(struct.surface_names{i},'Casing')
            icasing = i;
            break
        end
    end
end

ncasing = length(struct.surface(icasing).nodes);

% Build boundary node lists
CU = [];
CL = [];
count = 0;
icount = 0;
for node = 1:ncasing
    if count > ncasing/100;
        count = 0;
        icount = icount+1;
        disp(icount);
    end
    rot = struct.coordinates.data(struct.surface(icasing).nodes,5)-struct.coordinates.data(struct.surface(icasing).nodes(node),5);
    delx = abs(struct.coordinates.data(struct.surface(icasing).nodes,1)-struct.coordinates.data(struct.surface(icasing).nodes(node),1));
    i_per = find(rot < 6.02/180*pi & rot > 5.98/180*pi & delx < 1e-6);
    if ~isempty(i_per)
        CU(end+1) = struct.surface(icasing).nodes(i_per);
        CL(end+1) = struct.surface(icasing).nodes(node);
    end
    count = count+1;
end

% Find intersection points
for i = 1:8
    l_nodes = CL(Find_Nearest_Node(ax(i),struct.coordinates.data(CL,1),2));
    u_nodes = CU(Find_Nearest_Node(ax(i),struct.coordinates.data(CU,1),2));
    l_x = struct.coordinates.data(l_nodes,1);
    l_theta = struct.coordinates.data(l_nodes,5);
    u_x = struct.coordinates.data(u_nodes,1);
    u_theta = struct.coordinates.data(u_nodes,5);
    
    l_T(i) = l_theta(1)+(l_theta(2)-l_theta(1))*(ax(i)-l_x(1))/(l_x(2)-l_x(1));
    u_T(i) = u_theta(1)+(u_theta(2)-u_theta(1))*(ax(i)-u_x(1))/(u_x(2)-u_x(1));
end

% Check for order, we want to go clockwise, ie from most positive Theta first
for i = 1:8
    coordinates(:,1,i) = ones(145,1)*ax(i);
    if u_T(i) > l_T(i)
        coordinates(:,2,i) = linspace(u_T(i),l_T(i),145);
    else
        coordinates(:,2,i) = linspace(l_T(i),u_T(i),145);
    end
end

coordinates = coordinates(2:end,:,:);
