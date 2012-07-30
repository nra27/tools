function [surface_data,flow_data] = Read_ADF_Data(grid_file,flow_file,uns_files);

%
% [surface_data,flow_data] = Read_ADF_Data(grid_file,flow_file,n_files)
%
% This function reads the grid data file and the flow files,
% strips the surface node data and pairs it
% up with the flow data.  The stucture of data is:
%
% surface_data
%   +- surface_groups: cell array of names
%   |
%   +- group(i): the ith group
%       +- type: the type of the surface
%       +- surface_node_numbers: the surface node numbers for this group
%       +- flow_node_numbers: the bulk node numbers for this group
%       +- node_areas: the nodal areas for this group
%		+- node_normals: the i,j,k unit vector of the node normal
%
% flow_data
%   +- data_type: the name and order of the data stored {rho,u,v,w,p,nu,q}
%   +- coordinates: the (x,y,z) coordinates of the nodes in the domain
%   +- flow: the flow data (rho,u,v,w,p,nu,q) for this domain
%   +- (time: the solution time if unsteady) 
%
% If uns_files is 0, then it is assumed that the solution is steady.
% If uns_files is set to any other value or array, then those unsteady solutions
% are read in, using flow_file as the root.
%
%
% Modified by NRA to check for Taw and htc data 21-03-2007
%

% Non dimensional parameters
rho_ref = 1.226;
p_ref = 101300;
u_ref = sqrt(p_ref/rho_ref);
q_ref = -p_ref^1.5/rho_ref^0.5;

% Initialise ADF parameters
D = ADFI_Declarations;
[D,error_return] = ADF_Set_Error_State(1,D);

Handles.dlgbox = figure('units','points','position',[40 40 200 70],'windowstyle','normal',...
        'name','Read HYDRA ADF Data','buttondownfcn',[],'visible','on','resize','off',...
        'menubar','none','colormap',[],'numbertitle','off','doublebuffer','on','Tag','nozoom');
Handles.axes = axes('position',[0.1 0.35 0.8 0.2],'box','on','xtick',[],'ytick',[],'xlim',[0 1],'ylim',[0 1]);
Handles.line = line([-1 -1],[0.5 0.5]);
set(Handles.line,'color','b','linewidth',14);
set(Handles.line,'xdata',[-1 2]);

% Open Grid file
Handles.title = title('Reading Grid File');
pause(0.02);
[D,grid.root.ID,error_return] = ADF_Database_Open(grid_file,'READ_ONLY','NATIVE',D);

% Get surface group data
set(Handles.title,'string','Reading Node: surface groups');
pause(0.02);
[D,grid.surface_groups.ID,error_return] = ADF_Get_Node_ID(grid.root.ID,'surface_groups',D);
[D,grid.surface_groups.dim_vals,error_return] = ADF_Get_Dimension_Values(grid.surface_groups.ID,D);
[D,grid.surface_groups.data,error_return] = ADF_Read_All_Data(grid.surface_groups.ID,D);

grid.surface_groups.data = Strip_to_Array(grid.surface_groups.data,grid.surface_groups.dim_vals(1));
grid.surface_groups.data = char(grid.surface_groups.data);

set(Handles.title,'string','Sorting Group Names');
pause(0.02);
for i = 1:grid.surface_groups.dim_vals(2)
    j = 1;
    while ~strcmp(grid.surface_groups.data(i,[j j+1]),'  ')
        name(j) = grid.surface_groups.data(i,j);
        j = j+1;
    end
    while strcmp(grid.surface_groups.data(i,j),' ');
        j = j+1;
    end
    surface_data.surface_groups{i} = name;
    surface_data.group(i).type = grid.surface_groups.data(i,j);
    clear name
end

% Read surface node data
set(Handles.title,'string','Reading Node: bnd node-->group');
pause(0.02);
[D,grid.bnd_node_group.ID,error_return] = ADF_Get_Node_ID(grid.root.ID,'bnd_node-->group',D);
[D,grid.bnd_node_group.data,error_return] = ADF_Read_All_Data(grid.bnd_node_group.ID,D);

set(Handles.title,'string','Reading Node: bnd node-->node');
pause(0.02);
[D,grid.bnd_node_node.ID,error_return] = ADF_Get_Node_ID(grid.root.ID,'bnd_node-->node',D);
[D,grid.bnd_node_node.data,error_return] = ADF_Read_All_Data(grid.bnd_node_node.ID,D);

