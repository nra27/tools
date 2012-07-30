function data = Resample_Casing_Data(surface_data,flow_data,step_flag,variable);
%
% data = Rescale_Casing_Data(surface_data,flow_data,step_flag,variable)
%
% A function to take a hydra grid and flow file and resample the given variable
% as if it were experimental, if the geometry has a step, put step flag = 1
% Currently only pressure and wall_heat_flux are valid variables
%
% data is a structure containing
%  |
%  --> blade = the blade data
%  --> repeat = the repeat angle (radians)
%  --> casing
%		|
%		--> s_target = the s-direction matrix
%		--> x_target = the x-direction matrix
%		--> data_target = the resampled data

warning off

% Define the blade position
fid = fopen('J:\users\casgt\hpb\Definitions\ResHPB21.dat');
blade = fscanf(fid,'%f',[3 inf])';
fclose(fid);

% Set to r,theta,s and rescale
blade(:,4) = sqrt((blade(:,2)).^2+(blade(:,3)).^2);
blade(:,5) = atan2(blade(:,3),blade(:,2));
blade(:,6) = blade(:,4).*blade(:,5);

blade(:,1) = blade(:,1);
blade(:,6) = blade(:,6);
blade(end+1,:) = blade(1,:);

% Find casing surface
number_of_surfaces = length(surface_data.surface_groups);

for i = 1:number_of_surfaces
	if strcmp(surface_data.surface_groups{i},'Casing')
		group = i;
	end
end

if ~exist('group','var')
	casing = input('Please enter the name of the casing surface.','s');
	for i = 1:number_of_surfaces
		if strcmp(surface_data.surface_groups{i},casing)
			group = i;
		end
	end
end

flow_data = Set_to_RTheta(flow_data);
coordinates = flow_data.coordinates(surface_data.group(group).flow_node_numbers,:);
coordinates(:,6) = coordinates(:,4).*coordinates(:,5);

if strcmp(variable,'pressure')
	data = flow_data.flow(surface_data.group(group).flow_node_numbers,5);
elseif strcmp(variable,'wall_heat_flux')
	data = surface_data.group(group).wall_heat_flux;
else
	disp('This variable is not supported')
	return
end

% Find the periodic nodes
Handles.dlgbox = figure('units','points','position',[40 40 200 70],'windowstyle','normal',...
        'name','Resample HYDRA Casing Data','buttondownfcn',[],'visible','on','resize','off',...
        'menubar','none','colormap',[],'numbertitle','off','doublebuffer','on','Tag','nozoom');
Handles.axes = axes('position',[0.1 0.35 0.8 0.2],'box','on','xtick',[],'ytick',[],'xlim',[0 1],'ylim',[0 1]);
Handles.line = line([-1 -1],[0.5 0.5]);
set(Handles.line,'color','b','linewidth',14);
Handles.title = title('Finding Periodic Nodes');
set(Handles.line,'xdata',[0 0]);
drawnow;

repeat = 6/180*pi;
coordinates(:,7) = coordinates(:,5)+repeat;
coordinates(:,8) = coordinates(:,7).*coordinates(:,4);

periodic = [];

% Find periodic nodes
for i = 1:length(coordinates(:,6))
	diff = sqrt((coordinates(:,8)-coordinates(i,6)).^2+(coordinates(:,1)-coordinates(i,1)).^2);
	check = find((diff < 0.0001).*(diff > -0.0001));
	if ~isempty(check)
        jump = length(check);
		periodic(end+1:end+jump) = check;
	end
    set(Handles.line,'xdata',[0 i/length(coordinates(:,6))]);
    drawnow;
end


if step_flag == 1
    Handles.title = title('Finding Step Nodes');
    set(Handles.line,'xdata',[0 0]);
    drawnow;

    step = [];

    for i = 1:length(coordinates(:,6))
	    diff = sqrt((coordinates(:,6)-coordinates(i,6)).^2+(coordinates(:,1)-coordinates(i,1)).^2);
	    check = find((diff < 0.00001).*(diff > 0));
	    if ~isempty(check)
            jump = length(check);
		    step(end+1:end+jump) = check;
	    end
        set(Handles.line,'xdata',[0 i/length(coordinates(:,6))]);
        drawnow;
    end

    step = sort(step);
    new_step = step(1);
    for i = 2:length(step)
        if new_step(end) ~= step(i)
        new_step(end+1) = step(i);
    end
    end
    step = new_step;
    clear new_step;

    diff = coordinates(step,1)-min(coordinates(step,1));
    step = step(find(diff > 0.000001));
end

index = [];

% Set up new coordinates
if step_flag == 1
    for i = 1:length(coordinates(:,6))
	    if isempty(find(i == periodic)) & isempty(find(i == step))
		    index(end+1) = i;
	    end
    end
else
    for i = 1:length(coordinates(:,6))
	    if isempty(find(i == periodic))
		    index(end+1) = i;
	    end
    end
end

% Expand the domain
x_hydra = [coordinates(index,1); coordinates(index,1); coordinates(index,1); coordinates(index,1); coordinates(index,1)]*1000;
r_hydra = [coordinates(index,4); coordinates(index,4); coordinates(index,4); coordinates(index,4); coordinates(index,4)]*1000;
t_hydra = [coordinates(index,5)+2*repeat; coordinates(index,5)+repeat; coordinates(index,5); coordinates(index,5)-repeat; coordinates(index,5)-2*repeat];
s_hydra = r_hydra.*t_hydra;
data = [data(index); data(index); data(index); data(index); data(index)];

% Set up the required points
offset = 10/180*pi*272.754*0.145;
x_target = linspace(48.358,72.468,36);
for i = 1:length(x_target)
	s_target(i,:) = linspace(-11.7075-(i-1)/5,-11.7075+48-(i-1)/5,100)+offset;
end

% Resample
set(Handles.title,'string','Resampling Data');
set(Handles.line,'xdata',[0 0]);
for i = 1:length(x_target)
	set(Handles.line,'xdata',[0 i/length(x_target)]);
    drawnow;
	data_target(i,:) = griddata(x_hydra,s_hydra,data,x_target(i)*ones(1,100),s_target(i,:));
end

close(Handles.dlgbox);

data.casing.s_target = s_target;
data.casing.x_target = -x_target'*ones(1,100);
data.casing.data_target = data_target;
data.blade = -blade;
data.repeat = repeat;

warning on
