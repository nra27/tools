function flow_data = Calculate_Mach_Number(flow_data,omega);
%
% flow_data = Calculate_Mach_Number(flow_data,omega)
%
% A function to calculate the local absolute mach number
% for a hydra solution in the absolute frame

% Check to see if temperature is already calculated
number_of_variables = length(flow_data.data_type);
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

% Check to see if coordinates changed to r-theta
[M,N] = size(flow_data.coordinates);

if N == 3
    flow_data = Set_to_RTheta(flow_data);
end

r = flow_data.coordinates(:,4);
theta = flow_data.coordinates(:,5);

% Work out Mach number
R = 287.1;
gamma = 1.4;

u = flow_data.flow(:,2);
v = flow_data.flow(:,3);
w = flow_data.flow(:,4);

whirl = w.*cos(theta)-v.*sin(theta);
radial = w.*sin(theta)+v.*cos(theta);

U = sqrt(u.^2+(whirl+r*omega).^2+radial.^2);

M = U./sqrt((gamma*R*T));

flow_data.flow(:,end+1) = M;
flow_data.data_type{end+1} = 'mach number';