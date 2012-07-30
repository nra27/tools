
% Setup the flow and grid files then open ADF Data
gridfile = 'D:\hydra\grid_2.2\grid_files\HPB_plain.grid.1.adf'
flowfile = 'D:\hydra\grid_2.2\std_output\HPB_plain_2000.flow.adf'
%[surface_data,flow_data] = Read_ADF_Data(gridfile,flowfile,0);

omega = 933;
R = 287.1;
gamma = 1.4;

pl = [14:2:32 2:2:64];

for k = 11:13,

    disp(['plain plane ' num2str(k) '....'])
        
    if k < 10,
        load(['D:\hydra\grid_2.2\post\ADF\comp\ADF_coords_IN_' num2str(pl(k)) '.mat'])
        
        disp('IN')
        
        [m,n] = size(index);
        
        for i = 1:m,
            for j = 1:n,      
                % strip data
                plain(k).rho(i,j) = flow_data.flow(index(i,j),1);
                plain(k).u(i,j) = flow_data.flow(index(i,j),2);
                plain(k).v(i,j) = flow_data.flow(index(i,j),3);
                plain(k).w(i,j) = flow_data.flow(index(i,j),4);
                plain(k).p(i,j) = flow_data.flow(index(i,j),5); 
                plain(k).spall(i,j) = flow_data.flow(index(i,j),6);       
            end
        end 

        % Coordinates
        plain(k).x = x;    
        plain(k).y = z; % Swap from padram to adf  coordinate systems
        plain(k).z = y; % Swap from padram to adf  coordinate systems
        plain(k).r = sqrt(z.^2+y.^2);
        plain(k).theta = atan2(y,z);
        
    else
        
        disp('UH')
        
        load(['D:\hydra\grid_2.2\post\ADF\ADF_coords_UH_' num2str(pl(k)) '.mat'])
        
        [m,n] = size(index);
    
        for i = 1:m,
            for j = 1:n,      
                % strip data
                plain(k).rho(i,j) = flow_data.flow(index(i,j),1);
                plain(k).u(i,j) = flow_data.flow(index(i,j),2);
                plain(k).v(i,j) = flow_data.flow(index(i,j),3);
                plain(k).w(i,j) = flow_data.flow(index(i,j),4);
                plain(k).p(i,j) = flow_data.flow(index(i,j),5); 
                plain(k).spall(i,j) = flow_data.flow(index(i,j),6);       
            end
        end 

        % Coordinates
        plain(k).x = x;    
        plain(k).y = z; % Swap from padram to adf  coordinate systems
        plain(k).z = y; % Swap from padram to adf  coordinate systems
        plain(k).r = sqrt(z.^2+y.^2);
        plain(k).theta = atan2(y,z);
        
        disp('UH O')
        
        load(['D:\hydra\grid_2.2\post\ADF\ADF_coords_O_' num2str(146-pl(k)) '.mat'])
        
        [m,n] = size(index);
    
        for i = 1:m,
            for j = 1:n,      
                % strip data
                plain(k).rho(56-i,j) = flow_data.flow(index(i,j),1);
                plain(k).u(56-i,j) = flow_data.flow(index(i,j),2);
                plain(k).v(56-i,j) = flow_data.flow(index(i,j),3);
                plain(k).w(56-i,j) = flow_data.flow(index(i,j),4);
                plain(k).p(56-i,j) = flow_data.flow(index(i,j),5); 
                plain(k).spall(55-i+i,j) = flow_data.flow(index(i,j),6);   
                
                % Coordinates
                plain(k).x(56-i,:) = x(i,:);    
                plain(k).y(56-i,:) = z(i,:); % Swap from padram to adf  coordinate systems
                plain(k).z(56-i,:) = y(i,:); % Swap from padram to adf  coordinate systems
                plain(k).r(56-i,:) = sqrt(z(i,:).^2+y(i,:).^2);
                plain(k).theta(56-i,:) = atan2(y(i,:),z(i,:));
                
            end
        end 
        
