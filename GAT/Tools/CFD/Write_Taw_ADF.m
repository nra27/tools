function Write_Taw_ADF(new_file,grid,file_1,file_2,varargin)
%
% Write_Taw_ADF(new_file,grid,file_1,file_2,[file_3, ... ,file_n])
%
% A function to calculate the adiabatic wall temperature and
% heat-transfer coefficient, and write a new ADF flow file
% with this data. flow_1 is used as the base for this file.
% Checks are done to ensure that the flow files are the same
% size, and the wall temperature for each surface is recovered
% from the file.

% Non-dimensional values
rho_ref = 1.226;
p_ref = 101300;
q_ref = -p_ref^1.5/rho_ref^0.5;

% Setup ADF space
D = ADFI_Declarations;

% Read in boundary node pointers
[D,grid_1.root.ID,error_return] = ADF_Database_Open(grid,'READ_ONLY','NATIVE',D);
[D,grid_1.bnn.ID,error_return] = ADF_Get_Node_ID(grid_1.root.ID,'bnd_node-->node',D);
[D,bnd_node_node,error_return] = ADF_Read_All_Data(grid_1.bnn.ID,D);
[D,error_return] = ADF_Database_Close(grid_1.root.ID,D);
clear grid

% Open base flow file
[D,flow_1.ID,error_return] = ADF_Database_Open(file_1,'READ_ONLY','NATIVE',D);
[D,flow_1.n_children,error_return] = ADF_Number_of_Children(flow_1.ID,D);
[D,flow_1.n_children,flow_1.children,error_return] = ADF_Children_Names(flow_1.ID,1,flow_1.n_children,32,D);

% Open new flow file
[D,new.root.ID,error_return] = ADF_Database_Open(new_file,'NEW','NATIVE',D);

% For each of the nodes under the root, copy this to the new file
for node = 1:flow_1.n_children
    [D,temp.ID,error_return] = ADF_Get_Node_ID(flow_1.ID,flow_1.children{node},D);
    [D,temp.data_type,error_return] = ADF_Get_Data_Type(temp.ID,D);
    if ~strcmp(temp.data_type,'MT')
        [D,temp.n_dims,error_return] = ADF_Get_Number_of_Dimensions(temp.ID,D);
        [D,temp.dims,error_return] = ADF_Get_Dimension_Values(temp.ID,D);
        [D,temp.data,error_return] = ADF_Read_All_Data(temp.ID,D);
    end
    
    [D,temp.ID,error_return] = ADF_Create(new.root.ID,flow_1.children{node},D);
    if ~strcmp(temp.data_type,'MT')
        [D,error_return] = ADF_Put_Dimension_Information(temp.ID,temp.data_type,temp.n_dims,temp.dims,D);
        [D,error_return] = ADF_Write_All_Data(temp.ID,temp.data,D);
    end
    clear temp
end

% Populate heat-flux and wall temperature arrays.
[D,qdot.ID,error_return] = ADF_Get_Node_ID(flow_1.ID,'wall heat flux',D);
[D,qdot.data,error_return] = ADF_Read_All_Data(qdot.ID,D);
Qdot = qdot.data'*q_ref;

[D,n_dims,error_return] = ADF_Get_Number_of_Dimensions(qdot.ID,D);
[D,dims,error_return] = ADF_Get_Dimension_Values(qdot.ID,D);

[D,flow.ID,error_return] = ADF_Get_Node_ID(flow_1.ID,'flow',D);
[D,flow.data,error_return] = ADF_Read_All_Data(flow.ID,D);
flow.data = Strip_to_Array(flow.data,6);

flow.data(:,1) = flow.data(:,1)*rho_ref*287.1;
flow.data(:,5) = flow.data(:,5)*p_ref;

Twall = flow.data(bnd_node_node,5)./flow.data(bnd_node_node,1);

[D,error_return] = ADF_Database_Close(flow_1.ID,D);
[D,flow_2.ID,error_return] = ADF_Database_Open(file_2,'READ_ONLY','NATIVE',D);

[D,qdot.ID,error_return] = ADF_Get_Node_ID(flow_2.ID,'wall heat flux',D);
[D,qdot.data,error_return] = ADF_Read_All_Data(qdot.ID,D);
Qdot(:,2) = qdot.data*q_ref;

[D,flow.ID,error_return] = ADF_Get_Node_ID(flow_2.ID,'flow',D);
[D,flow.data,error_return] = ADF_Read_All_Data(flow.ID,D);
flow.data = Strip_to_Array(flow.data,6);

flow.data(:,1) = flow.data(:,1)*rho_ref*287.1;
flow.data(:,5) = flow.data(:,5)*p_ref;

Twall(:,2) = flow.data(bnd_node_node,5)./flow.data(bnd_node_node,1);
[D,error_return] = ADF_Database_Close(flow_2.ID,D);

% Loop over the extra files
for i = 1:length(varargin)
    [D,flow_2.ID,error_return] = ADF_Database_Open(varargin{i},'READ_ONLY','NATIVE',D);
    
    [D,qdot.ID,error_return] = ADF_Get_Node_ID(flow_2.ID,'wall heat flux',D);
    [D,qdot.data,error_return] = ADF_Read_All_Data(qdot.ID,D);
    Qdot(:,2+i) = qdot.data*q_ref;

    [D,flow.ID,error_return] = ADF_Get_Node_ID(flow_2.ID,'flow',D);
    [D,flow.data,error_return] = ADF_Read_All_Data(flow.ID,D);
    flow.data = Strip_to_Array(flow.data,6);

    flow.data(:,1) = flow.data(:,1)*rho_ref*287.1;
    flow.data(:,5) = flow.data(:,5)*p_ref;

    Twall(:,2+i) = flow.data(bnd_node_node,5)./flow.data(bnd_node_node,1);
    [D,error_return] = ADF_Database_Close(flow_2.ID,D);
end

% Calculate tad and htc
% Variables are Qdot and Twall
warning off
beta = Qdot(:,1)./Qdot(:,2); 

Tad = (Twall(:,1) - beta.*Twall(:,2))./(1 - beta);
htc = Qdot(:,2)./(Tad - Twall(:,2));

% P = zeros(dims(2),2);
% for i = 1:dims(2)
%     P(i,:) = polyfit(Twall(i,:),Qdot(i,:),1);
% end
warning on

clear Twall Qdot
% Tad = -P(:,2)./P(:,1);
% htc = -P(:,1);
% % Needs to produce Tad(:,1) and htc(:,1)
% clear P

% Remove all non-finite entries and replace with zero
A = isfinite(Tad);
B = zeros(size(Tad));
B(A) = Tad(A);
Tad = B;
A = isfinite(htc);
B = zeros(size(htc));
B(A) = htc(A);
htc = B;

clear A B

% Write out to file
[D,new.tad.ID,error_return] = ADF_Create(new.root.ID,'adiabatic wall temperature',D);
[D,error_return] = ADF_Put_Dimension_Information(new.tad.ID,'R8',n_dims,dims,D);
[D,error_return] = ADF_Write_All_Data(new.tad.ID,Tad,D);

[D,new.htc.ID,error_return] = ADF_Create(new.root.ID,'heat-transfer coefficient',D);
[D,error_return] = ADF_Put_Dimension_Information(new.htc.ID,'R8',n_dims,dims,D);
[D,error_return] = ADF_Write_All_Data(new.htc.ID,htc,D);

% Close new file
[D,error_return] = ADF_Database_Close(new.root.ID,D);