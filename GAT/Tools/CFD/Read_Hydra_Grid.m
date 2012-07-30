function mesh = Read_Hydra_Grid(filename);
%
% mesh = Read_Hydra_Grid(filename)
% A function to read a Hydra grid and convert to Fluent format

% Open dialogue box
Handles.dlgbox = figure('units','points','position',[40 40 200 70],'windowstyle','normal',...
        'name','Read HYDRA ADF Data','buttondownfcn',[],'visible','on','resize','off',...
        'menubar','none','colormap',[],'numbertitle','off','doublebuffer','on','Tag','nozoom');
Handles.axes = axes('position',[0.1 0.35 0.8 0.2],'box','on','xtick',[],'ytick',[],'xlim',[0 1],'ylim',[0 1]);
Handles.line = line([-1 -1],[0.5 0.5]);
set(Handles.line,'color','b','linewidth',14);
set(Handles.line,'xdata',[0 1]);

Handles.title = title('Reading ADF File');
set(Handles.line,'xdata',[0 1]);
drawnow;

% Set up ADF workspace
D = ADFI_Declarations;
[D,error_return] = ADF_Set_Error_State(1,D);

% Open grid file
[D,grid.root,error_return] = ADF_Database_Open(filename,'READ_ONLY','NATIVE',D);

% Read dimension
[D,grid.dimension,error_return] = ADF_Get_Node_ID(grid.root,'dimension',D);
[D,mesh.dimension,error_return] = ADF_Read_All_Data(grid.dimension,D);

% Sort grid types
[D,grid.n_children,error_return] = ADF_Number_of_Children(grid.root,D);
[D,grid.n_children,grid.children,error_return] = ADF_Children_Names(grid.root,1,grid.n_children,D.ADF_Label_Length,D);

temp = ' ';

for i = 1:grid.n_children
    if ~isempty(findstr(grid.children{i},'hex-->node'))
        temp(end+1) = 'h';
    elseif ~isempty(findstr(grid.children{i},'pri-->node'))
        temp(end+1) = 'p';
    elseif ~isempty(findstr(grid.children{i},'pyr-->node'))
        temp(end+1) = 's';
    elseif ~isempty(findstr(grid.children{i},'tet-->node'))
        temp(end+1) = 't';
    end
end

% Arrange cell order to match fluent
mesh.cell_types = ' ';
if ~isempty(findstr(temp,'p'))
    mesh.cell_types(end+1) = 'p';
end
if ~isempty(findstr(temp,'h'))
    mesh.cell_types(end+1) = 'h';
end
if ~isempty(findstr(temp,'s'))
    mesh.cell_types(end+1) = 's';
end
if ~isempty(findstr(temp,'t'))
    mesh.cell_types(end+1) = 't';
end
clear temp

% Read node coordinates
[D,grid.coordinates,error_return] = ADF_Get_Node_ID(grid.root,'node_coordinates',D);
[D,data,error_return] = ADF_Read_All_Data(grid.coordinates,D);
[D,dims,error_return] = ADF_Get_Dimension_Values(grid.coordinates,D);
mesh.coordinates = Strip_to_Array(data,dims(1));
mesh.n_nodes = dims(2);

mesh.n_cells = 0;
% Read cell data
if ~isempty(findstr(mesh.cell_types,'h'))
    [D,grid.hex,error_return] = ADF_Get_Node_ID(grid.root,'hex-->node',D);
    [D,data,error_return] = ADF_Read_All_Data(grid.hex,D);
    [D,dims,error_return] = ADF_Get_Dimension_Values(grid.hex,D);
    mesh.hex.n_cells = dims(2);
    mesh.n_cells = mesh.n_cells+mesh.hex.n_cells;
    mesh.hex.nodes = Strip_to_Array(data,dims(1));
end
if ~isempty(findstr(mesh.cell_types,'p'))
    [D,grid.pri,error_return] = ADF_Get_Node_ID(grid.root,'pri-->node',D);
    [D,data,error_return] = ADF_Read_All_Data(grid.pri,D);
    [D,dims,error_return] = ADF_Get_Dimension_Values(grid.pri,D);
    mesh.pri.n_cells = dims(2);
    mesh.n_cells = mesh.n_cells+mesh.pri.n_cells;
    mesh.pri.nodes = Strip_to_Array(data,dims(1));
