function [point_data] = Read_ADF_Surface_Points(flow_file,surface_flow_nodes);

%
% [flow_data] = Read_ADF_Points(flow_file,flow_nodes)
%

% Open Solution file(s)
% Non dimensional parameters
rho_ref = 1.226;
p_ref = 101300;
u_ref = sqrt(p_ref/rho_ref);
q_ref = -p_ref^1.5/rho_ref^0.5;

% Initialise ADF parameters
D = ADFI_Declarations;
[D,error_return] = ADF_Set_Error_State(1,D);
    
[D,solution.root.ID,error_return] = ADF_Database_Open(flow_file,'READ_ONLY','NATIVE',D);

% Read data
[D,solution.flow.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'flow',D);
[D,solution.flow.dim_vals,error_return] = ADF_Get_Dimension_Values(solution.flow.ID,D);

point_data = zeros(length(flow_nodes),solution.flow.dim_vals(1));

for k = 1:length(flow_nodes),
    % Set up pointers
    b_start = (flow_nodes(k)-1)*solution.flow.dim_vals(1)+1;
    b_end = b_start+5;
    [D,data,error_return] = ADF_Read_Block_Data(solution.flow.ID,b_start,b_end,D);
    point_data(k,:) = data.*[rho_ref u_ref u_ref u_ref p_ref 1];
end


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
