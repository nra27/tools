function Write_FieldView(varargin)
%
% Write_FieldView([format],[no_grid]);
% A function to translate from hydra to fieldview
% format can be either 'binary' or 'ASCII'
% If format is not defined, the defaults are:
%   ASCII for steady
%   binary for unsteady

% Non-dimensional values
rho_ref = 1.226;
p_ref = 101300;
u_ref = sqrt(p_ref/rho_ref);
q_ref = -p_ref^1.5/rho_ref^0.5;

% Node numbering transformations
mapping.hex.nodes = [1 2 4 3 5 6 8 7];
mapping.pri.nodes = [1 2 3 4 5 6];
mapping.pyr.nodes = [1 2 3 4 5];
mapping.tet.nodes = [1 2 3 4];

% Read input.dat
fid = fopen('input.dat','rt');
if fid == -1
    error('Cannot open input.dat');
end

for i = 1:4
    tline = fgetl(fid);
end

% Check to see if this is an unsteady solution
if findstr(tline,'unsteady')
    u_flag = 1; % Unsteady
    tline = fgetl(fid);
    n_grid = str2num(tline);
    n_grid = n_grid(1);
    tline = fgetl(fid);
    mesh_file = deblank(tline); % Read adf grid file name
    tline = fgetl(fid);
    tline = fgetl(fid);
    for i = 1:length(tline) % Read adf unsflow file name
        if ~strcmp(tline(i),' ')
            flow_file(i) = tline(i);
        else
            break
        end
    end
    tline = fgetl(fid);
    temp = sscanf(tline,'%d %f %d %d');
    n_files = temp(3)/temp(4);
    for i = 1:4
        tline = fgetl(fid);
    end
    tline = fgetl(fid);
    temp = sscanf(tline,'%f');
    n_zones = 1;
    gamma = temp(1);
    omega = temp(2);
    done = 0;
    while done == 0
        tline = fgetl(fid);
        temp = sscanf(tline,'%f');
        if temp(1) == 1
            done = 1;
        else
            n_zones = n_zones+1;
            gamma(n_zones) = temp(1);
            omega(n_zones) = temp(2);
        end
    end
else
    u_flag = 0; % Steady
    n_grid = str2num(tline);
    n_grid = n_grid(1);
    tline = fgetl(fid);
    mesh_file = deblank(tline); % Read adf grid file name
    for i = 1:n_grid
        tline = fgetl(fid);
    end
    flow_file = deblank(tline); % Read adf flow file name
    
    for i = 1:4
        tline = fgetl(fid);
    end
    
    % Read number of zones and get gamma/omega for each zone.
    tline = fgetl(fid);
    temp = sscanf(tline,'%f');
    n_zones = 1;
    gamma = temp(1);
    omega = temp(2);
    done = 0;
    while done == 0
        tline = fgetl(fid);
        temp = sscanf(tline,'%f');
        if temp(1) == 1
            done = 1;
        else
            n_zones = n_zones+1;
            gamma(n_zones) = temp(1);
            omega(n_zones) = temp(2);
        end
    end
end

% Close input.dat
fclose(fid);

% Extract file root
for i = 1:length(mesh_file)
    if ~strcmp(flow_file(i:i+4),'.flow')
        file_root(i) = flow_file(i);
    else
        break
    end
end

% Find out what the function calls were and set defaults
if nargin == 0
    if u_flag == 1 % Unsteady solution
        format = 'binary';
        g_flag = 1; % Write grid file
    elseif u_flag == 0 % Steady solution
        format = 'ascii';
        g_flag = 1;
    else
        error('Unknown solution class');
    end
end
if nargin == 1
    if strcmp(lower(varargin{1}),'binary')
        format = 'binary';
        g_flag = 1;
    elseif strcmp(lower(varargin{1}),'ascii')
        format = 'ascii';
        g_flag = 1;
    elseif strcmp(lower(varargin{1}),'no_grid')
        if u_flag == 1 % Unsteady solution
            format = 'binary';
            g_flag = 0; % Don't write grid file
        elseif u_flag == 0 % Steady solution
            format = 'ascii';
            g_flag = 1;
        end
    else
        error('Unknown function call');
    end
end
if nargin == 2
    format = varargin{1};
    if strcmp(lower(varargin{2}),'no_grid')
        g_flag = 0; % Don't write grid file
    else
        error('Unknown function call');
    end
end
    
