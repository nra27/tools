function [step] = Extract_casing_gauge_nodes(flow_data,surface_data,name,datum,varagin)

%
% Function to extract the casing gauge positions.
%
% [gauges] = Extract_casing_gauge_nodes(flow_data,surface_data,name,datum,[period,t_steps])
%
% datum (in degrees) is the position of the first gauge relative to TDC
%
% If there is unsteady flow_data, then the gauges are shifted at each time step.
% 
% If the points are outside the domain, they are wrapped 30 deg back to get
% the equilalent points.
%
% Current version just grabs the flow_nodes within a target area around
% each node, could be updated to use interpolation on the surface, using
% Gregs code.
%

%
% Add R-theta coordinates if required
%
if min(size(flow_data.coordinates)) < 5,
    disp('Adding R and theta coordinates')
    flow_data = Set_to_RTheta(flow_data);
else
end

%
% Unsteady ?
%
if max(size(size(flow_data.flow))) > 2,
    ang_step = varagin(1)/varagin(2);
    angle = [0:ang_step:(varagin(2)-1)*ang_step];
    disp('Unsteady flow_data found')
else
angle = 0;
end

%
% Find the casing surfaces
% 
disp('Finding the casing surfaces')
n = 1;
for i = 1:max(size(surface_data.surface_groups)),
    temp = surface_data.surface_groups{i};
    if strcmp(temp,name),
        surfs(n) = i;
        n = n+1;
    else
    end
end

for i = 1:length(surfs),
    casing_nodes_tmp(:,i) = surface_data.group(surfs(i)).flow_node_numbers;
end
[m1,m2] = size(casing_nodes_tmp); casing_nodes = reshape(casing_nodes_tmp,m1*m2,1);
casing_coordinates = flow_data.coordinates(casing_nodes,:);

% Blade leading edge
x_LE = 0.0536;
cax = 0.02435;
w_x = 0.0006;           % +/- x width of the region in which the data is collected for each gauge
w_t = 0.00025/0.2375;    % +/- theta width of the region in which the data is collected for each gauge
x_LE = 0.0536;

cut_percent = linspace(-20,79,8);

% cut positions
cut_percent = linspace(-20,79,8);
x_g = x_LE+cut_percent./100.*cax;

for k=1:length(angle),
    
    % Find the nodes at the approximate gauge positions
    n = 1;
    for i = 1:8,
        for j = 1:7,

            theta_g(n) = pi/2 + (datum + angle(k)/360*2*pi) - 0.001/0.2375*(i-1) -  8*0.001/0.2375*(j-1);
            x_grid(n) = x_g(i);

            temp = find( and( and(casing_coordinates(:,1)>x_g(i)-w_x,casing_coordinates(:,1)<x_g(i)+w_x) , ...
                and( casing_coordinates(:,5)>theta_g(n)-w_t,casing_coordinates(:,5)<theta_g(n)+w_t) ) );

            if min(size(temp)) == 0,
                temp = find( and( and(casing_coordinates(:,1)>x_g(i)-w_x,casing_coordinates(:,1)<x_g(i)+w_x) , ...
                    and( casing_coordinates(:,5)>theta_g(n)-(pi/6)-w_t,casing_coordinates(:,5)<theta_g(n)-(pi/6)+w_t) ) ) ;

                step(k).gauges(i,j).flow_nodes = casing_nodes(temp); % flow node numbers of the qauge positions
                step(k).gauges(i,j).x = flow_data.coordinates(casing_nodes(temp),1);
                step(k).gauges(i,j).y = flow_data.coordinates(casing_nodes(temp),2);
                step(k).gauges(i,j).z = flow_data.coordinates(casing_nodes(temp),3);
                step(k).gauges(i,j).r = flow_data.coordinates(casing_nodes(temp),4);
                step(k).gauges(i,j).theta = (flow_data.coordinates(casing_nodes(temp),5)+pi/6)/(2*pi)*360;
                
                if min(size(temp)) == 0, %disp('data is wrapped -ve')
                    temp = find( and( and(casing_coordinates(:,1)>x_g(i)-w_x,casing_coordinates(:,1)<x_g(i)+w_x) , ...
                        and( casing_coordinates(:,5)>theta_g(n)+(pi/6)-w_t,casing_coordinates(:,5)<theta_g(n)+(pi/6)+w_t) ) ) ;

                    step(k).gauges(i,j).flow_nodes = casing_nodes(temp); % flow node numbers of the qauge positions
                    step(k).gauges(i,j).x = flow_data.coordinates(casing_nodes(temp),1);
                    step(k).gauges(i,j).y = flow_data.coordinates(casing_nodes(temp),2);
                    step(k).gauges(i,j).z = flow_data.coordinates(casing_nodes(temp),3);
                    step(k).gauges(i,j).r = flow_data.coordinates(casing_nodes(temp),4);
                    step(k).gauges(i,j).theta = (flow_data.coordinates(casing_nodes(temp),5)-pi/6)/(2*pi)*360;
                                      
                    if min(size(temp)) == 0, 
                        disp('Missing gauges - widen search')
                    else
                    end
                    
                else
                end

            else
                step(k).gauges(i,j).flow_nodes = casing_nodes(temp); % flow node numbers of the qauge positions
                step(k).gauges(i,j).x = flow_data.coordinates(casing_nodes(temp),1);
                step(k).gauges(i,j).y = flow_data.coordinates(casing_nodes(temp),2);
                step(k).gauges(i,j).z = flow_data.coordinates(casing_nodes(temp),3);
                step(k).gauges(i,j).r = flow_data.coordinates(casing_nodes(temp),4);
                step(k).gauges(i,j).theta = flow_data.coordinates(casing_nodes(temp),5)/(2*pi)*360;
                
            end

            n = n+1;
        end
    end

    disp(['finding t_step ' num2str(k) ])
    for i = 1:56,plot(step(k).gauges(i).theta,step(k).gauges(i).x,'k+');hold on,end

end
