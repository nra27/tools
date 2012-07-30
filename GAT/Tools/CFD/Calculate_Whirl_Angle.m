function flow_data = Calculate_Whirl_Angle(flow_data,omega);
%
% flow_data = Calculate_Whirl_Angle(flow_data)
%
% A function to calculate the whirl angle of the flow
% in the output from hydra

% Check to see if coordinates changed to r-theta
[M,N] = size(flow_data.coordinates);

if N == 3
    flow_data = Set_to_RTheta(flow_data);
end

r = flow_data.coordinates(:,4);
theta = flow_data.coordinates(:,5);

% Get flow values
u = flow_data.flow(:,2);
v = flow_data.flow(:,3);
w = flow_data.flow(:,4);

V = v.*sin(theta);
W = w.*cos(theta);

% Calculate whirl angle
Phi = -atan2(u,(W-V+r*omega));

flow_data.data_type{end+1} = 'whirl angle';
flow_data.flow(:,end+1) = Phi;