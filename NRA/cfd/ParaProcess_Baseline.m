% Syntax... [camber_line] = ParaProcess(grid_file,flow_file,[baseline_flag])
%
% Function to process data from a parametric study grid
%
% NB So far this has only been tested on the 2.4% and 1.4% clearance grids
%
% hard coded plot flag, 1 to plot, 0 th skip
%

function [eta,inlet,exit,x_cuts,camber_line] = ParaProcess_Baseline(grid_file,flow_file)

%
% plot flag, 1 to plot, 0 to skip
%
    plot = 1;

%
% Read the data
%
    [surface_data,flow_data] = Read_ADF_Data(grid_file,flow_file);
    
%
% Check to see if coordinates have been changed to r-theta
%
    [M,N] = size(flow_data.coordinates);
    if N == 3
        flow_data = Set_to_RTheta(flow_data);
    end
    
    % Find the surfaces
    HPB_surf = strmatch('Blade',surface_data.surface_groups,'exact');

% Find the surfaces
    
	P = squeeze(flow_data.flow(surface_data.group(HPB_surf).flow_node_numbers,5));
	r = flow_data.coordinates(surface_data.group(HPB_surf).flow_node_numbers,4);
	theta = flow_data.coordinates(surface_data.group(HPB_surf).flow_node_numbers,5);
	A = surface_data.group(HPB_surf).node_areas;
	n = surface_data.group(HPB_surf).node_normals;
	   
    	Fx_temp = P.*A.*n(:,1);
        Fy_temp = P.*A.*n(:,2);
    	Fz_temp = P.*A.*n(:,3);   	
        Fr_temp = Fy_temp.*cos(theta)+Fz_temp.*sin(theta);
    	T_temp = r.*(Fz_temp.*cos(theta)-Fy_temp.*sin(theta));
    	Fx = sum(Fx_temp);
    	Fr = sum(Fy_temp);
    	T = sum(T_temp);

