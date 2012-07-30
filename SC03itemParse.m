% function data = SC03itemParse(filename,GRname)
%
% Extracts an item and returns it neatly interpolated onto a uniform 0.5
% time base
%
% e.g.
% 
% filename = 'Drum_with_casing_bdd.item'
% 
% GRname = 'GRTIPCLRST2'
% 

function [t,data] = SC03itemParse(filename,GRname)

fid = fopen(filename);
name_length = length(GRname);

% Search for the GR in the file
line = zeros(1,50e3);
for n = 1:50e3,
    test = fgetl(fid);
    line(n) = strncmp(test,GRname,name_length);
    if line(n) == 1,
        break
    else
        n = n+1;
    end
    
end

% Find the dimensions of the item
dims = fscanf(fid,'%f',6);

% Extract the item data
for i = 1:dims(6),
    data(:,i) = fscanf(fid,'%f',[1,2]);
end

fclose(fid);

% Dither the data on repeated points
data = data';
data_tmp = data;
for n = 1:length(data)-1,
    if data(n+1,1) == data(n,1),
        data_tmp(n+1,1) = data(n,1)+0.0000001;
        else
    end
    n = n+1;
end

% Interp onto a uniform timebase
t = 0:0.5:10000;
data = interp1(data_tmp(:,1),data(:,2),t);
