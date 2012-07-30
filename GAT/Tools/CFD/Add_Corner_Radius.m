function Gap = Add_Corner_Radius(old_filename,new_filename,tip_gap,radius);
%
% Gap = Add_Corner_Radius(old_filename,new_filename,tip_gap,radius)
% A function to modify a blade definition file to include a 
% parallel tip gap a given profile.  The tip-gap is given as
% an absolute radial offset in mm and the radius is given in mm.
% The % of LE and TE span is returned in Gap.

warning off
Handles.dlgbox = figure('units','points','position',[40 40 200 70],'windowstyle','normal',...
        'name','Padram Tools','buttondownfcn',[],'visible','on','resize','off',...
        'menubar','none','colormap',[],'numbertitle','off','doublebuffer','on','Tag','nozoom');
Handles.axes = axes('position',[0.1 0.35 0.8 0.2],'box','on','xtick',[],'ytick',[],'xlim',[0 1],'ylim',[0 1]);
Handles.line = line([-1 -1],[0.5 0.5]);
set(Handles.line,'color','b','linewidth',14);
set(Handles.line,'xdata',[-1 2]);

Handles.title = title('Reading Blade File');
drawnow;

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

% Group streamline parameters
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

% Set up profile locations and step values
radius = radius/1000;   % convert to SI
tip_gap = tip_gap/1000;    % convert tip-gap to SI
Gap(1) = tip_gap/(LE(end,2)-LE(1,2))*100;
Gap(2) = tip_gap/(TE(end,2)-TE(1,2))*100;

% Check values
if radius >= tip_gap
    disp('Requested radius is too large for the tip-gap!')
    return
end

% Build offset and step vectors
theta = [0:3:90]*pi/180;
offset = tip_gap+radius*(1-sin(theta));
step = radius*(1-cos(theta));
theta = [3:3:90]*pi/180;
offset(end+1:end+30) = tip_gap-radius*(1-cos(theta));
step(end+1:end+30) = radius*(1+sin(theta));

new_points = length(theta);

set(Handles.title,'string','Creating Corner Radius');
set(Handles.line,'xdata',[0 0]);
Handles.axes(2) = axes('position',[0.1 0.15 0.8 0.2],'box','on','xtick',[],'ytick',[],'xlim',[0 1],'ylim',[0 1]);
Handles.line(2) = line([-1 -1],[0.5 0.5]);
set(Handles.line(2),'xdata',[0 0]);
set(Handles.line(2),'color','b','linewidth',14);
set(Handles.line(2),'xdata',[-1 2]);
drawnow;

