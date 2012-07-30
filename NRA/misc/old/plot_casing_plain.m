
Mesh = Read_Plot3D('mesh.plot3d')

face = 1;plot(Mesh.block(face).x(:,:,end),(Mesh.block(face).y(:,:,end).^2+Mesh.block(face).z(:,:,end).^2).^0.5,'r')
hold on; axis equal
face = 2;plot(Mesh.block(face).x(:,:,end),(Mesh.block(face).y(:,:,end).^2+Mesh.block(face).z(:,:,end).^2).^0.5,'r')
face = 3;plot(Mesh.block(face).x(:,:,end),(Mesh.block(face).y(:,:,end).^2+Mesh.block(face).z(:,:,end).^2).^0.5,'r')
face = 4;plot(Mesh.block(face).x(:,:,end),(Mesh.block(face).y(:,:,end).^2+Mesh.block(face).z(:,:,end).^2).^0.5,'r')
face = 7;plot(Mesh.block(face).x(:,:,end),(Mesh.block(face).y(:,:,end).^2+Mesh.block(face).z(:,:,end).^2).^0.5,'r')
face = 8;plot(Mesh.block(face).x(:,:,end),(Mesh.block(face).y(:,:,end).^2+Mesh.block(face).z(:,:,end).^2).^0.5,'r')

% blade tip Omesh
face = 2;plot(Mesh.block(face).x(:,1,30),(Mesh.block(face).y(:,10,30).^2+Mesh.block(face).z(:,1,30).^2).^0.5,'k')