% 60 blades  
omega = 933.053;
Total_Torque = 60*sum(T);
eta.power = Total_Torque*omega;

    % HPB inlet surface is 6 for the baseline grids
    n = 6;

    % HPB domain inlet variables
    inlet.rho = flow_data.flow(surface_data.group(n).flow_node_numbers,1);
    inlet.u = flow_data.flow(surface_data.group(n).flow_node_numbers,2);
    inlet.v = flow_data.flow(surface_data.group(n).flow_node_numbers,3);
    inlet.w = flow_data.flow(surface_data.group(n).flow_node_numbers,4);
    inlet.p = flow_data.flow(surface_data.group(n).flow_node_numbers,5);
    inlet.A = surface_data.group(n).node_areas;

    % derived
    inlet.T = inlet.p./(inlet.rho*287.1);
    inlet.U = sqrt(inlet.u.^2+inlet.v.^2+inlet.w.^2);
    inlet.M = inlet.U./sqrt((1.4*287.1*inlet.T));
    inlet.P = inlet.p.*(1+(1.4-1)/2.*inlet.M.^2).^(1.4/(1.4-1));

    % HPB exit surface is 8 for the baseline grids
    n = 8;
    
    % HPB exit variables
    exit.rho = flow_data.flow(surface_data.group(n).flow_node_numbers,1);
    exit.u = flow_data.flow(surface_data.group(n).flow_node_numbers,2);
    exit.vrel = flow_data.flow(surface_data.group(n).flow_node_numbers,3);
    exit.w = flow_data.flow(surface_data.group(n).flow_node_numbers,4);
    exit.p = flow_data.flow(surface_data.group(n).flow_node_numbers,5);
    exit.A = surface_data.group(n).node_areas;
    exit.r = flow_data.coordinates(surface_data.group(n).flow_node_numbers,4);
    exit.vabs = exit.vrel-exit.r*omega;
    
    % derived
    gamma = 1.4;
    cp = 1004;
    cv = cp/gamma;
    exit.T = exit.p./(exit.rho*287.1);
    exit.U = sqrt(exit.u.^2+exit.vabs.^2+exit.w.^2);
    exit.M = exit.U./sqrt((1.4*287.1*exit.T));
    exit.P = exit.p.*(1+(1.4-1)/2.*exit.M.^2).^(1.4/(1.4-1));  
    exit.ds = cv*log(exit.p/(mean(inlet.p)))+cp*log(mean(inlet.rho)./exit.rho);
    
    % Extract cut plane data
    min_x = min(flow_data.coordinates(:,1));
    max_x = max(flow_data.coordinates(:,1));
    x_vals =  linspace(min_x+1e-3, max_x-1e-3, 50);  
    for k = 1:length(x_vals),
        n = find( and(( flow_data.coordinates(:,1) <= x_vals(k)+1e-3) , (flow_data.coordinates(:,1)>= x_vals(k)-1e-3)));
        x_cuts(k).flow = flow_data.flow(n,:);
      
    end
    x_cuts(1).x = x_vals;  

     % x_cuts =[];
   
    %
    % Compressible Mixing calculatiCal  on at exit
    % 

    gam = 1.4;
    R = 287.1;
    cp = 1005;

    % Total temperature
    exit.T0 = exit.T.*(1+0.4/2.*exit.M.^2);

    % bin the data into a set of radial heights

    ri = min(exit.r);
    ro = max(exit.r);
    heights = linspace(ri,ro,102);

    for n = 2:length(heights)-1,
        nodes = find(and( (exit.r > heights(n-1)), (exit.r < heights(n))));

        I_mass(n-1) = sum(exit.rho(nodes).*exit.u(nodes).*exit.A(nodes));
        I_ax_mom(n-1) = sum((exit.rho(nodes).*exit.u(nodes).^2 + exit.p(nodes)).*exit.A(nodes));
        I_ang_mom(n-1) = sum(exit.rho(nodes) .*exit.u(nodes) .*exit.vabs(nodes) .*exit.r(nodes) .*exit.A(nodes));
        I_energy(n-1) = sum(cp *exit.T0(nodes) .*exit.rho(nodes) .*exit.u(nodes) .*exit.A(nodes));

        A(n-1) = sum(exit.A(nodes));

        T0_mix(n-1) = I_energy(n-1)./(I_mass(n-1)*cp);


        % iterative loop to solve for v_mix

        err = 1;
        va_mix = -1;
        while abs(err) > 1e-12,

            term = gam*R*T0_mix(n-1) / (gam*R*T0_mix(n-1) - 0.2*(va_mix^2 + I_ang_mom(n-1)^2 / (I_mass(n-1)^2 * heights(n-1)^2)));

            err = va_mix - I_mass(n-1)*R*T0_mix(n-1) / (term*(I_ax_mom(n-1) - I_mass(n-1)*va_mix));  
            va_mix = I_mass(n-1)*R*T0_mix(n-1) / (term*(I_ax_mom(n-1) - I_mass(n-1)*va_mix));

        end

        v_mix(n-1) = va_mix;

        p_mix(n-1) = (I_ax_mom(n-1) - I_mass(n-1)*v_mix(n-1))/A(n-1);

        P_mix_(n-1) = p_mix(n-1)*(1+0.2*(v_mix(n-1)^2/(gam*R*T0_mix(n-1)-0.2*v_mix(n-1)^2)))^(gam/gam-1);     

    end

    % mass average of the radial profile
    exit.P_mix = sum(P_mix_.*I_mass)/sum(I_mass);
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    % HPB inlet
    inlet.mass_flow = 60*sum(inlet.rho.*inlet.u.*inlet.A);
    inlet.P_mw = sum(60*inlet.P.*inlet.rho.*inlet.u.*inlet.A)./inlet.mass_flow;
    inlet.T_mw = sum(60*inlet.T.*inlet.rho.*inlet.u.*inlet.A)./inlet.mass_flow;
    
    % HPB outlet
    exit.mass_flow = 60*sum(exit.rho.*exit.u.*exit.A);
    exit.P_mw = sum(60*exit.P.*exit.rho.*exit.u.*exit.A)./exit.mass_flow;
    exit.ds_mw = sum(60*exit.ds.*exit.rho.*exit.u.*exit.A)./exit.mass_flow;
      
    % Virtual Efficiency
    eta.is_power_mw = inlet.mass_flow.*1005.*374.4.*(1- (exit.P_mw./8.04e5)^(0.4/1.4) );
    eta.is_power_mix = inlet.mass_flow.*1005.*374.4.*(1- (exit.P_mix./8.04e5)^(0.4/1.4) );
    eta.eta_mw = eta.power./eta.is_power_mw;
    eta.eta_mix = eta.power./eta.is_power_mix;

    
