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
        grad = (Blade.section(n).streamline(chop_in+1,2)-Blade.section(n).streamline(chop_in,2))/...
                (Blade.section(n).streamline(chop_in+1,1)-Blade.section(n).streamline(chop_in,2));
        New_in = [inlet Blade.section(n).streamline(chop_in,2)+grad*(inlet-Blade.section(n).streamline(chop_in,1))];
        Blade.section(n).streamline(chop_in,:) = New_in;
    else
        chop_in = 1;
    end
    
    if outlet_flag == 1
        chop_out = min(find(Blade.section(n).streamline(:,1) > outlet));
        grad = (Blade.section(n).streamline(chop_out,2)-Blade.section(n).streamline(chop_out-1,2))/...
                (Blade.section(n).streamline(chop_out,1)-Blade.section(n).streamline(chop_out-1,1));
        New_out = [outlet Blade.section(n).streamline(chop_out-1,2)+grad*(Blade.section(n).streamline(chop_out-1,1)-outlet)];
        Blade.section(n).streamline(chop_out,:) = New_out;
    else
        chop_out = Blade.section(n).n_streamline;
    end
    
    % Write the new stream data
    New.section(n).streamline = Blade.section(n).streamline(chop_in:chop_out,:);
    New.section(n).n_profile = Blade.section(n).n_profile;
    New.section(n).name = Blade.section(n).name;
    
    % Write the suporting stream data
    New.section(n).n_streamline = chop_out-chop_in+1;
    New.section(n).LE_stream_point = Blade.section(n).LE_stream_point-chop_in+1;
    New.section(n).TE_stream_point = Blade.section(n).TE_stream_point-chop_in+1;
end

% Write the new file
Write_Blade_File(new_file,New);