set(Handles.title,'string','Reading Node: node coordinates');
pause(0.02);
[D,grid.coordinates.ID,error_return] = ADF_Get_Node_ID(grid.root.ID,'node_coordinates',D);
[D,grid.coordinates.data,error_return] = ADF_Read_All_Data(grid.coordinates.ID,D);
[D,grid.coordinates.dim_vals,error_return] = ADF_Get_Dimension_Values(grid.coordinates.ID,D);
grid.coordinates.data = Strip_to_Array(grid.coordinates.data,grid.coordinates.dim_vals(1));
flow_data.coordinates = grid.coordinates.data;

set(Handles.title,'string','Reading Node: bnd node weights');
pause(0.02);
[D,grid.bnd_node_weights.ID,error_return] = ADF_Get_Node_ID(grid.root.ID,'bnd_node_weights',D);
[D,grid.bnd_node_weights.data,error_return] = ADF_Read_All_Data(grid.bnd_node_weights.ID,D);
[D,grid.bnd_node_weights.dim_vals,error_return] = ADF_Get_Dimension_Values(grid.bnd_node_weights.ID,D);
grid.bnd_node_weights.data = Strip_to_Array(grid.bnd_node_weights.data,grid.bnd_node_weights.dim_vals(1));

set(Handles.title,'string','Reading Node: bnd node normal');
pause(0.02);
[D,grid.bnd_node_normal.ID,error_return] = ADF_Get_Node_ID(grid.root.ID,'bnd_node_normal',D);
[D,grid.bnd_node_normal.data,error_return] = ADF_Read_All_Data(grid.bnd_node_normal.ID,D);
[D,grid.bnd_node_normal.dim_vals,error_return] = ADF_Get_Dimension_Values(grid.bnd_node_normal.ID,D);
grid.bnd_node_normal.data = Strip_to_Array(grid.bnd_node_normal.data,grid.bnd_node_normal.dim_vals(1));

% Create surface node area
grid.node_area = sqrt(sum((grid.bnd_node_weights.data.^2),2));

% Sort surface nodes into groups
set(Handles.title,'string','Sorting surface node grid data');
set(Handles.line,'xdata',[0 0]);
pause(0.02);
for i = 1:grid.surface_groups.dim_vals(2)
    set(Handles.line,'xdata',[0 i/grid.surface_groups.dim_vals(2)]);
    pause(0.02);
    surface_data.group(i).surface_node_numbers = find(grid.bnd_node_group.data == i)';
    surface_data.group(i).flow_node_numbers = grid.bnd_node_node.data(surface_data.group(i).surface_node_numbers)';
end

% Close Grid file
[D,error_return] = ADF_Database_Close(grid.root.ID,D);

% Open Solution file(s)

