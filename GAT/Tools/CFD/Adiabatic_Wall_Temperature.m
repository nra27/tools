function Adiabatic_Wall_Temperature(file_root,wall_temps);
%
% Adiabatic_Wall_Temperature(file_root,wall_temps)
%
% Function to calculate the adiabatic wall temperature
% from the wall heat fluxes and the set wall temperatures.

warning off
number_of_files = length(wall_temps);

Handles.dlgbox = figure('units','points','position',[40 40 200 70],'windowstyle','normal',...
        'name','Adiabatic Wall Temperature','buttondownfcn',[],'visible','on','resize','off',...
        'menubar','none','colormap',[],'numbertitle','off','doublebuffer','on');
Handles.axes = axes('position',[0.1 0.35 0.8 0.2],'box','on','xtick',[],'ytick',[],'xlim',[0 1],'ylim',[0 1]);
Handles.line = line([-1 -1],[0.5 0.5]);
set(Handles.line,'color','b','linewidth',14);

% Define the filenames from file_root and wall_temps
for i = 1:number_of_files
    filenames{i} = ['../bc_' num2str(wall_temps(i)) '_wf/' file_root '.flow.' num2str(wall_temps(i)) '.adf'];
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

% Initialise Adiabatic Wall Temp array
Number_of_Points = length(Qdot);
Twall = zeros(1,Number_of_Points);

set(Handles.title,'string','Calculating Adiabatic Wall Temperatures');
set(Handles.line,'xdata',[0 0]);
pause(0.02);
lim = 0.009;
% Poor long loop to extrapolate wall temps
for i = 1:Number_of_Points
    Twall(i) = extrap1(Qdot(:,i),wall_temps',0,1);
    if i/Number_of_Points > lim
        set(Handles.line,'xdata',[0 lim]);
        pause(0.02);
        lim = lim+0.01;
    end
end

set(Handles.title,'string','Writing Data to File');
set(Handles.line,'xdata',[0 0.01]);
pause(0.1);
% Generate the Adiabatic file name
writefile = [file_root '.flow.adia.adf'];

% Write the data
D = Write_Awal_Data(writefile,Twall,D);

set(Handles.line,'xdata',[0 0.99]);
pause(1);
close(Handles.dlgbox);
warning on