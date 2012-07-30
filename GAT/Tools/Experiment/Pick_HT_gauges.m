function ht_runs = Pick_HT_gauges(runs,location);
%
% ht_runs = Pick_HT_gauges(runs,location)
%
% A function to pick the runs that give the best ht
% signals for plotting.

% Check to see where we are
if strcmp(location,'osney')
    file_root = '\\Engs-cheddar\Data\D''ata 2\''Casing_HT_Build2\';
elseif strcmp(location,'home')
    file_root = 'E:\E''xperimental Data\''Casing_HT_Build2\';
else
    disp('Where am I?')
    return
end

% Check size of runs to establish loop-limits
[gauges,temps] = size(runs);

% Start Gauge loop
for gauge = 1:gauges
    disp(['Working on gauge ' num2str(gauge)])
    target = 100;
    % Start temperature loop
    for temp = 1:temps        
        % Load data
        eval(['load ' file_root 'run_' num2str(runs(gauge,temp)) '\rawQdot_2rev;']);
        
        Pr = opt.PresR/3.1654;
        Re = opt.Re/2.7e6;
        N = opt.speed/460.48;
        
        errors = abs(3-Pr-Re-N);
        
        if errors <= target
            target = errors;
            ht_runs(gauge) = temp;
        end
    end
end