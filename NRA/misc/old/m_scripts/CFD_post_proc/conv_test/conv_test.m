

sol_dir  = [100:100:4000];


%
% Strip out an exit plane

omega = 933;
R = 287.1;
gamma = 1.4;
cp = 1004;
cv = cp/gamma;

% 
% load the x,y,z coordinates
% load h:\RT27a\3D\HPB\grid_2.2\grid_files\ADF\ADF_coords_OUT_10.mat
load ~/hydra/RT27a/3D/HPB/grid_2.2/grid_files/ADF/ADF_coords_OUT_10.mat
[m,n] = size(index);

for k = 18,%:length(sol_dir),
    
    disp(['Processing iteration ' num2str(sol_dir(k))])
    
    %
    % Load the matlab flow file
    %load(['H:\RT27a\3D\HPB\grid_2.2\conv_test\matlab\ADF_data_' num2str(sol_dir(k)) '.mat'])
    load(['~/hydra/RT27a/3D/HPB/grid_2.2/conv_test/matlab/ADF_data_' num2str(sol_dir(k)) '.mat'])
    
    disp('Data loaded...')
    
    for i = 1:m,
        for j = 1:n,
            % strip data
            data(k).rho(i,j) = flow_data.flow(index(i,j),1);
            data(k).u(i,j) = flow_data.flow(index(i,j),2);
            data(k).v(i,j) = flow_data.flow(index(i,j),3);
            data(k).w(i,j) = flow_data.flow(index(i,j),4);
            data(k).p(i,j) = flow_data.flow(index(i,j),5);
            data(k).spall(i,j) = flow_data.flow(index(i,j),6);
            
            % Wall heat flux hasn't been stripped to plaid coordinates yet 
            data(k).qdot = surface_data.group(3).wall_heat_flux;
            data(k).casing_nodes = surface_data.group(3).flow_node_numbers;
            data(k).casing_coordinates = flow_data.coordinates(data(k).casing_nodes,:);
           
        end
    end

    % Coordinates
    data(k).x = x;
    data(k).y = z; % Swap from padram to adf coordinate systems
    data(k).z = y; % Swap from padram to adf coordinate systems
    data(k).r = sqrt(z.^2+y.^2);
    data(k).theta = atan2(y,z);

    % x is pointing downstream, u is positive streamwise
    % z is up, w is +ve up
    % y is to the left, v is +ve to the left (looking upstream)

    %
    % Derived variables

    % Velocities
    data(k).v_theta = data(k).w.*cos(data(k).theta) + data(k).v.*sin(data(k).theta);
    data(k).v_r = data(k).w.*sin(data(k).theta) - data(k).v.*cos(data(k).theta);
    data(k).v_theta_abs = data(k).v_theta - data(k).r*omega;

    % static temperature
    data(k).T = data(k).p./(R.*data(k).rho);

    % Velocity
    data(k).V_rel = sqrt(data(k).u.^2+data(k).v.^2+data(k).w.^2);
    data(k).V_abs = sqrt(data(k).u.^2+data(k).v_r.^2+data(k).v_theta_abs.^2);

    % Mach number
    data(k).M_rel = data(k).V_rel./sqrt(gamma*R*data(k).T);
    data(k).M_abs = data(k).V_abs./sqrt(gamma*R*data(k).T);

    % Total pressure
    data(k).P_rel = data(k).p.*(1+(gamma-1)/2.*data(k).M_rel).^(gamma/(gamma-1));
    data(k).P_abs = data(k).p.*(1+(gamma-1)/2.*data(k).M_abs).^(gamma/(gamma-1));

    % Total temperature
    data(k).T0_rel = data(k).T.*(1+(gamma-1)/2.*data(k).M_rel);
    data(k).T0_abs = data(k).T.*(1+(gamma-1)/2.*data(k).M_abs);

    % Entropy relative to stp
    data(k).s = cv*log(data(k).p/1e5)+cp*log(1.2759./data(k).rho);
    
    % x-vorticity
    x_vort = NaN*ones(m,n); % initialise the matrix, with a ring of NaN to help ploting
    v_theta = data(k).v_theta;
    v_r = data(k).v_r;
    r = data(k).r;
    theta = data(k).theta;

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

data(k).x_vort = x_vort;
    
end
