function Add_Parallel_Streamline(old_filename,new_filename,offset);
%
% Add_Parallel_Streamline(old_filename,new_filename,offset)
% A function to add a streamline parallel to the casing streamline
% at a specified offset (specified in m).  This is for giving a constant tip-gap

HPB = Read_Blade_File(old_filename);

% % Up-sample the profiles
for i = 1:HPB.n_sections
    % Split into SS and PS and interpolate
    SS(i,:,3) = linspace(HPB.section(i).profile(1,3),HPB.section(i).profile(HPB.section(i).TE_profile_point,3),15000);
    SS(i,:,2) = interp1(HPB.section(i).profile(1:HPB.section(i).TE_profile_point,3),HPB.section(i).profile(1:HPB.section(i).TE_profile_point,2),SS(i,:,3),'spline');
    SS(i,:,1) = interp1(HPB.section(i).profile(1:HPB.section(i).TE_profile_point,3),HPB.section(i).profile(1:HPB.section(i).TE_profile_point,1),SS(i,:,3),'spline');
    
    PS(i,:,3) = linspace(HPB.section(i).profile(HPB.section(i).TE_profile_point,3),HPB.section(i).profile(end,3),15000);
    PS(i,:,2) = interp1(HPB.section(i).profile(HPB.section(i).TE_profile_point:end,3),HPB.section(i).profile(HPB.section(i).TE_profile_point:end,2),PS(i,:,3),'spline');
    PS(i,:,1) = interp1(HPB.section(i).profile(HPB.section(i).TE_profile_point:end,3),HPB.section(i).profile(HPB.section(i).TE_profile_point:end,1),PS(i,:,3),'spline');    
end

% Interpolate streamline parameters
for i = 1:HPB.n_sections
    Inlet(i,:) = HPB.section(i).streamline(1,:);
    Outlet(i,:) = HPB.section(i).streamline(end,:);
    LE(i,:) = HPB.section(i).streamline(HPB.section(i).LE_stream_point,:);
    TE(i,:) = HPB.section(i).streamline(HPB.section(i).TE_stream_point,:);
    AA_in(i) = HPB.section(i).AA_in;
    AA_out(i) = HPB.section(i).AA_out;
    LE_rad(i) = HPB.section(i).LE_rad;
    TE_rad(i) = HPB.section(i).TE_rad;
    MA_in(i) = HPB.section(i).MA_in;
    MA_out(i) = HPB.section(i).MA_out;
end

% Create template profile
New.section = HPB.section(end);
New.section.streamline(:,2) = New.section.streamline(:,2)-offset;

% Calculate new Inlet, LE, TE and Outlet streamline points
% Inlet
gp = Inlet(end,1) - Inlet(end-1,1);  % Plane gradient
if gp == 0  % Plane is radial so do nothing!
else    % Plane is angled so work out interception point
    mp = (Inlet(end,2)-Inlet(end-1,2))/gp;
    cp = Inlet(end,2)-mp*Inlet(end,1);
    
    ms = (New.section.streamline(1,2)-New.section.streamline(2,2))/(New.section.streamline(1,1)-New.section.streamline(2,1));
    cs = New.section.streamline(1,2)-ms*New.section.streamline(1,1);
    
    New.section.streamline(1,1) = (cs-cp)/(mp-ms);
    New.section.streamline(1,2) = mp*New.section.streamline(1,1)+cp;
end

% Outlet
gp = Outlet(end,1) - Outlet(end-1,1);  % Plane gradient
if gp == 0  % Plane is radial so do nothing!
else    % Plane is angled so work out interception point
    mp = (Outlet(end,2)-Outlet(end-1,2))/gp;
    cp = Outlet(end,2)-mp*Outlet(end,1);
    
    ms = (New.section.streamline(end-1,2)-New.section.streamline(end,2))/(New.section.streamline(end-1,1)-New.section.streamline(end,1));
    cs = New.section.streamline(end,2)-ms*New.section.streamline(end,1);
    
    New.section.streamline(end,1) = (cs-cp)/(mp-ms);
    New.section.streamline(end,2) = mp*New.section.streamline(end,1)+cp;
end 
    
