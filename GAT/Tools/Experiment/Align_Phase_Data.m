function Align_Phase_Data;
%
% A function to align the phase data associated with
% the specified 'master runs'

% Set master runs.
m_runs = [8153 8153 8153 8153 8153 8153 8153 8153 ...
        8153 8153 8153 8153 8153 8153 8153 8153 ...
        8154 8154 8154 8154 8154 8154 8154 8154 ...
        8154 8154 8154 8154 8154 8154 8154 8154 ...
        8155 8155 8155 8155 8155 8155 8155 8155 ...
        8155 8155 8155 8155 8155 8155 8155 8155 ...
        8156 8156 8156 8156 8156 8156 8156 8156];

% Is gauge offset?
m_runs(2,:) = [0 0 0 0 0 0 0 0 ...
        0 0 0 0 0 0 0 0 ...
        0 0 0 0 0 0 0 0 ...
        0 0 0 0 0 0 0 0 ...
        0 0 0 0 0 0 0 0 ...
        0 0 0 0 0 0 0 0 ...
        0 0 0 0 0 0 0 0];

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

% Set up master phase location for each gauge
for gauges = 1:56;
    % Change into the directory
    eval(['cd ' file_root '/run_' num2str(m_runs(1,gauges))]);
    disp(['Setting up master for gauge ' num2str(gauges)]);
    load phaseavv_qdot
    
    num = gauges+8*m_runs(2,gauges)-floor((gauges+8*m_runs(2,gauges)-1)/16)*16;
    [max,m_phase(gauges)] = max(qdot(:,num));
end

% Now shift all the other runs to match
runs = [8084 8085 8086 8087 8088 8089 8090 8092 8094 8096 8097 8098 8099 8101 ...
        8102 8103 8104 8105 8106 8107 8108 8145 8146 8147 8148 8150 8151 ...
        8152 8153 8154 8155 8156 8157 8158 8159 8161 8162 8163 8164 8165 ...
        8166 8167 8168 8170 8171 8172 8173 8174 8175];

run_g = [1:16; 17:32; 33:48; 49:56 1:8; 9:24; 25:40; 41:56; 1:16; 17:32; 33:48; 49:56 1:8; 9:24; 25:40; 41:56; ...
        1:16; 17:32; 33:48; 49:56 1:8; 9:24; 25:40; 41:56; 1:16; 17:32; 33:48; 49:56 1:8; 9:24; 25:40; ...
        41:56; 1:16; 17:32; 33:48; 49:56 1:8; 9:24; 25:40; 41:56; 1:16; 17:32; 33:48; 49:56 1:8; 9:24; ...
        25:40; 41:56; 1:16; 17:32; 33:48; 49:56 1:8; 9:24; 25:40; 41:56];

for run = 1:length(runs)
    eval(['cd ' file_root '/run_' num2str(runs(run))]);
    disp(['Working on run ' num2str(runs(run))]);
    load phaseavv_qdot
    
    for channel = 1:16
        % Find max index
        [max,n_phase] = max(qdot(:,channel));
        
        % Shift data to match master phase
        shift = n_phase-m_phase(run_g(run,channel));
        if shift > 0
            qdot(:,channel) = [qdot(shift+1:end,channel); qdot(1:shift,channel)];
        elseif shift < 0
            qdot(:,channel) = [qdot(end+shift+1:end,channel); qdot(1:end+shift,channel)];
        end
    end
    
    save phaseavv_qdot Tw base opt qdot
    clear Tw base opt qdot
end
