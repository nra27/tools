function flow_data = Calculate_Temperature(flow_data,omega);
%
% flow_data = Caluculate_Temperature(flow_data,omega)
% 
% A function to calculate the local flow temperature
% for a hydra solution

flow_data.data_type{end+1} = 'temperature';

R = 287.1;
P = flow_data.flow(:,5);
rho = flow_data.flow(:,1);

T = P./(rho*R);

flow_data.flow(:,end+1) = T;