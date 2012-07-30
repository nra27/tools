function [new_mesh,new_boundata] = Create_Squeeler(mesh,boundata,width,depth,layers);
%
% [new_mesh,new_boundata] = Create_Squeeler(mesh,boundata,width,depth,layers)
%
% Create_Squeeler, a function to add a squeeler tip to a padram p3d mesh.
% mesh = the plot3d mesh file
% boundata = the plot3d boundata file
% width = the node in the tip gap mesh which will become the edge of the squeeler
% depth = the depth of the recess in meters
% layers = the number of node layers to be placed in the recess.
%
% NB at the moment this code assumes that we are using radial meshes.

new_mesh = mesh;

% First create the floor 'tip' profile for the mesh at the required depth
% Find blade tip corner points
base.x = zeros(1,mesh.dims(2,1));
base.r = zeros(1,mesh.dims(2,1));
base.s = zeros(1,mesh.dims(2,1));
for b = [2 4:6]
    mesh.block(b).r = sqrt(mesh.block(b).y.^2+mesh.block(b).z.^2);
    mesh.block(b).t = atan2(mesh.block(b).z,mesh.block(b).y);
    mesh.block(b).s = mesh.block(b).r.*mesh.block(b).t;
end

j_mid = ceil(mesh.dims(4,2)/2);
k_tip = mesh.dims(2,3)-mesh.dims(4,3)+1;

for i = 1:mesh.dims(2,1);
    R = mesh.block(2).r(i,1,k_tip)-depth;
    base.r(i) = R;
    base.x(i) = interp1(squeeze(mesh.block(2).r(i,1,:)),squeeze(mesh.block(2).x(i,1,:)),R,'linear');
    base.y(i) = interp1(squeeze(mesh.block(2).r(i,1,:)),squeeze(mesh.block(2).y(i,1,:)),R,'linear');
    base.z(i) = interp1(squeeze(mesh.block(2).r(i,1,:)),squeeze(mesh.block(2).z(i,1,:)),R,'linear');
    base.t(i) = interp1(squeeze(mesh.block(2).r(i,1,:)),squeeze(mesh.block(2).t(i,1,:)),R,'linear');
    base.s(i) = interp1(squeeze(mesh.block(2).r(i,1,:)),squeeze(mesh.block(2).s(i,1,:)),R,'linear');
    if mesh.block(2).x(i,1,k_tip) == mesh.block(4).x(1,end,1) & mesh.block(2).y(i,1,k_tip) == mesh.block(4).y(1,end,1) & mesh.block(2).z(i,1,k_tip) == mesh.block(4).z(1,end,1)
        le_1 = 1:i;
    elseif mesh.block(2).x(i,1,k_tip) == mesh.block(4).x(end,end,1) & mesh.block(2).y(i,1,k_tip) == mesh.block(4).y(end,end,1) & mesh.block(2).z(i,1,k_tip) == mesh.block(4).z(end,end,1)
        i_ss = le_1(end):i;
    elseif mesh.block(2).x(i,1,k_tip) == mesh.block(4).x(end,1,1) & mesh.block(2).y(i,1,k_tip) == mesh.block(4).y(end,1,1) & mesh.block(2).z(i,1,k_tip) == mesh.block(4).z(end,1,1)
        i_te = i_ss(end):i;
    elseif mesh.block(2).x(i,1,k_tip) == mesh.block(4).x(1,1,1) & mesh.block(2).y(i,1,k_tip) == mesh.block(4).y(1,1,1) & mesh.block(2).z(i,1,k_tip) == mesh.block(4).z(1,1,1)
        i_ps = i_te(end):i;
        le_2 = i:mesh.dims(2,1);
    end
end
i_le = [le_2(1:end-1) le_1];

% Then interpolate the middle, le and te mesh profiles
% First do the main chunck
mid.x = zeros(mesh.dims(4,1),mesh.dims(4,2));
mid.y = zeros(mesh.dims(4,1),mesh.dims(4,2));
mid.z = zeros(mesh.dims(4,1),mesh.dims(4,2));
mid.r = zeros(mesh.dims(4,1),mesh.dims(4,2));
mid.s = zeros(mesh.dims(4,1),mesh.dims(4,2));
mid.t = zeros(mesh.dims(4,1),mesh.dims(4,2));

mid.x(:,end) = base.x(i_ss);
mid.x(:,1) = base.x(fliplr(i_ps));
mid.y(:,end) = base.y(i_ss);
mid.y(:,1) = base.y(fliplr(i_ps));
mid.z(:,end) = base.z(i_ss);
mid.z(:,1) = base.z(fliplr(i_ps));
mid.r(:,end) = base.r(i_ss);
mid.r(:,1) = base.r(fliplr(i_ps));
mid.s(:,end) = base.s(i_ss);
mid.s(:,1) = base.s(fliplr(i_ps));
mid.t(:,end) = base.t(i_ss);
mid.t(:,1) = base.t(fliplr(i_ps));