%         disp('LH O')
%         
%         load(['D:\hydra\grid_2.2\post\ADF\ADF_coords_O_' num2str(pl(k)+4) '.mat'])
%         
%         [m,n] = size(index);
%     
%         for i = 1:m,
%             for j = 1:n,      
%                 % strip data
%                 plain(k).rho(56+i,j) = flow_data.flow(index(i,j),1);
%                 plain(k).u(56+i,j) = flow_data.flow(index(i,j),2);
%                 plain(k).v(56+i,j) = flow_data.flow(index(i,j),3);
%                 plain(k).w(56+i,j) = flow_data.flow(index(i,j),4);
%                 plain(k).p(56+i,j) = flow_data.flow(index(i,j),5); 
%                 plain(k).spall(55+i+i,j) = flow_data.flow(index(i,j),6);   
%                 
%                 % Coordinates
%                 plain(k).x(56+i,:) = x(i,:);    
%                 plain(k).y(56+i,:) = z(i,:); % Swap from padram to adf  coordinate systems
%                 plain(k).z(56+i,:) = y(i,:); % Swap from padram to adf  coordinate systems
%                 plain(k).r(56+i,:) = sqrt(z(i,:).^2+y(i,:).^2);
%                 plain(k).theta(56+i,:) = atan2(y(i,:),z(i,:));
%                 
%             end
%         end 
%         
%         disp('LH')
%         
%         load(['D:\hydra\grid_2.2\post\ADF\ADF_coords_LH_' num2str(pl(k)) '.mat'])
%         
%         [m,n] = size(index);
%     
%         for i = 1:m,
%             for j = 1:n,      
%                 % strip data
%                 plain(k).rho(i,j) = flow_data.flow(index(i,j),1);
%                 plain(k).u(i,j) = flow_data.flow(index(i,j),2);
%                 plain(k).v(i,j) = flow_data.flow(index(i,j),3);
%                 plain(k).w(i,j) = flow_data.flow(index(i,j),4);
%                 plain(k).p(i,j) = flow_data.flow(index(i,j),5); 
%                 plain(k).spall(i,j) = flow_data.flow(index(i,j),6);       
%             end
%         end 
% 
%         % Coordinates
%         plain(k).x = x;    
%         plain(k).y = z; % Swap from padram to adf  coordinate systems
%         plain(k).z = y; % Swap from padram to adf  coordinate systems
%         plain(k).r = sqrt(z.^2+y.^2);
%         plain(k).theta = atan2(y,z);
% 
end
% 
% 
% 
% % x is pointing downstream, u is positive streamwise
% % z is up, w is +ve up
% % y is to the left, v is +ve to the left (looking upstream)
% 
% %
% % Derived variables
% %
% 
% % Velocities
% plain(k).v_theta = plain(k).w.*cos(plain(k).theta) + plain(k).v.*sin(plain(k).theta);
% plain(k).v_r = plain(k).w.*sin(plain(k).theta) - plain(k).v.*cos(plain(k).theta);
% plain(k).v_theta_abs = plain(k).v_theta - plain(k).r*omega;
% 
% % static temperature
% plain(k).T = plain(k).p./(R.*plain(k).rho);
% 
% % Velocity
% plain(k).V_rel = sqrt(plain(k).u.^2+plain(k).v.^2+plain(k).w.^2);
% plain(k).V_abs = sqrt(plain(k).u.^2+plain(k).v_r.^2+plain(k).v_theta_abs.^2);
% 
% % Mach number
% plain(k).M_rel = plain(k).V_rel./sqrt(gamma*R*plain(k).T);
% plain(k).M_abs = plain(k).V_abs./sqrt(gamma*R*plain(k).T);
% 
% % Total pressure
% plain(k).P_rel = plain(k).p.*(1+(gamma-1)/2.*plain(k).M_rel).^(gamma/(gamma-1));
% plain(k).P_abs = plain(k).p.*(1+(gamma-1)/2.*plain(k).M_abs).^(gamma/(gamma-1));
% 
% % Total temperature
% plain(k).T0_rel = plain(k).T.*(1+(gamma-1)/2.*plain(k).M_rel);
% plain(k).T0_abs = plain(k).T.*(1+(gamma-1)/2.*plain(k).M_abs);
% 
% % x-vorticity
% x_vort = NaN*ones(m,n); % initialise the matrix, with a ring of NaN to help ploting
% v_theta = plain(k).v_theta;
% v_r = plain(k).v_r;
% r = plain(k).r;
% theta = plain(k).theta;
% 
% for i = 2:m-1,
%     for j = 2:n-1,   
%         
%         u1 = -v_theta(i-1,j-1);
%         u2 = -v_theta(i,j-1);
%         u3 = -v_r(i+1,j-1);
%         u4 = -v_r(i+1,j);
%         u5 = v_theta(i+1,j+1);
%         u6 = v_theta(i,j+1);
%         u7 = v_r(i-1,j+1);
%         u8 = v_r(i-1,j);
%         
%         edge1 = r(i,j-1)*abs(theta(i,j-1) - theta(i-1,j-1));
%         edge2 = r(i,j-1)*abs(theta(i+1,j-1) - theta(i,j-1));
%         edge3 = abs(r(i+1,j-1)-r(i+1,j));
%         edge4 = abs(r(i+1,j)-r(i+1,j+1));
%         edge5 = r(i+1,j+1)*abs(theta(i+1,j+1) - theta(i,j+1));
%         edge6 = r(i,j+1)*abs(theta(i-1,j+1) - theta(i,j+1));
%         edge7 = abs(r(i-1,j)-r(i-1,j+1));
%         edge8 = abs(r(i-1,j-1)-r(i-1,j));            
%         
%         Area(i,j) = r(i,j)*abs((r(i,j-1)-r(i,j+1)))*abs(theta(i-1,j)-theta(i+1,j));
%         
%         x_vort(i,j) = 1./Area(i,j)*sum( u1*edge1 + u2*edge2 + u3*edge3 + u4*edge4 + ...
%             u5*edge5 + u6*edge6 + u7*edge7 + u8*edge8 );
%         
%     end
% end 
% 
% plain(k).x_vort = x_vort;
    
end

%save(['D:\hydra\grid_2.2\post\\ADF_data.mat'],'data')

