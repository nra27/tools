
% Setup the flow and grid files then open ADF Data
gridfile = 'D:\hydra\grid_2.2.step\grid_files\HPB_step.grid.1.adf'
flowfile = 'D:\hydra\grid_2.2.step\std_output\HPB_step_SG_2000.flow.adf'
%[surface_data,flow_data] = Read_ADF_Data(gridfile,flowfile,0);


R = 287.1;
gamma = 1.4;

for k = 6, 

    load(['D:\hydra\grid_2.2.step\post\ADF\ADF_coords_O_' num2str(k) '.mat'])
    
    k
    
    for i = 1:14,
        
        for j = 1:100,
            
            % strip data
            data.plane(k).O.rho(i,j) = flow_data.flow(index(i,j),1);
            data.plane(k).O.u(i,j) = flow_data.flow(index(i,j),2);
            data.plane(k).O.v(i,j) = flow_data.flow(index(i,j),3);
            data.plane(k).O.w(i,j) = flow_data.flow(index(i,j),4);
            data.plane(k).O.p(i,j) = flow_data.flow(index(i,j),5); 
            data.plane(k).O.spall(i,j) = flow_data.flow(index(i,j),6);
            
        end
        
    end

    data.plane(k).O.x = x;    
    data.plane(k).O.y = y;
    data.plane(k).O.z = z;
    
    % Derived variables
    data.plane(k).O.V = sqrt(data.plane(k).O.u.^2+data.plane(k).O.v.^2+data.plane(k).O.w.^2);
    data.plane(k).O.T = data.plane(k).O.p./(R.*data.plane(k).O.rho);
    data.plane(k).O.M = data.plane(k).O.V./sqrt(gamma*R*data.plane(k).O.T);
   
end

%save(['D:\hydra\grid_2.2\post\\ADF_data.mat'],'data')

% % % Setup the flow and grid files then open ADF Data
% % gridfile = 'D:\hydra\grid_2.2.step\grid_files\HPB_step.grid.1.adf'
% % flowfile = 'D:\hydra\grid_2.2.step\std_output\HPB_step_SG_2000.flow.adf'
% % [surface_data,flow_data] = Read_ADF_Data(gridfile,flowfile,0);
% 
% R = 287.1;
% gamma = 1.4;
% 
% for k = 1:12,
% 
%     load(['D:\hydra\grid_2.2\padram\ADF_coords_OUT_' num2str(k) '.mat'])
%     %load('D:\hydra\grid_2.2.step\ADF_data.mat')
%     
%     for i = 1:93,
%         
%         for j = 1:100,
%             
%             % strip data
%             data.plane(k).OUT.rho(i,j) = flow_data.flow(index(i,j),1);
%             data.plane(k).OUT.u(i,j) = flow_data.flow(index(i,j),2);
%             data.plane(k).OUT.v(i,j) = flow_data.flow(index(i,j),3);
%             data.plane(k).OUT.w(i,j) = flow_data.flow(index(i,j),4);
%             data.plane(k).OUT.p(i,j) = flow_data.flow(index(i,j),5); 
%             data.plane(k).OUT.spall(i,j) = flow_data.flow(index(i,j),6);
%             
%         end
%         
%     end
% 
%     data.plane(k).OUT.x = x;    
%     data.plane(k).OUT.y = y;
%     data.plane(k).OUT.z = z;
%     
%     % Derived variables
%     data.plane(k).OUT.V = sqrt(data.plane(k).OUT.u.^2+data.plane(k).OUT.v.^2+data.plane(k).OUT.w.^2);
%     data.plane(k).OUT.T = data.plane(k).OUT.p./(R.*data.plane(k).OUT.rho);
%     data.plane(k).OUT.M = data.plane(k).OUT.V./sqrt(gamma*R*data.plane(k).OUT.T);
%    
% end
% 
% %save(['D:\hydra\grid_2.2.step\ADF_data.mat'],'data')