f = 13;  % Counter for 2nd bar
for n = 1:new_points
    set(Handles.line(2),'xdata',[0 0]);
    drawnow;
    
    % Create template profile
    New.section(n) = HPB.section(end);
    New.section(n).streamline(:,2) = New.section(n).streamline(:,2)-offset(n);
    
    % Calculate new Inlet, LE, TE and Outlet streamline points
    % Inlet
    gp = Inlet(end,1) - Inlet(end-1,1);  % Plane gradient
    if gp == 0  % Plane is radial so do nothing!
    else    % Plane is angled so work out interception point
        mp = (Inlet(end,2)-Inlet(end-1,2))/gp;
        cp = Inlet(end,2)-mp*Inlet(end,1);
        
        ms = (New.section(n).streamline(1,2)-New.section(n).streamline(2,2))/(New.section(n).streamline(1,1)-New.section(n).streamline(2,1));
        cs = New.section(n).streamline(1,2)-ms*New.section(n).streamline(1,1);
        
        New.section(n).streamline(1,1) = (cs-cp)/(mp-ms);
        New.section(n).streamline(1,2) = mp*New.section(n).streamline(1,1)+cp;
    end
    
    set(Handles.line(2),'xdata',[0 1/f]);
    drawnow;
    
    % Outlet
    gp = Outlet(end,1)-Outlet(end-1,1);  % Plane gradient
    if gp == 0  % Plane is radial so do nothing!
    else    % Plane is angled so work out interception point
        mp = (Outlet(end,2)-Outlet(end-1,2))/gp;
        cp = Outlet(end,2)-mp*Outlet(end,1);
        
        ms = (New.section(n).streamline(end-1,2)-New.section(n).streamline(end,2))/(New.section(n).streamline(end-1,1)-New.section(n).streamline(end,1));
        cs = New.section(n).streamline(end,2)-ms*New.section(n).streamline(end,1);
        
        New.section(n).streamline(end,1) = (cs-cp)/(mp-ms);
        New.section(n).streamline(end,2) = mp*New.section(n).streamline(end,1)+cp;
    end 
    
    set(Handles.line(2),'xdata',[0 2/f]);
    drawnow;
    
    % LE
    gp = LE(end,1) - LE(end-1,1);  % Plane gradient
    if gp == 0  % Plane is radial so do nothing!
    elseif gp > 0   % Plane is sloped forward
        mp = (LE(end,2)-LE(end-1,2))/gp;
        cp = LE(end,2)-mp*LE(end,1);
        
        ms = (New.section(n).streamline(New.section(n).LE_stream_point-1,2)-New.section(n).streamline(New.section(n).LE_stream_point,2))/...
            (New.section(n).streamline(New.section(n).LE_stream_point-1,1)-New.section(n).streamline(New.section(n).LE_stream_point,1));
        cs = New.section(n).streamline(New.section(n).LE_stream_point,2)-ms*New.section(n).streamline(New.section(n).LE_stream_point,1);
        
        New.section(n).streamline(New.section(n).LE_stream_point+1:end+1,:) = New.section(n).streamline(New.section(n).LE_stream_point:end,:);
        
        New.section(n).streamline(New.section(n).LE_stream_point,1) = (cs-cp)/(mp-ms);
        New.section(n).streamline(New.section(n).LE_stream_point,2) = mp*New.section(n).streamline(New.section(n).LE_stream_point,1)+cp;
        
        New.section(n).n_streamline = New.section(n).n_streamline+1;
        New.section(n).TE_stream_point = New.section(n).TE_stream_point+1;
    else    % Plane is sloped backwards
        mp = (LE(end,2)-LE(end-1,2))/gp;
        cp = LE(end,2)-mp*LE(end,1);
        
        ms = (New.section(n).streamline(New.section(n).LE_stream_point,2)-New.section(n).streamline(New.section(n).LE_stream_point+1,2))/...
            (New.section(n).streamline(New.section(n).LE_stream_point,1)-New.section(n).streamline(New.section(n).LE_stream_point+1,1));
        cs = New.section(n).streamline(New.section(n).LE_stream_point,2)-ms*New.section(n).streamline(New.section(n).LE_stream_point,1);
        
        New.section(n).streamline(New.section(n).LE_stream_point+2:end+1,:) = New.section(n).streamline(New.section(n).LE_stream_point+1:end,:);
        
        New.section(n).streamline(New.section(n).LE_stream_point+1,1) = (cs-cp)/(mp-ms);
        New.section(n).streamline(New.section(n).LE_stream_point+1,2) = mp*New.section(n).streamline(New.section(n).LE_stream_point+1,1)+cp;
        
        New.section(n).n_streamline = New.section(n).n_streamline+1;
        New.section(n).LE_stream_point = New.section(n).LE_stream_point+1;
        New.section(n).TE_stream_point = New.section(n).TE_stream_point+1;
    end
    
    set(Handles.line(2),'xdata',[0 3/f]);
    drawnow;
    
    % TE
    gp = TE(end,1) - TE(end-1,1);  % Plane gradient
    if gp == 0  % Plane is radial so do nothing!
    elseif gp > 0   % Plane is sloped forward
        mp = (TE(end,2)-TE(end-1,2))/gp;
        cp = TE(end,2)-mp*TE(end,1);
        
        ms = (New.section(n).streamline(New.section(n).TE_stream_point-1,2)-New.section(n).streamline(New.section(n).TE_stream_point,2))/...
            (New.section(n).streamline(New.section(n).TE_stream_point-1,1)-New.section(n).streamline(New.section(n).TE_stream_point,1));
        cs = New.section(n).streamline(New.section(n).TE_stream_point,2)-ms*New.section(n).streamline(New.section(n).TE_stream_point,1);
        
        New.section(n).streamline(New.section(n).TE_stream_point+1:end+1,:) = New.section(n).streamline(New.section(n).TE_stream_point:end,:);
        
        New.section(n).streamline(New.section(n).TE_stream_point,1) = (cs-cp)/(mp-ms);
        New.section(n).streamline(New.section(n).TE_stream_point,2) = mp*New.section(n).streamline(New.section(n).TE_stream_point,1)+cp;
        
        New.section(n).n_streamline = New.section(n).n_streamline+1;
    else    % Plane is sloped backwards
        mp = (TE(end,2)-TE(end-1,2))/gp;
        cp = TE(end,2)-mp*TE(end,1);
        
        ms = (New.section(n).streamline(New.section(n).TE_stream_point,2)-New.section(n).streamline(New.section(n).TE_stream_point+1,2))/...
            (New.section(n).streamline(New.section(n).TE_stream_point,1)-New.section(n).streamline(New.section(n).TE_stream_point+1,1));
        cs = New.section(n).streamline(New.section(n).TE_stream_point,2)-ms*New.section(n).streamline(New.section(n).TE_stream_point,1);
        
        New.section(n).streamline(New.section(n).TE_stream_point+2:end+1,:) = New.section(n).streamline(New.section(n).TE_stream_point+1:end,:);
        
        New.section(n).streamline(New.section(n).TE_stream_point+1,1) = (cs-cp)/(mp-ms);
        New.section(n).streamline(New.section(n).TE_stream_point+1,2) = mp*New.section(n).streamline(New.section(n).TE_stream_point+1,1)+cp;
        
        New.section(n).n_streamline = New.section(n).n_streamline+1;
        New.section(n).TE_stream_point = New.section(n).TE_stream_point+1;
    end
    
    set(Handles.line(2),'xdata',[0 4/f]);
    drawnow;
    
    % Stretch the x-profiles to match the new chord
    SS_old_chord = New.section(n).profile(New.section(n).TE_profile_point,3)-New.section(n).profile(1,3);
    PS_old_chord = New.section(n).profile(New.section(n).TE_profile_point,3)-New.section(n).profile(end,3);  % Should be same as above!
    
    SS_frac = (New.section(n).profile(1:New.section(n).TE_profile_point,3)-New.section(n).profile(1,3))/SS_old_chord;
    PS_frac = (New.section(n).profile(New.section(n).TE_profile_point:end,3)-New.section(n).profile(end,3))/PS_old_chord;
    
    new_chord = New.section(n).streamline(New.section(n).TE_stream_point,1)-New.section(n).streamline(New.section(n).LE_stream_point,1);
    
    New.section(n).profile(1:New.section(n).TE_profile_point,3) = SS_frac*new_chord+New.section(n).streamline(New.section(n).LE_stream_point,1);
    New.section(n).profile(New.section(n).TE_profile_point:end,3) = PS_frac*new_chord+New.section(n).streamline(New.section(n).LE_stream_point,1);
    
    % Map the new x-profile on the streamline to get the new r-profile
    New.section(n).profile(:,1) = interp1(New.section(n).streamline(:,1),New.section(n).streamline(:,2),New.section(n).profile(:,3),'linear');
    
    set(Handles.line(2),'xdata',[0 5/f]);
    drawnow;
    
    % Interpolate the new theta-profile from the new x- and r-profiles
    New_SS(:,3) = linspace(New.section(n).profile(1,3),New.section(n).profile(New.section(n).TE_profile_point,3),15000)';
    New_SS(:,1) = interp1(New.section(n).profile(1:New.section(n).TE_profile_point,3),New.section(n).profile(1:New.section(n).TE_profile_point,1),New_SS(:,3),'spline');
    
    New_PS(:,3) = linspace(New.section(n).profile(New.section(n).TE_profile_point,3),New.section(n).profile(end,3),15000)';
    New_PS(:,1) = interp1(New.section(n).profile(New.section(n).TE_profile_point:end,3),New.section(n).profile(New.section(n).TE_profile_point:end,1),New_PS(:,3),'spline');
    
    for i = 1:15000
        New_SS(i,2) = interp1(SS(:,i,1),SS(:,i,2),New_SS(i,1),'spline');
        New_PS(i,2) = interp1(PS(:,i,1),PS(:,i,2),New_PS(i,1),'spline');
        if rem(i,3000) == 0
            set(Handles.line(2),'xdata',[0 (i/(f*3000)+5/f)]);
            drawnow;
        end
    end
    
    % Calculate the streamline gradient
    New_SS(:,4) = New_SS(:,1).*New_SS(:,2);
    New_PS(:,4) = New_PS(:,1).*New_PS(:,2);
    
    Grad_SS = [New_PS(end-1,:); New_SS; New_PS(2,:)];
    Grad_PS = [New_SS(end-1,:); New_PS; New_SS(2,:)];
    
    Stream_SS = sqrt((Grad_SS(3:end,3)-Grad_SS(2:end-1,3)).^2+(Grad_SS(3:end,4)-Grad_SS(2:end-1,4)).^2);
    Stream_PS = sqrt((Grad_PS(3:end,3)-Grad_PS(2:end-1,3)).^2+(Grad_PS(3:end,4)-Grad_SS(2:end-1,4)).^2);
    stream_SS = sqrt((Grad_SS(2:end-1,3)-Grad_SS(1:end-2,3)).^2+(Grad_SS(2:end-1,4)-Grad_SS(1:end-2,4)).^2);
    stream_PS = sqrt((Grad_PS(2:end-1,3)-Grad_SS(1:end-2,3)).^2+(Grad_PS(2:end-1,4)-Grad_SS(1:end-2,4)).^2); 
    
    GSX = (Grad_SS(3:end,3)-Grad_SS(1:end-2,3))./(Stream_SS+stream_SS);
    GPX = (Grad_PS(3:end,3)-Grad_PS(1:end-2,3))./(Stream_PS+stream_PS);
    GSS = (Grad_SS(3:end,4)-Grad_SS(1:end-2,4))./(Stream_SS+stream_SS);
    GPS = (Grad_PS(3:end,4)-Grad_PS(1:end-2,4))./(Stream_PS+stream_PS);
    
    GLSS = sqrt(GSX.^2+GSS.^2);
    GLPS = sqrt(GPX.^2+GPS.^2);
    
    GSX = GSX./GLSS;
    GSS = GSS./GLSS;
    GPX = GPX./GLPS;
    GPS = GPS./GLPS;
    
    GSX = GSX*step(n);
    GSS = GSS*step(n);
    GPX = GPX*step(n);
    GPS = GPS*step(n);
    
    set(Handles.line(2),'xdata',[0 11/f]);
    drawnow;
    
    New_SS(:,3) = New_SS(:,3)+GSS;  % new x-cords
    New_PS(:,3) = New_PS(:,3)+GPS;  % new x-cords
    New_SS(:,1) = interp1(New.section(n).streamline(:,1),New.section(n).streamline(:,2),New_SS(:,3),'linear');  % new r-cords
    New_PS(:,1) = interp1(New.section(n).streamline(:,1),New.section(n).streamline(:,2),New_PS(:,3),'linear');  % new r-cords
    New_SS(:,2) = (New_SS(:,4)-GSX)./New_SS(:,1);    % new theta values
    New_PS(:,2) = (New_PS(:,4)-GPX)./New_PS(:,1);    % new theta values
    
    set(Handles.line(2),'xdata',[0 12/f]);
    drawnow;
    
    % Downsample using new chord
    New.section(n).profile(1:New.section(n).TE_profile_point,3) = New_SS(1,3)+(New_SS(end,3)-New_SS(1,3))*SS_frac;
    New.section(n).profile(New.section(n).TE_profile_point:end,3) = New_SS(1,3)+(New_SS(end,3)-New_SS(1,3))*PS_frac;
    New.section(n).profile(1:New.section(n).TE_profile_point,1) = interp1(New_SS(:,3),New_SS(:,1),New.section(n).profile(1:New.section(n).TE_profile_point,3),'cubic');
    New.section(n).profile(New.section(n).TE_profile_point:end,1) = interp1(New_PS(:,3),New_PS(:,1),New.section(n).profile(New.section(n).TE_profile_point:end,3),'cubic');
    New.section(n).profile(1:New.section(n).TE_profile_point,2) = interp1(New_SS(:,3),New_SS(:,2),New.section(n).profile(1:New.section(n).TE_profile_point,3),'cubic');
    New.section(n).profile(New.section(n).TE_profile_point:end,2) = interp1(New_PS(:,3),New_PS(:,2),New.section(n).profile(New.section(n).TE_profile_point:end,3),'cubic');
    
    % Interpolate Air- and Metal-angles as well as LE and TE cirlce radii
    New.section(n).AA_in = interp1(LE(:,2),AA_in,New.section(n).streamline(New.section(n).LE_stream_point,2));
    New.section(n).MA_in = interp1(LE(:,2),MA_in,New.section(n).streamline(New.section(n).LE_stream_point,2));
    New.section(n).LE_rad = interp1(LE(:,2),LE_rad,New.section(n).streamline(New.section(n).LE_stream_point,2))-step(n);
    New.section(n).AA_out = interp1(TE(:,2),AA_out,New.section(n).streamline(New.section(n).TE_stream_point,2));
    New.section(n).MA_out = interp1(TE(:,2),MA_out,New.section(n).streamline(New.section(n).TE_stream_point,2));
    New.section(n).TE_rad = interp1(TE(:,2),TE_rad,New.section(n).streamline(New.section(n).TE_stream_point,2))-step(n);
    
    % Re-assign streamline LE and TE points
    % Check x-value of new LE point
    if New_SS(1,3) < New.section(n).streamline(New.section(n).LE_stream_point+1,1)
        New.section(n).streamline(New.section(n).LE_stream_point,:) = [New_SS(1,3) New_SS(1,1)];
    elseif New_SS(1,3) > New.section(n).streamline(New.section(n).LE_stream_point+1,1)
        New.section(n).streamline(New.section(n).LE_stream_point,:) = New.section(n).streamline(New.section(n).LE_stream_point+1,:);
        New.section(n).streamline(New.section(n).LE_stream_point+1,:) = [New_SS(1,3) New_SS(1,1)];
        New.section(n).LE_stream_point = New.section(n).LE_stream_point+1;
    else
        New.section(n).streamline = [New.section(n).streamline(1:New.section(n).LE_stream_point,:); New.section(n).streamline(New.section(n).LE_stream_point+1:end,:)];
        New.section(n).n_streamline = New.section(n).n_streamline-1;
        New.section(n).TE_stream_point = New.section(n).TE_stream_point-1;
    end
    
    % Check x-value of new TE point
    if New_PS(1,3) > New.section(n).streamline(New.section(n).TE_stream_point-1,1)
        New.section(n).streamline(New.section(n).TE_stream_point,:) = [New_PS(1,3) New_PS(1,1)];
    elseif New_PS(1,3) < New.section(n).streamline(New.section(n).TE_stream_point-1,1)
        New.section(n).streamline(New.section(n).TE_stream_point,:) = New.section(n).streamline(New.section(n).TE_stream_point-1,:);
        New.section(n).streamline(New.section(n).TE_stream_point-1,:) = [New_PS(1,3) New_PS(1,1)];
        New.section(n).TE_stream_point = New.section(n).TE_stream_point-1;
    else
        New.section(n).streamline = [New.section(n).streamline(1:New.section(n).LE_stream_point,:); New.section(n).streamline(New.section(n).LE_stream_point+1:end,:)];
        New.section(n).n_streamline = New.section(n).n_streamline-1;
        New.section(n).TE_stream_point = New.section(n).TE_stream_point-1;
    end
    
    set(Handles.line(2),'xdata',[0 13/f]);
    drawnow;
    
    % Rename section
    New.section(n).name = ['BLADE  ' num2str(HPB.n_sections-1+n)];
    set(Handles.line,'xdata',[0 n/new_points]);
    drawnow;