if exist('uns_files','var') == 0; % For single steady solution
    Handles.title = title('Reading Solution File');
    set(Handles.line,'xdata',[-1 2]);
    pause(0.02);
    
    [D,solution.root.ID,error_return] = ADF_Database_Open(flow_file,'READ_ONLY','NATIVE',D);
    
    % Read data
    set(Handles.title,'string','Reading Node: flow');
    pause(0.02);
    [D,solution.flow.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'flow',D);
    [D,solution.flow.dim_vals,error_return] = ADF_Get_Dimension_Values(solution.flow.ID,D);
    [D,solution.flow.data,error_return] = ADF_Read_All_Data(solution.flow.ID,D);
    solution.flow.data = Strip_to_Array(solution.flow.data,solution.flow.dim_vals(1));
    
    solution.flow.data(:,1) = solution.flow.data(:,1)*rho_ref;
    solution.flow.data(:,2:4) = solution.flow.data(:,2:4)*u_ref;
    solution.flow.data(:,5) = solution.flow.data(:,5)*p_ref;
    
    flow_data.data_type = {'density' 'u_velocity' 'v_velocity' 'w_velocity' 'pressure' 'spallart'};
    flow_data.flow = solution.flow.data;
    
    % Check to see if there is heat-transfer data
    heat = 0;
    [D,solution.root.n_children,error_return] = ADF_Number_of_Children(solution.root.ID,D);
    [D,solution.root.n_children,solution.root.children,error_return] = ADF_Children_Names(solution.root.ID,1,solution.root.n_children,D.ADF_Name_Length,D);
    for i = 1:solution.root.n_children
        if strcmp(solution.root.children{i}(1:14),'wall heat flux')
            heat = 1;
        end
    end
    if heat
        set(Handles.title,'string','Reading Node: wall heat flux');
        pause(0.02);
        [D,solution.wall_heat_flux.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'wall heat flux',D);
        [D,solution.wall_heat_flux.data,error_return] = ADF_Read_All_Data(solution.wall_heat_flux.ID,D);
        
        solution.wall_heat_flux.data = solution.wall_heat_flux.data*q_ref;
    end
    
    % Check to see if there is heat-transfer-coefficient data
    htc = 0;
    [D,solution.root.n_children,error_return] = ADF_Number_of_Children(solution.root.ID,D);
    [D,solution.root.n_children,solution.root.children,error_return] = ADF_Children_Names(solution.root.ID,1,solution.root.n_children,D.ADF_Name_Length,D);
    for i = 1:solution.root.n_children
        if strcmp(solution.root.children{i}(1:13),'heat-transfer')
            htc = 1;
        end
    end
    if htc 
        set(Handles.title,'string','Reading Node: htc');
        pause(0.02);
        [D,solution.htc.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'heat-transfer coefficient',D);
        [D,solution.htc.data,error_return] = ADF_Read_All_Data(solution.htc.ID,D);

    end
        
    % Check to see if there is Taw data
    Taw = 0;
    [D,solution.root.n_children,error_return] = ADF_Number_of_Children(solution.root.ID,D);
    [D,solution.root.n_children,solution.root.children,error_return] = ADF_Children_Names(solution.root.ID,1,solution.root.n_children,D.ADF_Name_Length,D);
    for i = 1:solution.root.n_children
        if strcmp(solution.root.children{i}(1:9),'adiabatic')
            Taw = 1;
        end
    end
    if Taw
        set(Handles.title,'string','Reading Node: Taw');
        pause(0.02);
        [D,solution.Taw.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'adiabatic wall temperature',D);
        [D,solution.Taw.data,error_return] = ADF_Read_All_Data(solution.Taw.ID,D);

    end
    
    
    % Close Solution file
    [D,error_return] = ADF_Database_Close(solution.root.ID,D);
    
    % Sort surface nodes into groups
    set(Handles.title,'string','Sorting surface node flow data');
    set(Handles.line,'xdata',[0 0]);
    pause(0.02);
    for i = 1:grid.surface_groups.dim_vals(2)
        set(Handles.line,'xdata',[0 i/grid.surface_groups.dim_vals(2)]);
        pause(0.02);
        surface_data.group(i).node_areas = grid.node_area(surface_data.group(i).surface_node_numbers);
        surface_data.group(i).node_normals = grid.bnd_node_normal.data(surface_data.group(i).surface_node_numbers,:);
        
        if heat         
            flow_data.data_type{7} = 'heat_flux';
            if length(surface_data.group(i).surface_node_numbers) ~= 0
                flow_data.flow(surface_data.group(i).flow_node_numbers,7) = solution.wall_heat_flux.data(surface_data.group(i).surface_node_numbers);
            end
        end

        if htc
            flow_data.data_type{8} = 'htc';
            if length(surface_data.group(i).surface_node_numbers) ~= 0
                flow_data.flow(surface_data.group(i).flow_node_numbers,8) = solution.htc.data(surface_data.group(i).surface_node_numbers);
            end
        end

        if Taw
            flow_data.data_type{9} = 'Taw';
            if length(surface_data.group(i).surface_node_numbers) ~= 0
                flow_data.flow(surface_data.group(i).flow_node_numbers,9) = solution.Taw.data(surface_data.group(i).surface_node_numbers);
            end
        end
    end
    
