%function Casing_line_plotter(flow_file,grid_file)

%
% Read the ADF file
%
%[surface_data,flow_data] = Read_ADF_Data(grid_file,flow_file);
     
% Add R-theta coordinates
flow_data = Set_to_RTheta(flow_data);

% Blade leading edge
x_LE = 0.0536;

% Casing nodes are in group 3 for this grid
casing_nodes = surface_data.group(3).flow_node_numbers;
casing_coordinates = flow_data.coordinates(casing_nodes,:);

cax = 0.02435;
w = 0.0003; % width of the region in which the data is collected for each gauge line
x_LE = 0.0536;

cut_percent = linspace(-20,79,8);

% cut positions
cut = x_LE+cut_percent./100.*cax;

% Slices at the gauge locations
for i = 1:length(cut),
   temp = find(and(casing_coordinates(:,1)>cut(i)-w,casing_coordinates(:,1)<cut(i)+w ) );
   eval(['cut_' num2str(i) '=casing_nodes(temp);'])
   eval(['casing_cut_' num2str(i) '=temp;'])
   
   q_dot_temp = flow_data.flow(casing_nodes(temp),7);
   x_temp = flow_data.coordinates(casing_nodes(temp),2);
   theta_temp = flow_data.coordinates(casing_nodes(temp),5);
   
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

eval(['q_dot_' num2str(i) '= [q_dot_spline; q_dot_spline; q_dot_spline;];'])
   
eval(['x_' num2str(i) '= [x_lin-(max(x_lin)-min(x_lin)); x_lin; x_lin+(max(x_lin)-min(x_lin)) ];'])
eval(['theta_' num2str(i) '= [theta_lin-(max(theta_lin)-min(theta_lin)); theta_lin; theta_lin+(max(theta_lin)-min(theta_lin))];'])

end

% %
% % EXPERIMENTAL DATA
% %
% 
% load([ SOL_DIR '/HTR_build1.mat'])
% 
% d_theta_gauge = (0.001/0.277)/(2*pi)*360;

%
% plotting
%

for n = 1:8,
    subplot(2,4,n)
      
%     % Experimental Data
%     hold on
%     plot(linspace(0,24,576)+(n-1)*d_theta_gauge-4+16*d_theta_gauge,[Qdot(:,48+[n]);Qdot(:,48+[n]);Qdot(:,48+[n]);Qdot(:,48+[n]);],'r')
%     plot(linspace(0,24,576)+(n-1)*d_theta_gauge-4+8*d_theta_gauge,[Qdot(:,40+[n]);Qdot(:,40+[n]);Qdot(:,40+[n]);Qdot(:,40+[n]);],'b')
%     plot(linspace(0,24,576)+(n-1)*d_theta_gauge-4-0*d_theta_gauge,[Qdot(:,32+[n]);Qdot(:,32+[n]);Qdot(:,32+[n]);Qdot(:,32+[n]);],'g')
%     plot(linspace(0,24,576)+(n-1)*d_theta_gauge-4-8*d_theta_gauge,[Qdot(:,24+[n]);Qdot(:,24+[n]);Qdot(:,24+[n]);Qdot(:,24+[n]);],'c')
%     plot(linspace(0,24,576)+(n-1)*d_theta_gauge-4-16*d_theta_gauge,[Qdot(:,16+[n]);Qdot(:,16+[n]);Qdot(:,16+[n]);Qdot(:,16+[n]);],'m')
%     plot(linspace(0,24,576)+(n-1)*d_theta_gauge-4-24*d_theta_gauge,[Qdot(:,8+[n]);Qdot(:,8+[n]);Qdot(:,8+[n]);Qdot(:,8+[n]);],'k')
%     plot(linspace(0,24,576)+(n-1)*d_theta_gauge-4-32*d_theta_gauge,[Qdot(:,0+[n]);Qdot(:,0+[n]);Qdot(:,0+[n]);Qdot(:,0+[n]);],'y')
%      axis([ -2 10 -1e5 5e5])
%     title([num2str(round(cut_percent(n))) '% of C_a_x'])
%     ylabel('Heat flux Wm^{-2}')
%     xlabel('\theta (\circ) ')

    % CFD
    eval(['h = plot(x_' num2str(n) '/0.277*360/(2*pi)+1.1,q_dot_' num2str(n) ');'])
    set(h,'color','cyan','linewidth',2)
    grid on
    axis([ -2 10 -1e5 5e5])
    a = axis; 

end