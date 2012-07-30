


%
% Reshape data into a single casing vector
%
[n,m] = size(data.casing_surf_flow(1).Taw);
for i = 1:100,
    data.casing_surf_flow(i).Taw = reshape(data.casing_surf_flow(i).Taw,m*n,1);
    data.casing_surf_flow(i).htc = reshape(data.casing_surf_flow(i).htc,m*n,1);
    data.casing_surf_flow(i).q = reshape(data.casing_surf_flow(i).q,m*n,1);
    data.casing_surf_flow(i).rho = reshape(data.casing_surf_flow(i).rho,m*n,1);
    data.casing_surf_flow(i).p = reshape(data.casing_surf_flow(i).p,m*n,1);
end

n = 1;

x_over = 2;


% Blade leading edge
x_LE = 0.0536;
cax = 0.02435;
w_x = 0.0006;           % +/- x width of the region in which the data is collected for each gauge
w_t = 0.00025/0.2375;    % +/- theta width of the region in which the data is collected for each gauge
x_LE = 0.0536;


% cut positions
cut_percent = linspace(-20,79,8*x_over);
x_g = x_LE+cut_percent./100.*cax;

for k = 1:20,
    for i = 1:8*x_over,
        for j = 1:7,

            nodes = time_step(k).gauges(i,j).nodes;

            plot_data(k).gauges(i,j).rho = data.casing_surf_flow(k).rho(nodes);
            plot_data(k).gauges(i,j).p = data.casing_surf_flow(k).p(nodes);
            plot_data(k).gauges(i,j).Taw = data.casing_surf_flow(k).Taw(nodes);
            plot_data(k).gauges(i,j).htc = data.casing_surf_flow(k).htc(nodes);
            plot_data(k).gauges(i,j).q = data.casing_surf_flow(k).q(nodes);
    
            datum = 0;
            ang_step = 30/100;
            angle = [0:ang_step:(100-1)*ang_step];

            theta_g(n) = pi/2 + (datum + angle(k)/360*2*pi) - 0.001/0.2375*(i-1)/x_over -  8*0.001/0.2375*(j-1);
            x_grid(n) = x_g(i);

            th(i,j,k) = theta_g(n);
            x(i,j,k) = x_g(i);

            n = n+1;


        end
    end

end

%
% Averaging at each location
%

for k = 1:20, 
    for i = 1:8*x_over,
        for j = 1:7,

            rho(i,j,k) = mean(plot_data(k).gauges(i,j).rho);
            p(i,j,k) = mean(plot_data(k).gauges(i,j).p);
            q(i,j,k) = mean(plot_data(k).gauges(i,j).q);
            Taw(i,j,k) = mean(plot_data(k).gauges(i,j).Taw);
            htc(i,j,k) = mean(plot_data(k).gauges(i,j).htc);       
            
        end
    end
end


%
% Ploting
%

for k = 1:20, 
    
    subplot(1,2,1)
    contourf(th(:,:,1)'*0.2375,x(:,:,1)',p(:,:,k)'*1e5,13);
    caxis([2e5 5e5])
    axis off
    axis equal
    
    subplot(1,2,2)
    contourf(th(:,:,1)'*0.2375,x(:,:,1)',q(:,:,k)',13);
    hold on
    plot(-th(:,:,1)*0.2375,x(:,:,1),'k+')
    hold off
    caxis([-0.4e5 3e5])
    axis off
    axis equal
    
    pause(0.05)
    
end

%
% Ploting
%

for k = 1:20, 
    
    subplot(1,2,1)
    pcolor(th(:,:,1)'*0.2375,x(:,:,1)',p(:,:,k)'*1e5);
    caxis([2e5 5e5])
    axis off
    axis equal
    
    subplot(1,2,2)
    pcolor(th(:,:,1)'*0.2375,x(:,:,1)',q(:,:,k)');
    hold on
    plot(-th(:,:,1)*0.2375,x(:,:,1),'k+')
    hold off
    caxis([-0.4e5 3e5])
    axis off
    axis equal
    
    pause(0.05)
    
end

% save casing_gauge_data_strip_318.mat data_318 th x
% 
% cd /users/nra/hydra/stage_calcs/STAGE_PLAIN/300/hydra/
% 
% n = 1;
% 
% for k = 1:100,
%     
%     disp(['extracting time step ' num2str(k-1)])
%     [surface_data,flow_data] = Read_ADF_Data(grid_file,flow_file,k-1);
%     
%     for i = 1:8,
%         for j = 1:7,
% 
%             nodes = step(k).gauges(i,j).flow_nodes;
%                       
%             data_300(k).gauges(i,j).rho = flow_data.flow(nodes,1);
%             data_300(k).gauges(i,j).u = flow_data.flow(nodes,2);
%             data_300(k).gauges(i,j).v = flow_data.flow(nodes,3);
%             data_300(k).gauges(i,j).w = flow_data.flow(nodes,4);
%             data_300(k).gauges(i,j).p = flow_data.flow(nodes,5);
%             data_300(k).gauges(i,j).spall = flow_data.flow(nodes,6);
%             data_300(k).gauges(i,j).q_dot = flow_data.flow(nodes,7);
%             
%             datum = 0;
%             ang_step = 30/100;
%             angle = [0:ang_step:(100-1)*ang_step];
% 
%             theta_g(n) = pi/2 + (datum + angle(k)/360*2*pi) - 0.001/0.2375*(i-1) -  8*0.001/0.2375*(j-1);
%             x_grid(n) = x_g(i);
%             
%             th(i,j,k) = theta_g(n);
%             x(i,j,k) = x_g(i);   
% 
%             n = n+1;
%             
%             
%         end
%     end
%     
% end
% 
% save casing_gauge_data_strip_300.mat data_300 th x
% 
% 
% 
% clear all
% 
% load casing_gauge_data_strip_318.mat
% 
% %
% % Averaging at each location
% %
% 
% for k = 1:100, 
%     for i = 1:8,
%         for j = 1:7,
% 
%             rho(i,j,k) = mean(data_318(k).gauges(i,j).rho);
%             p(i,j,k) = mean(data_318(k).gauges(i,j).p);
%             q_dot(i,j,k) = mean(data_318(k).gauges(i,j).q_dot);
%                       
%         end
%     end
% end
% 
% %
% % Ploting
% %
% 
% for k = 1:100, 
%     
%     subplot(1,2,1)
%     contourf(th(:,:,1)'*0.2375,x(:,:,1)',p(:,:,k)',13);
%     caxis([2e5 5e5])
%     axis off
%     axis equal
%     
%     subplot(1,2,2)
%     contourf(th(:,:,1)'*0.2375,x(:,:,1)',q_dot(:,:,k)',13);
%     hold on
%     plot(-th(:,:,1)*0.2375,x(:,:,1),'k+')
%     hold off
%     caxis([-0.4e5 3e5])
%     axis off
%     axis equal
%     
%     pause(0.05)
% end
% 
% %
% % Attempting to set-up the same format as Greg and Yoshino data
% %
% 
% p_data = zeros(100,56);
% 
% for k = 1:100, 
%     for i = 1:8,
%         for j = 1:7,
%             
%             p_data(k,

            

