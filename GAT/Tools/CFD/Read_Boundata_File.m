function plot3d = Read_Boundata_File(filename);
%
% plot3d = Read_Boundata_File(filename)
% A function to read the p3d.boundata file

% Open the file
fid = fopen(filename);

% Read the file
i = 1;
s{i} = fgetl(fid);
while s{i} ~= -1
    i = i+1;
    s{i} = fgetl(fid);
end

% Close the file
fclose(fid);

% Parse the strings
for i = 1:(length(s)-1)
    plot3d(i).name = s{i}(1:9);
    plot3d(i).block1 = str2num(s{i}(10:14));
    plot3d(i).block2 = str2num(s{i}(15:19));
    plot3d(i).norm1 = s{i}(22);
    plot3d(i).norm2 = s{i}(25);
    plot3d(i).prime1 = s{i}(28);
    plot3d(i).prime2 = s{i}(31);
    plot3d(i).dir1 = s{i}(34);
    plot3d(i).dir2 = s{i}(37);
    plot3d(i).dims = sscanf(s{i}(38:end),'%d');
end

