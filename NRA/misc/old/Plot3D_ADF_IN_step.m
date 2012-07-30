%
% batch conversion of the Plot3D coords to the ADF index
%

% Setup the flow and grid files then open ADF Data
gridfile = 'D:\hydra\grid_2.2.step\grid_files\HPB_step.grid.1.adf'
flowfile = 'D:\hydra\grid_2.2.step\std_output\HPB_step_SG_2000.flow.adf'
%[surface_data,flow_data] = Read_ADF_Data(gridfile,flowfile,0);

% Quick and dirty Plot3D to ADF index conversion loop modified to be specific to each block

for k = 12:2:22,

    %
    % Inlet planes are 91x100
    %
    
    index = zeros(91,100);
    
    % Load the Plot3D coords
    load(['D:\hydra\grid_2.2.step\post\Plot3D\Plot3D_coords_IN_' num2str(k)])
           
    % Reduce the flow_data size for the find nearest search
    red_index = find(and(flow_data.coordinates(:,1) >= min(min(x)),flow_data.coordinates(:,1) <= max(max(x))));
    
    
    for i = 1:91,
        
        % Display progress
        disp(['Inlet plane ' num2str(k) ' point: i = ' num2str(i) ' of 91']);  
       
        for j = 1:100,
            
            % Set up probe vector and find the ADF node index 
            [index(i,j)] = FindNEAREST_red([x(i,j) z(i,j) y(i,j)],flow_data,red_index);
            
       
        end
    end
    
    % Save the index to the file
    save(['D:\hydra\grid_2.2.step\post\ADF\ADF_coords_IN_' num2str(k)],'x','y','z','index')
    
end

        