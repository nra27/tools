
% Setup the flow and grid files then open ADF Data
gridfile = 'D:\hydra\grid_2.2\grid_files\HPB_plain.grid.1.adf'
flowfile = 'D:\hydra\grid_2.2\std_output\HPB_plain_2000.flow.adf'
[surface_data,flow_data] = Read_ADF_Data(gridfile,flowfile,0);

R = 287.1;
gamma = 1.4;

for k = [1 16 64],

    load(['D:\hydra\grid_2.2\padram\ADF_coords_LH_' num2str(k) '.mat'])

    for i = 1:42,
        
        for j = 1:100,
            
            % strip data
            data.plane(k).LH.rho(i,j) = flow_data.flow(index(i,j),1);
            data.plane(k).LH.u(i,j) = flow_data.flow(index(i,j),2);
            data.plane(k).LH.v(i,j) = flow_data.flow(index(i,j),3);
            data.plane(k).LH.w(i,j) = flow_data.flow(index(i,j),4);
            data.plane(k).LH.p(i,j) = flow_data.flow(index(i,j),5); 
            data.plane(k).LH.spall(i,j) = flow_data.flow(index(i,j),6);
            
        end
        
    end

    data.plane(k).LH.x = x;    
    data.plane(k).LH.y = y;
    data.plane(k).LH.z = z;
    
    % Derived variables
    data.plane(k).LH.V = sqrt(data.plane(k).LH.u.^2+data.plane(k).LH.v.^2+data.plane(k).LH.w.^2);
    data.plane(k).LH.T = data.plane(k).LH.p./(R.*data.plane(k).LH.rho);
    data.plane(k).LH.M = data.plane(k).LH.V./sqrt(gamma*R*data.plane(k).LH.T);
    

    load(['D:\hydra\grid_2.2\padram\ADF_coords_UH_' num2str(k) '.mat'])

    for i = 1:42,
        
        for j = 1:100,
            
            % strip data
            data.plane(k).UH.rho(i,j) = flow_data.flow(index(i,j),1);
            data.plane(k).UH.u(i,j) = flow_data.flow(index(i,j),2);
            data.plane(k).UH.v(i,j) = flow_data.flow(index(i,j),3);
            data.plane(k).UH.w(i,j) = flow_data.flow(index(i,j),4);
            data.plane(k).UH.p(i,j) = flow_data.flow(index(i,j),5); 
            data.plane(k).UH.spall(i,j) = flow_data.flow(index(i,j),6);
            
        end
        
    end

    data.plane(k).UH.x = x;    
    data.plane(k).UH.y = y;
    data.plane(k).UH.z = z;
    
    % Derived variables
    data.plane(k).UH.V = sqrt(data.plane(k).UH.u.^2+data.plane(k).UH.v.^2+data.plane(k).UH.w.^2);
    data.plane(k).UH.T = data.plane(k).UH.p./(R.*data.plane(k).UH.rho);
    data.plane(k).UH.M = data.plane(k).UH.V./sqrt(gamma*R*data.plane(k).UH.T);
    
end

save(['D:\hydra\grid_2.2\ADF_data.mat'],'data')



% Setup the flow and grid files then open ADF Data
gridfile = 'D:\hydra\grid_2.2.step\grid_files\HPB_step.grid.1.adf'
flowfile = 'D:\hydra\grid_2.2.step\std_output\HPB_step_SG_2000.flow.adf'
[surface_data,flow_data] = Read_ADF_Data(gridfile,flowfile,0);

R = 287.1;
gamma = 1.4;

for k = [1 16 64],

    load(['D:\hydra\grid_2.2.step\padram\ADF_coords_LH_' num2str(k) '.mat'])

    for i = 1:42,
        
        for j = 1:100,
            
            % strip data
            data.plane(k).LH.rho(i,j) = flow_data.flow(index(i,j),1);
            data.plane(k).LH.u(i,j) = flow_data.flow(index(i,j),2);
            data.plane(k).LH.v(i,j) = flow_data.flow(index(i,j),3);
            data.plane(k).LH.w(i,j) = flow_data.flow(index(i,j),4);
            data.plane(k).LH.p(i,j) = flow_data.flow(index(i,j),5); 
            data.plane(k).LH.spall(i,j) = flow_data.flow(index(i,j),6);
            
        end
        
    end

    data.plane(k).LH.x = x;    
    data.plane(k).LH.y = y;
    data.plane(k).LH.z = z;
    
    % Derived variables
    data.plane(k).LH.V = sqrt(data.plane(k).LH.u.^2+data.plane(k).LH.v.^2+data.plane(k).LH.w.^2);
    data.plane(k).LH.T = data.plane(k).LH.p./(R.*data.plane(k).LH.rho);
    data.plane(k).LH.M = data.plane(k).LH.V./sqrt(gamma*R*data.plane(k).LH.T);

    load(['D:\hydra\grid_2.2.step\padram\ADF_coords_UH_' num2str(k) '.mat'])

    for i = 1:42,
        
        for j = 1:100,
            
            % strip data
            data.plane(k).UH.rho(i,j) = flow_data.flow(index(i,j),1);
            data.plane(k).UH.u(i,j) = flow_data.flow(index(i,j),2);
            data.plane(k).UH.v(i,j) = flow_data.flow(index(i,j),3);
            data.plane(k).UH.w(i,j) = flow_data.flow(index(i,j),4);
            data.plane(k).UH.p(i,j) = flow_data.flow(index(i,j),5); 
            data.plane(k).UH.spall(i,j) = flow_data.flow(index(i,j),6);
            
        end
        
    end

    data.plane(k).UH.x = x;    
    data.plane(k).UH.y = y;
    data.plane(k).UH.z = z;
    
    % Derived variables
    data.plane(k).UH.V = sqrt(data.plane(k).UH.u.^2+data.plane(k).UH.v.^2+data.plane(k).UH.w.^2);
    data.plane(k).UH.T = data.plane(k).UH.p./(R.*data.plane(k).UH.rho);
    data.plane(k).UH.M = data.plane(k).UH.V./sqrt(gamma*R*data.plane(k).UH.T);
    
end

save(['D:\hydra\grid_2.2.step\ADF_data.mat'],'data')