else % There are unsteady files to read
    for f = 1:length(uns_files)
        Handles.title = title(['Reading Solution File ' num2str(f)]);
        set(Handles.line,'xdata',[0 f/length(uns_files)]);
        pause(0.02);
        
        if uns_files(f) < 10
            filename = [flow_file '.0' num2str(uns_files(f))];
        else
            filename = [flow_file '.' num2str(uns_files(f))];
        end
        
        [D,solution.root.ID,error_return] = ADF_Database_Open(filename,'READ_ONLY','NATIVE',D);
        
        % Read data
        set(Handles.title,'string','Reading Node: flow');
        pause(0.02);
        [D,solution.flow.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'flow',D);
        [D,solution.flow.dim_vals,error_return] = ADF_Get_Dimension_Values(solution.flow.ID,D);
        [D,solution.flow.data,error_return] = ADF_Read_All_Data(solution.flow.ID,D);
        solution.flow.data = Strip_to_Array(solution.flow.data,solution.flow.dim_vals(1));
        
        solution.flow.data(:,1) = solution.flow.data(:,1)*rho_ref;
        solution.flow.data(:,2:4) = solution.flow.data(:,2:4)*u_ref;
        solution.flow.data(:,5) = solution.flow.data(:,5)*p_ref;
        
        flow_data.data_type = {'density' 'u_velocity' 'v_velocity' 'w_velocity' 'pressure' 'spallart'};
        flow_data.flow(:,1:6,f) = solution.flow.data;
        
        % Check to see if there is heat-transfer data
        heat = 0;
        [D,solution.root.n_children,error_return] = ADF_Number_of_Children(solution.root.ID,D);
        [D,solution.root.n_children,solution.root.children,error_return] = ADF_Children_Names(solution.root.ID,1,solution.root.n_children,D.ADF_Name_Length,D);
        for i = 1:solution.root.n_children
            if strcmp(solution.root.children{i}(1:14),'wall heat flux')
                heat = 1;
            end
        end
        if heat
            [D,solution.wall_heat_flux.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'wall heat flux',D);
            [D,solution.wall_heat_flux.data,error_return] = ADF_Read_All_Data(solution.wall_heat_flux.ID,D);
            
            solution.wall_heat_flux.data = solution.wall_heat_flux.data*q_ref;            
        end
        
        % Check to see if there is heat-transfer-coefficient data
        htc = 0;
        [D,solution.root.n_children,error_return] = ADF_Number_of_Children(solution.root.ID,D);
        [D,solution.root.n_children,solution.root.children,error_return] = ADF_Children_Names(solution.root.ID,1,solution.root.n_children,D.ADF_Name_Length,D);
        for i = 1:solution.root.n_children
            if strcmp(solution.root.children{i}(1:13),'heat-transfer')
                htc = 1;
            end
        end
        if htc
            [D,solution.htc.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'heat-transfer coefficient',D);
            [D,solution.htc.data,error_return] = ADF_Read_All_Data(solution.htc.ID,D);
                       
        end
        
        % Check to see if there is Taw data
        Taw = 0;
        [D,solution.root.n_children,error_return] = ADF_Number_of_Children(solution.root.ID,D);
        [D,solution.root.n_children,solution.root.children,error_return] = ADF_Children_Names(solution.root.ID,1,solution.root.n_children,D.ADF_Name_Length,D);
        for i = 1:solution.root.n_children
            if strcmp(solution.root.children{i}(1:9),'adiabatic')
                Taw = 1;
            end
        end
        if Taw
            [D,solution.Taw.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'adiabatic wall temperature',D);
            [D,solution.Taw.data,error_return] = ADF_Read_All_Data(solution.Taw.ID,D);
                       
        end
        
        
        % Read solution time
        [D,solution.time.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'cumulative_time',D);
        [D,flow_data.time(f),error_return] = ADF_Read_All_Data(solution.time.ID,D);
        
        % Close Solution file
        [D,error_return] = ADF_Database_Close(solution.root.ID,D);
        
        % Sort surface nodes into groups
        for i = 1:grid.surface_groups.dim_vals(2)
            surface_data.group(i).node_areas = grid.node_area(surface_data.group(i).surface_node_numbers);
            surface_data.group(i).node_normals = grid.bnd_node_normal.data(surface_data.group(i).surface_node_numbers,:);
            if heat         
                flow_data.data_type{7} = 'heat_flux';
                if length(surface_data.group(i).surface_node_numbers) ~= 0
                    flow_data.flow(surface_data.group(i).flow_node_numbers,7,f) = solution.wall_heat_flux.data(surface_data.group(i).surface_node_numbers);
                end
            end
            if htc         
                flow_data.data_type{8} = 'htc';
                if length(surface_data.group(i).surface_node_numbers) ~= 0
                    flow_data.flow(surface_data.group(i).flow_node_numbers,8,f) = solution.htc.data(surface_data.group(i).surface_node_numbers);
                end
            end
            if Taw         
                flow_data.data_type{9} = 'Taw';
                if length(surface_data.group(i).surface_node_numbers) ~= 0
                    flow_data.flow(surface_data.group(i).flow_node_numbers,9,f) = solution.Taw.data(surface_data.group(i).surface_node_numbers);
                end
            end
        end
    end
end

pause(1);
close(Handles.dlgbox);
