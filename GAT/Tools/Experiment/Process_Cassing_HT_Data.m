function Process_Cassing_HT_Data(function_string);
%
% A function to carry out an opperation on all of the heat-transfer data

runs = [8084 8085 8086 8087 8088 8089 8090 8092 8094 8096 8097 8098 8099 8101 ...
        8102 8103 8104 8105 8106 8107 8108 8145 8146 8147 8148 8150 8151 ...
        8152 8153 8154 8155 8156 8157 8158 8159 8161 8162 8163 8164 8165 ...
        8166 8167 8168 8170 8171 8172 8173 8174 8175];

% Make sure that we are where we think we should be
cd('C:\Documents and Settings\gat\My Documents\My Experiments\Casing_HT_Build2\processed');

location = input('Where am I?  :','s');
% Check to see where we are
if strcmp(location,'osney')
    file_root = '\\Engs-cheddar\Data\D''ata 2\''Casing_HT_Build2\';
elseif strcmp(location,'home')
    file_root = 'D:\E''xperimental Data\''Casing_HT_Build2\';
else
    error('Sorry, I don''t know where that is.')
end
    
% For all of the valid runs
for run = 1:length(runs)
    % Change into the directory
    eval(['cd ' file_root '/run_' num2str(runs(run))]);
    disp(['Working on run ' num2str(runs(run))]);
    eval(function_string);
end

cd('C:\Documents and Settings\gat\My Documents\My Experiments\Casing_HT_Build2\processed');
    