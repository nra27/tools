function Write_Neutral(filename,mesh);
%
% Write_Neutral(filename,mesh);
% A function to write a given mesh out in
% Gambit Neutral file format

% Version
vers = '0.0.1';

% Check to see if file exits
if exist(filename) == 2
    button = questdlg('File exists: overwrite?','Warning','Yes','No','No');
    if strcmp(button,'Yes')
        delete(filename);
    else
        return
    end
end

% Open file
fid = fopen(filename,'w');

% Write the header
fprintf(fid,'%s\n',['        CONTROL INFO ' vers]);
fprintf(fid,'%s\n','** GAMBIT NEUTRAL FILE');
if length(mesh.hed) > 80
    mesh.hed = mesh.hed(1:80);
end
fprintf(fid,'%s\n',mesh.hed);
fprintf(fid,'%s\n',['PROGRAM:    Plot3D to Neutral     VERSION:  ' vers]);
d = date;
t = fix(clock);
fprintf(fid,'%s',[d(1:2) ' ' d(4:6) ' ' d(8:11) '    ']);
fprintf(fid,'%2d:%2d:%2d \n',t(4:6));
fprintf(fid,'%s\n','     NUMNP     NELEM     NGRPS    NBSETS     NDFCD     NDFVL');
fprintf(fid,' %9d %9d %9d %9d %9d %9d\n',[mesh.NUMNP mesh.NELEM mesh.NGRPS mesh.NBSETS mesh.NDFCD mesh.NDFVL]);
fprintf(fid,'%s\n','ENDOFSECTION');

clear d t;

% Write node coordinates
fprintf(fid,'%s\n',['   NODAL COORDINATES ' vers]);
if mesh.NDFCD == 3 % 3D mesh
    for i = 1:mesh.NUMNP
        % Ensure that formatting is correct
        I = sprintf('%10d',i);
        X = sprintf('%20.10e',mesh.node_coordinates(i,1));
        Y = sprintf('%20.10e',mesh.node_coordinates(i,2));
        Z = sprintf('%20.10e',mesh.node_coordinates(i,3));
        fprintf(fid,'%s\n',[I ' ' X(1:17) X(19:20) ' ' Y(1:17) Y(19:20) ' ' Z(1:17) Z(19:20)]);
    end
else
    fclose(fid)
    error('Unknown number of grid dimensions.');
end
fprintf(fid,'%s\n','ENDOFSECTION');

% Write elements/cells
fprintf(fid,'%s\n',['      ELEMENTS/CELLS ' vers]);
offset = 0;
% Write the hexahedra
if mesh.hex.nel > 0
    for i = 1:mesh.hex.nel
        fprintf(fid,'%8d %2d %2d %8d%8d%8d%8d%8d%8d%8d\n',[i+offset 4 8 mesh.hex.nodes(1:7)]);
        fprintf(fid,'               %8d\n',mesh.hex.nodes(8));
    end
    offset = offset+mesh.hex.nel;
end
% Write the prisms
if mesh.pri.nel > 0
    for i = 1:mesh.pri.nel
        fprintf(fid,'%8d %2d %2d %8d%8d%8d%8d%8d%8d\n',[i+offset 5 6 mesh.pri.nodes]);
    end
    offset = offset+mesh.pri.nel;
end
% Write the pyramids
if mesh.pyr.nel > 0
    for i = 1:mesh.pyr.nel
        fprintf(fid,'%8d %2d %2d %8d%8d%8d%8d%8d\n',[i+offset 7 5 mesh.pyr.nodes]);
    end
    offset = offset+mesh.pyr.nel;
end
% Write the tetrahedra
if mesh.tet.nel > 0
    for i = 1:mesh.tet.nel
        fprintf(fid,'%8d %2d %2d %8d%8d%8d%8d\n',[i+offset 6 4 mesh.pyr.nodes]);
    end
end
fprintf(fid,'%s\n','ENDOFSECTION');  

% Write element group
for i = 1:length(mesh.group)
    nelgp = length(mesh.group(i).elements);
    fprintf(fid,'%s\n',['       ELEMENT GROUP ' vers]);
    fprintf(fid,'GROUP: %10d ',i);
    fprintf(fid,'ELEMENTS: %10d ',nelgp);
    fprintf(fid,'MATERIAL: %10d ',2);
    fprintf(fid,'NFLAGS: %10d\n',1);
    fprintf(fid,'%s\n','                           fluid');
    fprintf(fid,'%10d',0);
    rows = fix(nelgp/10);
    extra = rem(nelgp,10);
    for j = 1:rows
        fprintf(fid,'%8d%8d%8d%8d%8d%8d%8d%8d%8d%8d\n',mesh.group(i).elements([1:10]+(j-1)*10));
    end
    for j = 1:extra
        fprintf(fid,'%8d',mesh.group(i).elements(10*row+extra));
    end
    fprintf(fid,'%s\n','ENDOFSECTION');
end

% Write boundary groups
    

% Close the file
fclose(fid);