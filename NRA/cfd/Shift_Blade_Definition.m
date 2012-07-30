function Shift_Blade_Definition(old_file,new_file,x_shift);
%
% Shift_Blade_Definition(old_file,new_file,x_shift);
% A function to read in a Blade definition file and shift in the x
% direction

% Load starting file
Blade = Read_Blade_File(old_file);

% Copy header information
New.JH05 = Blade.JH05;
New.stream_name = Blade.stream_name;
New.flow_name = Blade.flow_name;
New.n_sections = Blade.n_sections;
New.n_off = Blade.n_off;
New.flip = Blade.flip;

% For each streamline
for n = 1:Blade.n_sections
    % Copy profile
    New.section(n).profile(:,1:2) = Blade.section(n).profile(:,1:2);
    New.section(n).profile(:,3) = Blade.section(n).profile(:,3) + x_shift;
    New.section(n).TE_profile_point = Blade.section(n).TE_profile_point;
    New.section(n).AA_in = Blade.section(n).AA_in;
    New.section(n).AA_out = Blade.section(n).AA_out;
    New.section(n).LE_rad = Blade.section(n).LE_rad;
    New.section(n).TE_rad = Blade.section(n).TE_rad;
    New.section(n).MA_in = Blade.section(n).MA_in;
    New.section(n).MA_out = Blade.section(n).MA_out;
    
      
    % Write the new stream data
    New.section(n).streamline(:,1) = Blade.section(n).streamline(1:end-1,1) + x_shift;
    New.section(n).streamline(end+1,1) = Blade.section(n).streamline(end,1);
    New.section(n).streamline(:,2) = Blade.section(n).streamline(:,2);
    New.section(n).n_profile = Blade.section(n).n_profile;
    New.section(n).name = Blade.section(n).name;
    
    % Write the suporting stream data
    New.section(n).n_streamline = Blade.section(n).n_streamline;
    New.section(n).LE_stream_point = Blade.section(n).LE_stream_point;
    New.section(n).TE_stream_point = Blade.section(n).TE_stream_point;

end

% Write the new file
Write_Blade_File(new_file,New);