% LE
gp = LE(end,1) - LE(end-1,1);  % Plane gradient
if gp == 0  % Plane is radial so do nothing!
elseif gp > 0   % Plane is sloped forward
    mp = (LE(end,2)-LE(end-1,2))/gp;
    cp = LE(end,2)-mp*LE(end,1);
    
    ms = (New.section.streamline(New.section.LE_stream_point-1,2)-New.section.streamline(New.section.LE_stream_point,2))/...
        (New.section.streamline(New.section.LE_stream_point-1,1)-New.section.streamline(New.section.LE_stream_point,1));
    cs = New.section.streamline(New.section.LE_stream_point,2)-ms*New.section.streamline(New.section.LE_stream_point,1);
    
    New.section.streamline(New.section.LE_stream_point+1:end+1,:) = New.section.streamline(New.section.LE_stream_point:end,:);
    
    New.section.streamline(New.section.LE_stream_point,1) = (cs-cp)/(mp-ms);
    New.section.streamline(New.section.LE_stream_point,2) = mp*New.section.streamline(New.section.LE_stream_point,1)+cp;
    
    New.section.n_streamline = New.section.n_streamline+1;
    New.section.TE_stream_point = New.section.TE_stream_point+1;
else    % Plane is sloped backwards
    mp = (LE(end,2)-LE(end-1,2))/gp;
    cp = LE(end,2)-mp*LE(end,1);
    
    ms = (New.section.streamline(New.section.LE_stream_point,2)-New.section.streamline(New.section.LE_stream_point+1,2))/...
        (New.section.streamline(New.section.LE_stream_point,1)-New.section.streamline(New.section.LE_stream_point+1,1));
    cs = New.section.streamline(New.section.LE_stream_point,2)-ms*New.section.streamline(New.section.LE_stream_point,1);
    
    New.section.streamline(New.section.LE_stream_point+2:end+1,:) = New.section.streamline(New.section.LE_stream_point+1:end,:);
    
    New.section.streamline(New.section.LE_stream_point+1,1) = (cs-cp)/(mp-ms);
    New.section.streamline(New.section.LE_stream_point+1,2) = mp*New.section.streamline(New.section.LE_stream_point+1,1)+cp;
    
    New.section.n_streamline = New.section.n_streamline+1;
    New.section.LE_stream_point = New.section.LE_stream_point+1;
    New.section.TE_stream_point = New.section.TE_stream_point+1;
end

% TE
gp = TE(end,1) - TE(end-1,1);  % Plane gradient
if gp == 0  % Plane is radial so do nothing!
elseif gp > 0   % Plane is sloped forward
    mp = (TE(end,2)-TE(end-1,2))/gp;
    cp = TE(end,2)-mp*TE(end,1);
    
    ms = (New.section.streamline(New.section.TE_stream_point-1,2)-New.section.streamline(New.section.TE_stream_point,2))/...
        (New.section.streamline(New.section.TE_stream_point-1,1)-New.section.streamline(New.section.TE_stream_point,1));
    cs = New.section.streamline(New.section.TE_stream_point,2)-ms*New.section.streamline(New.section.TE_stream_point,1);
    
    New.section.streamline(New.section.TE_stream_point+1:end+1,:) = New.section.streamline(New.section.TE_stream_point:end,:);
    
    New.section.streamline(New.section.TE_stream_point,1) = (cs-cp)/(mp-ms);
    New.section.streamline(New.section.TE_stream_point,2) = mp*New.section.streamline(New.section.TE_stream_point,1)+cp;
    
    New.section.n_streamline = New.section.n_streamline+1;
else    % Plane is sloped backwards
    mp = (TE(end,2)-TE(end-1,2))/gp;
    cp = TE(end,2)-mp*TE(end,1);
    
    ms = (New.section.streamline(New.section.TE_stream_point,2)-New.section.streamline(New.section.TE_stream_point+1,2))/...
        (New.section.streamline(New.section.TE_stream_point,1)-New.section.streamline(New.section.TE_stream_point+1,1));
    cs = New.section.streamline(New.section.TE_stream_point,2)-ms*New.section.streamline(New.section.TE_stream_point,1);
    
    New.section.streamline(New.section.TE_stream_point+2:end+1,:) = New.section.streamline(New.section.TE_stream_point+1:end,:);
    
    New.section.streamline(New.section.TE_stream_point+1,1) = (cs-cp)/(mp-ms);
    New.section.streamline(New.section.TE_stream_point+1,2) = mp*New.section.streamline(New.section.TE_stream_point+1,1)+cp;
    
    New.section.n_streamline = New.section.n_streamline+1;
    New.section.TE_stream_point = New.section.TE_stream_point+1;
