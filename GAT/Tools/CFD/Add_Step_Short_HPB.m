function Add_Step(mesh_file,boundata_file)
%
% Add_Step(mesh_file,boundata_file)
%
% A function to add the upstream step to a suitable
% plot3d mesh.  No checks are done.
% Inlet_Radius is the desired radius at the casing on
% the inlet plane.

% Read mesh file
Mesh = Read_Plot3d(mesh_file);

% Read boundata file
boundata = Read_Boundata_File(boundata_file);

% Find x-cut plane from boundata file
for i = 1:length(boundata)
    if strncmp(boundata(i).name,'MERGECA2',8);
        cutplane = boundata(i).dims(8);
        break
    end
end

% Add new block
Mesh.n_blocks = 9;
Mesh.dims(9,:) = [cutplane Mesh.dims(7,2:3)];
Mesh.block(9).x = Mesh.block(7).x(1:cutplane,:,:);
Mesh.block(9).y = Mesh.block(7).y(1:cutplane,:,:);
Mesh.block(9).z = Mesh.block(7).z(1:cutplane,:,:);

% Trim old block
Mesh.dims(7,1) = Mesh.dims(7,1)-cutplane+1;
Mesh.block(7).x = Mesh.block(7).x(cutplane:end,:,:);
Mesh.block(7).y = Mesh.block(7).y(cutplane:end,:,:);
Mesh.block(7).z = Mesh.block(7).z(cutplane:end,:,:);

% Tidy old boundata entries
% Add delete flag
for i = 1:length(boundata)
    boundata(i).delete = 0;
end

% Set-up easy block dims
tg = Mesh.dims(4,3);    % Tip gap
ip = Mesh.dims(7,1);    % I-planes
jp = Mesh.dims(7,2);    % J-planes
kp = Mesh.dims(7,3);    % K-planes
% New k-dim
kn = kp-tg+1;

% Loop through the surfaces
for i = 1:length(boundata)
    if strncmp(boundata(i).name,'MERGELOW',8) & boundata(i).block1 == 7;
        boundata(i).dims([4 8]) = boundata(i).dims([4 8])-cutplane+1;
    elseif strncmp(boundata(i).name,'MERGEUPP',8) & boundata(i).block1 == 7;
        boundata(i).dims([4 8]) = boundata(i).dims([4 8])-cutplane+1;
    elseif strncmp(boundata(i).name,'MERGECAS',8) & boundata(i).block1 == 7;
        boundata(i).dims([3 7]) = [1 1];
        boundata(i).dims([4 8]) = boundata(i).dims([4 8])-cutplane+1;
    elseif strncmp(boundata(i).name,'MERGEHUB',8) & boundata(i).block1 == 7;
        boundata(i).dims([3 7]) = [1 1];
        boundata(i).dims([4 8]) = boundata(i).dims([4 8])-cutplane+1;
    elseif strncmp(boundata(i).name,'INLET   ',8) & boundata(i).block1 == 7;
        boundata(i).name(1:5) = 'PATCH';
        boundata(i).dims([6 10]) = [kn kn];
        boundata(i).prime1 = 'M';
        boundata(i).prime2 = 'M';
    elseif strncmp(boundata(i).name,'PATCH   ',8) & boundata(i).block1 == 7;
        boundata(i).dims(1:2) = boundata(i).dims(1:2)-cutplane+1;
    elseif strncmp(boundata(i).name,'MERGEHU2',8) & boundata(i).block1 == 7;
        boundata(i).delete = 1;
    elseif strncmp(boundata(i).name,'MERGECA2',8) & boundata(i).block1 == 7;
        boundata(i).name = 'MERGECA4 ';
        boundata(i).prime1 = 'M';
        boundata(i).prime2 = 'M';
        boundata(i).norm1 = 'I';
        boundata(i).norm2 = 'I';
        boundata(i).dir1 = 'J';
        boundata(i).dir2 = 'K';
        boundata(i).dims = [1 1 1 jp kn kp 1 jp kn kp];
    end
end

% Convert to r,theta
Mesh.block(9).r = sqrt(Mesh.block(9).y.^2+Mesh.block(9).z.^2);
Mesh.block(9).t = atan2(Mesh.block(9).z,Mesh.block(9).y);

% New casing line
mn = (Mesh.block(9).r(1,1,end)-Mesh.block(9).r(end,1,kn))/(Mesh.block(9).x(1,1,end)-Mesh.block(9).x(end,1,kn));
cn = Mesh.block(9).r(1,1,end)-Mesh.block(9).x(1,1,end)*mn;

% Make s-template from cutplane
% Radial line
mr = (Mesh.block(9).r(cutplane,1,1)-Mesh.block(9).r(cutplane,1,end))/(Mesh.block(9).x(cutplane,1,1)-Mesh.block(9).x(cutplane,1,end));
cr = Mesh.block(9).r(cutplane,1,1)-Mesh.block(9).x(cutplane,1,1)*mr; 

% Intersection point
xi = (cn-cr)/(mr-mn);
ri = mn*xi+cn -0.001;
si = sqrt((xi-Mesh.block(9).x(cutplane,1,1))^2+(ri-(Mesh.block(9).x(cutplane,1,1)*mr+cr))^2);

