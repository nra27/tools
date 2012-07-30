function Modify_Tip_Gap(filename,offset,step);
%
% Modify_Tip_Gap(filename,offset,step)
% A function to complement Modify_Profile and Padram
% to add a profile to the blade tip.
% This reads in the plot3d file and modifies the tip-gap
% blocks with the profile given in offset and step.

% Open dialog box
Handles.dlgbox = figure('units','points','position',[40 40 200 70],'windowstyle','normal',...
        'name','Modify Tip Gap','buttondownfcn',[],'visible','on','resize','off',...
        'menubar','none','colormap',[],'numbertitle','off','doublebuffer','on','Tag','nozoom');
Handles.axes = axes('position',[0.1 0.35 0.8 0.2],'box','on','xtick',[],'ytick',[],'xlim',[0 1],'ylim',[0 1]);
Handles.line = line([-1 -1],[0.5 0.5]);
set(Handles.line,'color','b','linewidth',14);
set(Handles.line,'xdata',[-1 2]);
Handles.title = title('Reading Grid File');
drawnow

% Read file
Mesh = Read_Plot3D(filename);

% Set number of points in up-sampled blade profile
up_sample = 30000;

% Establish k-profile
k_profile = sqrt(Mesh.block(4).y(1,1,:).^2+Mesh.block(4).z(1,1,:).^2);  % Radial profile of points in tip-gap

% Perturb all available k-planes in the tip-gap
for k = 1:(length(k_profile)-1)
    offset(k,:) = offset(1,:)*(k_profile(end)-k_profile(k))/(k_profile(end)-k_profile(1));
end

set(Handles.title,'string','Adding Tip Profile');
set(Handles.line,'xdata',[0 0]);
drawnow

% Loop on k-planes
for k = 1:(length(k_profile)-1) 
    % Setup boundary profile
    boundary_x = [Mesh.block(5).x(1:end,end,k); Mesh.block(4).x(2:end,end,k); Mesh.block(6).x(2:end,end,k); flipud(Mesh.block(4).x(1:end-1,1,k))];
    boundary_y = [Mesh.block(5).y(1:end,end,k); Mesh.block(4).y(2:end,end,k); Mesh.block(6).y(2:end,end,k); flipud(Mesh.block(4).y(1:end-1,1,k))];
    boundary_z = [Mesh.block(5).z(1:end,end,k); Mesh.block(4).z(2:end,end,k); Mesh.block(6).z(2:end,end,k); flipud(Mesh.block(4).z(1:end-1,1,k))];
    
    % Work out streamline distance
    boundary_b = [0; sqrt(diff(boundary_x).^2+diff(boundary_y).^2+diff(boundary_z).^2)];
    boundary_b = cumsum(boundary_b);
    
    % Up sample
    boundary_B = linspace(boundary_b(1),boundary_b(end),up_sample);
    boundary_X = interp1(boundary_b,boundary_x,boundary_B,'spline');
    boundary_Y = interp1(boundary_b,boundary_y,boundary_B,'spline');
    boundary_Z = interp1(boundary_b,boundary_z,boundary_B,'spline');
    
    % Set to x,r,s
    boundary_R = sqrt(boundary_Y.^2+boundary_Z.^2);
    boundary_T = atan2(boundary_Z,boundary_Y);
    boundary_S = boundary_R.*boundary_T;
    
    % For the main tip-gap block
    block = 4;
    % Loop through all of the points in the chosen k-plane
    for i = 1:Mesh.dims(block,1)
        for j = 2:(Mesh.dims(block,2)-1)
            % Set point to x,r,s
            x = Mesh.block(block).x(i,j,k);
            r = sqrt(Mesh.block(block).y(i,j,k)^2+Mesh.block(block).z(i,j,k)^2);
            t = atan2(Mesh.block(block).z(i,j,k),Mesh.block(block).y(i,j,k));
            s = r.*t;
            
            % Calculate distance
            d = min(sqrt((boundary_X-x).^2+(boundary_R-r).^2+(boundary_S-s).^2));
            
            % This is the actual step, so interpolate to find the required offset
            % But first check to see if we are past the edge of the corner
            if d > max(step)
                delta = max(offset(k,:));
            else
                delta = interp1(step,offset(k,:),d,'spline');
            end
            
            % Modify coordinates and reconvert
            r = r+delta;
            Mesh.block(block).y(i,j,k) = r*cos(t);
            Mesh.block(block).z(i,j,k) = r*sin(t);
        end
    end
                     
    % For the two radial blocks
    for block = 5:6
        for i = 1:Mesh.dims(block,1)
            for j = 1:(Mesh.dims(block,2)-1)
                % Set point to x,r,s
                x = Mesh.block(block).x(i,j,k);
                r = sqrt(Mesh.block(block).y(i,j,k)^2+Mesh.block(block).z(i,j,k)^2);
                t = atan2(Mesh.block(block).z(i,j,k),Mesh.block(block).y(i,j,k));
                s = r.*t;
                
                % Calculate distance
                d = min(sqrt((boundary_X-x).^2+(boundary_R-r).^2+(boundary_S-s).^2));
                
                % This is the actual step, so interpolate to find the required offset
                % But first check to see if we are past the edge of the corner
                if d > max(step)
                    delta = max(offset(k,:));
                else
                    delta = interp1(step,offset(k,:),d,'spline');
                end
                
                % Modify coordinates and reconvert
                r = r+delta;
                Mesh.block(block).y(i,j,k) = r*cos(t);
                Mesh.block(block).z(i,j,k) = r*sin(t);
            end
        end
    end
    set(Handles.line,'xdata',[0 k/(length(k_profile)-1)]);
    drawnow
end

Handles.title = title('Writing Grid File');
drawnow

% Save file
Write_Plot3D(filename,Mesh);

close(Handles.dlgbox);