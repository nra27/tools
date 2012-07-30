function flow_data = Calculate_Po(flow_data,omega);
%
% flow_data = Calculate_Po(flow_data,omega)
%
% A function to calculate the local flow total pressure
% for a hydra solution in the absolute frame

% Check to see if mach number is already calculated
number_of_variables = length(flow_data.data_type);
found = 0;

for i = 1:number_of_variables
	if strcmp(flow_data.data_type{i},'mach number')
		found = 1;
		M = flow_data.flow(:,i);
	end
end
if found == 0
	flow_data = Calculate_Mach_Number(flow_data,omega);
	M = flow_data.flow(:,end);
end

% Calculate total pressure
gamma = 1.4;
P = flow_data.flow(:,5);
Po = P.*((1+0.5*(gamma-1)*M.^2).^(gamma/(gamma-1)));

flow_data.data_type{end+1} = 'total pressure';
flow_data.flow(:,end+1) = Po;