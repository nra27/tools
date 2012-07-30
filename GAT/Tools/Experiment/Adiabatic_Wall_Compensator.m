function T_ad = Adiabatic_Wall_Compensator(location,points_flag);
%

% Check to see where we are
if strcmp(location,'osney')
    file_root = '\\Engs-cheddar\Data\D''ata 2\''Casing_HT_Build2\';
elseif strcmp(location,'home')
    file_root = 'D:\E''xperimental Data\''Casing_HT_Build2\';
else
    disp('Where am I?')
    return
end

% Phase averaged
% Caculate Adiabatic Wall Temperature
if points_flag == 1
    load Time_Mean_Points;
    new_points = points;
end
load Phase_Averaged_Points;
load HT_Run_Distribution;

% Check size of runs to establish loop-limits
[gauges,temps] = size(runs);

% Caculate Adiabatic Wall Temperature
% Start gauge loop
for gauge = 1:gauges
    if gauge == 14 % Don't bother with gauge 14
        continue
    end
    
    disp(['Gauge = ' num2str(gauge)]);
    
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
        
        Q_dot(temp) = mean(qdot(:,line));
        T_wall(temp) = Tw(line)-Delta(row,line);
        T_total(temp) = opt.T01;
    end
    
    % Set up figure
    figure(gauge)
    set(gauge,'NumberTitle','off','Name',['Gauge ' num2str(gauge)],'menubar','none')
    set(gauge,'position',[475 590 626 397])
    plot(T_wall,Q_dot,'b*');
    hold on
    plot(T_wall(points{gauge}),Q_dot(points{gauge}),'ro');
    
    if points_flag == 0
        new_points{gauge} = [];
        for i = 1:length(points{gauge})
            plot(T_wall(points{gauge}(i)),Q_dot(points{gauge}(i)),'go');
            s = input('Is this run acceptable? :','s');
            if strcmp(s,'y');
                new_points{gauge}(end+1) = points{gauge}(i);
                plot(T_wall(points{gauge}(i)),Q_dot(points{gauge}(i)),'ro');
            else
                plot(T_wall(points{gauge}(i)),Q_dot(points{gauge}(i)),'ro');
            end
        end
    end
    
    coefs = Line_Fit(T_wall(new_points{gauge}),Q_dot(new_points{gauge}),-1);
    
    plot(T_wall(new_points{gauge}),Q_dot(new_points{gauge}),'go');
    
    %keyboard
    
    t = [280:400];
    q = polyval(coefs,t);
    
    plot(t,q,'k');
    plot([280 400],[0 0],'k');
    plot(-coefs(2)/coefs(1),0,'r*')
    set(gca,'xlim',[280 400]);
    drawnow
    pause(1)
    
    T_ad(gauge) = -coefs(2)/coefs(1);
end

% Fill in for gauge 14!
if gauge > 14
    T_ad(14) = mean([T_ad(13) T_ad(15)]);
end
    
points = new_points;
save Time_Mean_Points points