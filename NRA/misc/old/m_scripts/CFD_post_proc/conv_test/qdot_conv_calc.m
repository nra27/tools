%
% Overtip heat transfer convergence calc
%

% Windows root
WIN_ROOT = 'H:\RT27a\3D\HPB\grid_2.2';

% Linux root
% LIN_ROOT  = '/home/nra/hydra/RT27a/3D/HPB/grid_2.2';

% Set the file names
% Windows
flow_file = [WIN_ROOT '\conv_test\4000\HPB_plain.flow.adf'];
grid_file = [WIN_ROOT '\grid_files\HPB_plain.grid.1.adf'];

% % LINUX 
% flow_file = [LIN_ROOT '/conv_test/4000/HPB_plain.flow.adf'];
% grid_file = [LIN_ROOT '/grid_files/HPB_plain.grid.1.adf'];

% Open up the files to get the full coordinate data - ooops didn't save it
% in the data struct
warning off
[surface_data,flow_data] = Read_ADF_Data(grid_file,flow_file,1);
load grid_2.2_conv_test_data.mat
warning on

% Add R-theta coordinates
flow_data = Set_to_RTheta(flow_data);

% Blade leading edge
x_LE = 0.0536;

% Casing nodes
casing_nodes = surface_data.group(3).flow_node_numbers;
casing_coordinates = flow_data.coordinates(casing_nodes,:);

cax = 0.02435;
w = 0.0003;
x_LE = 0.0536;

cut_percent = linspace(-20,79,8);

% cut = 0.05;
cut = x_LE+cut_percent./100.*cax;

r =1;

for r = 1:40,
    % Slices at the gauge locations

    for i = 1:length(cut),
        temp = find(and(casing_coordinates(:,1)>cut(i)-w,casing_coordinates(:,1)<cut(i)+w ) );
        eval(['cut_' num2str(i) '=casing_nodes(temp);'])
        eval(['casing_cut_' num2str(i) '=temp;'])

        %
        % Take the qdot from each solution in turn
        %

        q_dot_temp = data(r).qdot(temp);
        x_temp = flow_data.coordinates(casing_nodes(temp),2);

        % jitter the repeated data points
        for j = 1:length(q_dot_temp),
            repeat = find(q_dot_temp==q_dot_temp(j));
            [m,n] = size(repeat);
            if m>1,
                q_dot_temp(j) =  q_dot_temp(j) + 0.00001;
            else
            end
        end

        % jitter the repeated data points
        for k = 1:length(q_dot_temp),
            repeat = find(x_temp==x_temp(k));
            [m,n] = size(repeat);
            if m>1,
                x_temp(k) =  x_temp(k) + 0.0000000001;
            else
            end
        end

        x_lin = linspace(min(x_temp),max(x_temp),144);
        q_dot_spline(m,:) = interp1(x_temp,q_dot_temp,x_lin,'linear')';
        x_lin = x_lin';
        
        eval(['q_dot_' num2str(i) '(' num2str(r) ',:)= [q_dot_spline q_dot_spline q_dot_spline];'])
        eval(['x_' num2str(i) '= [x_lin-(max(x_lin)-min(x_lin)) x_lin x_lin+(max(x_lin)-min(x_lin))];'])
       
        
    end
    
r = r+1;
end


