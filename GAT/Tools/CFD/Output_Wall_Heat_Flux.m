function Qdot = Output_Wall_Heat_Flux(file_root,wall_temps);
%
% Qdot = Output_Wall_Heat_Flux(file_root,wall_temps)
%
% Function to load the the wall heat fluxes from the
% given ADF files

number_of_files = length(wall_temps);

Handles.dlgbox = figure('units','points','position',[40 40 200 70],'windowstyle','normal',...
        'name','Adiabatic Wall Temperature','buttondownfcn',[],'visible','on','resize','off',...
        'menubar','none','colormap',[],'numbertitle','off','doublebuffer','on');
Handles.axes = axes('position',[0.1 0.35 0.8 0.2],'box','on','xtick',[],'ytick',[],'xlim',[0 1],'ylim',[0 1]);
Handles.line = line([-1 -1],[0.5 0.5]);
set(Handles.line,'color','b','linewidth',14);

% Define the filenames from file_root and wall_temps
for i = 1:number_of_files
    filenames{i} = [file_root '.' num2str(wall_temps(i)) '.flow.adf'];
end

% Initialise ADF variables
D = ADFI_Declarations;
[D,error_return] = ADF_Set_Error_State(1,D);

Handles.title = title('Reading ADF Files');

% Read the Qdot data in for the files
for i = 1:number_of_files
    [D,Qdot(i,:)] = Read_Qdot_Data(filenames{i},D);
    set(Handles.line,'xdata',[0 i/number_of_files]);
    pause(0.02);
end

close(Handles.dlgbox);