end

% Interpolate Air- and Metal-angles as well as LE and TE cirlce radii
New.section.AA_in = interp1(Inlet(:,2),AA_in,New.section.streamline(New.section.LE_stream_point,2));
New.section.MA_in = interp1(Inlet(:,2),MA_in,New.section.streamline(New.section.LE_stream_point,2));
New.section.LE_rad = interp1(Inlet(:,2),LE_rad,New.section.streamline(New.section.LE_stream_point,2));
New.section.AA_out = interp1(Outlet(:,2),AA_out,New.section.streamline(New.section.TE_stream_point,2));
New.section.MA_out = interp1(Outlet(:,2),MA_out,New.section.streamline(New.section.TE_stream_point,2));
New.section.TE_rad = interp1(Outlet(:,2),TE_rad,New.section.streamline(New.section.TE_stream_point,2));

% Stretch the x-profiles to match the new chord
SS_old_chord = New.section.profile(New.section.TE_profile_point,3)-New.section.profile(1,3);
PS_old_chord = New.section.profile(New.section.TE_profile_point,3)-New.section.profile(end,3);  % Should be same as above!

SS_frac = (New.section.profile(1:New.section.TE_profile_point,3)-New.section.profile(1,3))/SS_old_chord;
PS_frac = (New.section.profile(New.section.TE_profile_point:end,3)-New.section.profile(end,3))/PS_old_chord;

new_chord = New.section.streamline(New.section.TE_stream_point,1)-New.section.streamline(New.section.LE_stream_point,1);

New.section.profile(1:New.section.TE_profile_point,3) = SS_frac*new_chord+New.section.streamline(New.section.LE_stream_point,1);
New.section.profile(New.section.TE_profile_point:end,3) = PS_frac*new_chord+New.section.streamline(New.section.LE_stream_point,1);

% Map the new x-profile on the streamline to get the new r-profile
New.section.profile(:,1) = interp1(New.section.streamline(:,1),New.section.streamline(:,2),New.section.profile(:,3),'linear');

% Interpolate the new theta-profile from the new x- and r-profiles
New_SS(:,3) = linspace(New.section.profile(1,3),New.section.profile(New.section.TE_profile_point,3),15000)';
New_SS(:,1) = interp1(New.section.profile(1:New.section.TE_profile_point,3),New.section.profile(1:New.section.TE_profile_point,1),New_SS(:,3),'spline');

New_PS(:,3) = linspace(New.section.profile(New.section.TE_profile_point,3),New.section.profile(end,3),15000)';
New_PS(:,1) = interp1(New.section.profile(New.section.TE_profile_point:end,3),New.section.profile(New.section.TE_profile_point:end,1),New_PS(:,3),'spline');

for i = 1:15000
    New_SS(i,2) = interp1(SS(:,i,1),SS(:,i,2),New_SS(i,1),'spline');
    New_PS(i,2) = interp1(PS(:,i,1),PS(:,i,2),New_PS(i,1),'spline');
end

% Downsample to the points that we want
New.section.profile(1:New.section.TE_profile_point,2) = interp1(New_SS(:,3),New_SS(:,2),New.section.profile(1:New.section.TE_profile_point,3),'spline');
New.section.profile(New.section.TE_profile_point:end,2) = interp1(New_PS(:,3),New_PS(:,2),New.section.profile(New.section.TE_profile_point:end,3),'spline');

% Move section up
HPB.section(end+1) = HPB.section(end);
% Rename
i = str2num(HPB.section(end).name(7:end));
HPB.section(end).name = ['BLADE  ' num2str(i+1)];

% Insert new section
HPB.section(end-1) = New.section;
HPB.n_sections = HPB.n_sections+1;

% Write file
Write_Blade_File(new_filename,HPB);