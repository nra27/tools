
% Setup the flow and grid files then open ADF Data
gridfile = 'D:\hydra\grid_2.2\grid_files\HPB_plain.grid.1.adf'
flowfile = 'D:\hydra\grid_2.2\std_output\HPB_plain_2000.flow.adf'
[surface_data,flow_data] = Read_ADF_Data(gridfile,flowfile,0);

omega = 933;
R = 287.1;
gamma = 1.4;

for k = 14,%[2:2:32 36:2:64],

    k 
    
    load(['D:\hydra\grid_2.2\post\ADF\ADF_coords_IN_plain_' num2str(k) '.mat'])
      
    [m,n] = size(index);
    
    for i = 1:m,
        for j = 1:n,      
            % strip data
            data.plane(k).IN.rho(i,j) = flow_data.flow(index(i,j),1);
            data.plane(k).IN.u(i,j) = flow_data.flow(index(i,j),2);
            data.plane(k).IN.v(i,j) = flow_data.flow(index(i,j),3);
            data.plane(k).IN.w(i,j) = flow_data.flow(index(i,j),4);
            data.plane(k).IN.p(i,j) = flow_data.flow(index(i,j),5); 
            data.plane(k).IN.spall(i,j) = flow_data.flow(index(i,j),6);       
        end
    end 

    % Coordinates
    data.plane(k).IN.x = x;    
    data.plane(k).IN.y = z; % Swap from padram to adf  coordinate systems
    data.plane(k).IN.z = y; % Swap from padram to adf  coordinate systems
    data.plane(k).IN.r = sqrt(z.^2+y.^2);
    data.plane(k).IN.theta = atan2(y,z);
    
    % x is pointing downstream, u is positive streamwise
    % z is up, w is +ve up
    % y is to the left, v is +ve to the left (looking upstream)
    
    %
    % Derived variables
    %
    
%     % Velocities
%     data.plane(k).LH.v_theta = data.plane(k).LH.w.*cos(data.plane(k).LH.theta) + data.plane(k).LH.v.*sin(data.plane(k).LH.theta);
%     data.plane(k).LH.v_r = data.plane(k).LH.w.*sin(data.plane(k).LH.theta) - data.plane(k).LH.v.*cos(data.plane(k).LH.theta);
%     data.plane(k).LH.v_theta_abs = data.plane(k).LH.v_theta - data.plane(k).LH.r*omega;
%     
%     % static temperature
%     data.plane(k).LH.T = data.plane(k).LH.p./(R.*data.plane(k).LH.rho);
% 
%     % Velocity
%     data.plane(k).LH.V_rel = sqrt(data.plane(k).LH.u.^2+data.plane(k).LH.v.^2+data.plane(k).LH.w.^2);
%     data.plane(k).LH.V_abs = sqrt(data.plane(k).LH.u.^2+data.plane(k).LH.v_r.^2+data.plane(k).LH.v_theta_abs.^2);
% 
%     % Mach number
%     data.plane(k).LH.M_rel = data.plane(k).LH.V_rel./sqrt(gamma*R*data.plane(k).LH.T);
%     data.plane(k).LH.M_abs = data.plane(k).LH.V_abs./sqrt(gamma*R*data.plane(k).LH.T);
%     
%     % Total pressure
%     data.plane(k).LH.P_rel = data.plane(k).LH.p.*(1+(gamma-1)/2.*data.plane(k).LH.M_rel).^(gamma/(gamma-1));
%     data.plane(k).LH.P_abs = data.plane(k).LH.p.*(1+(gamma-1)/2.*data.plane(k).LH.M_abs).^(gamma/(gamma-1));
%    
%     % Total temperature
%     data.plane(k).LH.T0_rel = data.plane(k).LH.T.*(1+(gamma-1)/2.*data.plane(k).LH.M_rel);
%     data.plane(k).LH.T0_abs = data.plane(k).LH.T.*(1+(gamma-1)/2.*data.plane(k).LH.M_abs);
%     
%     % x-vorticity
%     x_vort = NaN*ones(m,n); % initialise the matrix, with a ring of NaN to help ploting
%     v_theta = data.plane(k).LH.v_theta;
%     v_r = data.plane(k).LH.v_r;
%     r = data.plane(k).LH.r;
%     theta = data.plane(k).LH.theta;
%    
%     for i = 2:m-1,
%         for j = 2:n-1,   
%             
%             u1 = -v_theta(i-1,j-1);
%             u2 = -v_theta(i,j-1);
%             u3 = -v_r(i+1,j-1);
%             u4 = -v_r(i+1,j);
%             u5 = v_theta(i+1,j+1);
%             u6 = v_theta(i,j+1);
%             u7 = v_r(i-1,j+1);
%             u8 = v_r(i-1,j);
%             
%             edge1 = r(i,j-1)*abs(theta(i,j-1) - theta(i-1,j-1));
%             edge2 = r(i,j-1)*abs(theta(i+1,j-1) - theta(i,j-1));
%             edge3 = abs(r(i+1,j-1)-r(i+1,j));
%             edge4 = abs(r(i+1,j)-r(i+1,j+1));
%             edge5 = r(i+1,j+1)*abs(theta(i+1,j+1) - theta(i,j+1));
%             edge6 = r(i,j+1)*abs(theta(i-1,j+1) - theta(i,j+1));
%             edge7 = abs(r(i-1,j)-r(i-1,j+1));
%             edge8 = abs(r(i-1,j-1)-r(i-1,j));            
%             
%             Area(i,j) = r(i,j)*abs((r(i,j-1)-r(i,j+1)))*abs(theta(i-1,j)-theta(i+1,j));
%             
%             x_vort(i,j) = 1./Area(i,j)*sum( u1*edge1 + u2*edge2 + u3*edge3 + u4*edge4 + ...
%                                             u5*edge5 + u6*edge6 + u7*edge7 + u8*edge8 );
%                                         
%         end
%     end 
%   
%     data.plane(k).LH.x_vort = x_vort;
%     
end

