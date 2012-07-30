% Syntax... [camber_line] = ParaProcess(grid_file,flow_file)
%
% Function to extract the camberline data from a parametric study grid
%
% NB So far this has only been tested on the 2.4% and 1.4% clearance grids
%
% hard coded plot flag, 1 to plot, 0 th skip
%

function [camber_line] = ParaProcess(grid_file,flow_file)

%
% plot flag, 1 to plot, 0 to skip
%
    plot = 1;

%
% Read the data
%
    [surface_data,flow_data] = Read_ADF_Data(grid_file,flow_file);

    figure
    
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
    omega = 933.053;
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
    abs_vel = sqrt(u.^2+(v+r.*omega).^2+w.^2);
    M_rel = rel_vel./sqrt(1.4*p./rho);
    M_abs = abs_vel./sqrt(1.4*p./rho);

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
    