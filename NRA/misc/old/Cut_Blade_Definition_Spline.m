function Cut_Blade_Definition(old_file,new_file,inlet,inlet_flag,outlet,outlet_flag);
%
% Cut_Blade_Definition(old_file,new_file,inlet_off,outlet_off);
% A function to read in a Blade definition file and shorten the inlet
% and outlet streamline profiles using an inlet and exit cut plain
% defined by the x-value

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
    New.section(n).profile = Blade.section(n).profile;
    New.section(n).TE_profile_point = Blade.section(n).TE_profile_point;
    New.section(n).AA_in = Blade.section(n).AA_in;
    New.section(n).AA_out = Blade.section(n).AA_out;
    New.section(n).LE_rad = Blade.section(n).LE_rad;
    New.section(n).TE_rad = Blade.section(n).TE_rad;
    New.section(n).MA_in = Blade.section(n).MA_in;
    New.section(n).MA_out = Blade.section(n).MA_out;
    
    % Reprofile streamline
    if inlet_flag == 1
        chop_in = max(find(Blade.section(n).streamline(:,1) < inlet));
        % temp_stream = Blade.section(n).streamline([chop_in-1 chop_in chop_in+1 chop_in+2 chop_in+3],:);
        temp_stream = Blade.section(n).streamline([chop_in chop_in+1 chop_in+2 chop_in+3],:);
        Blade.section(n).streamline(chop_in,:) = [inlet spline(temp_stream(:,1),temp_stream(:,2),inlet)];
    else
        chop_in = 1;
    end
    
    if outlet_flag == 1
        chop_out = min(find(Blade.section(n).streamline(:,1) > outlet));
        %temp_stream = Blade.section(n).streamline([chop_out-2 chop_out-1 chop_out chop_out+1 chop_out+2],:);
        temp_stream = Blade.section(n).streamline([chop_out-1 chop_out chop_out+1],:);
        Blade.section(n).streamline(chop_out,:) = [outlet spline(temp_stream(:,1),temp_stream(:,2),outlet)];
    else
        chop_out = Blade.section(n).n_streamline;
    end
    
    % Write the new stream data
    New.section(n).streamline = Blade.section(n).streamline(chop_in:chop_out,:);
    
    % Write the profile data
    New.section(n).n_profile = Blade.section(n).n_profile;
    
    % Write the suporting stream data
    New.section(n).n_streamline = chop_out-chop_in+1;
    New.section(n).LE_stream_point = Blade.section(n).LE_stream_point-chop_in+1;
    New.section(n).TE_stream_point = Blade.section(n).TE_stream_point-chop_in+1;
end

% Write the new file
blade = New;

% Open file
fid = fopen(new_file,'w');

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