function Write_Fluent(filename,mesh);
% Write_Fluent(mesh)
% A function to write out a mesh to Fluent .msh format

% Open dialogue box
Handles.dlgbox = figure('units','points','position',[40 40 200 70],'windowstyle','normal',...
        'name','Read HYDRA ADF Data','buttondownfcn',[],'visible','on','resize','off',...
        'menubar','none','colormap',[],'numbertitle','off','doublebuffer','on','Tag','nozoom');
Handles.axes = axes('position',[0.1 0.35 0.8 0.2],'box','on','xtick',[],'ytick',[],'xlim',[0 1],'ylim',[0 1]);
Handles.line = line([-1 -1],[0.5 0.5]);
set(Handles.line,'color','b','linewidth',14);
set(Handles.line,'xdata',[0 1]);

Handles.title = title('Writing MSH File');
set(Handles.line,'xdata',[0 1]);
drawnow;

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

% Write file header
fprintf(fid,'(0 "Hydra to Fluent File")\n');
fprintf(fid,'\n');

% Write dimensions
fprintf(fid,'(0 "Dimension:")\n');
fprintf(fid,'(2 %1d)\n',mesh.dimension);
fprintf(fid,'\n');

% Write nodes - they will be writen as one zone
fprintf(fid,'(0 "Nodes:")\n');
fprintf(fid,'(10 (0 1 %X 1 %d))\n',[mesh.n_nodes mesh.dimension]);
fprintf(fid,'(10 (1 1 %X 1 %d)(\n',[mesh.n_nodes mesh.dimension]);

if mesh.dimension == 2
    for i = 1:mesh.n_nodes
        X = sprintf('%18.10e',mesh.coordinates(i,1));
        Y = sprintf('%18.10e',mesh.coordinates(i,2));
        fprintf(fid,'%s\n',['   ' X(1:15) X(17:18) '    ' Y(1:15) Y(17:18)]);
    end 
elseif mesh.dimension == 3
    for i = 1:mesh.n_nodes
        X = sprintf('%18.10e',mesh.coordinates(i,1));
        Y = sprintf('%18.10e',mesh.coordinates(i,2));
        Z = sprintf('%18.10e',mesh.coordinates(i,3));
        fprintf(fid,'%s\n',['   ' X(1:15) X(17:18) '    ' Y(1:15) Y(17:18) '    ' Z(1:15) Z(17:18)]);
    end
end
fprintf(fid,'))\n');
fprintf(fid,'\n');

% Write cells
fprintf(fid,'(0 "Cells:")\n');
fprintf(fid,'(12 (0 1 %X 0))\n',mesh.n_cells);
% If we only have one type of cell, the write as a block
if length(mesh.cell_types) == 2
    if strcmp(mesh.cell_types(2),'h')
        fprintf(fid,'(12 (2 1 %X 1 4))\n',mesh.hex.n_cells);
    elseif strcmp(mesh.cell_types(2),'p')
        fprintf(fid,'(12 (2 1 %X 1 6))\n',mesh.pri.n_cells);
    elseif strcmp(mesh.cell_types(2),'s')
        fprintf(fid,'(12 (2 1 %X 1 5))\n',mesh.pyr.n_cells);
    elseif strcmp(mesh.cell_types(2),'t')
        fprintf(fid,'(12 (2 1 %X 1 2))\n',mesh.tet.n_cells);
    else
        error('Unknown cell type!');
    end
