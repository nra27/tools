
function [flow_data] = ADF_Read_Point(ID,flow_node,D)

% NB currently hard coded for 6 flow variables !!!!!!

% Non dimensional parameters
rho_ref = 1.226; 
p_ref = 101300; 
u_ref = sqrt(p_ref/rho_ref); 
q_ref = -p_ref^1.5/rho_ref^0.5;

% Set up pointers to extract the 6 flow parameters
data_start = (flow_node-1)*6 + 1;
data_end = (flow_node-1)*6 + 6;

% Read subset of the data
[D,flow_data,error_return] = ADF_Read_Block_Data(ID,data_start,data_end,D);

% Convert from R-R to SI units
flow_data = flow_data.*[rho_ref u_ref u_ref u_ref p_ref 1];
    