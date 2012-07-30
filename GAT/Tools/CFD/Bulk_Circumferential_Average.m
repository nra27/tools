function average = Bulk_Circumferential_Average(x,r,flow_data,variable);
%
% average = Bulk_Circumferential_Average(x,r,flow_data,variable)
%
% This function generates the circumferential average of the flow data 'variable',
% defined at an axial and radial possition. Only works with single values of x and r.


% First of all convert flow data to r-theta
flow_data = Set_to_RTheta(flow_data);

% Next get indecies for radial slice
X_Big = x+0.005;
X_Lil = x-0.005;

Bigger = flow_data.coordinates(:,1) > X_Lil;
Smaller = flow_data.coordinates(:,1) < X_Big;

Radial_Slice = find(Bigger.*Smaller);

% Now get indecies for circumferential slice
slice_data.data_type = flow_data.data_type;
slice_data.coordinates = flow_data.coordinates(Radial_Slice,:);
slice_data.flow = flow_data.flow(Radial_Slice,:);

clear Bigger Smaller Radial_Slice

R_Big = r+0.005;
R_Lil = r-0.005;

Bigger = slice_data.coordinates(:,4) > R_Lil;
Smaller = slice_data.coordinates(:,4) < R_Big;

Circ_Slice = find(Bigger.*Smaller);

% Get the data for the circumferentail slice
circ_data.data_type = slice_data.data_type;
circ_data.coordinates = slice_data.coordinates(Circ_Slice,:);
circ_data.flow = slice_data.flow(Circ_Slice,:);

Min_Theta = min(circ_data.coordinates(:,5));
Max_Theta = max(circ_data.coordinates(:,5));

% Compose the theta array for search and convert to y,z
theta = linspace(Min_Theta,Max_Theta,20);
y = r*cos(theta);
z = r*sin(theta);

for i = 1:20
	index(i) = Find_Nearest_Node(x,y(i),z(i),flow_data.coordinates(:,1),flow_data.coordinates(:,2),flow_data.coordinates(:,3));
end

% Now get the required flow data
number_of_flow_variables = length(flow_data.data_type);
for i = 1:number_of_flow_variables
	if strcmp(flow_data.data_type{i},variable)
		flow_index = i;
	end
end

data = flow_data.flow(index,flow_index);
average = mean(data);