end

% Move section(n) up
HPB.section(end+new_points) = HPB.section(end);
% Rename
HPB.section(end).name = ['BLADE  ' num2str(HPB.n_sections+new_points)];

% Insert new section
HPB.section(end-new_points:end-1) = New.section;
HPB.n_sections = HPB.n_sections+new_points;

% Reduce last profile to same as last in radius
HPB.section(end).profile = HPB.section(end-1).profile;
HPB.section(end).profile(:,1) = interp1(HPB.section(end).streamline(:,1),HPB.section(end).streamline(:,2),HPB.section(end).profile(:,3),'linear');
HPB.section(end).LE_rad = HPB.section(end-1).LE_rad;
HPB.section(end).TE_rad = HPB.section(end-1).TE_rad;
HPB.section(end).AA_in = HPB.section(end-1).AA_in;
HPB.section(end).AA_out = HPB.section(end-1).AA_out;
HPB.section(end).MA_in = HPB.section(end-1).MA_in;
HPB.section(end).MA_out = HPB.section(end-1).MA_out;
HPB.section(end).TE_profile_point = HPB.section(end-1).TE_profile_point;

% Re-assign streamline LE and TE points
% Check x-value of new LE point
if HPB.section(end).profile(1,3) < HPB.section(end).streamline(HPB.section(end).LE_stream_point+1,1)
    HPB.section(end).streamline(HPB.section(end).LE_stream_point,:) = [HPB.section(end).profile(1,3) HPB.section(end).profile(1,1)];
