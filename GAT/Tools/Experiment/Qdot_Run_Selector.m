function Qdot = Qdot_Run_Selector(location);
%
% A function to select valid runs

% Check to see where we are
if strcmp(location,'osney')
    file_root = '\\Engs-cheddar\Data\D''ata 2\''Casing_HT_Build2\';
elseif strcmp(location,'home')
    file_root = 'E:\E''xperimental Data\''Casing_HT_Build2\';
else
    disp('Where am I?')
    return
end

% Load runs sheet
load HT_Run_Distribution
load Corrected_Qdot

% Check size of runs to establish loop-limits
[gauges,run_nos] = size(runs);

% Start gauge loop
for gauge = 1:gauges
    
    disp(['Gauge = ' num2str(gauge)])
    
    % Start run loop
    for run = 1:run_nos          
        figure(gauge)
        set(gauge,'NumberTitle','off','Name',['Gauge ' num2str(gauge)],'Menubar','none');
        set(gauge,'position',[397   568   626   397]);
        plot(Qcor(:,gauge,run))
        set(gca,'ylim',[-5e4 25e4])
        hold on
        drawnow
    end
    for run = 1:run_nos       
        figure(gauge)
        plot(Qcor(:,gauge,run),'r')
        s = input('Is this the best run?   :','s');
        if strcmp(s,'y')
            Qdot(:,gauge) = Qcor(:,gauge,run);
            break
        else
            plot(Qcor(:,gauge,run),'b')
        end
    end
end