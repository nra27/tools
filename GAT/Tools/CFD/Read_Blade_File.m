function blade = Read_Blade_File(filename);
%
% blade = Read_Blade_File('file_name')
% A function to read a Rolls-Royce JH05 blade definition file

% Open file
fid = fopen(filename,'r');

% Read header information
blade.JH05 = fgetl(fid);
if ~strcmp(blade.JH05,'JH05  1')
    disp('This is not a valid file!')
    fclose(fid);
    return
end
blade.stream_name = fgetl(fid);
blade.flow_name = fgetl(fid);

temp = fscanf(fid,'%d',3);
blade.n_sections = temp(1); % number of streamline sections
blade.n_off = temp(2);      % number of blades on disc
blade.flip = temp(3);       % flag to flip blade
fgetl(fid);                 % force end of line

% Loop through the number of streamline sections
for i = 1:blade.n_sections
    blade.section(i).name = fgetl(fid);
    if ~strcmp(deblank(blade.section(i).name),['BLADE ' num2str(i)])
        disp(i)
        disp('There has been a file error!')
        return
    end
    
    % Read profile dimensions
    temp = fscanf(fid,'%d',5);
    blade.section(i).n_streamline = temp(1);    % number of points on the stream line
    blade.section(i).LE_stream_point = temp(2); % index of LE stream point
    blade.section(i).TE_stream_point = temp(3); % index of TE stream point
    blade.section(i).n_profile = temp(4);       % number of points on the blade profile
    blade.section(i).TE_profile_point = temp(5);% index of the TE profile point
    
    % Read LE and TE properties
    temp = fscanf(fid,'%f',6);
    blade.section(i).AA_in = temp(1);   % Inlet air angle
    blade.section(i).AA_out = temp(2);  % Exit air angle
    blade.section(i).LE_rad = temp(3);  % LE circle radius
    blade.section(i).TE_rad = temp(4);  % TE circle radius
    blade.section(i).MA_in = temp(5);   % Inlet metal angle
    blade.section(i).MA_out = temp(6);  % Exit metal angle
    
    % Read the streamline data
    blade.section(i).streamline = fscanf(fid,'%f',[2,blade.section(i).n_streamline])';
    
    % Read the profile data
    blade.section(i).profile = fscanf(fid,'%f',[3,blade.section(i).n_profile])';
    
    fgetl(fid);  % force an end of line
end

fclose(fid);