end
if ~isempty(findstr(mesh.cell_types,'t'))
    [D,grid.tet,error_return] = ADF_Get_Node_ID(grid.root,'tet-->node',D);
    [D,data,error_return] = ADF_Read_All_Data(grid.tet,D);
    [D,dims,error_return] = ADF_Get_Dimension_Values(grid.tet,D);
    mesh.tet.n_cells = dims(2);
    mesh.n_cells = mesh.n_cells+mesh.tet.n_cells;
    mesh.tet.nodes = Strip_to_Array(data,dims(1));
end
if ~isempty(findstr(mesh.cell_types,'s'))
    [D,grid.pyr,error_return] = ADF_Get_Node_ID(grid.root,'pyr-->node',D);
    [D,data,error_return] = ADF_Read_All_Data(grid.pyr,D);
    [D,dims,error_return] = ADF_Get_Dimension_Values(grid.pyr,D);
    mesh.pyr.n_cells = dims(2);
    mesh.n_cells = mesh.n_cells+mesh.pyr.n_cells;
    mesh.pyr.nodes = Strip_to_Array(data,dims(1));
end

% Build face list.  This is will take a while.  For each cell, give each face a
% unique identifier, using the normal numbering
icell = 0;
elements = [];

if strcmp(mesh.cell_types,' h')
    order = {'hex'};
elseif strcmp(mesh.cell_types,' p')
    order = {'pri'};
elseif strcmp(mesh.cell_types,' s')
    order = {'pyr'};
elseif strcmp(mesh.cell_types,' t')
    order = {'tet'};
elseif strcmp(mesh.cell_types,' ph')
    order = {'pri','hex'};
elseif strcmp(mesh.cell_types,' st')
    order = {'pyr','tet'};
elseif strcmp(mesh.cell_types,' phst')
    order = {'hex','pri','pyr','tet'};
    mesh.cell_types = ' hpst';
end

