function [data] = Calculate_Taw_PLAIN

%
% Directory structure must be
%
% CASE +
%      - 300 +
%            - hydra
%      - 318 +
%            - hydra

time_step = [0:99];

%
% Change to the STAGE_PLAIN directory
%
cd /users/hydra/RT27a/3D/stage_calcs/STAGE_PLAIN

grid_file = '../grid_files/STAGE.grid.1.adf'
flow_file = 'hydra/STAGE.flowuns.adf'

for k = 1:100,
    
    %
    % Load the two wall temperature files
    %
    disp('Loading the 300 wall temperature case')
    cd /users/hydra/RT27a/3D/stage_calcs/STAGE_PLAIN/300
    [surface_data,flow_data_300] = Read_ADF_Data(grid_file,flow_file,k-1);
        
    disp('Loading the 318 wall temperature case')
    cd /users/hydra/RT27a/3D/stage_calcs/STAGE_PLAIN/318
    [surface_data,flow_data_318] = Read_ADF_Data(grid_file,flow_file,k-1);

    if k == 1, % We only need to find the nodes on the first time step
    
        % We are only interested in the blade and casing surfaces for the HPB
        % region
        
        %
        % Find the casing surfaces
        %
        disp('Finding the Casing surfaces')
        n = 1;
        for i = 1:max(size(surface_data.surface_groups)),
            temp = surface_data.surface_groups{i};
            if strcmp(temp,'Casing'),
                casing_surfs(n) = i;
                n = n+1;
            else
            end
        end

        %
        % Find the casing surfaces
        %
        disp('Finding the Blade surfaces')
        n = 1;
        for i = 1:max(size(surface_data.surface_groups)),
            temp = surface_data.surface_groups{i};
            if strcmp(temp,'Blade'),
                blade_surfs(n) = i;
                n = n+1;
            else
            end
        end
 
        % This bit only needs doing once for each grid
        
        for i = 1:length(casing_surfs),
            
            % Get casing nodes
            casing_nodes(:,i) = surface_data.group(casing_surfs(i)).flow_node_numbers;        
            data.casing.x(:,i) = flow_data_318.coordinates(casing_nodes(:,i),1);
            data.casing.y(:,i) = flow_data_318.coordinates(casing_nodes(:,i),2);
            data.casing.z(:,i) = flow_data_318.coordinates(casing_nodes(:,i),3);      
            data.casing.n(:,i) = casing_nodes(:,i);
            data.casing.node_areas(:,i) = surface_data.group(casing_surfs(i)).node_areas;
        
        end
        
        for i = 1:length(blade_surfs),
            
            % Get blade nodes
            blade_nodes(:,i) = surface_data.group(blade_surfs(i)).flow_node_numbers;
            data.blade.x(:,i) = flow_data_318.coordinates(blade_nodes(:,i),1);
            data.blade.y(:,i) = flow_data_318.coordinates(blade_nodes(:,i),2);
            data.blade.z(:,i) = flow_data_318.coordinates(blade_nodes(:,i),3);
            data.blade.n(:,i) = blade_nodes(:,i);
            data.blade.node_areas(:,i) = surface_data.group(blade_surfs(i)).node_areas;
            
        end
        
        
    else
    end
    

    % This bit needs doing each time step, and for each surface

    for i = 1:length(casing_surfs),
        
       
        % Calculate the htc and Taw
        q_dot_300 = flow_data_300.flow(casing_nodes(:,i),7);
        q_dot_318 = flow_data_318.flow(casing_nodes(:,i),7);  
        warning off 
        alpha = q_dot_300./q_dot_318;
        casing.Taw(:,i) = (alpha*318-300)./(alpha-1);
        casing.htc(:,i) = q_dot_300./(casing.Taw(:,i)-300);
        
            % Eliminate NaNs from zero heat transfer rate nodes
            tmp = find(isnan(casing.Taw(:,i)));
            casing.Taw(tmp,i) = 318;
        
        % Strip all of the relevent casing data
        casing.q(:,i) = q_dot_318;
        casing.rho(:,i) = flow_data_318.flow(casing_nodes(:,i),5);
        casing.p(:,i) = flow_data_318.flow(casing_nodes(:,i),1);
  
    end

    
    for i = 1:length(blade_surfs),
        
               
        % Calculate the htc and Taw
        q_dot_300 = flow_data_300.flow(casing_nodes(:,i),7);
        q_dot_318 = flow_data_318.flow(casing_nodes(:,i),7);    
        warning off 
       
        alpha = q_dot_300./q_dot_318;
        blade.Taw(:,i) = (alpha*318-300)./(alpha-1);
        blade.htc(:,i) = q_dot_300./(blade.Taw(:,i)-300);
        blade.q(:,i) = q_dot_318;
        
            % Eliminate NaNs from zero heat transfer rate nodes
            tmp = find(isnan(blade.Taw(:,i)));
            blade.Taw(tmp,i) = 318;
    
        % Check to see if you get the same values - YES!
        % blade_htc_2(:,i) = q_dot_318./(blade_Taw(:,i)-318);
       
        % Strip all of the relevent casing data
        
        blade.q(:,i) = q_dot_318;
        blade.rho(:,i) = flow_data_318.flow(blade_nodes(:,i),1);
        blade.p(:,i) = flow_data_318.flow(blade_nodes(:,i),5);
        
    
    end
  
    %
    % Assemble a data structure
    %
    data.casing_surf_flow(k) = casing;
    data.blade_surf_flow(k) = blade;
    
end

save surface_data_redux.mat data




