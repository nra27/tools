function [new_mesh,new_boundata] = Resample_K_Planes(mesh,boundata,k_start,k_blade,varargin);

%function [new_mesh,new_boundata] = Resample_K_Planes(mesh,boundata,k_start,k_blade,[k_tip,radius]);
%
% A function to resample the k-plane distribution in a
% plot3d mesh file.  Linear variation from hub-to-casing
% is assummed. Boundata file is adjusted
% k_blade is a percentage new distribution over the blade.
% k_tip is a percentage new distribution in the tip gap (if needed)
% k_start is the k_plane to use as the lower template (1 = hub)
% radius (if defined) will add a corner radius to the tip

% Convert to r-theta-s
for i_block = 1:mesh.n_blocks
    mesh.block(i_block).r = sqrt(mesh.block(i_block).y.^2+mesh.block(i_block).z.^2);
    mesh.block(i_block).t = atan2(mesh.block(i_block).z,mesh.block(i_block).y);
    mesh.block(i_block).s = mesh.block(i_block).r.*mesh.block(i_block).t;
end

% Check periodic angle
per_angle = mesh.block(end-1).t(1,1,1)-mesh.block(end-1).t(1,end,1);
disp(['Found periodic angle of ' num2str(abs(per_angle*180/pi)) ' degrees']);

% Characterise blocks
if mesh.n_blocks == 5
    type = 'no tip';
    disp('This mesh has no tip-gap');
elseif mesh.n_blocks == 6
    type = 'plane tip';
    disp('This mesh has a square tip-gap');
elseif mesh.n_blocks == 8
    type = 'radial tip';
    disp('This mesh has a radial tip-gap mesh');
else
    error('Don''t know what this mesh is!');
end

if k_start > 1
    k_blade(1:k_start-1) = 0;
    k_blade = k_blade-k_blade(k_start);
    k_blade = k_blade/k_blade(end);
end

