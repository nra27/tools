function flow_data = Calculate_Relative_To(flow_data);
%
% flow_data = Calculate_Relative_To(flow_data)
%
% A function to calculate the local flow total temperature
% for a hydra solution in the relative frame

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
	flow_data = Calculate_Mach_Number(flow_data);
	M = flow_data.flow(:,end);
end

% Check to see if temperature is already calculated
found = 0;

for i = 1:number_of_variables
	if strcmp(flow_data.data_type{i},'temperature')
		found = 1;
		T = flow_data.flow(:,i);
	end
end
if found == 0
	flow_data = Calculate_Temperature(flow_data);
	T = flow_data.flow(:,end);
end

% Calculate total temperature
gamma = 1.3906;

To = T.*(1+0.5*(gamma-1)*M.^2);

flow_data.data_type{end+1} = 'relative total temperature';
flow_data.flow(:,end+1) = To;