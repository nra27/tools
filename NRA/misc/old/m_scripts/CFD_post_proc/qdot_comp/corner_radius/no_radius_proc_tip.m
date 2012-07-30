%
% Setup the workspace
%

    % Windows or Linux?
    [ROOT] = FindHYDRA;

    % Top of the solution tree
    SOL_DIR = '/gat_noradius_test';

%
% ReadADF
%
    % Set the file names
    flow_file = [ROOT SOL_DIR '/test.flow.adf'];
    grid_file = [ROOT SOL_DIR '/test.grid.1.adf'];        
    heat = 1;

    % Open up the file
    warning off
    [surface_data,flow_data] = Read_ADF_Data(grid_file,flow_file,heat);
    warning on 

% Add R-theta coordinates
flow_data = Set_to_RTheta(flow_data);

% Blade leading edge
x_LE = 0.0536;

% Casing nodes
blade_nodes = surface_data.group(5).flow_node_numbers;
blade_coordinates = flow_data.coordinates(blade_nodes,:);

blade_nodes = blade_nodes(end-5000:end);
blade_coordinates = blade_coordinates(end-5000:end,:);




cax = 0.02435;
w = 0.0003;
x_LE = 0.0536;

cut_percent = linspace(-20,79,8);

% cut = 0.05;
cut = x_LE+cut_percent./100.*cax;

% Slices at the gauge locations
for i = 3:length(cut),
   temp = find(and(blade_coordinates(:,1)>cut(i)-w,blade_coordinates(:,1)<cut(i)+w ) );
   eval(['blade_' num2str(i) '=blade_nodes(temp);'])
   eval(['blade_cut_' num2str(i) '=temp;'])
   
   q_dot_temp = surface_data.group(5).wall_heat_flux(temp);
   x_temp = flow_data.coordinates(blade_nodes(temp),2);
   theta_temp = flow_data.coordinates(blade_nodes(temp),5);
   
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
            theta_temp(k) =  theta_temp(k) + 0.0000000001;
        else
        end
   end

x_lin = linspace(min(x_temp),max(x_temp),144);
theta_lin = linspace(min(theta_temp),max(theta_temp),144)';
q_dot_spline = interp1(x_temp,q_dot_temp,x_lin,'linear')';
x_lin = x_lin';
 
eval(['q_dot_' num2str(i) '_no_rad = [q_dot_spline;];'])
eval(['x_' num2str(i) '= x_lin;'])
eval(['theta_' num2str(i) '= [theta_lin;];'])

end

% %
% % EXPERIMENTAL DATA
% %
% 
% load([ROOT SOL_DIR '/HTR_build1.mat'])
% 
% d_theta_gauge = (0.001/0.277)/(2*pi)*360;
% 
%
% plotting
%

for n = 3:8,
   subplot(2,3,n-2)
    title([num2str(round(cut_percent(n))) '% of C_a_x'])
    ylabel('Heat flux Wm^{-2}')
    xlabel('\theta (\circ) ')
    % CFD
    eval(['h = plot(x_' num2str(n) '/0.277*360/(2*pi)+1.1,q_dot_' num2str(n) '_no_rad);'])
    set(h,'color','red','linewidth',1)
    grid on

    a = axis;
    axis([ a(1) a(2) 0e5 3.5e4])
    hold on

end