% For each mesh type
switch type
case 'radial tip'
    k_tip = varargin{1};
    i_tip = mesh.dims(1,3)-mesh.dims(4,3)+1;
    new_mesh.n_blocks = mesh.n_blocks;
    
    % For each full passage block
    for i_block = [1 2 3 7 8]
        disp(['Distributing k-planes in block' num2str(i_block)]);
        new_mesh.dims(i_block,:) = [mesh.dims(i_block,1:2) (length(k_blade)+length(k_tip)-1)];
        
        for k_plane = 1:(k_start-1)
            new_mesh.block(i_block).x(:,:,k_plane) = mesh.block(i_block).x(:,:,k_plane);
            new_mesh.block(i_block).y(:,:,k_plane) = mesh.block(i_block).y(:,:,k_plane);
            new_mesh.block(i_block).z(:,:,k_plane) = mesh.block(i_block).z(:,:,k_plane);
            new_mesh.block(i_block).r(:,:,k_plane) = mesh.block(i_block).r(:,:,k_plane);
            new_mesh.block(i_block).t(:,:,k_plane) = mesh.block(i_block).t(:,:,k_plane);
            new_mesh.block(i_block).s(:,:,k_plane) = mesh.block(i_block).s(:,:,k_plane);
        end
        for k_plane = k_start:length(k_blade)
            new_mesh.block(i_block).x(:,:,k_plane) = mesh.block(i_block).x(:,:,k_start) + k_blade(k_plane)*(mesh.block(i_block).x(:,:,i_tip)-mesh.block(i_block).x(:,:,k_start));
            new_mesh.block(i_block).y(:,:,k_plane) = mesh.block(i_block).y(:,:,k_start) + k_blade(k_plane)*(mesh.block(i_block).y(:,:,i_tip)-mesh.block(i_block).y(:,:,k_start));
            new_mesh.block(i_block).z(:,:,k_plane) = mesh.block(i_block).z(:,:,k_start) + k_blade(k_plane)*(mesh.block(i_block).z(:,:,i_tip)-mesh.block(i_block).z(:,:,k_start));
            new_mesh.block(i_block).r(:,:,k_plane) = mesh.block(i_block).r(:,:,k_start) + k_blade(k_plane)*(mesh.block(i_block).r(:,:,i_tip)-mesh.block(i_block).r(:,:,k_start));
            new_mesh.block(i_block).t(:,:,k_plane) = mesh.block(i_block).t(:,:,k_start) + k_blade(k_plane)*(mesh.block(i_block).t(:,:,i_tip)-mesh.block(i_block).t(:,:,k_start));
            new_mesh.block(i_block).s(:,:,k_plane) = mesh.block(i_block).s(:,:,k_start) + k_blade(k_plane)*(mesh.block(i_block).s(:,:,i_tip)-mesh.block(i_block).s(:,:,k_start));
        end
        for k_plane = 2:length(k_tip)
            new_mesh.block(i_block).x(:,:,end+1) = mesh.block(i_block).x(:,:,i_tip) + k_tip(k_plane)*(mesh.block(i_block).x(:,:,end)-mesh.block(i_block).x(:,:,i_tip));
            new_mesh.block(i_block).y(:,:,end+1) = mesh.block(i_block).y(:,:,i_tip) + k_tip(k_plane)*(mesh.block(i_block).y(:,:,end)-mesh.block(i_block).y(:,:,i_tip));
            new_mesh.block(i_block).z(:,:,end+1) = mesh.block(i_block).z(:,:,i_tip) + k_tip(k_plane)*(mesh.block(i_block).z(:,:,end)-mesh.block(i_block).z(:,:,i_tip));
            new_mesh.block(i_block).r(:,:,end+1) = mesh.block(i_block).r(:,:,i_tip) + k_tip(k_plane)*(mesh.block(i_block).r(:,:,end)-mesh.block(i_block).r(:,:,i_tip));
            new_mesh.block(i_block).t(:,:,end+1) = mesh.block(i_block).t(:,:,i_tip) + k_tip(k_plane)*(mesh.block(i_block).t(:,:,end)-mesh.block(i_block).t(:,:,i_tip));
            new_mesh.block(i_block).s(:,:,end+1) = mesh.block(i_block).s(:,:,i_tip) + k_tip(k_plane)*(mesh.block(i_block).s(:,:,end)-mesh.block(i_block).s(:,:,i_tip));
        end
    end
    
    for i_block = 4:6
        disp(['Distributing k-planes in block' num2str(i_block)]);
        new_mesh.dims(i_block,:) = [mesh.dims(i_block,1:2) length(k_tip)];
        for k_plane = 1:length(k_tip)
            new_mesh.block(i_block).x(:,:,k_plane) = mesh.block(i_block).x(:,:,1) + k_tip(k_plane)*(mesh.block(i_block).x(:,:,end)-mesh.block(i_block).x(:,:,1));
            new_mesh.block(i_block).y(:,:,k_plane) = mesh.block(i_block).y(:,:,1) + k_tip(k_plane)*(mesh.block(i_block).y(:,:,end)-mesh.block(i_block).y(:,:,1));
            new_mesh.block(i_block).z(:,:,k_plane) = mesh.block(i_block).z(:,:,1) + k_tip(k_plane)*(mesh.block(i_block).z(:,:,end)-mesh.block(i_block).z(:,:,1));
            new_mesh.block(i_block).r(:,:,k_plane) = mesh.block(i_block).r(:,:,1) + k_tip(k_plane)*(mesh.block(i_block).r(:,:,end)-mesh.block(i_block).r(:,:,1));
            new_mesh.block(i_block).t(:,:,k_plane) = mesh.block(i_block).t(:,:,1) + k_tip(k_plane)*(mesh.block(i_block).t(:,:,end)-mesh.block(i_block).t(:,:,1));
            new_mesh.block(i_block).s(:,:,k_plane) = mesh.block(i_block).s(:,:,1) + k_tip(k_plane)*(mesh.block(i_block).s(:,:,end)-mesh.block(i_block).s(:,:,1));
        end
    end

    % Modify boundata file
    new_boundata = boundata;
    for line = 1:length(boundata)
        if boundata(line).block1 == 1 & strcmp(boundata(line).norm1,'I')
            new_boundata(line).dims([6 10]) = new_mesh.dims(1,3);
        elseif boundata(line).block1 == 1 & strcmp(boundata(line).norm1,'J')
            new_boundata(line).dims([6 10]) = new_mesh.dims(1,3);
        elseif boundata(line).block1 == 1 & strcmp(boundata(line).norm1,'K') & boundata(line).dims(1) > 1
            new_boundata(line).dims([1 2]) = new_mesh.dims(1,3);
        elseif boundata(line).block1 == 3 & strcmp(boundata(line).norm1,'I')
            new_boundata(line).dims([6 10]) = new_mesh.dims(1,3);
        elseif boundata(line).block1 == 3 & strcmp(boundata(line).norm1,'J')
            new_boundata(line).dims([6 10]) = new_mesh.dims(1,3);
        elseif boundata(line).block1 == 3 & strcmp(boundata(line).norm1,'K') & boundata(line).dims(1) > 1
            new_boundata(line).dims([1 2]) = new_mesh.dims(1,3);
        elseif boundata(line).block1 == 7 & strcmp(boundata(line).norm1,'I')
            new_boundata(line).dims([6 10]) = new_mesh.dims(1,3);
        elseif boundata(line).block1 == 7 & strcmp(boundata(line).norm1,'J')
            new_boundata(line).dims([6 10]) = new_mesh.dims(1,3);
        elseif boundata(line).block1 == 7 & strcmp(boundata(line).norm1,'K') & boundata(line).dims(1) > 1
            new_boundata(line).dims([1 2]) = new_mesh.dims(1,3);
        elseif boundata(line).block1 == 8 & strcmp(boundata(line).norm1,'I')
            new_boundata(line).dims([6 10]) = new_mesh.dims(1,3);
        elseif boundata(line).block1 == 8 & strcmp(boundata(line).norm1,'J')
            new_boundata(line).dims([6 10]) = new_mesh.dims(1,3);
        elseif boundata(line).block1 == 8 & strcmp(boundata(line).norm1,'K') & boundata(line).dims(1) > 1
            new_boundata(line).dims([1 2]) = new_mesh.dims(1,3);
        elseif boundata(line).block1 == 4 & strcmp(boundata(line).norm1,'I')
            new_boundata(line).dims([6 10]) = new_mesh.dims(4,3);
        elseif boundata(line).block1 == 4 & strcmp(boundata(line).norm1,'J')
            new_boundata(line).dims([6 10]) = new_mesh.dims(4,3);
        elseif boundata(line).block1 == 4 & strcmp(boundata(line).norm1,'K') & boundata(line).dims(1) > 1
            new_boundata(line).dims([1 2]) = new_mesh.dims(4,3);
        elseif boundata(line).block1 == 5 & strcmp(boundata(line).norm1,'I')
            new_boundata(line).dims([6 10]) = new_mesh.dims(4,3);
        elseif boundata(line).block1 == 5 & strcmp(boundata(line).norm1,'J')
            new_boundata(line).dims([6 10]) = new_mesh.dims(4,3);
        elseif boundata(line).block1 == 5 & strcmp(boundata(line).norm1,'K') & boundata(line).dims(1) > 1
            new_boundata(line).dims([1 2]) = new_mesh.dims(4,3);
        elseif boundata(line).block1 == 6 & strcmp(boundata(line).norm1,'I')
            new_boundata(line).dims([6 10]) = new_mesh.dims(4,3);
        elseif boundata(line).block1 == 6 & strcmp(boundata(line).norm1,'J')
            new_boundata(line).dims([6 10]) = new_mesh.dims(4,3);
        elseif boundata(line).block1 == 6 & strcmp(boundata(line).norm1,'K') & boundata(line).dims(1) > 1
            new_boundata(line).dims([1 2]) = new_mesh.dims(4,3);
        elseif boundata(line).block1 == 2 & strcmp(boundata(line).norm1,'K') & boundata(line).dims(1) > 1
            new_boundata(line).dims([1 2]) = new_mesh.dims(1,3);
        elseif boundata(line).block1 == 2 & strcmp(boundata(line).norm1,'I')
            new_boundata(line).dims([6 10]) = new_mesh.dims(1,3);
        elseif boundata(line).block1 == 2 & strcmp(boundata(line).norm1,'J') & boundata(line).dims(6) == mesh.dims(1,3)-mesh.dims(4,3)+1
            new_boundata(line).dims([6 10]) = new_mesh.dims(1,3)-new_mesh.dims(4,3)+1;
        elseif boundata(line).block1 == 2 & strcmp(boundata(line).norm1,'J') & boundata(line).dims(5) == mesh.dims(1,3)-mesh.dims(4,3)+1
            new_boundata(line).dims([5 9]) = new_mesh.dims(1,3)-new_mesh.dims(4,3)+1;
            new_boundata(line).dims([6 10]) = new_mesh.dims(1,3);
        elseif boundata(line).block1 == 2 & strcmp(boundata(line).norm1,'J') & boundata(line).dims(1) > 1
            new_boundata(line).dims([6 10]) = new_mesh.dims(1,3);
        end
    end
    
    % Check if we are to add corner radius
    if length(varargin) == 2;
        radius = varargin{2};
        k_tip = new_mesh.dims(1,3)-new_mesh.dims(4,3)+1;
        
        % Build offset-step pair
        theta = [0:3:45]/180*pi;
        offset = radius/sqrt(2)-radius*sin(theta);
        step = radius-radius*cos(theta);
        
        % For the O-mesh
        old_block = new_mesh.block(2);
        disp('Purturbing j-planes in O-mesh');
        for k_plane = 1:new_mesh.dims(2,3);
            for i_plane = 1:new_mesh.dims(2,1);
                delta_r = old_block.r(i_plane,1,k_tip) - old_block.r(i_plane,1,k_plane);
                if delta_r < 0
                    delta_r = 0;
                end            
                
                if delta_r < radius/sqrt(2);
                    delta_b = interp1(offset,step,delta_r,'spline');
                    b = [0 cumsum(sqrt(diff(old_block.x(i_plane,end:-1:1,k_plane)).^2+diff(old_block.r(i_plane,end:-1:1,k_plane)).^2+diff(old_block.s(i_plane,end:-1:1,k_plane)).^2))];
                    b_dist = b/b(end);
                    x_m = old_block.x(i_plane,1,k_plane)-old_block.x(i_plane,end,k_plane);
                    r_m = old_block.r(i_plane,1,k_plane)-old_block.r(i_plane,end,k_plane);
                    s_m = old_block.s(i_plane,1,k_plane)-old_block.s(i_plane,end,k_plane);
                    
                    b_new = b_dist*(b(end)+delta_b)/b(end);
                    new_mesh.block(2).x(i_plane,end:-1:1,k_plane) = b_new*x_m+old_block.x(i_plane,end,k_plane);
                    new_mesh.block(2).r(i_plane,end:-1:1,k_plane) = b_new*r_m+old_block.r(i_plane,end,k_plane);
                    new_mesh.block(2).s(i_plane,end:-1:1,k_plane) = b_new*s_m+old_block.s(i_plane,end,k_plane);
                end
            end
        end
        
        % Convert to x,y,z
        new_mesh.block(2).t = new_mesh.block(2).s./new_mesh.block(2).r;
        new_mesh.block(2).y = new_mesh.block(2).r.*cos(new_mesh.block(2).t);
        new_mesh.block(2).z = new_mesh.block(2).r.*sin(new_mesh.block(2).t);
        
        
        % Now for the tip gap meshes
        % For each k-plane
        j_mid = ceil(new_mesh.dims(4,2)/2);
        k_blade = length(k_blade)-1;
        
        % Find the corner points
        for i_plane = 1:mesh.dims(2,1);
            if mesh.block(2).x(i_plane,1,i_tip) == mesh.block(4).x(1,end,1) & mesh.block(2).y(i_plane,1,i_tip) == mesh.block(4).y(1,end,1) & mesh.block(2).z(i_plane,1,i_tip) == mesh.block(4).z(1,end,1)
                le_1 = 1:i_plane;
            elseif mesh.block(2).x(i_plane,1,i_tip) == mesh.block(4).x(end,end,1) & mesh.block(2).y(i_plane,1,i_tip) == mesh.block(4).y(end,end,1) & mesh.block(2).z(i_plane,1,i_tip) == mesh.block(4).z(end,end,1)
                i_ss = le_1(end):i_plane;
            elseif mesh.block(2).x(i_plane,1,i_tip) == mesh.block(4).x(end,1,1) & mesh.block(2).y(i_plane,1,i_tip) == mesh.block(4).y(end,1,1) & mesh.block(2).z(i_plane,1,i_tip) == mesh.block(4).z(end,1,1)
                i_te = i_ss(end):i_plane;
            elseif mesh.block(2).x(i_plane,1,i_tip) == mesh.block(4).x(1,1,1) & mesh.block(2).y(i_plane,1,i_tip) == mesh.block(4).y(1,1,1) & mesh.block(2).z(i_plane,1,i_tip) == mesh.block(4).z(1,1,1)
                i_ps = i_te(end):i_plane;
                le_2 = i_plane:mesh.dims(2,1);
            end
        end
        i_le = [le_2(1:end-1) le_1];
        
        % First of all do the main block
        old_block = new_mesh.block(4);
        disp('Purturbing j-planes in main tip mesh');
        for k_plane = 1:new_mesh.dims(4,3)
            new_mesh.block(4).x(end:-1:1,1,k_plane) = new_mesh.block(2).x(i_ps,1,(k_plane+k_blade));
            new_mesh.block(4).r(end:-1:1,1,k_plane) = new_mesh.block(2).r(i_ps,1,(k_plane+k_blade));
            new_mesh.block(4).s(end:-1:1,1,k_plane) = new_mesh.block(2).s(i_ps,1,(k_plane+k_blade));
            
            new_mesh.block(4).x(:,end,k_plane) = new_mesh.block(2).x(i_ss,1,(k_plane+k_blade));
            new_mesh.block(4).r(:,end,k_plane) = new_mesh.block(2).r(i_ss,1,(k_plane+k_blade));
            new_mesh.block(4).s(:,end,k_plane) = new_mesh.block(2).s(i_ss,1,(k_plane+k_blade));
            
            for i_plane = 1:new_mesh.dims(4,1)
                b_ps = [0 cumsum(sqrt((diff(old_block.x(i_plane,j_mid:-1:1,k_plane)).^2)+(diff(old_block.r(i_plane,j_mid:-1:1,k_plane)).^2)+(diff(old_block.s(i_plane,j_mid:-1:1,k_plane)).^2)))];
                b_ss = [0 cumsum(sqrt((diff(old_block.x(i_plane,j_mid:end,k_plane)).^2)+(diff(old_block.r(i_plane,j_mid:end,k_plane)).^2)+(diff(old_block.s(i_plane,j_mid:end,k_plane)).^2)))];
                b_ps_dist = b_ps/b_ps(end);
                %b_ps_dist = linspace(0,1,length(b_ps));
                b_ss_dist = b_ss/b_ss(end);
                %b_ss_dist = linspace(0,1,length(b_ss));
                
                new_mesh.block(4).x(i_plane,j_mid:-1:1,k_plane) = new_mesh.block(4).x(i_plane,j_mid,k_plane)+b_ps_dist*(new_mesh.block(4).x(i_plane,1,k_plane)-new_mesh.block(4).x(i_plane,j_mid,k_plane));
                new_mesh.block(4).x(i_plane,j_mid:end,k_plane) = new_mesh.block(4).x(i_plane,j_mid,k_plane)+b_ss_dist*(new_mesh.block(4).x(i_plane,end,k_plane)-new_mesh.block(4).x(i_plane,j_mid,k_plane));
                new_mesh.block(4).r(i_plane,j_mid:-1:1,k_plane) = new_mesh.block(4).r(i_plane,j_mid,k_plane)+b_ps_dist*(new_mesh.block(4).r(i_plane,1,k_plane)-new_mesh.block(4).r(i_plane,j_mid,k_plane));
                new_mesh.block(4).r(i_plane,j_mid:end,k_plane) = new_mesh.block(4).r(i_plane,j_mid,k_plane)+b_ss_dist*(new_mesh.block(4).r(i_plane,end,k_plane)-new_mesh.block(4).r(i_plane,j_mid,k_plane));
                new_mesh.block(4).s(i_plane,j_mid:-1:1,k_plane) = new_mesh.block(4).s(i_plane,j_mid,k_plane)+b_ps_dist*(new_mesh.block(4).s(i_plane,1,k_plane)-new_mesh.block(4).s(i_plane,j_mid,k_plane));
                new_mesh.block(4).s(i_plane,j_mid:end,k_plane) = new_mesh.block(4).s(i_plane,j_mid,k_plane)+b_ss_dist*(new_mesh.block(4).s(i_plane,end,k_plane)-new_mesh.block(4).s(i_plane,j_mid,k_plane));
            end    
        end
       
        % Convert to x,y,z
        new_mesh.block(4).t = new_mesh.block(4).s./new_mesh.block(4).r;
        new_mesh.block(4).y = new_mesh.block(4).r.*cos(new_mesh.block(4).t);
        new_mesh.block(4).z = new_mesh.block(4).r.*sin(new_mesh.block(4).t);
        
        % Then do the le mesh
        old_block = new_mesh.block(5);
        disp('Purturbing j-planes in main le mesh');
        % For each k-plane
        for k_plane = 1:new_mesh.dims(5,3)
            new_mesh.block(5).x(:,end,k_plane) = new_mesh.block(2).x(i_le,1,(k_plane+k_blade));
            new_mesh.block(5).r(:,end,k_plane) = new_mesh.block(2).r(i_le,1,(k_plane+k_blade));
            new_mesh.block(5).s(:,end,k_plane) = new_mesh.block(2).s(i_le,1,(k_plane+k_blade));
            
            new_mesh.block(5).x(:,1,k_plane) = new_mesh.block(4).x(1,j_mid,k_plane);
            new_mesh.block(5).r(:,1,k_plane) = new_mesh.block(4).r(1,j_mid,k_plane);
            new_mesh.block(5).s(:,1,k_plane) = new_mesh.block(4).s(1,j_mid,k_plane);
            
            new_mesh.block(5).x(1,end:-1:1,k_plane) = new_mesh.block(4).x(1,1:j_mid,k_plane);
            new_mesh.block(5).r(1,end:-1:1,k_plane) = new_mesh.block(4).r(1,1:j_mid,k_plane);
            new_mesh.block(5).s(1,end:-1:1,k_plane) = new_mesh.block(4).s(1,1:j_mid,k_plane);
            
            new_mesh.block(5).x(end,:,k_plane) = new_mesh.block(4).x(1,j_mid:end,k_plane);
            new_mesh.block(5).r(end,:,k_plane) = new_mesh.block(4).r(1,j_mid:end,k_plane);
            new_mesh.block(5).s(end,:,k_plane) = new_mesh.block(4).s(1,j_mid:end,k_plane);
            
            for i_plane = 2:(new_mesh.dims(5,1)-1)
                b = [0 cumsum(sqrt(diff(old_block.x(i_plane,:,k_plane)).^2+diff(old_block.r(i_plane,:,k_plane)).^2+diff(old_block.s(i_plane,:,k_plane)).^2))];
                b_dist = b/b(end);
                %b_dist = linspace(0,1,length(b));
                
                new_mesh.block(5).x(i_plane,:,k_plane) = new_mesh.block(5).x(i_plane,1,k_plane)+b_dist*(new_mesh.block(5).x(i_plane,end,k_plane)-new_mesh.block(5).x(i_plane,1,k_plane));
                new_mesh.block(5).r(i_plane,:,k_plane) = new_mesh.block(5).r(i_plane,1,k_plane)+b_dist*(new_mesh.block(5).r(i_plane,end,k_plane)-new_mesh.block(5).r(i_plane,1,k_plane));
                new_mesh.block(5).s(i_plane,:,k_plane) = new_mesh.block(5).s(i_plane,1,k_plane)+b_dist*(new_mesh.block(5).s(i_plane,end,k_plane)-new_mesh.block(5).s(i_plane,1,k_plane));
            end
        end
        
        % Convert to x,y,z
        new_mesh.block(5).t = new_mesh.block(5).s./new_mesh.block(5).r;
        new_mesh.block(5).y = new_mesh.block(5).r.*cos(new_mesh.block(5).t);
        new_mesh.block(5).z = new_mesh.block(5).r.*sin(new_mesh.block(5).t);
        
        % And lastly the te mesh
        old_block = new_mesh.block(6);
        disp('Purturbing j-planes in te tip mesh');
        % For each k-plane
        for k_plane = 1:new_mesh.dims(6,3)
            new_mesh.block(6).x(:,end,k_plane) = new_mesh.block(2).x(i_te,1,(k_plane+k_blade));
            new_mesh.block(6).r(:,end,k_plane) = new_mesh.block(2).r(i_te,1,(k_plane+k_blade));
            new_mesh.block(6).s(:,end,k_plane) = new_mesh.block(2).s(i_te,1,(k_plane+k_blade));
            
            new_mesh.block(6).x(:,1,k_plane) = new_mesh.block(4).x(end,j_mid,k_plane);
            new_mesh.block(6).r(:,1,k_plane) = new_mesh.block(4).r(end,j_mid,k_plane);
            new_mesh.block(6).s(:,1,k_plane) = new_mesh.block(4).s(end,j_mid,k_plane);
            
            new_mesh.block(6).x(1,:,k_plane) = new_mesh.block(4).x(end,j_mid:end,k_plane);
            new_mesh.block(6).r(1,:,k_plane) = new_mesh.block(4).r(end,j_mid:end,k_plane);
            new_mesh.block(6).s(1,:,k_plane) = new_mesh.block(4).s(end,j_mid:end,k_plane);
            
            new_mesh.block(6).x(end,end:-1:1,k_plane) = new_mesh.block(4).x(end,1:j_mid,k_plane);
            new_mesh.block(6).r(end,end:-1:1,k_plane) = new_mesh.block(4).r(end,1:j_mid,k_plane);
            new_mesh.block(6).s(end,end:-1:1,k_plane) = new_mesh.block(4).s(end,1:j_mid,k_plane);
            
            for i_plane = 2:(new_mesh.dims(6,1)-1)
                b = [0 cumsum(sqrt(diff(old_block.x(i_plane,:,k_plane)).^2+diff(old_block.r(i_plane,:,k_plane)).^2+diff(old_block.s(i_plane,:,k_plane)).^2))];
                b_dist = b/b(end);
                %b_dist = linspace(0,1,length(b));
                
                new_mesh.block(6).x(i_plane,:,k_plane) = new_mesh.block(6).x(i_plane,1,k_plane)+b_dist*(new_mesh.block(6).x(i_plane,end,k_plane)-new_mesh.block(6).x(i_plane,1,k_plane));
                new_mesh.block(6).r(i_plane,:,k_plane) = new_mesh.block(6).r(i_plane,1,k_plane)+b_dist*(new_mesh.block(6).r(i_plane,end,k_plane)-new_mesh.block(6).r(i_plane,1,k_plane));
                new_mesh.block(6).s(i_plane,:,k_plane) = new_mesh.block(6).s(i_plane,1,k_plane)+b_dist*(new_mesh.block(6).s(i_plane,end,k_plane)-new_mesh.block(6).s(i_plane,1,k_plane));
            end
        end
        
        % Convert to x,y,z
        new_mesh.block(6).t = new_mesh.block(6).s./new_mesh.block(6).r;
        new_mesh.block(6).y = new_mesh.block(6).r.*cos(new_mesh.block(6).t);
        new_mesh.block(6).z = new_mesh.block(6).r.*sin(new_mesh.block(6).t);
        
        
        % Now put the radius on the blade tip
        % Set number of points in up-sampled blade profile
        up_sample = 30000;
        
        % Establish k-profile
        k_profile = squeeze(new_mesh.block(4).r(1,j_mid,:));  % Radial profile of points in tip-gap
        
        % Build offset-step pair
        theta = [45:3:90]/180*pi;
        offset = radius*sin(theta)-radius/sqrt(2);
        step = -(radius*cos(theta)-radius/sqrt(2));
        
        
        % Perturb all available k-planes in the tip-gap
        for k = 2:(length(k_profile)-1)
            offset(k,:) = offset(1,:)*(k_profile(end)-k_profile(k))/(k_profile(end)-k_profile(1));
        end
        
        disp('Purturbing k-planes in tip gap mesh');
        
        % Loop on k-planes
        for k = 1:(length(k_profile)-1) 
            disp([num2str(round(k/(new_mesh.dims(4,3)-1)*100)) '% done'])
            % Setup boundary profile
            boundary_x = [new_mesh.block(5).x(1:end,end,k); new_mesh.block(4).x(2:end,end,k); new_mesh.block(6).x(2:end,end,k); flipud(new_mesh.block(4).x(1:end-1,1,k))];
            boundary_r = [new_mesh.block(5).r(1:end,end,k); new_mesh.block(4).r(2:end,end,k); new_mesh.block(6).r(2:end,end,k); flipud(new_mesh.block(4).r(1:end-1,1,k))];
            boundary_s = [new_mesh.block(5).s(1:end,end,k); new_mesh.block(4).s(2:end,end,k); new_mesh.block(6).s(2:end,end,k); flipud(new_mesh.block(4).s(1:end-1,1,k))];
            
            % Work out streamline distance
            boundary_b = [0; sqrt(diff(boundary_x).^2+diff(boundary_r).^2+diff(boundary_s).^2)];
            boundary_b = cumsum(boundary_b);
            
            % Up sample
            boundary_B = linspace(boundary_b(1),boundary_b(end),up_sample);
            boundary_X = interp1(boundary_b,boundary_x,boundary_B,'spline');
            boundary_R = interp1(boundary_b,boundary_r,boundary_B,'spline');
            boundary_S = interp1(boundary_b,boundary_s,boundary_B,'spline');
            
            % For the main tip-gap block
            block = 4;
            % Loop through all of the points in the chosen k-plane
            for i = 1:new_mesh.dims(block,1)
                for j = 2:(new_mesh.dims(block,2)-1)
                    % Set point to x,r,s
                    x = new_mesh.block(block).x(i,j,k);
                    r = sqrt(new_mesh.block(block).y(i,j,k)^2+new_mesh.block(block).z(i,j,k)^2);
                    t = atan2(new_mesh.block(block).z(i,j,k),new_mesh.block(block).y(i,j,k));
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
                    
                    % Modify coordinates
                    new_mesh.block(block).r(i,j,k) = r+delta;
                end
            end
            
            % For the two radial blocks
            for block = 5:6
                for i = 1:new_mesh.dims(block,1)
                    for j = 1:(new_mesh.dims(block,2)-1)
                        % Set point to x,r,s
                        x = new_mesh.block(block).x(i,j,k);
                        r = sqrt(new_mesh.block(block).y(i,j,k)^2+new_mesh.block(block).z(i,j,k)^2);
                        t = atan2(new_mesh.block(block).z(i,j,k),new_mesh.block(block).y(i,j,k));
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
                        
                        % Modify coordinates
                        new_mesh.block(block).r(i,j,k) = r+delta;
                    end
                end
            end
        end
        % Reconvert to x y z
        for block = 4:6
            new_mesh.block(block).t = new_mesh.block(block).s./new_mesh.block(block).r;
            new_mesh.block(block).y = new_mesh.block(block).r.*cos(new_mesh.block(block).t);
            new_mesh.block(block).z = new_mesh.block(block).r.*sin(new_mesh.block(block).t);
        end
    end
end