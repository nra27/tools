%
% batch conversion of the Plot3D coords to the ADF index
%

% Setup the flow and grid files then open ADF Data
gridfile = 'D:\hydra\grid_2.2\grid_files\HPB_plain.grid.1.adf'
flowfile = 'D:\hydra\grid_2.2\std_output\HPB_plain_2000.flow.adf'
%[surface_data,flow_data] = Read_ADF_Data(gridfile,flowfile,0);

% Quick and dirty Plot3D to ADF index conversion loop modified to be specific to each block

for k = [4:2:144],

    %
    % O planes are 14x100
    %
    
    k
    
    index = zeros(14,100);
    
    % Load the Plot3D coords
    load(['D:\hydra\grid_2.2\post\Plot3D\Plot3D_coords_O_plain_' num2str(k)])
           
    % Reduce the flow_data size for the find nearest search
    red_index = find(and(flow_data.coordinates(:,1) >= min(min(x)),flow_data.coordinates(:,1) <= max(max(x))));
    temp_index = find(and(flow_data.coordinates(red_index,2) >= min(min(z)),flow_data.coordinates(red_index,2) <= max(max(z))));
    red_index = red_index(temp_index);
    
    for i = 1:14,
        
        % Display progress
        disp(['Inlet plane ' num2str(k) ' point: i = ' num2str(i) ' of 14']);  
       
        for j = 1:100,
            
            % Set up probe vector and find the ADF node index 
            [index(i,j)] = FindNEAREST_red([x(i,j) z(i,j) y(i,j)],flow_data,red_index);
            
        end
    end
    
    % Save the index to the file
    save(['D:\hydra\grid_2.2\post\ADF\ADF_coords_O_' num2str(k)],'x','y','z','index')
    
end

        