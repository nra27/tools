function Process_Cassing_Pressure_Data(function_string);
%
% A function to carry out an opperation on all of the heat-transfer data

runs = [8118 8119 8120 8121 8122 8123 8124 8125 8126 8127 8128 ...
    8129 8130 8131 8132 8133 8134 8135 8136 8137 8138 8139 8140 ...
    8141 8142 8143 8144];

% Make sure that we are where we think we should be
cd('C:\Documents and Settings\gat\My Documents\My Experiments\Casing_HT_Build2\processed');

location = input('Where am I?  :','s');
% Check to see where we are
if strcmp(location,'osney')
    file_root = '\\Engs-cheddar\Data\D''ata 2\''Casing_Pressure_Build2\';
elseif strcmp(location,'home')
    file_root = 'E:\E''xperimental Data\''Casing_Pressure_Build2\';
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

cd('C:\Documents and Settings\gat\My Documents\My Experiments\Casing_Pressure_Build2\processed');