function flow_data = Set_to_RTheta(flow_data);
%
% flow_data = Set_to_RTheta(flow_data)
%
% A short function to turn x,y,z data into x,r,theta data

flow_data.coordinates(:,4) = sqrt((flow_data.coordinates(:,2)).^2+(flow_data.coordinates(:,3)).^2);
flow_data.coordinates(:,5) = atan2(flow_data.coordinates(:,3),flow_data.coordinates(:,2));