for i = 1:mesh.dims(4,1)
    b = [0 cumsum(sqrt((diff(mesh.block(4).x(i,:,1))).^2+(diff(mesh.block(4).r(i,:,1))).^2+(diff(mesh.block(4).s(i,:,1))).^2))];
    b = b/b(end);
    mid.x(i,:) = mid.x(i,1)+b*(mid.x(i,end)-mid.x(i,1));
    mid.r(i,:) = mid.r(i,1)+b*(mid.r(i,end)-mid.r(i,1));
    mid.s(i,:) = mid.s(i,1)+b*(mid.s(i,end)-mid.s(i,1));
end
mid.t = mid.s./mid.r;
mid.y = mid.r.*cos(mid.t);
mid.z = mid.r.*sin(mid.t);

% Next do LE chunck
le.x = zeros(mesh.dims(5,1),mesh.dims(5,2));
le.y = zeros(mesh.dims(5,1),mesh.dims(5,2));
le.z = zeros(mesh.dims(5,1),mesh.dims(5,2));
le.r = zeros(mesh.dims(5,1),mesh.dims(5,2));
le.s = zeros(mesh.dims(5,1),mesh.dims(5,2));
le.t = zeros(mesh.dims(5,1),mesh.dims(5,2));

le.x(:,1) = mid.x(1,j_mid);
le.y(:,1) = mid.y(1,j_mid);
le.z(:,1) = mid.z(1,j_mid);
le.r(:,1) = mid.r(1,j_mid);
le.t(:,1) = mid.t(1,j_mid);
le.s(:,1) = mid.s(1,j_mid);
le.x(:,end) = base.x(i_le);
le.y(:,end) = base.y(i_le);
le.z(:,end) = base.z(i_le);
le.r(:,end) = base.r(i_le);
le.t(:,end) = base.t(i_le);
le.s(:,end) = base.s(i_le);

le.x(1,end:-1:1) = mid.x(1,1:j_mid);
le.y(1,end:-1:1) = mid.y(1,1:j_mid);
le.z(1,end:-1:1) = mid.z(1,1:j_mid);
le.r(1,end:-1:1) = mid.r(1,1:j_mid);
le.t(1,end:-1:1) = mid.t(1,1:j_mid);
le.s(1,end:-1:1) = mid.s(1,1:j_mid);
le.x(end,:) = mid.x(1,j_mid:end);
le.y(end,:) = mid.y(1,j_mid:end);
le.z(end,:) = mid.z(1,j_mid:end);
le.r(end,:) = mid.r(1,j_mid:end);
le.t(end,:) = mid.t(1,j_mid:end);
le.s(end,:) = mid.s(1,j_mid:end);
b = [0 cumsum(sqrt((diff(le.x(1,:))).^2+(diff(le.r(1,:)).^2)+(diff(le.s(1,:)).^2)))];
b = b/b(end);

for i = 2:(mesh.dims(5,1)-1)
    le.x(i,:) = le.x(i,1)+b*(le.x(i,end)-le.x(i,1));
    le.r(i,:) = le.r(i,1)+b*(le.r(i,end)-le.r(i,1));
    le.s(i,:) = le.s(i,1)+b*(le.s(i,end)-le.s(i,1));
end
le.t = le.s./le.r;
le.y = le.r.*cos(le.t);
le.z = le.r.*sin(le.t);

% Last do the TE chunk
te.x = zeros(mesh.dims(6,1),mesh.dims(6,2));
te.y = zeros(mesh.dims(6,1),mesh.dims(6,2));
te.z = zeros(mesh.dims(6,1),mesh.dims(6,2));
te.r = zeros(mesh.dims(6,1),mesh.dims(6,2));
te.s = zeros(mesh.dims(6,1),mesh.dims(6,2));
te.t = zeros(mesh.dims(6,1),mesh.dims(6,2));

te.x(:,1) = mid.x(end,j_mid);
te.y(:,1) = mid.y(end,j_mid);
te.z(:,1) = mid.z(end,j_mid);
te.r(:,1) = mid.r(end,j_mid);
te.t(:,1) = mid.t(end,j_mid);
te.s(:,1) = mid.s(end,j_mid);
te.x(:,end) = base.x(i_te);
te.y(:,end) = base.y(i_te);
te.z(:,end) = base.z(i_te);
te.r(:,end) = base.r(i_te);
te.t(:,end) = base.t(i_te);
te.s(:,end) = base.s(i_te);

