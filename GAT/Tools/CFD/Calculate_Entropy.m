function flow_data = Calculate_Entropy(flow_data,omega);
%
% flow_data = Caluculate_Temperature(flow_data,omega)
% 
% A function to calculate the local flow entropy
% for a hydra solution.  The origin is taken as s.t.p.

% Check to see if entropy has already been calculated
number_of_variables = length(flow_data.data_type);
found = 0;
for i = 1:number_of_variables
	if strcmp(flow_data.data_type{i},'entropy')
		found = 1;
	end
end
if found == 0
	return
end

% We need to calculate entropy
flow_data.data_type{end+1} = 'entropy';

gamma = 1.4;
cp = 1004;
cv = cp/gamma;

P = flow_data.flow(:,5);
rho = flow_data.flow(:,1);

s = cv*log(P/1e5)+cp*log(1.2759./rho);

flow_data.flow(:,end+1) = s;