for i = 1:length(order)
    switch order{i}
        % Do hex elements
    case 'hex'
        set(Handles.title,'string','Sorting Hex Elements');
        set(Handles.line,'xdata',[0 0]);
        drawnow;
        fluent_nodes = [1 2 3 4 7 8 5 6];
        fluent_faces = [4 3 2 1;3 4 6 5;4 1 7 6;2 3 5 8;1 2 8 7;7 8 5 6];
        for i = 1:mesh.hex.n_cells
            set(Handles.line,'xdata',[0 i/mesh.hex.n_cells]);
            drawnow
            icell = icell+1;
            cell_nodes = mesh.hex.nodes(i,fluent_nodes);
            for j = 1:6 % For each face
                face = cell_nodes(fluent_faces(j,:));
                % Check to see if we've been here already
                check = Check_Elements(elements,face,'q');
                if check == 0% If we haven't
                    elements(end+1,1:4) = face;
                    elements(end,6) = icell;
                else
                    if elements(check,5) == 0
                        elements(check,5) = icell;
                    else
                        elements(check,6) = icell;
                    end
                end
            end
        end
        
        % Do prisms
    case 'pri'
        set(Handles.title,'string','Sorting Pri Elements');
        set(Handles.line,'xdata',[0 0]);
        drawnow;
        fluent_nodes = [1 6 4 5 2 3];
        fluent_faces = [3 2 1 0;6 5 4 0;4 2 3 6;5 1 2 4;6 3 1 5];
        for i = 1:mesh.pri.n_cells
            set(Handles.line,'xdata',[0 i/mesh.pri.n_cells]);
            drawnow
            icell = icell+1;
            cell_nodes = mesh.pri.nodes(i,fluent_nodes);
            for j = 1:2 % For each face
                face = cell_nodes(fluent_faces(j,1:3));
                % Check to see if we've been here already
                check = Check_Elements(elements,face,'t');
                if check == 0% If we haven't
                    elements(end+1,1:3) = face;
                    elements(end,5) = icell;
                else
                    if elements(check,6) == 0
                        elements(check,6) = icell;
                    else
                        elements(check,5) = icell;
                    end
                end
            end
            for j = 3:5 % For each face
                face = cell_nodes(fluent_faces(j,:));
                % Check to see if we've been here already
                check = Check_Elements(elements,face,'q');
                if check == 0% If we haven't
                    elements(end+1,1:4) = face;
                    elements(end,5) = icell;
                else
                    if elements(check,6) == 0
                        elements(check,6) = icell;
                    else
                        elements(check,5) = icell;
                    end
                end
            end
        end
        
        % And now pyramids
    case 'pyr'
        set(Handles.title,'string','Sorting Pyr Elements');
        set(Handles.line,'xdata',[0 0]);
        drawnow;
        fluent_nodes = [1 2 3 4 5];
        fluent_faces = [4 3 2 1;5 4 3 0;3 5 2 0;2 5 1 0;1 5 4 0];
        for i = 1:mesh.pyr.n_cells
            set(Handles.line,'xdata',[0 i/mesh.pyr.n_cells]);
            drawnow
            icell = icell+1;
            cell_nodes = mesh.pyr.nodes(i,fluent_nodes);
            for j = 1 % For each face
                face = cell_nodes(fluent_faces(j,:));
                % Check to see if we've been here already
                check = Check_Elements(elements,face,'q');
                if check == 0% If we haven't
                    elements(end+1,1:4) = face;
                    elements(end,6) = icell;
                else
                    if elements(check,5) == 0
                        elements(check,5) = icell;
                    else
                        elements(check,6) = icell;
                    end
                end
            end
            for j = 2:5 % For each face
                face = cell_nodes(fluent_faces(j,1:3));
                % Check to see if we've been here already
                check = Check_Elements(elements,face,'t');
                if check == 0% If we haven't
                    elements(end+1,1:3) = face;
                    elements(end,6) = icell;
                else
                    if elements(check,5) == 0
                        elements(check,5) = icell;
                    else
                        elements(check,6) = icell;
                    end
                end
            end
        end
        
        
        % Lastly tets
    case 'tet'
        set(Handles.title,'string','Sorting Pyr Elements');
        set(Handles.line,'xdata',[0 0]);
        drawnow;
        fluent_nodes = [1 3 2 4];
        fluent_faces = [3 2 4 0;4 1 3 0;2 1 4 0;3 1 2 0];
        for i = 1:mesh.tet.n_cells
            set(Handles.line,'xdata',[0 i/mesh.tet.n_cells]);
            drawnow
            icell = icell+1;
            cell_nodes = mesh.tet.nodes(i,fluent_nodes);
            for j = 1:4 % For each face
                face = cell_nodes(fluent_faces(j,1:3));
                % Check to see if we've been here already
                check = Check_Elements(elements,face,'t');
                if check == 0% If we haven't
                    elements(end+1,1:3) = face;
                    elements(end,5) = icell;
                else
                    if elements(check,6) == 0
                        elements(check,6) = icell;
                    else
                        elements(check,5) = icell;
                    end
                end
            end
        end
    end
end

% Total number of faces
[mesh.n_faces i] = size(elements);

% Read faces
[D,grid.bnd_groups,error_return] = ADF_Get_Node_ID(grid.root,'surface_groups',D);
[D,data,error_return] = ADF_Read_All_Data(grid.bnd_groups,D);
[D,dims,error_return] = ADF_Get_Dimension_Values(grid.bnd_groups,D);
data = Strip_to_Array(data,dims(1));
data = char(data);

