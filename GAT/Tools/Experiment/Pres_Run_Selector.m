function Pres = Pres_Run_Selector(location);
%
% A function to select valid runs

% Check to see where we are
if strcmp(location,'osney')
    file_root = '\\Engs-cheddar\Data\D''ata 2\''Casing_Pressure_Build2\';
elseif strcmp(location,'home')
    file_root = 'E:\E''xperimental Data\''Casing_Pressure_Build2\';
else
    disp('Where am I?')
    return
end

% Load runs sheet
load Pres_Run_Distribution

% Check size of runs to establish loop-limits
[gauges,run_nos] = size(runs);

% Start gauge loop
for gauge = 1:56
    
    disp(['Gauge = ' num2str(gauge)])
    
    % Start run loop
    for run = 1:run_nos
        if runs(gauge,run) > 0
            % Load data
            eval(['load ' file_root 'run_' num2str(runs(gauge,run)) '\phaseavv_pres;']);
            eval(['load ' file_root 'run_' num2str(runs(gauge,run)) '\KU_DATA_' num2str(runs(gauge,run)) ';']);
            
            % Find gauge
            eval(['name1 = name' num2str(runs(gauge,run)) ';'])
            for line = 1:length(kulites)
                if str2num(name1(line,6:7)) == gauge
                    break
                end
            end
            
            Pressure(:,run) = pres(:,line)*(1+(8.04e5-opt.P01)/8.04e5)/1e5;
            figure(gauge)
            set(gauge,'NumberTitle','off','Name',['Gauge ' num2str(gauge)],'Menubar','none');
            set(gauge,'position',[397   568   626   397]);
            plot(Pressure(:,run))
            set(gca,'ylim',[2 5])
            hold on
            drawnow
        end
    end
    for run = 1:run_nos
        if runs(gauge,run) > 0        
            figure(gauge)
            plot(Pressure(:,run),'r')
            s = input('Is this the best run?   :','s');
            if strcmp(s,'y')
                Pres(:,gauge) = Pressure(:,run);
                break
            else
                plot(Pressure(:,run),'b')
            end
        end
    end
end