%
% Constants for the grid topology
%
    % This MIGHT change for other grids
    root_node = 28535;

    % This will change for each tip gap
    n_tg = 49;

    % Find the blade nodes ready to plot
    blade_nodes = surface_data.group(5).flow_node_numbers;
    xyz = flow_data.coordinates;

    % These should be fixed for all of the grids in the parametric study!!!!
    n_axial = 69;
    n_polar = 50;

%
% plot the blade tip N.B. the 25000 start point WILL change
%
    if plot == 1,
        figure
        subplot(1,2,1)
        % tip
        plot3(xyz(blade_nodes(25000:end),1),xyz(blade_nodes(25000:end),2),xyz(blade_nodes(25000:end),3),'.r')
        axis off
        axis equal
        hold on
        % camber line
        n = blade_nodes(root_node);
        plot3(xyz(n,1),xyz(n,2),xyz(n,3),'.b')
        plot3(xyz(n+1:n+n_axial-1,1),xyz(n+1:n+n_axial-1,2),xyz(n+1:n+n_axial-1,3),'.g')
    else end

%
% Write the node IDs to a matrix NB the 3400 -20 is found by HAND!!!! for
% each grid
%
    for i = 0:n_tg-1, 
        n = blade_nodes(root_node) + i*(3400 - 20 + 1);
        mat(i+1,1:n_axial) = (n:n+n_axial-1);
        if plot == 1,
        % plot the lines as they are found
        plot3(xyz(n:n+n_axial-1,1),xyz(n:n+n_axial-1,2),xyz(n:n+n_axial-1,3),'.k')
        else end
    end

%
% Extract the flow data at each node IDs
%
    for i = 1:n_tg,
        for j = 1:n_axial,
            camber_line.flow(i,j,:) = flow_data.flow(mat(i,j),:);
            camber_line.x(i,j) = flow_data.coordinates(mat(i,j),1);
            camber_line.y(i,j) = flow_data.coordinates(mat(i,j),2);
            camber_line.z(i,j) = flow_data.coordinates(mat(i,j),3);
        end
    end

%
% Contour plot of the camberline flow to check 
%
    if plot == 1,
        subplot(1,2,2)
        contourf(camber_line.x,camber_line.z,camber_line.flow(:,:,1),13)
        axis off
        axis equal
    else end

%
% Calculate Flow properties
%
  
    rho = camber_line.flow(:,:,1);
    u = camber_line.flow(:,:,2);
    v = camber_line.flow(:,:,3);
    w = camber_line.flow(:,:,4);
    p =  camber_line.flow(:,:,5);
    z = camber_line.flow(:,:,6);
    x = camber_line.x;
    y = camber_line.y;
    z = camber_line.z;
    r = sqrt(y.^2+z.^2);
    rel_vel = sqrt(u.^2+v.^2+w.^2);
    abs_vel = sqrt(u.^2+(v-r.*omega).^2+w.^2);
    camber_line.M_rel = rel_vel./sqrt(1.4*p./rho);
    camber_line.M_abs = abs_vel./sqrt(1.4*p./rho);

%
% Calculate the mass flux normal to the camberline
%
    for i = 1:n_tg-1, % radially
        for j = 1:n_axial-1, % axially

            rho_ = mean(mean(rho(i:i+1,j:j+1)));
            u_ = mean(mean(u(i:i+1,j:j+1)));
            v_ = mean(mean(v(i:i+1,j:j+1)));
            dx_ = x(i,j+1)-x(i,j);
            camber_line.x_(i,j) = mean([x(i,j+1) x(i,j)]);
            dy_ = y(i,j+1)-y(i,j);
            dz_ = z(i+1,j)-z(i,j);
            theta = atan(dy_/dx_);

            % Check to see if the patch is pointing up or downstream
            if dy_ < 0,
                V_norm_ = -v_*cos(theta) - u_*sin(theta);
            else
                V_norm_ = -v_*cos(theta) + u_*sin(theta);
            end

            A_(i,j) = sqrt(dx_^2+dy_^2)*dz_;
            camber_line.m_(i,j) = A_(i,j)*rho_*V_norm_;
            camber_line.rho_ij(i,j) = rho_;
            camber_line.V_norm_ij(i,j) = V_norm_;

        end

    end   
    