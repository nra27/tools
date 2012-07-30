function Write_Blade_File(filename,blade);
%
% Write_Blade_File(filename,blade)
% A function to write a Rolls-Royce blade definintion file

% Open file
fid = fopen(filename,'w');

% Write header information
fprintf(fid,[blade.JH05 '\n']);
fprintf(fid,[blade.stream_name '\n']); 
fprintf(fid,[blade.flow_name '\n']);

fprintf(fid,'%d %d %d\n',[blade.n_sections, blade.n_off, blade.flip]);

% Loop through the number of streamline sections
for i = 1:blade.n_sections
    % Write profile name
    fprintf(fid,'BLADE %d\n',i);
    
    % Write profile properties
    fprintf(fid,'%d %d %d %d %d\n',[blade.section(i).n_streamline, blade.section(i).LE_stream_point,...
            blade.section(i).TE_stream_point, blade.section(i).n_profile, blade.section(i).TE_profile_point]);
    
    % Write LE and TE properties
    fprintf(fid,'%17.12f %17.12f %17.12f %17.12f %17.12f %17.12f\n',[blade.section(i).AA_in, blade.section(i).AA_out,...
            blade.section(i).LE_rad, blade.section(i).TE_rad, blade.section(i).MA_in, blade.section(i).MA_out]);
    
    % Write the streamline data
    fprintf(fid,'%17.12f %17.12f\n',blade.section(i).streamline');
    
    % Write the profile data
    fprintf(fid,'%17.12f %17.12f %17.12f\n',blade.section(i).profile');
end

fclose(fid);