%
% batch conversion of the Plot3D coords to the ADF index
%

% Setup the flow and grid files then open ADF Data
gridfile = 'D:\hydra\grid_2.2.step\grid_files\HPB_step.grid.1.adf'
flowfile = 'D:\hydra\grid_2.2.step\std_output\HPB_step_SG_2000.flow.adf'
[surface_data,flow_data] = Read_ADF_Data(gridfile,flowfile,0);

% Quick and dirty Plot3D to ADF index conversion loop modified to be specific to each block

for k = 2:2:26,

    %
    % OUTLET planes are 93x100
    %
    
    index = zeros(93,100);
    
    % Load the Plot3D coords
    load(['D:\hydra\grid_2.2.step\post\Plot3D\Plot3D_coords_OUT_' num2str(k)])
           
    for i = 1:93,
        for j = 1:100,
            
            % Display progress
            disp(['Outlet plane ' num2str(k) ' point: i = ' num2str(i) ' of 93, j = ' num2str(j) ' of 100']);  
       
            % Set up probe vector and find the ADF node index 
            [index(i,j)] = FindNEAREST([x(i,j) z(i,j) y(i,j)],flow_data);
       
        end
    end
    
    % Save the index to the file
    save(['D:\hydra\grid_2.2.step\post\ADF\ADF_coords_OUT_' num2str(k)],'x','y','z','index')
    
end

        