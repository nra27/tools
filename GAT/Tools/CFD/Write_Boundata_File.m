function Write_Boundata_File(filename,plot3d);
%
% Write_Boundata_File(filename,plot3d)
% A function to write a p3d.boundata file

% Check to see if file exist already and delete if necessary
if exist(filename) == 2
    delete(filename);
end

% Open the file
fid = fopen(filename,'w');

for i = 1:length(plot3d)
    fprintf(fid,'%s',plot3d(i).name);
    fprintf(fid,'%5d',plot3d(i).block1);
    fprintf(fid,'%5d',plot3d(i).block2);
    fprintf(fid,'  %s',plot3d(i).norm1);
    fprintf(fid,'  %s',plot3d(i).norm2);
    fprintf(fid,'  %s',plot3d(i).prime1);
    fprintf(fid,'  %s',plot3d(i).prime2);
    fprintf(fid,'  %s',plot3d(i).dir1);
    fprintf(fid,'  %s',plot3d(i).dir2);
    fprintf(fid,'%5d%5d%5d%5d%5d%5d%5d%5d%5d%5d\n',plot3d(i).dims);
end

% Close the file
fclose(fid);