te.x(1,:) = mid.x(end,j_mid:end);
te.y(1,:) = mid.y(end,j_mid:end);
te.z(1,:) = mid.z(end,j_mid:end);
te.r(1,:) = mid.r(end,j_mid:end);
te.t(1,:) = mid.t(end,j_mid:end);
te.s(1,:) = mid.s(end,j_mid:end);
te.x(end,:) = mid.x(end,j_mid:-1:1);
te.y(end,:) = mid.y(end,j_mid:-1:1);
te.z(end,:) = mid.z(end,j_mid:-1:1);
te.r(end,:) = mid.r(end,j_mid:-1:1);
te.t(end,:) = mid.t(end,j_mid:-1:1);
te.s(end,:) = mid.s(end,j_mid:-1:1);
b = [0 cumsum(sqrt((diff(te.x(1,:))).^2+(diff(te.r(1,:)).^2)+(diff(te.s(1,:)).^2)))];
b = b/b(end);

for i = 2:(mesh.dims(6,1)-1)
    te.x(i,:) = te.x(i,1)+b*(te.x(i,end)-te.x(i,1));
    te.r(i,:) = te.r(i,1)+b*(te.r(i,end)-te.r(i,1));
    te.s(i,:) = te.s(i,1)+b*(te.s(i,end)-te.s(i,1));
end
te.t = te.s./te.r;
te.y = te.r.*cos(te.t);
te.z = te.r.*sin(te.t);


% Create the required blocks by interpolating
b = linspace(0,1,layers+2);
for k = 1:(layers+2);
    new_mesh.block(9).x(:,:,k) = mid.x(:,(width:end-width+1))+b(k)*(mesh.block(4).x(:,(width:end-width+1),1)-mid.x(:,(width:end-width+1)));
    new_mesh.block(9).y(:,:,k) = mid.y(:,(width:end-width+1))+b(k)*(mesh.block(4).y(:,(width:end-width+1),1)-mid.y(:,(width:end-width+1)));
    new_mesh.block(9).z(:,:,k) = mid.z(:,(width:end-width+1))+b(k)*(mesh.block(4).z(:,(width:end-width+1),1)-mid.z(:,(width:end-width+1)));
    
    new_mesh.block(10).x(:,:,k) = le.x(:,(1:end-width+1))+b(k)*(mesh.block(5).x(:,(1:end-width+1),1)-le.x(:,(1:end-width+1)));
    new_mesh.block(10).y(:,:,k) = le.y(:,(1:end-width+1))+b(k)*(mesh.block(5).y(:,(1:end-width+1),1)-le.y(:,(1:end-width+1)));
    new_mesh.block(10).z(:,:,k) = le.z(:,(1:end-width+1))+b(k)*(mesh.block(5).z(:,(1:end-width+1),1)-le.z(:,(1:end-width+1)));
    
    new_mesh.block(11).x(:,:,k) = te.x(:,(1:end-width+1))+b(k)*(mesh.block(6).x(:,(1:end-width+1),1)-te.x(:,(1:end-width+1)));
    new_mesh.block(11).y(:,:,k) = te.y(:,(1:end-width+1))+b(k)*(mesh.block(6).y(:,(1:end-width+1),1)-te.y(:,(1:end-width+1)));
    new_mesh.block(11).z(:,:,k) = te.z(:,(1:end-width+1))+b(k)*(mesh.block(6).z(:,(1:end-width+1),1)-te.z(:,(1:end-width+1)));
end


% Write the mesh dims
new_mesh.n_blocks = 11;
new_mesh.dims(9,:) = [mesh.dims(4,1) mesh.dims(4,2)-2*width+2 layers+2];
new_mesh.dims(10,:) = [mesh.dims(5,1) mesh.dims(5,2)-width+1 layers+2];
new_mesh.dims(11,:) = [mesh.dims(6,1) mesh.dims(6,2)-width+1 layers+2];

% Write the boundata
new_boundata = boundata(1:28);
new_boundata(28).dims([6 10]) = [width width];
new_boundata(29) = boundata(28);
new_boundata(29).name = 'PATCH    ';
new_boundata(29).dims([5 6 9 10]) = [width new_mesh.dims(4,2)-width+1 width new_mesh.dims(4,2)-width+1];
new_boundata(30) = boundata(28);
new_boundata(30).name = 'MERGEOGV ';
new_boundata(30).dims([5 9]) = [new_mesh.dims(4,2)-width+1 new_mesh.dims(4,2)-width+1];
new_boundata(31:35) = boundata(29:33);
new_boundata(36) = boundata(34);
new_boundata(36).name = 'PATCH    ';
new_boundata(36).dims([6 10]) = [new_mesh.dims(5,2)-width+1 new_mesh.dims(5,2)-width+1];
new_boundata(37) = boundata(34);
new_boundata(37).name = 'MERGEOGV ';
new_boundata(37).dims([5 9]) = [new_mesh.dims(5,2)-width+1 new_mesh.dims(5,2)-width+1];
new_boundata(38:42) = boundata(35:39);
new_boundata(43) = boundata(40);
new_boundata(43).name = 'PATCH    ';
new_boundata(43).dims([6 10]) = [new_mesh.dims(6,2)-width+1 new_mesh.dims(6,2)-width+1];
new_boundata(44) = boundata(40);
new_boundata(44).name = 'MERGEOGV ';
new_boundata(44).dims([5 9]) = [new_mesh.dims(6,2)-width+1 new_mesh.dims(6,2)-width+1];
new_boundata(45:57) = boundata(41:53);
new_boundata(58:63) = boundata(24:29);
for i = 58:63
    new_boundata(i).block1 = 9;
    new_boundata(i).block2 = 9;
