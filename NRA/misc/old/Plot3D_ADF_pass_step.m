%
% batch conversion of the Plot3D coords to the ADF index
%

% Setup the flow and grid files then open ADF Data
gridfile = 'D:\hydra\grid_2.2.step\grid_files\HPB_step.grid.1.adf'
flowfile = 'D:\hydra\grid_2.2.step\std_output\HPB_step_SG_2000.flow.adf'
[surface_data,flow_data] = Read_ADF_Data(gridfile,flowfile,0);

% Quick and dirty Plot3D to ADF index conversion loop


%a 2 4 6 10 12 14 18 20 22 26 28 30 36 38 42 44 46 50 52 54 58 60 62 66

for k = [58 60 62 66]; %[ 8 24 32 40 48 56 64],%[32 48 64], % 1:3:66,

    index = zeros(42,100);
    dist = zeros(42,100);
    
    %
    % Upper H mesh
    %
      
    % Load the Plot3D coords
    load(['D:\hydra\grid_2.2.step\padram\Plot3D_coords_UH_' num2str(k)])
           
    for i = 1:42,
        
        for j = 1:100,
            
            % Display progress
            disp(['Upper H Cut plane ' num2str(k) ' point: i = ' num2str(i) ' of 42, j = ' num2str(j) ' of 100']);  
       
            % Set up probe vector and find the ADF node index 
            [index(i,j)] = FindNEAREST([x(i,j) z(i,j) y(i,j)],flow_data);
       
        end
    end
    
    % Save the index to the file
    save(['D:\hydra\grid_2.2.step\padram\ADF_coords_UH_' num2str(k)],'x','y','z','index')
    
    %
    % Lower H mesh
    %
    
    % Load the Plot3D coords
    load(['D:\hydra\grid_2.2.step\padram\Plot3D_coords_LH_' num2str(k)])
           
    for i = 1:42,
        
        for j = 1:100,
            
           % Display progress
            disp(['Lower H Cut plane ' num2str(k) ' point: i = ' num2str(i) ' of 42, j = ' num2str(j) ' of 100']);  
       
            % Set up probe vector and find the ADF node index 
            [index(i,j)] = FindNEAREST([x(i,j) z(i,j) y(i,j)],flow_data);
       
        end
    end
    
    % Save the index to the file
    save(['D:\hydra\grid_2.2.step\padram\ADF_coords_LH_' num2str(k)],'x','y','z','index')
   
    
    
end


        
        