%save(['D:\hydra\grid_2.2\post\\ADF_data.mat'],'data')

% % % Setup the flow and grid files then open ADF Data
% % gridfile = 'D:\hydra\grid_2.2.step\grid_files\HPB_step.grid.1.adf'
% % flowfile = 'D:\hydra\grid_2.2.step\std_output\HPB_step_SG_2000.flow.adf'
% % [surface_data,flow_data] = Read_ADF_Data(gridfile,flowfile,0);
% 
% R = 287.1;
% gamma = 1.4;
% 
% for k = 1:12,
% 
%     load(['D:\hydra\grid_2.2\padram\ADF_coords_OUT_' num2str(k) '.mat'])
%     %load('D:\hydra\grid_2.2.step\ADF_data.mat')
%     
%     for i = 1:93,
%         
%         for j = 1:100,
%             
%             % strip data
%             data.plane(k).OUT.rho(i,j) = flow_data.flow(index(i,j),1);
%             data.plane(k).OUT.u(i,j) = flow_data.flow(index(i,j),2);
%             data.plane(k).OUT.v(i,j) = flow_data.flow(index(i,j),3);
%             data.plane(k).OUT.w(i,j) = flow_data.flow(index(i,j),4);
%             data.plane(k).OUT.p(i,j) = flow_data.flow(index(i,j),5); 
%             data.plane(k).OUT.spall(i,j) = flow_data.flow(index(i,j),6);
%             
%         end
%         
%     end
% 
%     data.plane(k).OUT.x = x;    
%     data.plane(k).OUT.y = y;
%     data.plane(k).OUT.z = z;
%     
%     % Derived variables
%     data.plane(k).OUT.V = sqrt(data.plane(k).OUT.u.^2+data.plane(k).OUT.v.^2+data.plane(k).OUT.w.^2);
%     data.plane(k).OUT.T = data.plane(k).OUT.p./(R.*data.plane(k).OUT.rho);
%     data.plane(k).OUT.M = data.plane(k).OUT.V./sqrt(gamma*R*data.plane(k).OUT.T);
%    
% end
% 
% %save(['D:\hydra\grid_2.2.step\ADF_data.mat'],'data')