old_s = squeeze(sqrt(((Mesh.block(9).x(cutplane,1,:)-Mesh.block(9).x(cutplane,1,1))/mr).^2+(Mesh.block(9).r(cutplane,1,:)-Mesh.block(9).r(cutplane,1,1)).^2));
new_s = old_s*si/old_s(kn);
s_frac = new_s/si;




% swap to avoid nans
cn = -cn/mn;
mn = 1/mn;

% For each i-plane, stretch in radial direction
for i = 1:(cutplane-1)
    
    % Radial line
    mr = (Mesh.block(9).x(i,1,1)-Mesh.block(9).x(i,1,end))/(Mesh.block(9).r(i,1,1)-Mesh.block(9).r(i,1,end));
    cr = Mesh.block(9).x(i,1,1)-Mesh.block(9).r(i,1,1)*mr; 
    
    % Intersection point
    alpha = 0.99* (1-i/cutplane)
    ri = (cn-cr)/(mr-mn) - 0.0005*alpha;
    
   
    r_hub = Mesh.block(9).r(i,1,1);
    new_r = (ri - r_hub)*s_frac + r_hub;
    
    % Set all of the j-planes to the new values
    for j = 1:jp
        Mesh.block(9).r(i,j,:) = new_r;
    end
    
end

% Set back to x,y,z    
Mesh.block(9).y = Mesh.block(9).r.*cos(Mesh.block(9).t);
Mesh.block(9).z = Mesh.block(9).r.*sin(Mesh.block(9).t);

% Trim top off mesh
Mesh.dims(9,3) = kn;
Mesh.block(9).x = Mesh.block(9).x(:,:,1:kn);
Mesh.block(9).y = Mesh.block(9).y(:,:,1:kn);
Mesh.block(9).z = Mesh.block(9).z(:,:,1:kn);

% Add new boundata information
boundata(end+1).name = 'INLET    ';
boundata(end).block1 = 9;
boundata(end).block2 = 9;
boundata(end).norm1 = 'I';
boundata(end).norm2 = 'I';
boundata(end).prime1 = 'P';
boundata(end).prime2 = 'P';
boundata(end).dir1 = 'J';
boundata(end).dir2 = 'K';
boundata(end).dims = [1 1 1 jp 1 kn 1 jp 1 kn];
boundata(end).delete = 0;

boundata(end+1).name = 'PATCH    ';
boundata(end).block1 = 9;
boundata(end).block2 = 9;
boundata(end).norm1 = 'I';
boundata(end).norm2 = 'I';
boundata(end).prime1 = 'P';
boundata(end).prime2 = 'P';
boundata(end).dir1 = 'J';
boundata(end).dir2 = 'K';
boundata(end).dims = [cutplane cutplane 1 jp 1 kn 1 jp 1 kn];
boundata(end).delete = 0;

boundata(end+1).name = 'MERGELOW ';
boundata(end).block1 = 9;
boundata(end).block2 = 9;
boundata(end).norm1 = 'J';
boundata(end).norm2 = 'J';
boundata(end).prime1 = 'P';
boundata(end).prime2 = 'P';
boundata(end).dir1 = 'I';
boundata(end).dir2 = 'K';
boundata(end).dims = [1 1 1 cutplane 1 kn 1 cutplane 1 kn];
boundata(end).delete = 0;

boundata(end+1).name = 'MERGEUPP ';
boundata(end).block1 = 9;
boundata(end).block2 = 9;
boundata(end).norm1 = 'J';
boundata(end).norm2 = 'J';
boundata(end).prime1 = 'M';
boundata(end).prime2 = 'M';
boundata(end).dir1 = 'I';
boundata(end).dir2 = 'K';
boundata(end).dims = [jp jp 1 cutplane 1 kn 1 cutplane 1 kn];
boundata(end).delete = 0;

boundata(end+1).name = 'MERGEHU2 ';
boundata(end).block1 = 9;
boundata(end).block2 = 9;
boundata(end).norm1 = 'K';
boundata(end).norm2 = 'K';
boundata(end).prime1 = 'P';
boundata(end).prime2 = 'P';
boundata(end).dir1 = 'I';
boundata(end).dir2 = 'J';
boundata(end).dims = [1 1 1 cutplane 1 jp 1 cutplane 1 jp];
boundata(end).delete = 0;

boundata(end+1).name = 'MERGECA2 ';
boundata(end).block1 = 9;
boundata(end).block2 = 9;
boundata(end).norm1 = 'K';
boundata(end).norm2 = 'K';
boundata(end).prime1 = 'M';
boundata(end).prime2 = 'M';
boundata(end).dir1 = 'I';
boundata(end).dir2 = 'J';
boundata(end).dims = [kn kn 1 cutplane 1 jp 1 cutplane 1 jp];
boundata(end).delete = 0;

% Get rid of unneeded lines
boundata_new = boundata(1);
for i = 2:length(boundata)
    if boundata(i).delete == 0
        boundata_new(end+1) = boundata(i);
    end
end

% Save the files
Write_Plot3D('mesh.plot3d',Mesh);
Write_Boundata_File('p3d.boundata',boundata_new);