elseif HPB.section(end).profile(1,3) > HPB.section(end).streamline(HPB.section(end).LE_stream_point+1,1)
    HPB.section(end).streamline(HPB.section(end).LE_stream_point,:) = HPB.section(end).streamline(HPB.section(end).LE_stream_point+1,:);
    HPB.section(end).streamline(HPB.section(end).LE_stream_point+1,:) = [HPB.section(end).profile(1,3) HPB.section(end).profile(1,1)];
    HPB.section(end).LE_stream_point = HPB.section(end).LE_stream_point+1;
else
    HPB.section(end).streamline = [HPB.section(end).streamline(1:HPB.section(end).LE_stream_point,:); HPB.section(end).streamline(HPB.section(end).LE_stream_point+1:end,:)];
    HPB.section(end).n_streamline = HPB.section(end).n_streamline-1;
    HPB.section(end).TE_stream_point = HPB.section(end).TE_stream_point-1;
end

% Check x-value of new TE point
if HPB.section(end).profile(HPB.section(end).TE_profile_point,3) > HPB.section(end).streamline(HPB.section(end).TE_stream_point-1,1)
    HPB.section(end).streamline(HPB.section(end).TE_stream_point,:) = [HPB.section(end).profile(HPB.section(end).TE_profile_point,3) HPB.section(end).profile(HPB.section(end).TE_profile_point,1)];
elseif HPB.section(end).profile(HPB.section(end).TE_profile_point,3) < HPB.section(end).streamline(HPB.section(end).TE_stream_point-1,1)
    HPB.section(end).streamline(HPB.section(end).TE_stream_point,:) = HPB.section(end).streamline(HPB.section(end).TE_stream_point-1,:);
    HPB.section(end).streamline(HPB.section(end).TE_stream_point-1,:) = [HPB.section(end).profile(HPB.section(end).TE_profile_point,3) HPB.section(end).profile(HPB.section(end).TE_profile_point,1)];
    HPB.section(end).TE_stream_point = HPB.section(end).TE_stream_point-1;
else
    HPB.section(end).streamline = [HPB.section(end).streamline(1:HPB.section(end).LE_stream_point,:); HPB.section(end).streamline(HPB.section(end).LE_stream_point+1:end,:)];
    HPB.section(end).n_streamline = HPB.section(end).n_streamline-1;
    HPB.section(end).TE_stream_point = HPB.section(end).TE_stream_point-1;
end

% Write file
Write_Blade_File(new_filename,HPB);
warning on
close(Handles.dlgbox)