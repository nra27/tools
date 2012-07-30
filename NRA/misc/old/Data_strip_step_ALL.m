
% Setup the flow and grid files then open ADF Data
gridfile = 'D:\hydra\grid_2.2.step\grid_files\HPB_step.grid.1.adf'
flowfile = 'D:\hydra\grid_2.2.step\std_output\HPB_step_SG_2000.flow.adf'
[surface_data,flow_data] = Read_ADF_Data(gridfile,flowfile,0);

omega = 933;
R = 287.1;
gamma = 1.4;

pl = [2:2:20];

for k = 1:10,

    disp(['cut plane ' num2str(k) '....'])
        
    
    load(['D:\hydra\grid_2.2.step\post\ADF\comp\ADF_coords_IN_' num2str(pl(k)) '.mat'])
        
    [m,n] = size(index);
    
    for i = 1:m,
        for j = 1:n,      
            % strip data
            cut(k).rho(i,j) = flow_data.flow(index(i,j),1);
            cut(k).u(i,j) = flow_data.flow(index(i,j),2);
            cut(k).v(i,j) = flow_data.flow(index(i,j),3);
            cut(k).w(i,j) = flow_data.flow(index(i,j),4);
            cut(k).p(i,j) = flow_data.flow(index(i,j),5); 
            cut(k).spall(i,j) = flow_data.flow(index(i,j),6);       
        end
    end 

    % Coordinates
    cut(k).x = x;    
    cut(k).y = z; % Swap from padram to adf  coordinate systems
    cut(k).z = y; % Swap from padram to adf  coordinate systems
    cut(k).r = sqrt(z.^2+y.^2);
    cut(k).theta = atan2(y,z);
    
    % x is pointing downstream, u is positive streamwise
    % z is up, w is +ve up
    % y is to the left, v is +ve to the left (looking upstream)
    
    %
    % Derived variables
    %
    
    % Velocities
    cut(k).v_theta = cut(k).w.*cos(cut(k).theta) + cut(k).v.*sin(cut(k).theta);
    cut(k).v_r = cut(k).w.*sin(cut(k).theta) - cut(k).v.*cos(cut(k).theta);
    cut(k).v_theta_abs = cut(k).v_theta - cut(k).r*omega;
    
    % static temperature
    cut(k).T = cut(k).p./(R.*cut(k).rho);

    % Velocity
    cut(k).V_rel = sqrt(cut(k).u.^2+cut(k).v.^2+cut(k).w.^2);
    cut(k).V_abs = sqrt(cut(k).u.^2+cut(k).v_r.^2+cut(k).v_theta_abs.^2);

    % Mach number
    cut(k).M_rel = cut(k).V_rel./sqrt(gamma*R*cut(k).T);
    cut(k).M_abs = cut(k).V_abs./sqrt(gamma*R*cut(k).T);
    
    % Total pressure
    cut(k).P_rel = cut(k).p.*(1+(gamma-1)/2.*cut(k).M_rel).^(gamma/(gamma-1));
    cut(k).P_abs = cut(k).p.*(1+(gamma-1)/2.*cut(k).M_abs).^(gamma/(gamma-1));
   
    % Total temperature
    cut(k).T0_rel = cut(k).T.*(1+(gamma-1)/2.*cut(k).M_rel);
    cut(k).T0_abs = cut(k).T.*(1+(gamma-1)/2.*cut(k).M_abs);
    
    % x-vorticity
    x_vort = NaN*ones(m,n); % initialise the matrix, with a ring of NaN to help ploting
    v_theta = cut(k).v_theta;
    v_r = cut(k).v_r;
    r = cut(k).r;
    theta = cut(k).theta;
   
    for i = 2:m-1,
        for j = 2:n-1,   
            
            u1 = -v_theta(i-1,j-1);
            u2 = -v_theta(i,j-1);
            u3 = -v_r(i+1,j-1);
            u4 = -v_r(i+1,j);
            u5 = v_theta(i+1,j+1);
            u6 = v_theta(i,j+1);
            u7 = v_r(i-1,j+1);
            u8 = v_r(i-1,j);
            
            edge1 = r(i,j-1)*abs(theta(i,j-1) - theta(i-1,j-1));
            edge2 = r(i,j-1)*abs(theta(i+1,j-1) - theta(i,j-1));
            edge3 = abs(r(i+1,j-1)-r(i+1,j));
            edge4 = abs(r(i+1,j)-r(i+1,j+1));
            edge5 = r(i+1,j+1)*abs(theta(i+1,j+1) - theta(i,j+1));
            edge6 = r(i,j+1)*abs(theta(i-1,j+1) - theta(i,j+1));
            edge7 = abs(r(i-1,j)-r(i-1,j+1));
            edge8 = abs(r(i-1,j-1)-r(i-1,j));            
            
            Area(i,j) = r(i,j)*abs((r(i,j-1)-r(i,j+1)))*abs(theta(i-1,j)-theta(i+1,j));
            
            x_vort(i,j) = 1./Area(i,j)*sum( u1*edge1 + u2*edge2 + u3*edge3 + u4*edge4 + ...
                                            u5*edge5 + u6*edge6 + u7*edge7 + u8*edge8 );
                                        
        end
    end 
  
    cut(k).x_vort = x_vort;
    
end

%save(['D:\hydra\grid_2.2\post\\ADF_data.mat'],'data')

