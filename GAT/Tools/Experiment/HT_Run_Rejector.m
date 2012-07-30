function HT_Run_Rejector(location);
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

% Load run archive and steady data
load HT_Run_Distribution
load Time_Mean_Points

for i = 1:56
    points{i} = 1:10;
end

% Check size of runs to establish loop-limits
[gauges,temps] = size(runs);

fig = figure;
for phase = [1:7]
    for gauge = [1:8]+(phase-1)*8
        if gauge == 14 % Don't bother with gauge 14
            continue
        end
        
        disp(['Gauge = ' num2str(gauge)])
        
        % Start temperature loop for adiabatic wall temp
        for temp = 1:temps
            
            % Load data
            eval(['load ' file_root 'run_' num2str(runs(gauge,temp)) '\phaseavv_qdot;']);
            eval(['load ' file_root 'run_' num2str(runs(gauge,temp)) '\HT_DATA_' num2str(runs(gauge,temp)) ';']);
            
            % Find gauge
            eval(['name1 = name' num2str(runs(gauge,temp)) ';'])
            for line = 1:16
                if str2num(name1(line,6:7)) == gauge
                    break
                end
            end
            
            % Find Delta offset
            if gauge < 17 & gauge == line
                row = 1;
            elseif gauge < 33 & gauge-16 == line
                row = 2;
            elseif gauge < 49 & gauge-32 == line
                row = 3;
            elseif gauge < 56 & gauge-48 == line
                row = 4;
            elseif gauge < 9 & gauge+8 == line
                row = 4;
            elseif gauge < 25 & gauge-8 == line
                row = 5;
            elseif gauge < 41 & gauge-24 == line
                row = 6;
            else
                row = 7;
            end
            
            Q_dot(:,temp) = qdot(:,line);
            T_wall(temp) = Tw(line)-Delta(row,line);
            T_total(temp) = opt.T01;
        end
        
        % Set up figure
        set(fig,'NumberTitle','off','Name',['Gauge ' num2str(gauge)])
        
        for i = 1:temps
            if ~isempty(find(points{gauge}==i))
                plot([1:144],Q_dot(:,i),'b');
                hold on
            end
        end
        
        new_points{gauge} = [];
        
        for i = 1:temps
            if ~isempty(find(points{gauge}==i))
                plot([1:144],Q_dot(:,i),'k');
                s  = input('Is this run viable? ','s');
                if strcmp(s,'y')
                    plot([1:144],Q_dot(:,i),'r');
                    new_points{gauge}(end+1) = i;
                else
                    plot([1:144],Q_dot(:,i),'b');
                end
            end
        end
        hold off
    end
end

points = new_points;
close(fig);

save Phase_Averaged_Points points