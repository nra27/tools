function [heat_data,point_data,data] = Read_ADF_Surface_Data_Points(flow_file,flow_nodes_root,num_f,surface_nodes_root,num_s);

% Non dimensional parameters
rho_ref = 1.226;
p_ref = 101300;
u_ref = sqrt(p_ref/rho_ref);
q_ref = -p_ref^1.5/rho_ref^0.5;

% Initialise ADF parameters
D = ADFI_Declarations;
[D,error_return] = ADF_Set_Error_State(1,D);

% Open Solution file(s)
  
[D,solution.root.ID,error_return] = ADF_Database_Open(flow_file,'READ_ONLY','NATIVE',D);
[D,solution.flow.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'flow',D);
[D,solution.flow.dim_vals,error_return] = ADF_Get_Dimension_Values(solution.flow.ID,D);

b_start = flow_nodes_root;
b_end = b_start+num_f*6-1;
    
[D,data,error_return] = ADF_Read_Block_Data(solution.flow.ID,b_start,b_end,D);
point_data = reshape(data,num_f,6);
point_data(:,1) = point_data(:,1)*rho_ref;
point_data(:,2:4) = point_data(:,2:4)*u_ref;
point_data(:,5) = point_data(:,5)*p_ref;

    % Set up pointers
    b_start = surface_nodes_root;
    b_end = b_start+num_s-1;

    [D,solution.wall_heat_flux.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'wall heat flux',D);
    [D,solution.wall_heat_flux.data,error_return] = ADF_Read_Block_Data(solution.wall_heat_flux.ID,b_start,b_end,D);
    disp('q_dot finished')
    [D,solution.htc.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'heat-transfer coefficient',D);
    [D,solution.htc.data,error_return] = ADF_Read_Block_Data(solution.htc.ID,b_start,b_end,D);
    disp('htc finished')
    [D,solution.Taw.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'adiabatic wall temperature',D);
    [D,solution.Taw.data,error_return] = ADF_Read_Block_Data(solution.Taw.ID,b_start,b_end,D);
    disp('Taw finished')
    
    heat_data = [solution.wall_heat_flux.data; solution.Taw.data; solution.htc.data]';

    %size(heat_data)
    
% point_data = [point_data; heat_data];

% Close Solution file
[D,error_return] = ADF_Database_Close(solution.root.ID,D);