% Branch depending on format
switch lower(format)
case 'ascii'
    if u_flag  % Unsteady solution
        % We will write the grid as one file and solutions as others
        
        % Set up ADF space 
        D = ADFI_Declarations;
        
        fprintf(1,'Reading Hydra grid file');
        % Open files for grid actions
        [D,mesh.ID,error_return] = ADF_Database_Open(mesh_file,'READ_ONLY','NATIVE',D);
        fprintf(1,'.');
        
        % Read the periodic angle
        [D,per_ang.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'periodic_angle',D);
        [D,per_ang.data,error_return] = ADF_Read_All_Data(per_ang.ID,D);
        fprintf(1,'.');
        
        % Check the element types in the mesh
        [D,mesh.element_types,mesh.bnd_element_types,error_return] = Catalogue_Elements(mesh.ID,D);
        fprintf(1,'.');
        
        % Read the surface groups
        [D,surface_groups.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'surface_groups',D);
        [D,surface_groups.dims,error_return] = ADF_Get_Dimension_Values(surface_groups.ID,D);
        [D,surface_groups.data,error_return] = ADF_Read_All_Data(surface_groups.ID,D);
        fprintf(1,'.');
        
        surface_groups.data = Strip_to_Array(surface_groups.data,surface_groups.dims(1));
        surface_groups.data = char(surface_groups.data);
        
        for i = 1:surface_groups.dims(2)
            j = 1;
            while ~strcmp(surface_groups.data(i,[j j+1]),'  ')
                name(j) = surface_groups.data(i,j);
                j = j+1;
            end
            while strcmp(surface_groups.data(i,j),' ');
                j = j+1;
            end
            surface(i).name = name;
            surface(i).type = surface_groups.data(i,j);
            clear name
        end
        
        % Read in node_coordinates
        [D,coordinates.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'node_coordinates',D);
        [D,coordinates.data,error_return] = ADF_Read_All_Data(coordinates.ID,D);
        [D,coordinates.dims,error_return] = ADF_Get_Dimension_Values(coordinates.ID,D);
        coordinates.data = Strip_to_Array(coordinates.data,3);
        fprintf(1,'.');
        
        % Read in node_zone pointers
        [D,node_zone.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'node-->zone',D);
        [D,node_zone.data,error_return] = ADF_Read_All_Data(node_zone.ID,D);
        [D,bnd_node_zone.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_node-->zone',D);
        [D,bnd_node_zone.data,error_return] = ADF_Read_All_Data(node_zone.ID,D);
        fprintf(1,'.');
        
        % Read in boundary node pointers
        [D,bnd_node_node.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_node-->node',D);
        [D,bnd_node_node.data,error_return] = ADF_Read_All_Data(bnd_node_node.ID,D);
        [D,bnd_node_group.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_node-->group',D);
        [D,bnd_node_group.data,error_return] = ADF_Read_All_Data(bnd_node_group.ID,D);  
        fprintf(1,'.');
        
        % Read in Element-->Node pointers
        if findstr(mesh.element_types,'h')
            [D,hex.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'hex-->node',D);
            [D,hex.dims,error_return] = ADF_Get_Dimension_Values(hex.ID,D);
            [D,hex.data,error_return] = ADF_Read_All_Data(hex.ID,D);
            hex.data = Strip_to_Array(hex.data,hex.dims(1));
            fprintf(1,'.');
        end
        if findstr(mesh.element_types,'p')
            [D,pri.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'pri-->node',D);
            [D,pri.dims,error_return] = ADF_Get_Dimension_Values(pri.ID,D);
            [D,pri.data,error_return] = ADF_Read_All_Data(pri.ID,D);
            pri.data = Strip_to_Array(pri.data,pri.dims(1));
            fprintf(1,'.');
        end
        if findstr(mesh.element_types,'s')
            [D,pyr.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'pyr-->node',D);
            [D,pyr.dims,error_return] = ADF_Get_Dimension_Values(pyr.ID,D);
            [D,pyr.data,error_return] = ADF_Read_All_Data(pyr.ID,D);
            pyr.data = Strip_to_Array(pyr.data,pyr.dims(1));
            fprintf(1,'.');
        end
        if findstr(mesh.element_types,'t')
            [D,tet.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'tet-->node',D);
            [D,tet.dims,error_return] = ADF_Get_Dimension_Values(tet.ID,D);
            [D,tet.data,error_return] = ADF_Read_All_Data(tet.ID,D);
            tet.data = Strip_to_Array(tet.data,tet.dims(1));
            fprintf(1,'.');
        end
        clear M N
        
        % Read in and sort surface elements
        if findstr(mesh.bnd_element_types,'t') 
            [D,bnd_tri_group.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_tri-->group',D);
            [D,bnd_tri_group.data,error_return] = ADF_Read_All_Data(bnd_tri_group.ID,D);
            [D,bnd_tri_nodes.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_tri-->node',D);
            [D,bnd_tri_nodes.data,error_return] = ADF_Read_All_Data(bnd_tri_nodes.ID,D);
            bnd_tri_nodes.data = Strip_to_Array(bnd_tri_nodes.data,3);
            fprintf(1,'.');
        end
        if findstr(mesh.bnd_element_types,'q') 
            [D,bnd_quad_group.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_quad-->group',D);
            [D,bnd_quad_group.data,error_return] = ADF_Read_All_Data(bnd_quad_group.ID,D);
            [D,bnd_quad_nodes.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_quad-->node',D);
            [D,bnd_quad_nodes.data,error_return] = ADF_Read_All_Data(bnd_quad_nodes.ID,D);
            bnd_quad_nodes.data = Strip_to_Array(bnd_quad_nodes.data,4);
            fprintf(1,'.');
        end
        fprintf(1,'\n');
        
        fprintf(1,'Sorting surface elements.......');
        for i = 1:surface_groups.dims(2)
            surface_data.group(i).element_types = ' ';
            surface_data.group(i).nodes = bnd_node_node.data(find(bnd_node_group.data == i));
            if findstr(mesh.bnd_element_types,'t')
                surface_data.group(i).element_types(end+1) = 't';
                surface_data.group(i).tri = bnd_tri_nodes.data(find(bnd_tri_group.data == i),:);
            end
            if findstr(mesh.bnd_element_types,'q')
                surface_data.group(i).element_types(end+1) = 'q';
                surface_data.group(i).quad = bnd_quad_nodes.data(find(bnd_quad_group.data == i),:);
            end
            % Check for tri elements in the quads!
            check = surface_data.group(i).quad(:,1) == surface_data.group(i).quad(:,4);
            if isempty(findstr(mesh.bnd_element_types,'t')) & find(check)
                surface_data.group(i).element_types(end+1) = 't';
                surface_data.group(i).tri = surface_data.group(i).quad(check,1:3);
            elseif findstr(mesh.bnd_element_types,'t') & find(check)
                surface_data.group(i).tri(end+1:end+length(find(check)),:) = surface_data.group(i).quad(find(check),1:3);
            end
            % Remove these elements from quads.
            surface_data.group(i).quad = surface_data.group(i).quad(find(1-check),:);
            surface(i).element_types = surface_data.group(i).element_types;
            fprintf(1,'.');
        end
        clear check
        fprintf(1,'\n');
        
        % Sort nodes, elements and faces into zones
        for zone = 1:n_zones
            fprintf(1,'Zone %d \n',zone);
            fprintf(1,'Sorting nodes into zones........... \n');
            % Sort nodes
            grid(zone).node.i_nodes = find(node_zone.data == zone);
            grid(zone).node.nodes = coordinates.data(grid(zone).node.i_nodes,:);
            node_map(grid(zone).node.i_nodes) = [1:length(grid(zone).node.i_nodes)];
            M = size(grid(zone).node.nodes,1);
            grid(zone).n_nodes = M;
            
            fprintf(1,'Sorting faces into zones');
            % Sort faces
            grid(zone).n_faces = 0;
            for i = 1:size(surface,2)
                grid(zone).face_types{i} = ' ';
                if findstr(surface_data.group(i).element_types,'t')
                    if find(node_zone.data(surface_data.group(i).tri(1,1)) == zone);
                        grid(zone).tri(i).i_tri = surface_data.group(i).tri;
                        grid(zone).tri(i).n_tri = size(grid(zone).tri(i).i_tri,1);
                        grid(zone).n_faces = grid(zone).n_faces+grid(zone).tri(i).n_tri;
                        
                        grid(zone).face_types{i}(end+1) = 't';
                    end
                    fprintf(1,'.');
                end
                if findstr(surface_data.group(i).element_types,'q')
                    if find(node_zone.data(surface_data.group(i).quad(1,1)) == zone);
                        grid(zone).quad(i).i_quad = surface_data.group(i).quad;
                        grid(zone).quad(i).n_quad = size(grid(zone).quad(i).i_quad,1);
                        grid(zone).n_faces = grid(zone).n_faces+grid(zone).quad(i).n_quad;
                        
                        grid(zone).face_types{i}(end+1) = 'q';
                    end
                    fprintf(1,'.');
                end
            end       
            fprintf(1,'\n');
            
            fprintf(1,'Sorting elements into zones');
            % Sort elements
            grid(zone).n_elements = 0;
            grid(zone).element_types = ' ';
            if findstr(mesh.element_types,'h');
                fprintf(1,'....');
                grid(zone).hex.i_hex = find(node_zone.data(hex.data(:,1)) == zone);
                grid(zone).hex.n_hex = length(grid(zone).hex.i_hex);
                grid(zone).n_elements = grid(zone).n_elements+grid(zone).hex.n_hex;
                if grid(zone).hex.n_hex > 0
                    grid(zone).element_types(end+1) = 'h';
                end
            end
            if findstr(mesh.element_types,'p');
                fprintf(1,'....');
                grid(zone).pri.i_pri = find(node_zone.data(pri.data(:,1)) == zone);
                grid(zone).pri.n_pri = length(grid(zone).pri.i_pri);
                grid(zone).n_elements = grid(zone).n_elements+grid(zone).pri.n_pri;
                if grid(zone).pri.n_pri > 0
                    grid(zone).element_types(end+1) = 'p';
                end
            end
            if findstr(mesh.element_types,'s');
                fprintf(1,'....');
                grid(zone).pyr.i_pyr = find(node_zone.data(pyr.data(:,1)) == zone);
                grid(zone).pyr.n_pyr = length(grid(zone).pyr.i_pyr);
                grid(zone).n_elements = grid(zone).n_elements+grid(zone).pyr.n_pyr;
                if grid(zone).pyr.n_pyr > 0
                    grid(zone).element_types(end+1) = 's';
                end
            end
            if findstr(mesh.element_types,'t');
                fprintf(1,'....');
                grid(zone).tet.i_tet = find(node_zone.data(tet.data(:,1)) == zone);
                grid(zone).tet.n_tet = length(grid(zone).tet.i_tet);
                grid(zone).n_elements = grid(zone).n_elements+grid(zone).tet.n_tet;
                if grid(zone).tet.n_tet > 0
                    grid(zone).element_types(end+1) = 't';
                end
            end
            fprintf(1,'\n');
        end
        
        
        % Close grid file
        [D,error_return] = ADF_Database_Close(mesh.ID,D);
        clear M N coordinates surface_data bnd_node_group node_zone mesh surface_groups
        clear bnd_node_zone bnd_quad_group bnd_quad_nodes bnd_tri_nodes bnd_tri_group
        
        fprintf(1,'Closing ADF grid file \n');
        
        if g_flag == 1
            fprintf(1,'Opening FieldView grid file \n');

            % Open FieldView file
            fid = fopen([file_root '.uns'],'wt');

            % Write the file header
            fprintf(fid,'FIELDVIEW_Grids 3 0 \n \n');

            % Write the grids
            fprintf(fid,'Grids %d \n \n',n_zones);

            % Write the boundary table
            fprintf(fid,'Boundary Table %d \n',size(surface,2));
            for i = 1:size(surface,2)
                % Not sure about handed-ness to leave it at the moment
                if strcmp(surface(i).type,'v') | strcmp(surface(i).type,'i')
                    fprintf(fid,'1 0 0 %s \n',surface(i).name); % This is a 'blocking' surface
                else
                    fprintf(fid,'0 0 0 %s \n',surface(i).name); % This is a 'non-blocking' surface
                end
            end
            fprintf(fid,' \n');

            for zone = 1:n_zones
                fprintf(1,'Zone %d \n',zone);
                fprintf(1,'Writing nodes...\n');
                % Write out nodes
                fprintf(fid,'Nodes %d \n',grid(zone).n_nodes);
                fprintf(fid,'%16.10e  %16.10e  %16.10e \n',grid(zone).node.nodes');
                fprintf(fid,' \n');

                fprintf(1,'Writing faces');
                % Write out Boundary faces
                fprintf(fid,'Boundary Faces %d \n',sum(grid(zone).n_faces));
                for i = 1:size(surface,2)
                    fprintf(1,'.');
                    if findstr(grid(zone).face_types{i},'t')
                        for j = 1:grid(zone).tri(i).n_tri
                            fprintf(fid,'%d 3 %d %d %d %d \n',[i node_map(grid(zone).tri(i).i_tri(j,:))]);
                        end
                    end
                    if findstr(grid(zone).face_types{i},'q')
                        for j = 1:grid(zone).quad(i).n_quad
                            fprintf(fid,'%d 4 %d %d %d %d \n',[i node_map(grid(zone).quad(i).i_quad(j,:))]);
                        end
                    end
                end
                fprintf(fid,' \n');
                fprintf(1,'\n');

                fprintf(1,'Writing elements');
                % Write out elements
                fprintf(fid,'Elements \n');
                if findstr(grid(zone).element_types,'t')
                    c = 0;
                    for j = 1:grid(zone).tet.n_tet
                        c = c+1;
                        if c > (grid(zone).tet.n_tet/10)
                            fprintf(1,'.');
                            c = 0;
                        end
                        fprintf(fid,'1 1 %d %d %d %d \n',node_map(tet.data(grid(zone).tet.i_tet(j),mapping.tet.nodes)));
                    end
                end
                if findstr(grid(zone).element_types,'h')
                    c = 0;
                    for j = 1:grid(zone).hex.n_hex
                        c = c+1;
                        if c > (grid(zone).hex.n_hex/10)
                            fprintf(1,'.');
                            c = 0;
                        end
                        fprintf(fid,'2 1 %d %d %d %d %d %d %d %d \n',node_map(hex.data(grid(zone).hex.i_hex(j),mapping.hex.nodes)));
                    end
                end
                if findstr(grid(zone).element_types,'p')
                    c = 0;
                    for j = 1:grid(zone).pri.n_pri
                        c = c+1;
                        if c > (grid(zone).pri.n_pri/10)
                            fprintf(1,'.');
                            c = 0;
                        end
                        fprintf(fid,'3 1 %d %d %d %d %d %d \n',node_map(pri.data(grid(zone).pri.i_pri(j),mapping.pri.nodes)));
                    end
                end
                if findstr(grid(zone).element_types,'s')
                    c = 0;
                    for j = 1:grid(zone).pyr.n_pyr
                        c = c+1;
                        if c > (grid(zone).pyr.n_pyr/10)
                            fprintf(1,'.');
                            c = 0;
                        end
                        fprintf(fid,'4 1 %d %d %d %d %d \n',node_map(pyr.data(grid(zone).pyr.i_tet(j),mapping.pyr.nodes)));
                    end
                end
                fprintf(fid,' \n');
                fprintf(1,'\n');
            end

            % Close grid file
            fclose(fid);
            fprintf(1,'Closing FieldView grid file \n');
        end
        
        clear hex tet pri pyr
        clear surface node_map mapping
    
        % Free up memory
        for zone = 1:n_zones
            fgrid(zone).n_nodes = grid(zone).n_nodes;
            fgrid(zone).i_nodes = grid(zone).node.i_nodes;
        end
        clear grid
        
        % For the unsteady solutions
        for f = 0:n_files
            fprintf(1,'Reading ADF flow file %d',f);
            if f < 10
                uns_flow_file = [flow_file '.0' num2str(f)];
            elseif f == 100
                uns_flow_file = [flow_file '.00'];
            else
                uns_flow_file = [flow_file '.' num2str(f)];
            end
            
            % Open flow file
            [D,flow.ID,error_return] = ADF_Database_Open(uns_flow_file,'READ_ONLY','NATIVE',D);
            fprintf(1,'.');
            
            % Read in simulation time
            [D,time.ID,error_return] = ADF_Get_Node_ID(flow.ID,'cumulative_time',D);
            [D,time.data,error_return] = ADF_Read_All_Data(time.ID,D);
            fprintf(1,'.');
            
            % Read in flow data
            [D,variables.ID,error_return] = ADF_Get_Node_ID(flow.ID,'flow',D);
            [D,variables.dims,error_return] = ADF_Get_Dimension_Values(variables.ID,D);
            [D,variables.data,error_return] = ADF_Read_All_Data(variables.ID,D);
            variables.data = Strip_to_Array(variables.data,6);
            fprintf(1,'.');
            
            [D,flow.n_children,error_return] = ADF_Number_of_Children(flow.ID,D);
            [D,flow.n_children,flow.children,error_return] = ADF_Children_Names(flow.ID,1,flow.n_children,D.ADF_Name_Length,D);
            heat = 0;
            tad = 0;
            for i = 1:flow.n_children
                if strcmp(flow.children{i}(1:14),'wall heat flux')
                    heat = 1;
                end
                if strcmp(flow.children{i}(1:26),'adiabatic wall temperature')
                    tad = 1;
                end
            end
            
            if heat % If there is heat-flux data
                [D,qdot.ID,error_return] = ADF_Get_Node_ID(flow.ID,'wall heat flux',D);
                [D,qdot.data,error_return] = ADF_Read_All_Data(qdot.ID,D);
                fprintf(1,'.');
                
                variables.data(bnd_node_node.data,7) = qdot.data;
                variables.data(:,7) = variables.data(:,7)*q_ref;
            end
            if tad % If there is tad and htc data
                [D,taw.ID,error_return] = ADF_Get_Node_ID(flow.ID,'adiabatic wall temperature',D);
                [D,taw.data,error_return] = ADF_Read_All_Data(taw.ID,D);
                fprintf(1,'.');
                
                variables.data(bnd_node_node.data,8) = tad.data;
                
                [D,htc.ID,error_return] = ADF_Get_Node_ID(flow.ID,'heat-transfer coefficient',D);
                [D,htc.data,error_return] = ADF_Read_All_Data(htc.ID,D);
                fprintf(1,'.');
                
                variables.data(bnd_node_node.data,9) = htc.data;
            end
            
            % Remove Hydra non-dimensionalising
            variables.data(:,1) = variables.data(:,1)*rho_ref;
            variables.data(:,2:4) = variables.data(:,2:4)*u_ref;
            variables.data(:,5) = variables.data(:,5)*p_ref;
            fprintf(1,'\n');
            
            % Close flow file
            [D,error_return] = ADF_Database_Close(flow.ID,D);
            clear flow qdot taw htc
            fprintf(1,'Closing ADF flow file %d \n',f);
            fprintf(1,'Opening FieldView flow file %d \n',f);
            
            % Open FieldView solution file
            if f < 10
                fid = fopen([file_root '0' num2str(f) '.uns'],'wt');
            elseif f == 100
                fid = fopen([file_root '00.uns'],'wt');
            else
                fid = fopen([file_root num2str(f) '.uns'],'wt');
            end
            
            % Write the file header
            fprintf(fid,'FIELDVIEW_Results 3 0 \n \n');
            
            % Write the constants
            fprintf(fid,'Constants \n');
            fprintf(fid,'%16.10e 0.0 0.0 0.0 \n \n',time.data);
            
            % Write the grids
            fprintf(fid,'Grids %d \n \n',n_zones);
            
            % Write the variable names
            fprintf(fid,'Variable Names %d \n',6+heat+2*tad);
            fprintf(fid,'density \n');
            fprintf(fid,'u_vel; velocity \n');
            fprintf(fid,'v_vel \n');
            fprintf(fid,'w_vel \n');
            fprintf(fid,'pressure \n');
            fprintf(fid,'turbulence \n');
            if heat
                fprintf(fid,'heat flux \n');
            end
            if tad
                fprintf(fid,'adiabatic wall temperature \n');
                fprintf(fid,'heat-transfer coefficient \n');
            end
            fprintf(fid,' \n');
            
            % Write the boundary variable names
            fprintf(fid,'Boundary Variable Names 0 \n \n');
            
            for zone = 1:n_zones
                fprintf(1,'Zone %d \n',zone);
                % Write out nodes
                fprintf(fid,'Nodes %d \n \n',grid(zone).n_nodes);        
                
                % Write out flow variables
                fprintf(fid,'Variables \n');
                if heat
                    fprintf(1,'Writing variables.......\n');
                    fprintf(fid,'%16.10e  %16.10e  %16.10e  %16.10e  %16.10e  %16.10e  %16.10e \n',variables.data(grid(zone).node.i_nodes,:));
                elseif tad
                    fprintf(1,'Writing variables.......\n');
                    fprintf(fid,'%16.10e  %16.10e  %16.10e  %16.10e  %16.10e  %16.10e  %16.10e  %16.10e  %16.10e \n',variables.data(grid(zone).node.i_nodes,:));
                else
                    fprintf(1,'Writing variables......\n');
                    fprintf(fid,'%16.10e  %16.10e  %16.10e  %16.10e  %16.10e  %16.10e \n',variables.data(grid(zone).node.i_nodes,:));
                end
                fprintf(fid,' \n');
            end
            
            % Close solution file
            fprintf(1,'Closing FieldView flow file %d \n',f);
            fclose(fid);
        end
        
        fprintf(1,'Done!');
        
        % Write FieldView Region file
        % Convert units
        per_ang = abs(per_ang.data/pi*180);
        omega = omega/(2*pi);
        
        fid = fopen([file_root '.uns.fvreg'],'wt');
        fprintf(fid,'FVREG 2 \n');
        fprintf(fid,'DATASET_COORD_TYPE      CYLINDRICAL \n');
        fprintf(fid,'MACHINE_AXIS            X \n');
        fprintf(fid,'ROTATION_ORIENTATION    CCW \n');
        fprintf(fid,'MACHINE_AXIS_VECTOR     1.0 0.0 0.0 \n');
        fprintf(fid,'ZERO_THETA_VECTOR       0.0 1.0 0.0 \n');
        fprintf(fid,'FACET_COUNT             180 \n');
        fprintf(fid,'VELOCITIES              1 \n');
        fprintf(fid,'velocity \n');
        
        for zone = 1:n_zones
            fprintf(fid,'BLADE_ROW \n');
            fprintf(fid,'   BLADES_PER_ROW %d \n',round(360/per_ang(zone)));
            fprintf(fid,'   WHEEL_SPEED %8.4f \n',omega(zone));
            fprintf(fid,'   PERIOD %8.4f \n',per_ang(zone));
            fprintf(fid,'   NUM_REGIONS 1 \n');
            fprintf(fid,'   REGION \n');
            fprintf(fid,'      Zone-%d \n',zone);
            fprintf(fid,'      NUM_GRIDS 1');
            fprintf(fid,'         %d \n',zone);
        end
        fclose(fid);
        
        
    else % Steady solution
        % We will write the steady solution using the unified file format
        
        % Set up ADF space 
        D = ADFI_Declarations;
        
        % Open files for grid actions
        [D,mesh.ID,error_return] = ADF_Database_Open(mesh_file,'READ_ONLY','NATIVE',D);
        fprintf(1,'Reading Hydra grid file');
        
        % Read the periodic angle
        [D,per_ang.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'periodic_angle',D);
        [D,per_ang.data,error_return] = ADF_Read_All_Data(per_ang.ID,D);
        fprintf(1,'.');
        
        % Check the element types in the mesh
        [D,mesh.element_types,mesh.bnd_element_types,error_return] = Catalogue_Elements(mesh.ID,D);
        fprintf(1,'.');
        
        % Read the surface groups
        [D,surface_groups.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'surface_groups',D);
        [D,surface_groups.dims,error_return] = ADF_Get_Dimension_Values(surface_groups.ID,D);
        [D,surface_groups.data,error_return] = ADF_Read_All_Data(surface_groups.ID,D);
        
        surface_groups.data = Strip_to_Array(surface_groups.data,surface_groups.dims(1));
        surface_groups.data = char(surface_groups.data);
        
        for i = 1:surface_groups.dims(2)
            j = 1;
            while ~strcmp(surface_groups.data(i,[j j+1]),'  ')
                name(j) = surface_groups.data(i,j);
                j = j+1;
            end
            while strcmp(surface_groups.data(i,j),' ');
                j = j+1;
            end
            surface(i).name = name;
            surface(i).type = surface_groups.data(i,j);
            clear name
        end
        
        % Read in node_coordinates
        [D,coordinates.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'node_coordinates',D);
        [D,coordinates.data,error_return] = ADF_Read_All_Data(coordinates.ID,D);
        [D,coordinates.dims,error_return] = ADF_Get_Dimension_Values(coordinates.ID,D);
        coordinates.data = Strip_to_Array(coordinates.data,3);
        fprintf(1,'.');
        
        % Read in node_zone pointers
        [D,node_zone.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'node-->zone',D);
        [D,node_zone.data,error_return] = ADF_Read_All_Data(node_zone.ID,D);
        [D,bnd_node_zone.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_node-->zone',D);
        [D,bnd_node_zone.data,error_return] = ADF_Read_All_Data(node_zone.ID,D);
        fprintf(1,'.');
        
        % Read in boundary node pointers
        [D,bnd_node_node.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_node-->node',D);
        [D,bnd_node_node.data,error_return] = ADF_Read_All_Data(bnd_node_node.ID,D);
        [D,bnd_node_group.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_node-->group',D);
        [D,bnd_node_group.data,error_return] = ADF_Read_All_Data(bnd_node_group.ID,D);  
        fprintf(1,'.');
        
        % Read in Element-->Node pointers
        if findstr(mesh.element_types,'h')
            [D,hex.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'hex-->node',D);
            [D,hex.dims,error_return] = ADF_Get_Dimension_Values(hex.ID,D);
            [D,hex.data,error_return] = ADF_Read_All_Data(hex.ID,D);
            hex.data = Strip_to_Array(hex.data,hex.dims(1));
            fprintf(1,'.');
        end
        if findstr(mesh.element_types,'p')
            [D,pri.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'pri-->node',D);
            [D,pri.dims,error_return] = ADF_Get_Dimension_Values(pri.ID,D);
            [D,pri.data,error_return] = ADF_Read_All_Data(pri.ID,D);
            pri.data = Strip_to_Array(pri.data,pri.dims(1));
            fprintf(1,'.');
        end
        if findstr(mesh.element_types,'s')
            [D,pyr.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'pyr-->node',D);
            [D,pyr.dims,error_return] = ADF_Get_Dimension_Values(pyr.ID,D);
            [D,pyr.data,error_return] = ADF_Read_All_Data(pyr.ID,D);
            pyr.data = Strip_to_Array(pyr.data,pyr.dims(1));
            fprintf(1,'.');
        end
        if findstr(mesh.element_types,'t')
            [D,tet.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'tet-->node',D);
            [D,tet.dims,error_return] = ADF_Get_Dimension_Values(tet.ID,D);
            [D,tet.data,error_return] = ADF_Read_All_Data(tet.ID,D);
            tet.data = Strip_to_Array(tet.data,tet.dims(1));
            fprintf(1,'.');
        end
        clear M N
        
        % Read in and sort surface elements
        if findstr(mesh.bnd_element_types,'t') 
            [D,bnd_tri_group.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_tri-->group',D);
            [D,bnd_tri_group.data,error_return] = ADF_Read_All_Data(bnd_tri_group.ID,D);
            [D,bnd_tri_nodes.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_tri-->node',D);
            [D,bnd_tri_nodes.data,error_return] = ADF_Read_All_Data(bnd_tri_nodes.ID,D);
            bnd_tri_nodes.data = Strip_to_Array(bnd_tri_nodes.data,3);
            fprintf(1,'.');
        end
        if findstr(mesh.bnd_element_types,'q') 
            [D,bnd_quad_group.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_quad-->group',D);
            [D,bnd_quad_group.data,error_return] = ADF_Read_All_Data(bnd_quad_group.ID,D);
            [D,bnd_quad_nodes.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_quad-->node',D);
            [D,bnd_quad_nodes.data,error_return] = ADF_Read_All_Data(bnd_quad_nodes.ID,D);
            bnd_quad_nodes.data = Strip_to_Array(bnd_quad_nodes.data,4);
            fprintf(1,'.');
        end
        fprintf(1,'\n');
        
        fprintf(1,'Sorting surface elements');
        for i = 1:surface_groups.dims(2)
            surface_data.group(i).element_types = ' ';
            surface_data.group(i).nodes = bnd_node_node.data(find(bnd_node_group.data == i));
            if findstr(mesh.bnd_element_types,'t')
                surface_data.group(i).element_types(end+1) = 't';
                surface_data.group(i).tri = bnd_tri_nodes.data(find(bnd_tri_group.data == i),:);
            end
            if findstr(mesh.bnd_element_types,'q')
                surface_data.group(i).element_types(end+1) = 'q';
                surface_data.group(i).quad = bnd_quad_nodes.data(find(bnd_quad_group.data == i),:);
            end
            % Check for tri elements in the quads!
            check = surface_data.group(i).quad(:,1) == surface_data.group(i).quad(:,4);
            if isempty(findstr(mesh.bnd_element_types,'t')) & find(check)
                surface_data.group(i).element_types(end+1) = 't';
                surface_data.group(i).tri = surface_data.group(i).quad(check,1:3);
            elseif findstr(mesh.bnd_element_types,'t') & find(check)
                surface_data.group(i).tri(end+1:end+length(find(check)),:) = surface_data.group(i).quad(find(check),1:3);
            end
            % Remove these elements from quads.
            surface_data.group(i).quad = surface_data.group(i).quad(find(1-check),:);
            surface(i).element_types = surface_data.group(i).element_types;
            fprintf(1,'.');
        end
        clear check
        fprintf(1,'\n');
        
        % Sort nodes, elements and faces into zones
        for zone = 1:n_zones
            fprintf(1,'Zone %d \n',zone);
            fprintf(1,'Sorting nodes into zones........... \n');
            % Sort nodes
            grid(zone).node.i_nodes = find(node_zone.data == zone);
            grid(zone).node.nodes = coordinates.data(grid(zone).node.i_nodes,:);
            node_map(grid(zone).node.i_nodes) = [1:length(grid(zone).node.i_nodes)];
            M = size(grid(zone).node.nodes,1);
            grid(zone).n_nodes = M;
            
            fprintf(1,'Sorting faces into zones');
            % Sort faces
            for i = 1:size(surface,2)
                grid(zone).n_faces(i) = 0;
                grid(zone).face_types{i} = ' ';
                if findstr(surface_data.group(i).element_types,'t')
                    if find(node_zone.data(surface_data.group(i).tri(1,1)) == zone);
                        grid(zone).tri(i).i_tri = surface_data.group(i).tri;
                        grid(zone).tri(i).n_tri = size(grid(zone).tri(i).i_tri,1);
                        grid(zone).n_faces(i) = grid(zone).n_faces(i)+grid(zone).tri(i).n_tri;
                        
                        grid(zone).face_types{i}(end+1) = 't';
                    end
                    fprintf(1,'.');
                end
                if findstr(surface_data.group(i).element_types,'q')
                    if find(node_zone.data(surface_data.group(i).quad(1,1)) == zone);
                        grid(zone).quad(i).i_quad = surface_data.group(i).quad;
                        grid(zone).quad(i).n_quad = size(grid(zone).quad(i).i_quad,1);
                        grid(zone).n_faces(i) = grid(zone).n_faces(i)+grid(zone).quad(i).n_quad;
                        
                        grid(zone).face_types{i}(end+1) = 'q';
                    end
                    fprintf(1,'.');
                end
            end  
            fprintf(1,'\n');
            
            fprintf(1,'Sorting elements into zones');
            % Sort elements
            grid(zone).n_elements = 0;
            grid(zone).element_types = ' ';
            if findstr(mesh.element_types,'h');
                fprintf(1,'....');
                grid(zone).hex.i_hex = find(node_zone.data(hex.data(:,1)) == zone);
                grid(zone).hex.n_hex = length(grid(zone).hex.i_hex);
                grid(zone).n_elements = grid(zone).n_elements+grid(zone).hex.n_hex;
                if grid(zone).hex.n_hex > 0
                    grid(zone).element_types(end+1) = 'h';
                end
            end
            if findstr(mesh.element_types,'p');
                fprintf(1,'....');
                grid(zone).pri.i_pri = find(node_zone.data(pri.data(:,1)) == zone);
                grid(zone).pri.n_pri = length(grid(zone).pri.i_pri);
                grid(zone).n_elements = grid(zone).n_elements+grid(zone).pri.n_pri;
                if grid(zone).pri.n_pri > 0
                    grid(zone).element_types(end+1) = 'p';
                end
            end
            if findstr(mesh.element_types,'s');
                fprintf(1,'....');
                grid(zone).pyr.i_pyr = find(node_zone.data(pyr.data(:,1)) == zone);
                grid(zone).pyr.n_pyr = length(grid(zone).pyr.i_pyr);
                grid(zone).n_elements = grid(zone).n_elements+grid(zone).pyr.n_pyr;
                if grid(zone).pyr.n_pyr > 0
                    grid(zone).element_types(end+1) = 's';
                end
            end
            if findstr(mesh.element_types,'t');
                fprintf(1,'....');
                grid(zone).tet.i_tet = find(node_zone.data(tet.data(:,1)) == zone);
                grid(zone).tet.n_tet = length(grid(zone).tet.i_tet);
                grid(zone).n_elements = grid(zone).n_elements+grid(zone).tet.n_tet;
                if grid(zone).tet.n_tet > 0
                    grid(zone).element_types(end+1) = 't';
                end
            end
            fprintf(1,'\n');
        end
        
        % Close grid file
        [D,error_return] = ADF_Database_Close(mesh.ID,D);
        clear M N coordinates surface_data bnd_node_group node_zone mesh surface_groups
        clear bnd_node_zone bnd_quad_group bnd_quad_nodes bnd_tri_nodes bnd_tri_group
        fprintf(1,'Closing Hydra grid file\n');
        fprintf(1,'Reading Hydra flow file');
        
        % Open flow file
        [D,flow.ID,error_return] = ADF_Database_Open(flow_file,'READ_ONLY','NATIVE',D);
        fprintf(1,'.');
        
        % Read in flow data
        [D,variables.ID,error_return] = ADF_Get_Node_ID(flow.ID,'flow',D);
        [D,variables.dims,error_return] = ADF_Get_Dimension_Values(variables.ID,D);
        [D,variables.data,error_return] = ADF_Read_All_Data(variables.ID,D);
        variables.data = Strip_to_Array(variables.data,6);
        fprintf(1,'.');
        
        [D,flow.n_children,error_return] = ADF_Number_of_Children(flow.ID,D);
        [D,flow.n_children,flow.children,error_return] = ADF_Children_Names(flow.ID,1,flow.n_children,D.ADF_Name_Length,D);
        heat = 0;
        tad = 0;
        for i = 1:flow.n_children
            if strcmp(flow.children{i}(1:14),'wall heat flux')
                heat = 1;
            end
            if strcmp(flow.children{i}(1:26),'adiabatic wall temperature')
                tad = 1;
            end
        end

        if heat % If there is heat-flux data
            [D,qdot.ID,error_return] = ADF_Get_Node_ID(flow.ID,'wall heat flux',D);
            [D,qdot.data,error_return] = ADF_Read_All_Data(qdot.ID,D);
            fprintf(1,'.');

            variables.data(bnd_node_node.data,7) = qdot.data;
            variables.data(:,7) = variables.data(:,7)*q_ref;
        end
        if tad % If there is tad and htc data
            [D,taw.ID,error_return] = ADF_Get_Node_ID(flow.ID,'adiabatic wall temperature',D);
            [D,taw.data,error_return] = ADF_Read_All_Data(taw.ID,D);
            fprintf(1,'.');

            variables.data(bnd_node_node.data,8) = taw.data;

            [D,htc.ID,error_return] = ADF_Get_Node_ID(flow.ID,'heat-transfer coefficient',D);
            [D,htc.data,error_return] = ADF_Read_All_Data(htc.ID,D);
            fprintf(1,'.');

            variables.data(bnd_node_node.data,9) = htc.data;
        end

        % Remove Hydra non-dimensionalising
        variables.data(:,1) = variables.data(:,1)*rho_ref;
        variables.data(:,2:4) = variables.data(:,2:4)*u_ref;
        variables.data(:,5) = variables.data(:,5)*p_ref;
        fprintf(1,'\n');
        
        % Close flow file
        [D,error_return] = ADF_Database_Close(flow.ID,D);
        clear flow qdot taw htc
        fprintf(1,'Closing Hydra flow file \n');
        fprintf(1,'Opening FieldView file \n');
        
        % Open FieldView file
        fid = fopen([file_root '.uns'],'wt');
        
        % Write the file header
        fprintf(fid,'FIELDVIEW 3 0 \n \n');
        
        % Write the constants
        fprintf(fid,'Constants \n');
        fprintf(fid,'0.0 0.0 0.0 0.0 \n \n'); % This is a steady solution and hydra does not uses these
        
        % Write the grids
        fprintf(fid,'Grids %d \n \n',n_zones);
        
        % Write the boundary table
        fprintf(fid,'Boundary Table %d \n',size(surface,2));
        for i = 1:size(surface,2)
            % Not sure about handed-ness to leave it at the moment
            if strcmp(surface(i).type,'v') | strcmp(surface(i).type,'i')
                fprintf(fid,'1 0 0 %s \n',surface(i).name); % This is a 'blocking' surface
            else
                fprintf(fid,'0 0 0 %s \n',surface(i).name); % This is a 'non-blocking' surface
            end
        end
        fprintf(fid,' \n');
        
        % Write the variable names
        fprintf(fid,'Variable Names %d \n',6+heat+2*tad);
        fprintf(fid,'density \n');
        fprintf(fid,'u_vel; velocity \n');
        fprintf(fid,'v_vel \n');
        fprintf(fid,'w_vel \n');
        fprintf(fid,'pressure \n');
        fprintf(fid,'turbulence \n');
        if heat
            fprintf(fid,'heat flux \n');
        end
        if tad
            fprintf(fid,'adiabatic wall temperature \n');
            fprintf(fid,'heat-transfer coefficient \n');
        end
        fprintf(fid,' \n');
        
        % Write the boundary variable names
        fprintf(fid,'Boundary Variable Names 0 \n \n');
        
        for zone = 1:n_zones
            fprintf(1,'Zone %d \n',zone);
            fprintf(1,'Writing nodes...\n');
            % Write out nodes
            fprintf(fid,'Nodes %d \n',grid(zone).n_nodes);
            fprintf(fid,'%16.10e  %16.10e  %16.10e \n',grid(zone).node.nodes');
            fprintf(fid,' \n');
            
            fprintf(1,'Writing faces');
            % Write out Boundary faces
            fprintf(fid,'Boundary Faces %d \n',sum(grid(zone).n_faces));
            for i = 1:size(surface,2)
                fprintf(1,'.');
                if findstr(grid(zone).face_types{i},'t')
                    for j = 1:grid(zone).tri(i).n_tri
                        fprintf(fid,'%d 3 %d %d %d %d \n',[i node_map(grid(zone).tri(i).i_tri(j,:))]);
                    end
                end
                if findstr(grid(zone).face_types{i},'q')
                    for j = 1:grid(zone).quad(i).n_quad
                        fprintf(fid,'%d 4 %d %d %d %d \n',[i node_map(grid(zone).quad(i).i_quad(j,:))]);
                    end
                end
            end
            fprintf(fid,' \n');
            fprintf(1,'\n');
            
            fprintf(1,'Writing elements');
            % Write out elements
            fprintf(fid,'Elements \n');
            if findstr(grid(zone).element_types,'t')
                c = 0;
                for j = 1:grid(zone).tet.n_tet
                    c = c+1;
                    if c > (grid(zone).tet.n_tet/10)
                        fprintf(1,'.');
                        c = 0;
                    end
                    fprintf(fid,'1 1 %d %d %d %d \n',node_map(tet.data(grid(zone).tet.i_tet(j),mapping.tet.nodes)));
                end
            end
            if findstr(grid(zone).element_types,'h')
                c = 0;
                for j = 1:grid(zone).hex.n_hex
                    c = c+1;
                    if c > (grid(zone).hex.n_hex/10)
                        fprintf(1,'.');
                        c = 0;
                    end
                    fprintf(fid,'2 1 %d %d %d %d %d %d %d %d \n',node_map(hex.data(grid(zone).hex.i_hex(j),mapping.hex.nodes)));
                end
            end
            if findstr(grid(zone).element_types,'p')
                c = 0;
                for j = 1:grid(zone).pri.n_pri
                    c = c+1;
                    if c > (grid(zone).pri.n_pri/10)
                        fprintf(1,'.');
                        c = 0;
                    end
                    fprintf(fid,'3 1 %d %d %d %d %d %d \n',node_map(pri.data(grid(zone).pri.i_pri(j),mapping.pri.nodes)));
                end
            end
            if findstr(grid(zone).element_types,'s')
                c = 0;
                for j = 1:grid(zone).pyr.n_pyr
                    c = c+1;
                    if c > (grid(zone).pyr.n_pyr/10)
                        fprintf(1,'.');
                        c = 0;
                    end
                    fprintf(fid,'4 1 %d %d %d %d %d \n',node_map(pyr.data(grid(zone).pyr.i_tet(j),mapping.pyr.nodes)));
                end
            end
            fprintf(fid,' \n');
            fprintf(1,'\n');
            
            % Write out flow variables
            fprintf(fid,'Variables \n');
            if heat
                fprintf(1,'Writing variables.......\n');
                fprintf(fid,'%16.10e  %16.10e  %16.10e  %16.10e  %16.10e  %16.10e  %16.10e \n',variables.data(grid(zone).node.i_nodes,:));
            elseif tad
                fprintf(1,'Writing variables.......\n');
                fprintf(fid,'%16.10e  %16.10e  %16.10e  %16.10e  %16.10e  %16.10e  %16.10e  %16.10e  %16.10e \n',variables.data(grid(zone).node.i_nodes,:));
            else
                fprintf(1,'Writing variables......\n');
                fprintf(fid,'%16.10e  %16.10e  %16.10e  %16.10e  %16.10e  %16.10e \n',variables.data(grid(zone).node.i_nodes,:));
            end
            fprintf(fid,' \n');
        end
        fprintf(1,'\n');
        
        % Close combined file
        fclose(fid);
        disp('Done!');
        
        % Write FieldView Region file
        % Convert units
        per_ang = abs(per_ang.data/pi*180);
        omega = omega/(2*pi);
        
        fid = fopen([file_root '.uns.fvreg'],'wt');
        fprintf(fid,'FVREG 2 \n');
        fprintf(fid,'DATASET_COORD_TYPE      CYLINDRICAL \n');
        fprintf(fid,'MACHINE_AXIS            X \n');
        fprintf(fid,'ROTATION_ORIENTATION    CCW \n');
        fprintf(fid,'MACHINE_AXIS_VECTOR     1.0 0.0 0.0 \n');
        fprintf(fid,'ZERO_THETA_VECTOR       0.0 1.0 0.0 \n');
        fprintf(fid,'FACET_COUNT             180 \n');
        fprintf(fid,'VELOCITIES              1 \n');
        fprintf(fid,'velocity \n');
        
        for zone = 1:n_zones
            fprintf(fid,'BLADE_ROW \n');
            fprintf(fid,'   BLADES_PER_ROW %d \n',round(360/per_ang(zone)));
            fprintf(fid,'   WHEEL_SPEED %8.4f \n',omega(zone));
            fprintf(fid,'   PERIOD %8.4f \n',per_ang(zone));
            fprintf(fid,'   NUM_REGIONS 1 \n');
            fprintf(fid,'   REGION \n');
            fprintf(fid,'      Zone-%d \n',zone);
            fprintf(fid,'      NUM_GRIDS 1');
            fprintf(fid,'         %d \n',zone);
        end
        fclose(fid);
        
    end
    
case 'binary'
    if u_flag  % Unsteady solution
        % We will write the grid as one file and solutions as others
        
        % Set up ADF space 
        D = ADFI_Declarations;
        fprintf(1,'Reading Hydra grid file');
        
        % Open files for grid actions
        [D,mesh.ID,error_return] = ADF_Database_Open(mesh_file,'READ_ONLY','NATIVE',D);
        fprintf(1,'.');
        
        % Read the periodic angle
        [D,per_ang.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'periodic_angle',D);
        [D,per_ang.data,error_return] = ADF_Read_All_Data(per_ang.ID,D);
        fprintf(1,'.');
        
        % Check the element types in the mesh
        [D,mesh.element_types,mesh.bnd_element_types,error_return] = Catalogue_Elements(mesh.ID,D);
        fprintf(1,'.');
        
        % Read the surface groups
        [D,surface_groups.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'surface_groups',D);
        [D,surface_groups.dims,error_return] = ADF_Get_Dimension_Values(surface_groups.ID,D);
        [D,surface_groups.data,error_return] = ADF_Read_All_Data(surface_groups.ID,D);
        fprintf(1,'.');
        
        surface_groups.data = Strip_to_Array(surface_groups.data,surface_groups.dims(1));
        surface_groups.data = char(surface_groups.data);
        
        for i = 1:surface_groups.dims(2)
            j = 1;
            while ~strcmp(surface_groups.data(i,[j j+1]),'  ')
                name(j) = surface_groups.data(i,j);
                j = j+1;
            end
            while strcmp(surface_groups.data(i,j),' ');
                j = j+1;
            end
            surface(i).name = name;
            surface(i).type = surface_groups.data(i,j);
            clear name
        end
        
        % Read in node_coordinates
        [D,coordinates.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'node_coordinates',D);
        [D,coordinates.data,error_return] = ADF_Read_All_Data(coordinates.ID,D);
        [D,coordinates.dims,error_return] = ADF_Get_Dimension_Values(coordinates.ID,D);
        coordinates.data = Strip_to_Array(coordinates.data,3);
        fprintf(1,'.');
        
        % Read in node_zone pointers
        [D,node_zone.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'node-->zone',D);
        [D,node_zone.data,error_return] = ADF_Read_All_Data(node_zone.ID,D);
        [D,bnd_node_zone.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_node-->zone',D);
        [D,bnd_node_zone.data,error_return] = ADF_Read_All_Data(node_zone.ID,D);
        fprintf(1,'.');
        
        % Read in boundary node pointers
        [D,bnd_node_node.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_node-->node',D);
        [D,bnd_node_node.data,error_return] = ADF_Read_All_Data(bnd_node_node.ID,D);
        [D,bnd_node_group.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_node-->group',D);
        [D,bnd_node_group.data,error_return] = ADF_Read_All_Data(bnd_node_group.ID,D);  
        fprintf(1,'.');
        
        % Read in Element-->Node pointers
        if findstr(mesh.element_types,'h')
            [D,hex.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'hex-->node',D);
            [D,hex.dims,error_return] = ADF_Get_Dimension_Values(hex.ID,D);
            [D,hex.data,error_return] = ADF_Read_All_Data(hex.ID,D);
            hex.data = Strip_to_Array(hex.data,hex.dims(1));
            hex.wall = zeros(hex.dims(2),6);
            fprintf(1,'.');
        end
        if findstr(mesh.element_types,'p')
            [D,pri.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'pri-->node',D);
            [D,pri.dims,error_return] = ADF_Get_Dimension_Values(pri.ID,D);
            [D,pri.data,error_return] = ADF_Read_All_Data(pri.ID,D);
            pri.data = Strip_to_Array(pri.data,pri.dims(1));
            pri.wall = zeros(pri.dims(2),5);
            fprintf(1,'.');
        end
        if findstr(mesh.element_types,'s')
            [D,pyr.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'pyr-->node',D);
            [D,pyr.dims,error_return] = ADF_Get_Dimension_Values(pyr.ID,D);
            [D,pyr.data,error_return] = ADF_Read_All_Data(pyr.ID,D);
            pyr.data = Strip_to_Array(pyr.data,pyr.dims(1));
            pyr.wall = zeros(pyr.dims(2),5);
            fprintf(1,'.');
        end
        if findstr(mesh.element_types,'t')
            [D,tet.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'tet-->node',D);
            [D,tet.dims,error_return] = ADF_Get_Dimension_Values(tet.ID,D);
            [D,tet.data,error_return] = ADF_Read_All_Data(tet.ID,D);
            tet.data = Strip_to_Array(tet.data,tet.dims(1));
            tet.wall = zeros(tet.dims(2),5);
            fprintf(1,'.');
        end
        
        % Read in and sort surface elements
        if findstr(mesh.bnd_element_types,'t') 
            [D,bnd_tri_group.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_tri-->group',D);
            [D,bnd_tri_group.data,error_return] = ADF_Read_All_Data(bnd_tri_group.ID,D);
            [D,bnd_tri_nodes.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_tri-->node',D);
            [D,bnd_tri_nodes.data,error_return] = ADF_Read_All_Data(bnd_tri_nodes.ID,D);
            bnd_tri_nodes.data = Strip_to_Array(bnd_tri_nodes.data,3);
            fprintf(1,'.');
        end
        if findstr(mesh.bnd_element_types,'q') 
            [D,bnd_quad_group.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_quad-->group',D);
            [D,bnd_quad_group.data,error_return] = ADF_Read_All_Data(bnd_quad_group.ID,D);
            [D,bnd_quad_nodes.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_quad-->node',D);
            [D,bnd_quad_nodes.data,error_return] = ADF_Read_All_Data(bnd_quad_nodes.ID,D);
            bnd_quad_nodes.data = Strip_to_Array(bnd_quad_nodes.data,4);
            fprintf(1,'.');
        end
        fprintf(1,' \n');
        
        fprintf(1,'Sorting surface elements.......');
        for i = 1:surface_groups.dims(2)
            surface_data.group(i).element_types = ' ';
            surface_data.group(i).nodes = bnd_node_node.data(find(bnd_node_group.data == i));
            if findstr(mesh.bnd_element_types,'t')
                surface_data.group(i).element_types(end+1) = 't';
                surface_data.group(i).tri = bnd_tri_nodes.data(find(bnd_tri_group.data == i),:);
            end
            if findstr(mesh.bnd_element_types,'q')
                surface_data.group(i).element_types(end+1) = 'q';
                surface_data.group(i).quad = bnd_quad_nodes.data(find(bnd_quad_group.data == i),:);
            end
            % Check for tri elements in the quads!
            check = surface_data.group(i).quad(:,1) == surface_data.group(i).quad(:,4);
            if isempty(findstr(mesh.bnd_element_types,'t')) & find(check)
                surface_data.group(i).element_types(end+1) = 't';
                surface_data.group(i).tri = surface_data.group(i).quad(check,1:3);
            elseif findstr(mesh.bnd_element_types,'t') & find(check)
                surface_data.group(i).tri(end+1:end+length(find(check)),:) = surface_data.group(i).quad(find(check),1:3);
            end
            % Remove these elements from quads.
            surface_data.group(i).quad = surface_data.group(i).quad(find(1-check),:);
            surface(i).element_types = surface_data.group(i).element_types;
            fprintf(1,'.');
        end
        clear check
        fprintf(1,'\n');
        
        % Build FieldView wall data
        if g_flag == 1
            blocking_mask = bnd_node_group.data*0;
            for i = 1:size(surface,2)
                if strcmp(surface(i).type,'v') | strcmp(surface(i).type,'i')
                    blocking_mask = blocking_mask+bnd_node_group.data == i;
                end
            end
            blocking_nodes = find(blocking_mask);
            blocking_nodes = bnd_node_node.data(blocking_nodes); % These are the boundary nodes on a blocking boundary
            clear blocking_mask

            fprintf(1,'Building wall arrays (be patient) \n');
            % For each of these nodes, find the elements which they are in and build the wall map for them
            if findstr(mesh.element_types,'h')
                h_data = hex.data*0;
            end
            if findstr(mesh.element_types,'t')
                t_data = tet.data*0;
            end
            if findstr(mesh.element_types,'p')
                p_data = pri.data*0;
            end
            if findstr(mesh.element_types,'s')
                s_data = pyr.data*0;
            end

            if findstr(mesh.element_types,'h')
                fprintf(1,'Hex elements');
                c = 0;
                for i = 1:size(hex.data,1)
                    c = c+1;
                    if c > size(hex.data,1)/30
                        fprintf(1,'.');
                        c = 0;
                    end
                    for j = 1:8
                        h_data(i,j) = sum(blocking_nodes==hex.data(i,j));
                    end
                end
                for i = 1:8
                    h_data(i,:) = h_data(i,:)*2^(i-1);
                end
                h_data = sum(h_data,2);
                hex.wall(:,1) = 7*(bitand(h_data,153) == 153);
                hex.wall(:,2) = 7*(bitand(h_data,102) == 102);
                hex.wall(:,3) = 7*(bitand(h_data,15) == 15);
                hex.wall(:,4) = 7*(bitand(h_data,240) == 240);
                hex.wall(:,5) = 7*(bitand(h_data,51) == 51);
                hex.wall(:,6) = 7*(bitand(h_data,204) == 204);
                fprintf(1,'\n');
                clear h_data
            end

            if findstr(mesh.element_types,'t')
                fprintf(1,'Tet elements');
                c = 0;
                for i = 1:size(tet.data,1)
                    c = c+1;
                    if c > size(tet.data,1)/30
                        fprintf(1,'.');
                        c = 0;
                    end
                    for j = 1:4
                        t_data(i,j) = sum(blocking_nodes==tet.data(i,j));
                    end
                end
                for i = 1:4
                    t_data(i,:) = t_data(i,:)*2^(i-1);
                end
                t_data = sum(t_data,2);
                tet.wall(:,1) = 7*(bitand(t_data,7) == 7);
                tet.wall(:,2) = 7*(bitand(t_data,14) == 14);
                tet.wall(:,3) = 7*(bitand(t_data,13) == 13);
                tet.wall(:,4) = 7*(bitand(t_data,11) == 11);
                fprintf(1,'\n');
                clear t_data
            end

            if findstr(mesh.element_types,'p')
                fprintf(1,'Pri elements');
                c = 0;
                for i = 1:size(pri.data,1)
                    c = c+1;
                    if c > size(pri.data,1)/30
                        fprintf(1,'.');
                        c = 0;
                    end
                    for j = 1:6
                        p_data(i,j) = sum(blocking_nodes==pri.data(i,j));
                    end
                end
                for i = 1:6
                    p_data(i,:) = p_data(i,:)*2^(i-1);
                end
                p_data = sum(p_data,2);
                pri.wall(:,1) = 7*(bitand(p_data,15) == 15);
                pri.wall(:,2) = 7*(bitand(p_data,51) == 51);
                pri.wall(:,3) = 7*(bitand(p_data,60) == 60);
                pri.wall(:,4) = 7*(bitand(p_data,41) == 41);
                pri.wall(:,5) = 7*(bitand(p_data,22) == 22);
                fprintf(1,'\n');
                clear p_data
            end

            if findstr(mesh.element_types,'s')
                fprintf(1,'Pyr elements');
                c = 0;
                for i = 1:size(pyr.data,1)
                    c = c+1;
                    if c > size(pyr.data,1)/30
                        fprintf(1,'.');
                        c = 0;
                    end
                    for j = 1:5
                        s_data(i,j) = sum(blocking_nodes==pyr.data(i,j));
                    end
                end
                for i = 1:5
                    s_data(i,:) = s_data(i,:)*2^(i-1);
                end
                s_data = sum(s_data,2);
                pyr.wall(:,1) = 7*(bitand(s_data,15) == 15);
                pyr.wall(:,2) = 7*(bitand(s_data,22) == 22);
                pyr.wall(:,3) = 7*(bitand(s_data,28) == 28);
                pyr.wall(:,4) = 7*(bitand(s_data,25) == 25);
                pyr.wall(:,5) = 7*(bitand(s_data,19) == 19);
                fprintf(1,'\n');
                clear s_data
            end
            clear blocking_nodes
        end
        
        % Sort nodes, elements and faces into zones
        for zone = 1:n_zones
            fprintf(1,'Zone %d \n',zone);
            fprintf(1,'Sorting nodes into zones........... \n');
            % Sort nodes
            grid(zone).node.i_nodes = find(node_zone.data == zone);
            grid(zone).node.nodes = coordinates.data(grid(zone).node.i_nodes,:);
            node_map(grid(zone).node.i_nodes) = [1:length(grid(zone).node.i_nodes)];
            M = size(grid(zone).node.nodes,1);
            grid(zone).n_nodes = M;
            
            fprintf(1,'Sorting faces into zones');
            % Sort faces
            for i = 1:size(surface,2)
                grid(zone).n_faces(i) = 0;
                grid(zone).face_types{i} = ' ';
                if findstr(surface_data.group(i).element_types,'t')
                    if find(node_zone.data(surface_data.group(i).tri(1,1)) == zone);
                        grid(zone).tri(i).i_tri = surface_data.group(i).tri;
                        grid(zone).tri(i).n_tri = size(grid(zone).tri(i).i_tri,1);
                        grid(zone).n_faces(i) = grid(zone).n_faces(i)+grid(zone).tri(i).n_tri;
                        
                        grid(zone).face_types{i}(end+1) = 't';
                    end
                    fprintf(1,'.');
                end
                if findstr(surface_data.group(i).element_types,'q')
                    if find(node_zone.data(surface_data.group(i).quad(1,1)) == zone);
                        grid(zone).quad(i).i_quad = surface_data.group(i).quad;
                        grid(zone).quad(i).n_quad = size(grid(zone).quad(i).i_quad,1);
                        grid(zone).n_faces(i) = grid(zone).n_faces(i)+grid(zone).quad(i).n_quad;
                        
                        grid(zone).face_types{i}(end+1) = 'q';
                    end
                    fprintf(1,'.');
                end
            end
            fprintf(1,'\n');
            
            fprintf(1,'Sorting elements into zones');
            % Sort elements
            grid(zone).n_elements = 0;
            grid(zone).element_types = ' ';
            if findstr(mesh.element_types,'h');
                fprintf(1,'....');
                grid(zone).hex.i_hex = find(node_zone.data(hex.data(:,1)) == zone);
                grid(zone).hex.n_hex = length(grid(zone).hex.i_hex);
                grid(zone).n_elements = grid(zone).n_elements+grid(zone).hex.n_hex;
                if grid(zone).hex.n_hex > 0
                    grid(zone).element_types(end+1) = 'h';
                end
            end
            if findstr(mesh.element_types,'p');
                fprintf(1,'....');
                grid(zone).pri.i_pri = find(node_zone.data(pri.data(:,1)) == zone);
                grid(zone).pri.n_pri = length(grid(zone).pri.i_pri);
                grid(zone).n_elements = grid(zone).n_elements+grid(zone).pri.n_pri;
                if grid(zone).pri.n_pri > 0
                    grid(zone).element_types(end+1) = 'p';
                end
            end
            if findstr(mesh.element_types,'s');
                fprintf(1,'....');
                grid(zone).pyr.i_pyr = find(node_zone.data(pyr.data(:,1)) == zone);
                grid(zone).pyr.n_pyr = length(grid(zone).pyr.i_pyr);
                grid(zone).n_elements = grid(zone).n_elements+grid(zone).pyr.n_pyr;
                if grid(zone).pyr.n_pyr > 0
                    grid(zone).element_types(end+1) = 's';
                end
            end
            if findstr(mesh.element_types,'t');
                fprintf(1,'....');
                grid(zone).tet.i_tet = find(node_zone.data(tet.data(:,1)) == zone);
                grid(zone).tet.n_tet = length(grid(zone).tet.i_tet);
                grid(zone).n_elements = grid(zone).n_elements+grid(zone).tet.n_tet;
                if grid(zone).tet.n_tet > 0
                    grid(zone).element_types(end+1) = 't';
                end
            end
            fprintf(1,'\n');
        end
        
        
        % Close grid file
        [D,error_return] = ADF_Database_Close(mesh.ID,D);
        clear M N coordinates surface_data bnd_node_group node_zone mesh surface_groups
        clear bnd_node_zone bnd_quad_group bnd_quad_nodes bnd_tri_nodes bnd_tri_group
        
        fprintf(1,'Closing ADF grid file \n');
        
        if g_flag == 1
            fprintf(1,'Opening FieldView grid file \n');

            % Open FieldView file
            fid = fopen([file_root '.bin'],'w');
            fwrite(fid,66051,'int32');  % Write header
            fwrite_str80(fid,'FIELDVIEW');

            fwrite(fid,[3 0],'int32');  % Write version number
            fwrite(fid,1,'int32');  % This is a grid file
            fwrite(fid,0,'int32');  % FieldView requires that this is 0!

            % Write the grids
            fwrite(fid,n_zones,'int32');  % Write the number of zones

            % Write the boundary table
            fwrite(fid,size(surface,2),'int32');
            for i = 1:size(surface,2)
                % Not sure about handed-ness to leave it at the moment
                fwrite(fid,[0 0],'int32');
                fwrite_str80(fid,surface(i).name);
            end

            for zone = 1:n_zones
                fprintf(1,'Zone %d \n',zone);
                fprintf(1,'Writing nodes...\n');

                % Write out nodes
                fwrite(fid,[1001 grid(zone).n_nodes],'int32');
                fwrite(fid,grid(zone).node.nodes(:,1),'single');
                fwrite(fid,grid(zone).node.nodes(:,2),'single');
                fwrite(fid,grid(zone).node.nodes(:,3),'single');

                fprintf(1,'Writing faces');
                % Write out Boundary faces
                for i = 1:size(surface,2)
                    fprintf(1,'.');
                    if grid(zone).n_faces(i)
                        fwrite(fid,[1002 i grid(zone).n_faces(i)],'int32');
                        if findstr(grid(zone).face_types{i},'t')
                            for j = 1:grid(zone).tri(i).n_tri
                                fwrite(fid,[node_map(grid(zone).tri(i).i_tri(j,:)) 0],'int32');
                            end
                        end
                        if findstr(grid(zone).face_types{i},'q')
                            for j = 1:grid(zone).quad(i).n_quad
                                fwrite(fid,node_map(grid(zone).quad(i).i_quad(j,:)),'int32');
                            end
                        end
                    end
                end
                fprintf(1,'\n');

                fprintf(1,'Writing elements');
                % Write out elements types and numbers
                fwrite(fid,1003,'int32');
                if findstr(grid(zone).element_types,'t')
                    fwrite(fid,grid(zone).tet.n_tet,'int32');
                else
                    fwrite(fid,0,'int32');
                end
                if findstr(grid(zone).element_types,'h')
                    fwrite(fid,grid(zone).hex.n_hex,'int32');
                else
                    fwrite(fid,0,'int32');
                end
                if findstr(grid(zone).element_types,'p')
                    fwrite(fid,grid(zone).pri.n_pri,'int32');
                else
                    fwrite(fid,0,'int32');
                end
                if findstr(grid(zone).element_types,'s')
                    fwrite(fid,grid(zone).pyr.n_pyr,'int32');
                else
                    fwrite(fid,0,'int32');
                end

                % Now write out element nodes
                if findstr(grid(zone).element_types,'t')
                    c = 0;
                    for j = 1:grid(zone).tet.n_tet
                        c = c+1;
                        if c > (grid(zone).tet.n_tet/10)
                            fprintf(1,'.');
                            c = 0;
                        end
                        header = fv_encode_element_header(1,tet.wall(grid(zone).tet.i_tet(j),:));
                        fwrite(fid,header,'uint32');
                        fwrite(fid,node_map(tet.data(grid(zone).tet.i_tet(j),mapping.tet.nodes)),'int32');
                    end
                end
                if findstr(grid(zone).element_types,'h')
                    c = 0;
                    for j = 1:grid(zone).hex.n_hex
                        c = c+1;
                        if c > (grid(zone).hex.n_hex/10)
                            fprintf(1,'.');
                            c = 0;
                        end
                        header = fv_encode_element_header(2,hex.wall(grid(zone).hex.i_hex(j),:));
                        fwrite(fid,header,'uint32');
                        fwrite(fid,node_map(hex.data(grid(zone).hex.i_hex(j),mapping.hex.nodes)),'int32');
                    end
                end
                if findstr(grid(zone).element_types,'p')
                    c = 0;
                    for j = 1:grid(zone).pri.n_pri
                        c = c+1;
                        if c > (grid(zone).pri.n_pri/10)
                            fprintf(1,'.');
                            c = 0;
                        end
                        header = fv_encode_element_header(3,pri.wall(grid(zone).pri.i_pri(j),:));
                        fwrite(fid,header,'uint32');
                        fwrite(fid,node_map(pri.data(grid(zone).pri.i_pri(j),mapping.pri.nodes)),'int32');
                    end
                end
                if findstr(grid(zone).element_types,'s')
                    c = 0;
                    for j = 1:grid(zone).pyr.n_pyr
                        c = c+1;
                        if c > (grid(zone).pyr.n_pyr/10)
                            fprintf(1,'.');
                            c = 0;
                        end
                        header = fv_encode_element_header(4,pyr.wall(grid(zone).pyr.i_pyr(j),:));
                        fwrite(fid,header,'uint32');
                        fwrite(fid,node_map(pyr.data(grid(zone).pyr.i_tet(j),mapping.pyr.nodes)),'int32');
                    end
                end
                fprintf(1,'\n');
            end

            % Close grid file
            fclose(fid);
            fprintf(1,'Closing FieldView grid file \n');
        end
        clear hex tet pri pyr
        clear surface node_map mapping
    
        % Free up memory
        for zone = 1:n_zones
            fgrid(zone).n_nodes = grid(zone).n_nodes;
            fgrid(zone).i_nodes = grid(zone).node.i_nodes;
        end
        clear grid
        
        % For the unsteady solutions
        for f = 0:n_files 
            fprintf(1,'Reading ADF flow file %d',f);
            if f < 10
                uns_flow_file = [flow_file '.0' num2str(f)];
            elseif f == 100
                uns_flow_file = [flow_file '.00'];
            else
                uns_flow_file = [flow_file '.' num2str(f)];
            end
            
            % Open flow file
            [D,flow.ID,error_return] = ADF_Database_Open(uns_flow_file,'READ_ONLY','NATIVE',D);
            fprintf(1,'.');
            
            % Read in simulation time
            [D,time.ID,error_return] = ADF_Get_Node_ID(flow.ID,'cumulative_time',D);
            [D,time.data,error_return] = ADF_Read_All_Data(time.ID,D);
            fprintf(1,'.');
            
            % Read in flow data
            [D,variables.ID,error_return] = ADF_Get_Node_ID(flow.ID,'flow',D);
            [D,variables.dims,error_return] = ADF_Get_Dimension_Values(variables.ID,D);
            [D,variables.data,error_return] = ADF_Read_All_Data(variables.ID,D);
            variables.data = Strip_to_Array(variables.data,6);
            fprintf(1,'.');
            
            [D,flow.n_children,error_return] = ADF_Number_of_Children(flow.ID,D);
            [D,flow.n_children,flow.children,error_return] = ADF_Children_Names(flow.ID,1,flow.n_children,D.ADF_Name_Length,D);
            heat = 0;
            tad = 0;
            for i = 1:flow.n_children
                if strcmp(flow.children{i}(1:14),'wall heat flux')
                    heat = 1;
                end
                if strcmp(flow.children{i}(1:26),'adiabatic wall temperature')
                    tad = 1;
                end
            end
            
            if heat % If there is heat-flux data
                [D,qdot.ID,error_return] = ADF_Get_Node_ID(flow.ID,'wall heat flux',D);
                [D,qdot.data,error_return] = ADF_Read_All_Data(qdot.ID,D);
                fprintf(1,'.');
                
                variables.data(bnd_node_node.data,7) = qdot.data;
                variables.data(:,7) = variables.data(:,7)*q_ref;
            end
            if tad % If there is tad and htc data
                [D,taw.ID,error_return] = ADF_Get_Node_ID(flow.ID,'adiabatic wall temperature',D);
                [D,taw.data,error_return] = ADF_Read_All_Data(taw.ID,D);
                fprintf(1,'.');
                
                variables.data(bnd_node_node.data,8) = taw.data;
                
                [D,htc.ID,error_return] = ADF_Get_Node_ID(flow.ID,'heat-transfer coefficient',D);
                [D,htc.data,error_return] = ADF_Read_All_Data(htc.ID,D);
                fprintf(1,'.');
                
                variables.data(bnd_node_node.data,9) = htc.data;
            end
            
            % Remove Hydra non-dimensionalising
            variables.data(:,1) = variables.data(:,1)*rho_ref;
            variables.data(:,2:4) = variables.data(:,2:4)*u_ref;
            variables.data(:,5) = variables.data(:,5)*p_ref;
            fprintf(1,'\n');
            
            % Close flow file
            [D,error_return] = ADF_Database_Close(flow.ID,D);
            clear flow qdot taw htc
            fprintf(1,'Closing ADF flow file %d \n',f);
            fprintf(1,'Opening FieldView flow file %d \n',f);
            
            % Open FieldView results file
            if f < 10
                fid = fopen([file_root '0' num2str(f) '.bin'],'w');
            elseif f == 100
                fid = fopen([file_root '00.bin'],'w');
            else
                fid = fopen([file_root num2str(f) '.bin'],'w');
            end
            
            
            fwrite(fid,66051,'int32');  % Write header
            fwrite_str80(fid,'FIELDVIEW');

            fwrite(fid,[3 0],'int32');  % Write version number
            fwrite(fid,2,'int32');  % This is a mixed file
            fwrite(fid,0,'int32');  % FieldView requires that this is 0!

            fwrite(fid,[0.0 0.0 0.0 0.0],'single');  % These are not used in hydra

            fwrite(fid,n_zones,'int32');  % Write the number of zones

            % Write the variable names
            fwrite(fid,6+heat+2*tad,'int32');
            fwrite_str80(fid,'density');
            fwrite_str80(fid,'u_vel; velocity');
            fwrite_str80(fid,'v_vel');
            fwrite_str80(fid,'w_vel');
            fwrite_str80(fid,'pressure');
            fwrite_str80(fid,'turbulence');
            if heat
                fwrite_str80(fid,'heat flux');
            end
            if tad
                fwrite_str80(fid,'adiabatic wall temperature');
                fwrite_str80(fid,'heat-transfer coefficient');
            end

            % Write the boundary variable names
            fwrite(fid,0,'int32');

            for zone = 1:n_zones
                fprintf(1,'Zone %d \n',zone);
                fprintf(1,'Writing nodes...\n');
                % Write out nodes
                fwrite(fid,[1001 fgrid(zone).n_nodes],'int32');

                % Write out flow variables
                fwrite(fid,1004,'int32');
                fprintf(1,'Writing variables');
                for j = 1:(6+heat+2*tad)
                    fprintf(1,'.');
                    fwrite(fid,variables.data(fgrid(zone).i_nodes,j),'single');
                end
                fprintf(1,'\n');

                % Write out boundary variables header
                fwrite(fid,1006,'int32');
            end

            % Close results file
            fclose(fid);

        end
                    
        disp('Done!');
        
        % Write FieldView Region file
        % Convert units
        per_ang = abs(per_ang.data/pi*180);
        omega = omega/(2*pi);
        
        fid = fopen([file_root '.bin.fvreg'],'w');
        fprintf(fid,'FVREG 2 \n');
        fprintf(fid,'DATASET_COORD_TYPE      CYLINDRICAL \n');
        fprintf(fid,'MACHINE_AXIS            X \n');
        fprintf(fid,'ROTATION_ORIENTATION    CCW \n');
        fprintf(fid,'MACHINE_AXIS_VECTOR     1.0 0.0 0.0 \n');
        fprintf(fid,'ZERO_THETA_VECTOR       0.0 1.0 0.0 \n');
        fprintf(fid,'FACET_COUNT             180 \n');
        fprintf(fid,'VELOCITIES              1 \n');
        fprintf(fid,'velocity \n');
        
        for zone = 1:n_zones
            fprintf(fid,'BLADE_ROW \n');
            fprintf(fid,'   BLADES_PER_ROW %d \n',round(360/per_ang(zone)));
            fprintf(fid,'   WHEEL_SPEED %8.4f \n',omega(zone));
            fprintf(fid,'   PERIOD %8.4f \n',per_ang(zone));
            fprintf(fid,'   NUM_REGIONS 1 \n');
            fprintf(fid,'   REGION \n');
            fprintf(fid,'      Zone-%d \n',zone);
            fprintf(fid,'      NUM_GRIDS 1');
            fprintf(fid,'         %d \n',zone);
        end
        fclose(fid);
        
        
    else % Steady solution
        % We will write the steady solution using the unified file format
        
        % Set up ADF space 
        D = ADFI_Declarations;
        
        % Open files for grid actions
        [D,mesh.ID,error_return] = ADF_Database_Open(mesh_file,'READ_ONLY','NATIVE',D);
        fprintf(1,'Reading Hydra grid file');
        
        % Read the periodic angle
        [D,per_ang.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'periodic_angle',D);
        [D,per_ang.data,error_return] = ADF_Read_All_Data(per_ang.ID,D);
        fprintf(1,'.');
        
        % Check the element types in the mesh
        [D,mesh.element_types,mesh.bnd_element_types,error_return] = Catalogue_Elements(mesh.ID,D);
        fprintf(1,'.');
        
        % Read the surface groups
        [D,surface_groups.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'surface_groups',D);
        [D,surface_groups.dims,error_return] = ADF_Get_Dimension_Values(surface_groups.ID,D);
        [D,surface_groups.data,error_return] = ADF_Read_All_Data(surface_groups.ID,D);
        fprintf(1,'.');
        
        surface_groups.data = Strip_to_Array(surface_groups.data,surface_groups.dims(1));
        surface_groups.data = char(surface_groups.data);
        
        for i = 1:surface_groups.dims(2)
            j = 1;
            while ~strcmp(surface_groups.data(i,[j j+1]),'  ')
                name(j) = surface_groups.data(i,j);
                j = j+1;
            end
            while strcmp(surface_groups.data(i,j),' ');
                j = j+1;
            end
            surface(i).name = name;
            surface(i).type = surface_groups.data(i,j);
            clear name
        end
        
        % Read in node_coordinates
        [D,coordinates.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'node_coordinates',D);
        [D,coordinates.data,error_return] = ADF_Read_All_Data(coordinates.ID,D);
        [D,coordinates.dims,error_return] = ADF_Get_Dimension_Values(coordinates.ID,D);
        coordinates.data = Strip_to_Array(coordinates.data,3);
        fprintf(1,'.');
        
        % Read in node_zone pointers
        [D,node_zone.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'node-->zone',D);
        [D,node_zone.data,error_return] = ADF_Read_All_Data(node_zone.ID,D);
        [D,bnd_node_zone.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_node-->zone',D);
        [D,bnd_node_zone.data,error_return] = ADF_Read_All_Data(node_zone.ID,D);
        fprintf(1,'.');
        
        % Read in boundary node pointers
        [D,bnd_node_node.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_node-->node',D);
        [D,bnd_node_node.data,error_return] = ADF_Read_All_Data(bnd_node_node.ID,D);
        [D,bnd_node_group.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_node-->group',D);
        [D,bnd_node_group.data,error_return] = ADF_Read_All_Data(bnd_node_group.ID,D);  
        fprintf(1,'.');
        
        % Read in Element-->Node pointers
        if findstr(mesh.element_types,'h')
            [D,hex.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'hex-->node',D);
            [D,hex.dims,error_return] = ADF_Get_Dimension_Values(hex.ID,D);
            [D,hex.data,error_return] = ADF_Read_All_Data(hex.ID,D);
            hex.data = Strip_to_Array(hex.data,hex.dims(1));
            hex.wall = zeros(hex.dims(2),6);
            fprintf(1,'.');
        end
        if findstr(mesh.element_types,'p')
            [D,pri.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'pri-->node',D);
            [D,pri.dims,error_return] = ADF_Get_Dimension_Values(pri.ID,D);
            [D,pri.data,error_return] = ADF_Read_All_Data(pri.ID,D);
            pri.data = Strip_to_Array(pri.data,pri.dims(1));
            pri.wall = zeros(pri.dims(2),6);
            fprintf(1,'.');
        end
        if findstr(mesh.element_types,'s')
            [D,pyr.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'pyr-->node',D);
            [D,pyr.dims,error_return] = ADF_Get_Dimension_Values(pyr.ID,D);
            [D,pyr.data,error_return] = ADF_Read_All_Data(pyr.ID,D);
            pyr.data = Strip_to_Array(pyr.data,pyr.dims(1));
            pyr.wall = zeros(pyr.dims(2),6);
            fprintf(1,'.');
        end
        if findstr(mesh.element_types,'t')
            [D,tet.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'tet-->node',D);
            [D,tet.dims,error_return] = ADF_Get_Dimension_Values(tet.ID,D);
            [D,tet.data,error_return] = ADF_Read_All_Data(tet.ID,D);
            tet.data = Strip_to_Array(tet.data,tet.dims(1));
            tet.wall = zeros(tet.dims(2),4);
            fprintf(1,'.');
        end
        clear M N
        
        % Read in and sort surface elements
        if findstr(mesh.bnd_element_types,'t') 
            [D,bnd_tri_group.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_tri-->group',D);
            [D,bnd_tri_group.data,error_return] = ADF_Read_All_Data(bnd_tri_group.ID,D);
            [D,bnd_tri_nodes.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_tri-->node',D);
            [D,bnd_tri_nodes.data,error_return] = ADF_Read_All_Data(bnd_tri_nodes.ID,D);
            bnd_tri_nodes.data = Strip_to_Array(bnd_tri_nodes.data,3);
            fprintf(1,'.');
        end
        if findstr(mesh.bnd_element_types,'q') 
            [D,bnd_quad_group.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_quad-->group',D);
            [D,bnd_quad_group.data,error_return] = ADF_Read_All_Data(bnd_quad_group.ID,D);
            [D,bnd_quad_nodes.ID,error_return] = ADF_Get_Node_ID(mesh.ID,'bnd_quad-->node',D);
            [D,bnd_quad_nodes.data,error_return] = ADF_Read_All_Data(bnd_quad_nodes.ID,D);
            bnd_quad_nodes.data = Strip_to_Array(bnd_quad_nodes.data,4);
            fprintf(1,'.');
        end
        fprintf(1,'\n');
        
        fprintf(1,'Sorting surface elements');
        for i = 1:surface_groups.dims(2)
            surface_data.group(i).element_types = ' ';
            surface_data.group(i).nodes = bnd_node_node.data(find(bnd_node_group.data == i));
            if findstr(mesh.bnd_element_types,'t')
                surface_data.group(i).element_types(end+1) = 't';
                surface_data.group(i).tri = bnd_tri_nodes.data(find(bnd_tri_group.data == i),:);
            end
            if findstr(mesh.bnd_element_types,'q')
                surface_data.group(i).element_types(end+1) = 'q';
                surface_data.group(i).quad = bnd_quad_nodes.data(find(bnd_quad_group.data == i),:);
            end
            % Check for tri elements in the quads!
            check = surface_data.group(i).quad(:,1) == surface_data.group(i).quad(:,4);
            if isempty(findstr(mesh.bnd_element_types,'t')) & find(check)
                surface_data.group(i).element_types(end+1) = 't';
                surface_data.group(i).tri = surface_data.group(i).quad(check,1:3);
            elseif findstr(mesh.bnd_element_types,'t') & find(check)
                surface_data.group(i).tri(end+1:end+length(find(check)),:) = surface_data.group(i).quad(find(check),1:3);
            end
            % Remove these elements from quads.
            surface_data.group(i).quad = surface_data.group(i).quad(find(1-check),:);
            surface(i).element_types = surface_data.group(i).element_types;
            fprintf(1,'.');
        end
        clear check
        fprintf(1,'\n');
        
        % Build FieldView wall data
        blocking_mask = bnd_node_group.data*0;
        for i = 1:size(surface,2)
            if strcmp(surface(i).type,'v') | strcmp(surface(i).type,'i')
                blocking_mask = blocking_mask+bnd_node_group.data == i;
            end
        end
        blocking_nodes = find(blocking_mask);
        blocking_nodes = bnd_node_node.data(blocking_nodes); % These are the boundary nodes on a blocking boundary
        clear blocking_mask
        
        fprintf(1,'Building wall arrays (be patient) \n');
        % For each of these nodes, find the elements which they are in and build the wall map for them
        if findstr(mesh.element_types,'h')
            h_data = hex.data*0;
        end
        if findstr(mesh.element_types,'t')
            t_data = tet.data*0;
        end
        if findstr(mesh.element_types,'p')
            p_data = pri.data*0;
        end
        if findstr(mesh.element_types,'s')
            s_data = pyr.data*0;
        end
        
        if findstr(mesh.element_types,'h')
            fprintf(1,'Hex elements');
            c = 0;
            for i = 1:size(hex.data,1)
                c = c+1;
                if c > size(hex.data,1)/30
                    fprintf(1,'.');
                    c = 0;
                end
                for j = 1:8
                    h_data(i,j) = sum(blocking_nodes==hex.data(i,j));
                end
            end
            for i = 1:8
                h_data(i,:) = h_data(i,:)*2^(i-1);
            end
            h_data = sum(h_data,2);
            hex.wall(:,1) = 7*(bitand(h_data,153) == 153);
            hex.wall(:,2) = 7*(bitand(h_data,102) == 102);
            hex.wall(:,3) = 7*(bitand(h_data,15) == 15);
            hex.wall(:,4) = 7*(bitand(h_data,240) == 240);
            hex.wall(:,5) = 7*(bitand(h_data,51) == 51);
            hex.wall(:,6) = 7*(bitand(h_data,204) == 204);
            fprintf(1,'\n');
            clear h_data
        end
        
        if findstr(mesh.element_types,'t')
            fprintf(1,'Tet elements');
            c = 0;
            for i = 1:size(tet.data,1)
                c = c+1;
                if c > size(tet.data,1)/30
                    fprintf(1,'.');
                    c = 0;
                end
                for j = 1:4
                    t_data(i,j) = sum(blocking_nodes==tet.data(i,j));
                end
            end
            for i = 1:4
                t_data(i,:) = t_data(i,:)*2^(i-1);
            end
            t_data = sum(t_data,2);
            tet.wall(:,1) = 7*(bitand(t_data,7) == 7);
            tet.wall(:,2) = 7*(bitand(t_data,14) == 14);
            tet.wall(:,3) = 7*(bitand(t_data,13) == 13);
            tet.wall(:,4) = 7*(bitand(t_data,11) == 11);
            fprintf(1,'\n');
            clear t_data
        end
        
        if findstr(mesh.element_types,'p')
            fprintf(1,'Pri elements');
            c = 0;
            for i = 1:size(pri.data,1)
                c = c+1;
                if c > size(pri.data,1)/30
                    fprintf(1,'.');
                    c = 0;
                end
                for j = 1:6
                    p_data(i,j) = sum(blocking_nodes==pri.data(i,j));
                end
            end
            for i = 1:6
                p_data(i,:) = p_data(i,:)*2^(i-1);
            end
            p_data = sum(p_data,2);
            pri.wall(:,1) = 7*(bitand(p_data,15) == 15);
            pri.wall(:,2) = 7*(bitand(p_data,51) == 51);
            pri.wall(:,3) = 7*(bitand(p_data,60) == 60);
            pri.wall(:,4) = 7*(bitand(p_data,41) == 41);
            pri.wall(:,5) = 7*(bitand(p_data,22) == 22);
            fprintf(1,'\n');
            clear p_data
        end
        
        if findstr(mesh.element_types,'s')
            fprintf(1,'Pyr elements');
            c = 0;
            for i = 1:size(pyr.data,1)
                c = c+1;
                if c > size(pyr.data,1)/30
                    fprintf(1,'.');
                    c = 0;
                end
                for j = 1:5
                    s_data(i,j) = sum(blocking_nodes==pyr.data(i,j));
                end
            end
            for i = 1:5
                s_data(i,:) = s_data(i,:)*2^(i-1);
            end
            s_data = sum(s_data,2);
            pyr.wall(:,1) = 7*(bitand(s_data,15) == 15);
            pyr.wall(:,2) = 7*(bitand(s_data,22) == 22);
            pyr.wall(:,3) = 7*(bitand(s_data,28) == 28);
            pyr.wall(:,4) = 7*(bitand(s_data,25) == 25);
            pyr.wall(:,5) = 7*(bitand(s_data,19) == 19);
            fprintf(1,'\n');
            clear s_data
        end
        clear blocking_nodes
        
        % Sort nodes, elements and faces into zones
        for zone = 1:n_zones
            fprintf(1,'Zone %d \n',zone);
            fprintf(1,'Sorting nodes into zones........... \n');
            % Sort nodes
            grid(zone).node.i_nodes = find(node_zone.data == zone);
            grid(zone).node.nodes = coordinates.data(grid(zone).node.i_nodes,:);
            node_map(grid(zone).node.i_nodes) = [1:length(grid(zone).node.i_nodes)];
            M = size(grid(zone).node.nodes,1);
            grid(zone).n_nodes = M;
            
            fprintf(1,'Sorting faces into zones');
            % Sort faces
            for i = 1:size(surface,2)
                grid(zone).n_faces(i) = 0;
                grid(zone).face_types{i} = ' ';
                if findstr(surface_data.group(i).element_types,'t')
                    if find(node_zone.data(surface_data.group(i).tri(1,1)) == zone);
                        grid(zone).tri(i).i_tri = surface_data.group(i).tri;
                        grid(zone).tri(i).n_tri = size(grid(zone).tri(i).i_tri,1);
                        grid(zone).n_faces(i) = grid(zone).n_faces(i)+grid(zone).tri(i).n_tri;
                        
                        grid(zone).face_types{i}(end+1) = 't';
                    end
                    fprintf(1,'.');
                end
                if findstr(surface_data.group(i).element_types,'q')
                    if find(node_zone.data(surface_data.group(i).quad(1,1)) == zone);
                        grid(zone).quad(i).i_quad = surface_data.group(i).quad;
                        grid(zone).quad(i).n_quad = size(grid(zone).quad(i).i_quad,1);
                        grid(zone).n_faces(i) = grid(zone).n_faces(i)+grid(zone).quad(i).n_quad;
                        
                        grid(zone).face_types{i}(end+1) = 'q';
                    end
                    fprintf(1,'.');
                end
            end  
            fprintf(1,'\n');
            
            fprintf(1,'Sorting elements into zones');
            % Sort elements
            grid(zone).n_elements = 0;
            grid(zone).element_types = ' ';
            if findstr(mesh.element_types,'h');
                fprintf(1,'....');
                grid(zone).hex.i_hex = find(node_zone.data(hex.data(:,1)) == zone);
                grid(zone).hex.n_hex = length(grid(zone).hex.i_hex);
                grid(zone).n_elements = grid(zone).n_elements+grid(zone).hex.n_hex;
                if grid(zone).hex.n_hex > 0
                    grid(zone).element_types(end+1) = 'h';
                end
            end
            if findstr(mesh.element_types,'p');
                fprintf(1,'....');
                grid(zone).pri.i_pri = find(node_zone.data(pri.data(:,1)) == zone);
                grid(zone).pri.n_pri = length(grid(zone).pri.i_pri);
                grid(zone).n_elements = grid(zone).n_elements+grid(zone).pri.n_pri;
                if grid(zone).pri.n_pri > 0
                    grid(zone).element_types(end+1) = 'p';
                end
            end
            if findstr(mesh.element_types,'s');
                fprintf(1,'....');
                grid(zone).pyr.i_pyr = find(node_zone.data(pyr.data(:,1)) == zone);
                grid(zone).pyr.n_pyr = length(grid(zone).pyr.i_pyr);
                grid(zone).n_elements = grid(zone).n_elements+grid(zone).pyr.n_pyr;
                if grid(zone).pyr.n_pyr > 0
                    grid(zone).element_types(end+1) = 's';
                end
            end
            if findstr(mesh.element_types,'t');
                fprintf(1,'....');
                grid(zone).tet.i_tet = find(node_zone.data(tet.data(:,1)) == zone);
                grid(zone).tet.n_tet = length(grid(zone).tet.i_tet);
                grid(zone).n_elements = grid(zone).n_elements+grid(zone).tet.n_tet;
                if grid(zone).tet.n_tet > 0
                    grid(zone).element_types(end+1) = 't';
                end
            end
        end
        fprintf(1,'\n');
        
        % Close grid file
        [D,error_return] = ADF_Database_Close(mesh.ID,D);
        clear M N coordinates surface_data bnd_node_group node_zone mesh surface_groups
        clear bnd_node_zone bnd_quad_group bnd_quad_nodes bnd_tri_nodes bnd_tri_group
        fprintf(1,'Closing Hydra grid file\n');
        fprintf(1,'Reading Hydra flow file');
        
        % Open flow file
        [D,flow.ID,error_return] = ADF_Database_Open(flow_file,'READ_ONLY','NATIVE',D);
        fprintf(1,'.');
        
        % Read in flow data
        [D,variables.ID,error_return] = ADF_Get_Node_ID(flow.ID,'flow',D);
        [D,variables.dims,error_return] = ADF_Get_Dimension_Values(variables.ID,D);
        [D,variables.data,error_return] = ADF_Read_All_Data(variables.ID,D);
        variables.data = Strip_to_Array(variables.data,6);
        fprintf(1,'.');
        
        [D,flow.n_children,error_return] = ADF_Number_of_Children(flow.ID,D);
        [D,flow.n_children,flow.children,error_return] = ADF_Children_Names(flow.ID,1,flow.n_children,D.ADF_Name_Length,D);
        heat = 0;
        tad = 0;
        for i = 1:flow.n_children
            if strcmp(flow.children{i}(1:14),'wall heat flux')
                heat = 1;
            end
            if strcmp(flow.children{i}(1:26),'adiabatic wall temperature')
                tad = 1;
            end
        end

        if heat % If there is heat-flux data
            [D,qdot.ID,error_return] = ADF_Get_Node_ID(flow.ID,'wall heat flux',D);
            [D,qdot.data,error_return] = ADF_Read_All_Data(qdot.ID,D);
            fprintf(1,'.');

            variables.data(bnd_node_node.data,7) = qdot.data;
            variables.data(:,7) = variables.data(:,7)*q_ref;
        end
        if tad % If there is tad and htc data
            [D,taw.ID,error_return] = ADF_Get_Node_ID(flow.ID,'adiabatic wall temperature',D);
            [D,taw.data,error_return] = ADF_Read_All_Data(taw.ID,D);
            fprintf(1,'.');

            variables.data(bnd_node_node.data,8) = taw.data;

            [D,htc.ID,error_return] = ADF_Get_Node_ID(flow.ID,'heat-transfer coefficient',D);
            [D,htc.data,error_return] = ADF_Read_All_Data(htc.ID,D);
            fprintf(1,'.');

            variables.data(bnd_node_node.data,9) = htc.data;
        end

        % Remove Hydra non-dimensionalising
        variables.data(:,1) = variables.data(:,1)*rho_ref;
        variables.data(:,2:4) = variables.data(:,2:4)*u_ref;
        variables.data(:,5) = variables.data(:,5)*p_ref;
        fprintf(1,'\n');
        
        % Close flow file
        [D,error_return] = ADF_Database_Close(flow.ID,D);
        clear flow qdot taw htc
        fprintf(1,'Closing Hydra flow file \n');
        fprintf(1,'Opening FieldView file \n');
        
        % Open FieldView file
        fid = fopen([file_root '.bin'],'w');
        fwrite(fid,66051,'int32');  % Write header
        fwrite_str80(fid,'FIELDVIEW');
        
        fwrite(fid,[3 0],'int32');  % Write version number
        fwrite(fid,3,'int32');  % This is a mixed file
        fwrite(fid,0,'int32');  % FieldView requires that this is 0!
        
        fwrite(fid,[0.0 0.0 0.0 0.0],'single');  % These are not used in hydra
        
        fwrite(fid,n_zones,'int32');  % Write the number of zones
        
        % Write the boundary table
        fwrite(fid,size(surface,2),'int32');
        for i = 1:size(surface,2)
            % Not sure about handed-ness to leave it at the moment
            fwrite(fid,[0 0],'int32');
            fwrite_str80(fid,surface(i).name);
        end
        
        % Write the variable names
        fwrite(fid,6+heat+2*tad,'int32');
        fwrite_str80(fid,'density');
        fwrite_str80(fid,'u_vel; velocity');
        fwrite_str80(fid,'v_vel');
        fwrite_str80(fid,'w_vel');
        fwrite_str80(fid,'pressure');
        fwrite_str80(fid,'turbulence');
        if heat
            fwrite_str80(fid,'heat flux');
        end
        if tad
            fwrite_str80(fid,'adiabatic wall temperature');
            fwrite_str80(fid,'heat-transfer coefficient');
        end
        
        % Write the boundary variable names
        fwrite(fid,0,'int32');
        
        for zone = 1:n_zones
            fprintf(1,'Zone %d \n',zone);
            fprintf(1,'Writing nodes...\n');
            % Write out nodes
            fwrite(fid,[1001 grid(zone).n_nodes],'int32');
            fwrite(fid,grid(zone).node.nodes(:,1),'single');
            fwrite(fid,grid(zone).node.nodes(:,2),'single');
            fwrite(fid,grid(zone).node.nodes(:,3),'single');
            
            
            
            fprintf(1,'Writing faces');
            % Write out Boundary faces
            for i = 1:size(surface,2)
                fprintf(1,'.');
                if grid(zone).n_faces(i)
                    fwrite(fid,[1002 i grid(zone).n_faces(i)],'int32');
                    if findstr(grid(zone).face_types{i},'t')
                        for j = 1:grid(zone).tri(i).n_tri
                            fwrite(fid,[node_map(grid(zone).tri(i).i_tri(j,:)) 0],'int32');
                        end
                    end
                    if findstr(grid(zone).face_types{i},'q')
                        for j = 1:grid(zone).quad(i).n_quad
                            fwrite(fid,node_map(grid(zone).quad(i).i_quad(j,:)),'int32');
                        end
                    end
                end
            end
            fprintf(1,'\n');
            
            fprintf(1,'Writing elements');
            % Write out elements types and numbers
            fwrite(fid,1003,'int32');
            if findstr(grid(zone).element_types,'t')
                fwrite(fid,grid(zone).tet.n_tet,'int32');
            else
                fwrite(fid,0,'int32');    
            end
            if findstr(grid(zone).element_types,'h')
                fwrite(fid,grid(zone).hex.n_hex,'int32');
            else
                fwrite(fid,0,'int32'); 
            end
            if findstr(grid(zone).element_types,'p')
                fwrite(fid,grid(zone).pri.n_pri,'int32');
            else
                fwrite(fid,0,'int32'); 
            end
            if findstr(grid(zone).element_types,'s')
                fwrite(fid,grid(zone).pyr.n_pyr,'int32');
            else
                fwrite(fid,0,'int32'); 
            end
            
            % Now write out element nodes
            if findstr(grid(zone).element_types,'t')
                c = 0;
                for j = 1:grid(zone).tet.n_tet
                    c = c+1;
                    if c > (grid(zone).tet.n_tet/10)
                        fprintf(1,'.');
                        c = 0;
                    end
                    header = fv_encode_element_header(1,tet.wall(grid(zone).tet.i_tet(j),:));
                    fwrite(fid,header,'uint32');
                    fwrite(fid,node_map(tet.data(grid(zone).tet.i_tet(j),mapping.tet.nodes)),'int32');
                end   
            end
            if findstr(grid(zone).element_types,'h')
                c = 0;
                for j = 1:grid(zone).hex.n_hex
                    c = c+1;
                    if c > (grid(zone).hex.n_hex/10)
                        fprintf(1,'.');
                        c = 0;
                    end
                    header = fv_encode_element_header(2,hex.wall(grid(zone).hex.i_hex(j),:));
                    fwrite(fid,header,'uint32');
                    fwrite(fid,node_map(hex.data(grid(zone).hex.i_hex(j),mapping.hex.nodes)),'int32');
                end
            end
            if findstr(grid(zone).element_types,'p')
                c = 0;
                for j = 1:grid(zone).pri.n_pri
                    c = c+1;
                    if c > (grid(zone).pri.n_pri/10)
                        fprintf(1,'.');
                        c = 0;
                    end
                    header = fv_encode_element_header(3,pri.wall(grid(zone).pri.i_pri(j),:));
                    fwrite(fid,header,'uint32');
                    fwrite(fid,node_map(pri.data(grid(zone).pri.i_pri(j),mapping.pri.nodes)),'int32');
                end
            end
            if findstr(grid(zone).element_types,'s')
                c = 0;
                for j = 1:grid(zone).pyr.n_pyr
                    c = c+1;
                    if c > (grid(zone).pyr.n_pyr/10)
                        fprintf(1,'.');
                        c = 0;
                    end
                    header = fv_encode_element_header(4,pyr.wall(grid(zone).pyr.i_pyr(j),:));
                    fwrite(fid,header,'uint32');
                    fwrite(fid,node_map(pyr.data(grid(zone).pyr.i_tet(j),mapping.pyr.nodes)),'int32');
                end
            end
            fprintf(1,'\n');
            
            % Write out flow variables
            fwrite(fid,1004,'int32');
            fprintf(1,'Writing variables');
            for j = 1:(6+heat+2*tad)
                fprintf(1,'.');
                fwrite(fid,variables.data(grid(zone).node.i_nodes,j),'single');
            end
            fprintf(1,'\n');
            
            % Write out boundary variables header
            fwrite(fid,1006,'int32');
        end
        
        % Close combined file
        fclose(fid);
        
        disp('Done!');
        % Write FieldView Region file
        % Convert units
        per_ang = abs(per_ang.data/pi*180);
        omega = omega/(2*pi);
        
        fid = fopen([file_root '.bin.fvreg'],'wt');
        fprintf(fid,'FVREG 2 \n');
        fprintf(fid,'DATASET_COORD_TYPE      CYLINDRICAL \n');
        fprintf(fid,'MACHINE_AXIS            X \n');
        fprintf(fid,'ROTATION_ORIENTATION    CCW \n');
        fprintf(fid,'MACHINE_AXIS_VECTOR     1.0 0.0 0.0 \n');
        fprintf(fid,'ZERO_THETA_VECTOR       0.0 1.0 0.0 \n');
        fprintf(fid,'FACET_COUNT             180 \n');
        fprintf(fid,'VELOCITIES              1 \n');
        fprintf(fid,'velocity \n');
        
        for zone = 1:n_zones
            fprintf(fid,'BLADE_ROW \n');
            fprintf(fid,'   BLADES_PER_ROW %d \n',round(360/per_ang(zone)));
            fprintf(fid,'   WHEEL_SPEED %8.4f \n',omega(zone));
            fprintf(fid,'   PERIOD %8.4f \n',per_ang(zone));
            fprintf(fid,'   NUM_REGIONS 1 \n');
            fprintf(fid,'   REGION \n');
            fprintf(fid,'      Zone-%d \n',zone);
            fprintf(fid,'      NUM_GRIDS 1');
            fprintf(fid,'         %d \n',zone);
        end
        fclose(fid);
        
    end
otherwise
    disp('Unknown format, no files written.')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function header = fv_encode_element_header(element_ID,walls);

max_num_elem_faces = 6;
bits_per_wall = 3;
elem_type_bit_shift = max_num_elem_faces*bits_per_wall;
a_wall = 7;
not_a_wall = 0;

switch element_ID
case 1
    header = bitshift(1,elem_type_bit_shift);
    nfaces = 4;
case 2
    header = bitshift(4,elem_type_bit_shift);
    nfaces = 6;
case 3
    header = bitshift(3,elem_type_bit_shift);
    nfaces = 5;
case 4
    header = bitshift(2,elem_type_bit_shift);
    nfaces = 5;
otherwise
    error('Unknow element type.');
end

for i = 1:nfaces
    u = walls(i);
    if u > a_wall
        error('Bad wall value.');
    end
    
    header = bitor(header,bitshift(u,(i-1)*bits_per_wall));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fwrite_str80(fid,text_data);

output_data(1:80) = ' ';
output_data(1:length(text_data)) = text_data;

fwrite(fid,output_data,'uchar');