for i = 1:dims(2)
    j = 1;
    % Extract face tag
    while ~strcmp(data(i,j),' ')
        name(j) = data(i,j);
        j = j+1;
    end
    % Extract face identifier
    while strcmp(data(i,j),' ');
        j = j+1;
    end
    % Write to mesh
    mesh.group(i).face_tag = name;
    if strcmpi(data(i,j),'v')
        mesh.group(i).face_type = 3;
        mesh.group(i).face_name = 'wall';
    elseif strcmpi(data(i,j),'I')
        mesh.group(i).face_type = 4;
        mesh.group(i).face_name = 'pressure-inlet';
    elseif strcmpi(data(i,j),'O')
        mesh.group(i).face_type = 5;
        mesh.group(i).face_name = 'pressure-outlet';
    elseif strcmpi(data(i,j),'l')
        mesh.group(i).face_type = 8;
        mesh.group(i).face_name = 'shadow';
        mesh.periodic.stats(4) = i;
    elseif strcmpi(data(i,j),'u')
        mesh.group(i).face_type = 12;
        mesh.group(i).face_name = 'periodic';
        mesh.periodic.stats(3) = i;
    else
        error('This boundary type is not supported');
    end
    clear name;
end

% Create surface face connectivity
[D,grid.bnd_quad_group,error_return] = ADF_Get_Node_ID(grid.root,'bnd_quad-->group',D);
[D,bnd_groups,error_return] = ADF_Read_All_Data(grid.bnd_quad_group,D);
[D,grid.bnd_quad_nodes,error_return] = ADF_Get_Node_ID(grid.root,'bnd_quad-->node',D);
[D,bnd_nodes,error_return] = ADF_Read_All_data(grid.bnd_quad_nodes,D);
bnd_nodes = Strip_to_Array(bnd_nodes,4);

% Close grid file
[D,error_return] = ADF_Database_Close(grid.root,D);

% Loop over surface groups
for igroup = 1:length(mesh.group)
    label = ['Sorting ' mesh.group(igroup).face_tag ' Connections'];
    for i = 1:length(label)
        if strcmp(label(i),'_')
            label(i) = ' ';
        end
    end
    set(Handles.title,'string',label);
    set(Handles.line,'xdata',[0 0]);
    drawnow;
    faces = find(bnd_groups == igroup);
    % Loop of faces in surface group
    mesh.group(igroup).element_type = zeros(length(faces),1);
    mesh.group(igroup).elements = zeros(length(faces),6);
    for i = 1:length(faces)
        % Check for type
        set(Handles.line,'xdata',[0 i/length(faces)]);
        drawnow;
        if bnd_nodes(faces(i),1) == bnd_nodes(faces(i),4)
            % This is a triangle!
            mesh.group(igroup).element_type(i) = 3;
            check = Check_Elements(elements,bnd_nodes(faces(i),1:3),'t');
            mesh.group(igroup).elements(i,:) = elements(check,:);
            elements = [elements(1:check-1,:);elements(check+1:end,:)];
        else
            % This is a quad!
            mesh.group(igroup).element_type(i) = 4;
            check = Check_Elements(elements,bnd_nodes(faces(i),:),'q');
            mesh.group(igroup).elements(i,:) = elements(check,:);
            elements = [elements(1:check-1,:);elements(check+1:end,:)];
        end
    end
    mesh.group(igroup).n_elements = length(faces);
end

% Create interior group
mesh.group(end+1).face_type = 2;
mesh.group(end).face_name = 'interior';
mesh.group(end).face_tag = 'default-interior';
tri = elements(:,4) == 0;
mesh.group(end).element_type = tri*3+(1-tri)*4;
mesh.group(end).elements = elements;
[mesh.group(end).n_elements i] = size(mesh.group(end).elements);

% Create periodic match
for i = 1:(mesh.periodic.stats(3)-1)
    mesh.periodic.stats(1) = mesh.periodic.stats(1)+mesh.group(i).n_elements;
end
mesh.periodic.stats(1:2) = [mesh.periodic.stats(1)+1 mesh.periodic.stats(1)+mesh.group(i+1).n_elements];
mesh.periodic.faces = [mesh.periodic.stats(1):mesh.periodic.stats(2)]';

count = 0;
for i = 1:(mesh.periodic.stats(4)-1)
    count = count+mesh.group(i).n_elements;
end
mesh.periodic.faces(:,2) = [(count+1):(count+mesh.group(mesh.periodic.stats(4)).n_elements)]';

close(Handles.dlgbox);