function [mov] = Virtual_Gauges_56(data)

%
% Function to extract virtual casing gauge data.
%
% [mov] = Virtual_gauges(data)
%
% Current version just grabs the flow_nodes within a target area around
% each node, could be updated to use interpolation on the surface, using
% Gregs code.
%

%
% Reshape data into a single casing vector
%
[n,m] = size(data.casing.x);
data.casing.x = reshape(data.casing.x,m*n,1);
data.casing.y = reshape(data.casing.y,m*n,1);
data.casing.z = reshape(data.casing.z,m*n,1);
data.casing.n = reshape(data.casing.n,m*n,1);
data.casing.node_areas = reshape(data.casing.node_areas,m*n,1);
for i = 1:100,
    data.casing_surf_flow(i).Taw = reshape(data.casing_surf_flow(i).Taw,m*n,1);
    data.casing_surf_flow(i).htc = reshape(data.casing_surf_flow(i).htc,m*n,1);
    data.casing_surf_flow(i).q = reshape(data.casing_surf_flow(i).q,m*n,1);
    data.casing_surf_flow(i).rho = reshape(data.casing_surf_flow(i).rho,m*n,1);
    data.casing_surf_flow(i).p = reshape(data.casing_surf_flow(i).p,m*n,1);
end

%
% Add R-theta coordinates
%
data.casing.r = sqrt(data.casing.y.^2+data.casing.z.^2);
data.casing.th = atan2(data.casing.z,data.casing.y);

% 100 unsteady snapshots over 30 degrees
datum = 0;
ang_step = 30/100;
angle = [0:ang_step:(100-1)*ang_step];

% Blade leading edge
x_LE = 0.0536;
cax = 0.02435;
w_x = 0.0007;            % +/- x width of the region in which the data is collected for each gauge
w_t = 0.0003/0.2375;    % +/- theta width of the region in which the data is collected for each gauge
x_LE = 0.0536;

% cut positions
x_over = 1;
th_over = 1;
cut_percent = linspace(-20,79,8*x_over);
x_g = x_LE+cut_percent./100.*cax;

datum = 0;

n = 1;

for k=1:length(angle),
    
    % Find the nodes at the approximate gauge positions
 
    for i = 1:8*x_over,
        for j = 1:7*th_over,
            
            % Virtual gauge positions
            theta_g(n) = pi/2 + (datum + angle(k)/360*2*pi) - 0.001/0.2375*(i-1)/x_over -  8*0.001/0.2375*(j-1)/th_over;
            x_grid(n) = x_g(i);

            temp = find( and( and(data.casing.x > x_g(i)-w_x , data.casing.x < x_g(i)+w_x) , ...
                and( data.casing.th > theta_g(n)-w_t , data.casing.th <theta_g(n)+w_t) ) );

            %disp('found gauges !')
            
            if min(size(temp)) == 0, 
                %disp('gauges are +ve wrapped!')
                
                temp = find( and( and(data.casing.x > x_g(i)-w_x , data.casing.x < x_g(i)+w_x) , ...
                            and( data.casing.th > theta_g(n)-(pi/6)-w_t , data.casing.th <theta_g(n)-(pi/6)+w_t) ) );
            
                time_step(k).gauges(i,j).nodes = temp;
                time_step(k).gauges(i,j).x = data.casing.x(temp);
                time_step(k).gauges(i,j).th = data.casing.th(temp);
                                                 
                
                if min(size(temp)) == 0, 
                    %disp('gauges are -ve wrapped!')
                    
                    temp = find( and( and(data.casing.x > x_g(i)-w_x , data.casing.x < x_g(i)+w_x) , ...
                            and( data.casing.th > theta_g(n)+(pi/6)-w_t , data.casing.th <theta_g(n)+(pi/6)+w_t) ) );

                        time_step(k).gauges(i,j).nodes = temp;
                        time_step(k).gauges(i,j).x = data.casing.x(temp);
                        time_step(k).gauges(i,j).th = data.casing.th(temp);                                
                
                    if min(size(temp)) == 0, 
                        %disp('Missing gauges - widen search')
                    else
                    end
                    
                else
                end

            else
               time_step(k).gauges(i,j).nodes = temp;
               time_step(k).gauges(i,j).x = data.casing.x(temp);
               time_step(k).gauges(i,j).th = data.casing.th(temp); 
               
            end
            
            % Assemble and average the data
            plot_data(k).gauges(i,j).rho = data.casing_surf_flow(k).rho(temp);
            plot_data(k).gauges(i,j).p = data.casing_surf_flow(k).p(temp);
            plot_data(k).gauges(i,j).Taw = data.casing_surf_flow(k).Taw(temp);
            plot_data(k).gauges(i,j).htc = data.casing_surf_flow(k).htc(temp);
            plot_data(k).gauges(i,j).q = data.casing_surf_flow(k).q(temp);
    
            mov.rho(i,j,k) = mean(plot_data(k).gauges(i,j).rho);
            mov.p(i,j,k) = mean(plot_data(k).gauges(i,j).p);
            mov.q(i,j,k) = mean(plot_data(k).gauges(i,j).q);
            mov.Taw(i,j,k) = mean(plot_data(k).gauges(i,j).Taw);
            mov.htc(i,j,k) = mean(plot_data(k).gauges(i,j).htc);   
            
            % Plotting coordinates            
            mov.th(i,j,k) = theta_g(n);
            mov.x(i,j,k) = x_g(i);
                                    
        end
    end

    disp(['finding t_step ' num2str(k) ])
 
    n = n+1;

end
