function [point_data,heat_data] = Read_ADF_Points(flow_file,flow_nodes);

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


    [D,solution.wall_heat_flux.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'wall heat flux',D);
    [D,solution.wall_heat_flux.data,error_return] = ADF_Read_All_Data(solution.wall_heat_flux.ID,D);
    disp('q_dot finished')
    [D,solution.htc.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'heat-transfer coefficient',D);
    [D,solution.htc.data,error_return] = ADF_Read_All_Data(solution.htc.ID,D);
    disp('htc finished')
    [D,solution.Taw.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'adiabatic wall temperature',D);
    [D,solution.Taw.data,error_return] = ADF_Read_All_Data(solution.Taw.ID,D);
    disp('Taw finished')
    
    heat_data = [solution.wall_heat_flux.data*q_ref; solution.Taw.data; solution.htc.data]';


% Close Solution file
[D,error_return] = ADF_Database_Close(solution.root.ID,D);