end
new_boundata(58).dims([4 6 8 10]) = [new_mesh.dims(9,2) new_mesh.dims(9,3) new_mesh.dims(9,2) new_mesh.dims(9,3)];
new_boundata(59).dims([4 6 8 10]) = [new_mesh.dims(9,2) new_mesh.dims(9,3) new_mesh.dims(9,2) new_mesh.dims(9,3)];
new_boundata(60).dims([6 10]) = [new_mesh.dims(9,3) new_mesh.dims(9,3)];
new_boundata(60).name = 'MERGEOGV ';
new_boundata(61).dims([1 2 6 10]) = [new_mesh.dims(9,2) new_mesh.dims(9,2) new_mesh.dims(9,3) new_mesh.dims(9,3)];
new_boundata(61).name = 'MERGEOGV ';
new_boundata(62).dims([6 10]) = [new_mesh.dims(9,2) new_mesh.dims(9,2)];
new_boundata(63).name = 'PATCH    ';
new_boundata(63).dims([1 2 6 10]) = [new_mesh.dims(9,3) new_mesh.dims(9,3) new_mesh.dims(9,2) new_mesh.dims(9,2)];
new_boundata(64:69) = boundata(30:35);
for i = 64:69
    new_boundata(i).block1 = 10;
    new_boundata(i).block2 = 10;
end
new_boundata(64).name = 'MERGEPAR ';
new_boundata(64).dims([4 6 8 10]) = [new_mesh.dims(10,2) new_mesh.dims(10,3) new_mesh.dims(10,2) new_mesh.dims(10,3)];
new_boundata(65).name = 'MERGEPAR ';
new_boundata(65).dims([4 6 8 10]) = [new_mesh.dims(10,2) new_mesh.dims(10,3) new_mesh.dims(10,2) new_mesh.dims(10,3)];
new_boundata(66).name = 'MERGEPAR ';
new_boundata(66).dims([6 10]) = [new_mesh.dims(10,3) new_mesh.dims(10,3)];
new_boundata(67).name = 'MERGEOGV ';
new_boundata(67).dims([1 2 6 10]) = [new_mesh.dims(10,2) new_mesh.dims(10,2) new_mesh.dims(10,3) new_mesh.dims(10,3)];
new_boundata(68).dims([6 10]) = [new_mesh.dims(10,2) new_mesh.dims(10,2)];
new_boundata(69).name = 'PATCH    ';
new_boundata(69).dims([1 2 6 10]) = [new_mesh.dims(10,3) new_mesh.dims(10,3) new_mesh.dims(10,2) new_mesh.dims(10,2)];
new_boundata(70:75) = boundata(36:41);
for i = 70:75
    new_boundata(i).block1 = 11;
    new_boundata(i).block2 = 11;
end
new_boundata(70).name = 'MERGEPAF ';
new_boundata(70).dims([4 6 8 10]) = [new_mesh.dims(11,2) new_mesh.dims(11,3) new_mesh.dims(11,2) new_mesh.dims(11,3)];
new_boundata(71).name = 'MERGEPAF ';
new_boundata(71).dims([4 6 8 10]) = [new_mesh.dims(11,2) new_mesh.dims(11,3) new_mesh.dims(11,2) new_mesh.dims(11,3)];
new_boundata(72).name = 'MERGEPR  ';
new_boundata(72).dims([6 10]) = [new_mesh.dims(11,3) new_mesh.dims(11,3)];
new_boundata(73).name = 'MERGEOGV ';
new_boundata(73).dims([1 2 6 10]) = [new_mesh.dims(11,2) new_mesh.dims(11,2) new_mesh.dims(11,3) new_mesh.dims(11,3)];
new_boundata(74).dims([6 10]) = [new_mesh.dims(11,2) new_mesh.dims(11,2)];
new_boundata(75).name = 'PATCH    ';
new_boundata(75).dims([1 2 6 10]) = [new_mesh.dims(11,3) new_mesh.dims(11,3) new_mesh.dims(11,2) new_mesh.dims(11,2)];