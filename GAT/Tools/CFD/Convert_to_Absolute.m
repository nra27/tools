function Convert_to_Absolute(grid_file,flow_file,omega);
%
% Convert_to_Absolute(grid_file,flow_file,omega);
%
% A function to read in an ADF datafile in the relative reference
% frame and set to the absolute.

% Non dimensional parameters
rho_ref = 1.226;
p_ref = 101300;
u_ref = sqrt(p_ref/rho_ref);
q_ref = p_ref^1.5/rho_ref^0.5;

% Initialise ADF parameters
D = ADFI_Declarations;
[D,error_return] = ADF_Set_Error_State(1,D);

Handles.dlgbox = figure('units','points','position',[40 40 200 70],'windowstyle','normal',...
        'name','Read HYDRA ADF Data','buttondownfcn',[],'visible','on','resize','off',...
        'menubar','none','colormap',[],'numbertitle','off','doublebuffer','on');
Handles.axes = axes('position',[0.1 0.35 0.8 0.2],'box','on','xtick',[],'ytick',[],'xlim',[0 1],'ylim',[0 1]);
Handles.line = line([-1 -1],[0.5 0.5]);
set(Handles.line,'color','b','linewidth',14);
set(Handles.line,'xdata',[-1 2]);

% Open Grid file
Handles.title = title('Reading Grid File');
pause(0.02);
[D,grid.root.ID,error_return] = ADF_Database_Open(grid_file,'READ_ONLY','NATIVE',D);

% Read grid coordinates
set(Handles.title,'string','Reading Node: node coordinates');
pause(0.02);
[D,grid.coordinates.ID,error_return] = ADF_Get_Node_ID(grid.root.ID,'node_coordinates',D);
[D,grid.coordinates.data,error_return] = ADF_Read_All_Data(grid.coordinates.ID,D);
[D,grid.coordinates.dim_vals,error_return] = ADF_Get_Dimension_Values(grid.coordinates.ID,D);
grid.coordinates.data = Strip_to_Array(grid.coordinates.data,grid.coordinates.dim_vals(1));

% Close Grid file
[D,error_return] = ADF_Database_Close(grid.root.ID,D);

% Open Solution file
Handles.title = title('Reading Solution File');
pause(0.02);
set(Handles.line,'xdata',[-1 2]);

[D,solution.root.ID,error_return] = ADF_Database_Open(flow_file,'OLD','NATIVE',D);

% Read data
set(Handles.title,'string','Reading Node: flow');
pause(0.02);
[D,solution.flow.ID,error_return] = ADF_Get_Node_ID(solution.root.ID,'flow',D);
[D,solution.flow.dim_vals,error_return] = ADF_Get_Dimension_Values(solution.flow.ID,D);
[D,solution.flow.data,error_return] = ADF_Read_All_Data(solution.flow.ID,D);
solution.flow.data = Strip_to_Array(solution.flow.data,solution.flow.dim_vals(1));

solution.flow.data(:,1) = solution.flow.data(:,1)*rho_ref;
solution.flow.data(:,2:4) = solution.flow.data(:,2:4)*u_ref;
solution.flow.data(:,5) = solution.flow.data(:,5)*p_ref;

% Convert to r-theta
set(Handles.title,'string','Set to R-Theta');
pause(0.02);
r = sqrt((grid.coordinates.data(:,2)).^2+(grid.coordinates.data(:,3)).^2);
theta = atan2(grid.coordinates.data(:,3),grid.coordinates.data(:,2));

% Return to absolute frame
set(Handles.title,'string','Return to Absolute Frame');
pause(0.02);

solution.flow.data(:,3) = solution.flow.data(:,3)-r.*omega.*sin(theta);
solution.flow.data(:,4) = solution.flow.data(:,4)+r.*omega.*cos(theta);

solution.flow.data(:,1) = solution.flow.data(:,1)/rho_ref;
solution.flow.data(:,2:4) = solution.flow.data(:,2:4)/u_ref;
solution.flow.data(:,5) = solution.flow.data(:,5)/p_ref;

% Write to flow-file
set(Handles.title,'string','Writing Node: flow');
pause(0.02);
solution.flow.data = Array_to_Strip(solution.flow.data,solution.flow.dim_vals(1));
[D,error_return] = ADF_Write_All_Data(solution.flow.ID,solution.flow.data,D);

% Close Solution file
[D,error_return] = ADF_Database_Close(solution.root.ID,D);

pause(1);
close(Handles.dlgbox);