else
    % Write as a single mixed block
    fprintf(fid,'(12 (2 1 %X 1 0)(\n',mesh.n_cells);
    offset = 0;
    for itype = 1:(length(mesh.cell_types)-1)
        if strcmp(mesh.cell_types(itype+1),'h')
            if mesh.hex.n_cells <= (9-offset)
                for j = 1:mesh.hex.n_cells
                    fprintf(fid,' 4');
                end
                offset = offset+mesh.hex.n_cells;
            else
                for j = 1:(9-offset)
                    fprintf(fid,' 4');
                end
                fprintf(fid,'\n');
                row = floor((mesh.hex.n_cells-(9-offset))/9);
                offset = rem((mesh.hex.n_cells-(9-offset)),9);
                for j = 1:row
                    fprintf(fid,' 4 4 4 4 4 4 4 4 4\n');
                end
                for j = 1:offset
                    fprintf(fid,' 4');
                end
            end
        elseif strcmp(mesh.cell_types(itype+1),'p')
            if mesh.pri.n_cells <= (9-offset)
                for j = 1:mesh.pri.n_cells
                    fprintf(fid,' 6');
                end
                offset = offset+mesh.pri.n_cells;
            else
                for j = 1:(9-offset)
                    fprintf(fid,' 6');
                end
                fprintf(fid,'\n');
                row = floor((mesh.pri.n_cells-(9-offset))/9);
                offset = rem((mesh.pri.n_cells-(9-offset)),9);
                for j = 1:row
                    fprintf(fid,' 6 6 6 6 6 6 6 6 6\n');
                end
                for j = 1:offset
                    fprintf(fid,' 6');
                end
            end
        elseif strcmp(mesh.cell_types(itype+1),'s')
            if mesh.pyr.n_cells <= (9-offset)
                for j = 1:mesh.pyr.n_cells
                    fprintf(fid,' 5');
                end
                offset = offset+mesh.pyr.n_cells;
            else
                for j = 1:(9-offset)
                    fprintf(fid,' 5');
                end
                fprintf(fid,'\n');
                row = floor((mesh.pyr.n_cells-(9-offset))/9);
                offset = rem((mesh.pyr.n_cells-(9-offset)),9);
                for j = 1:row
                    fprintf(fid,' 5 5 5 5 5 5 5 5 5\n');
                end
                for j = 1:offset
                    fprintf(fid,' 5');
                end
            end
        elseif strcmp(mesh.cell_types(itype+1),'t')
            if mesh.tet.n_cells <= (9-offset)
                for j = 1:mesh.tet.n_cells
                    fprintf(fid,' 2');
                end
                offset = offset+mesh.tet.n_cells;
            else
                for j = 1:(9-offset)
                    fprintf(fid,' 2');
                end
                fprintf(fid,'\n');
                row = floor((mesh.tet.n_cells-(9-offset))/9);
                offset = rem((mesh.tet.n_cells-(9-offset)),9);
                for j = 1:row
                    fprintf(fid,' 2 2 2 2 2 2 2 2 2\n');
                end
                for j = 1:offset
                    fprintf(fid,' 2');
                end
            end
        else
            error('Unknown cell type!');
        end
    end
    fprintf(fid,'\n))\n');
end
fprintf(fid,'\n');

% Write faces
fprintf(fid,'(0 "Faces:")\n');
fprintf(fid,'(13 (0 1 %X 0))\n',mesh.n_faces);
ielement = 0;
for igroup = 1:length(mesh.group)   % Loop over the surface groups
    fprintf(fid,'(13 (%d %X %X %X 0)(\n',[igroup+2 ielement+1 ielement+mesh.group(igroup).n_elements mesh.group(igroup).face_type]);
    for i = 1:mesh.group(igroup).n_elements
        if mesh.group(igroup).element_type(i) == 3
            fprintf(fid,' 3 %X  %X  %X %X %X\n',[mesh.group(igroup).elements(i,1:3) mesh.group(igroup).elements(i,5:6)]);
        else
            fprintf(fid,' 4 %X  %X  %X  %X %X %X\n',mesh.group(igroup).elements(i,:));
        end
    end
    fprintf(fid,'))\n');
    ielement = ielement+mesh.group(igroup).n_elements;
end
fprintf(fid,'\n');

% Write periodic face connectivity
fprintf(fid,'(0 "Periodic:")\n');
fprintf(fid,'(18 (%X %X %d %d)(\n',[mesh.periodic.stats(1:2) mesh.periodic.stats(3:4)+2]);
for i = 1:(mesh.periodic.stats(2)-mesh.periodic.stats(1)+1)
    fprintf(fid,' %X %X\n',mesh.periodic.faces(i,:));
end
fprintf(fid,'))\n');
fprintf(fid,'\n');

% Write Zones
fprintf(fid,'(0 "Zones:")\n');
fprintf(fid,'(45 (2 fluid Fluid)())\n');
for igroup = 1:length(mesh.group)   % Loop over the surface groups
    fprintf(fid,'(45 (%d ',igroup+2);
    fprintf(fid,'%s ',mesh.group(igroup).face_name);
    fprintf(fid,'%s',mesh.group(igroup).face_tag);
    fprintf(fid,')())\n');
end

% Close file
fclose(fid);
close(Handles.dlgbox);