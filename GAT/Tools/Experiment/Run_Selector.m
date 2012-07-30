function [Tad,HTC] = Run_Selector(location);
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
load Run_Distribution

% Check size of runs to establish loop-limits
[gauges,temps] = size(runs);

% Setup fitting space
points{1} = [1:10];
for a = 1:10;
    for b = [a+1:10];
        points{end+1} = [a b];
    end
end
for a = 1:10;
    for b = [a+1:10];
        for c = [b+1:10];
            points{end+1} = [a b c];
        end
    end
end
for a = 1:10;
    for b = [a+1:10];
        for c = [b+1:10];
            for d = [c+1:10];
                points{end+1} = [a b c d];
            end
        end
    end
end
for a = 1:10;
    for b = [a+1:10];
        for c = [b+1:10];
            for d = [c+1:10];
                for e = [d+1:10];
                    points{end+1} = [a b c d e];
                end
            end
        end
    end
end
for a = 1:10;
    for b = [a+1:10];
        for c = [b+1:10];
            for d = [c+1:10];
                for e = [d+1:10];
                    for f = [e+1:10];
                        points{end+1} = [a b c d e f];
                    end
                end
            end
        end
    end
end
for a = 1:10;
    for b = [a+1:10];
        for c = [b+1:10];
            for d = [c+1:10];
                for e = [d+1:10];
                    for f = [e+1:10];
                        for g = [f+1:10];
                            points{end+1} = [a b c d e f g];
                        end
                    end
                end
            end
        end
    end
end
for a = 1:10;
    for b = [a+1:10];
        for c = [b+1:10];
            for d = [c+1:10];
                for e = [d+1:10];
                    for f = [e+1:10];
                        for g = [f+1:10];
                            for h = [g+1:10];
                                points{end+1} = [a b c d e f g h];
                            end
                        end
                    end
                end
            end
        end
    end
end
for a = 1:10;
    for b = [a+1:10];
        for c = [b+1:10];
            for d = [c+1:10];
                for e = [d+1:10];
                    for f = [e+1:10];
                        for g = [f+1:10];
                            for h = [g+1:10];
                                for i = [h+1:10];
                                    points{end+1} = [a b c d e f g h i];
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

new_points{1} = [];
new_points{2} = [];
new_points{3} = [];
new_points{4} = [];

% Start gauge loop
for gauge = [1:56]
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
    % Setup plot windows
    position = [13 625 626 397;647 625 626 397;13 201 626 397;647 201 626 397];
    for fig = 1:4
        figure(fig)
        set(fig,'position',position(fig,:),'menubar','none','numbertitle','off','doublebuffer','on','resize','off');
        set(gca,'ylim',[300 450]);
        hold on
    end
    
    % Loop through fitting space
    for fit = 1:length(points)
        % Loop across run
        for i = 1:144
            % T as set variable
            coefs_t = polyfit(T_wall(points{fit}),Q_dot(i,points{fit}),1);
            % Q as set variable
            coefs_q = polyfit(Q_dot(i,points{fit}),T_wall(points{fit}),1);
            coefs_q = Swap_Coefs(coefs_q);
            % Orthogonal fit
            coefs_tq = Line_Fit(T_wall(points{fit}),Q_dot(i,points{fit}),-1);
            coefs_qt = Line_Fit(T_wall(points{fit}),Q_dot(i,points{fit}),1);
            
            % Adiabatic Wall Temperature
            Tad_t(i,fit) = -coefs_t(2)/coefs_t(1);
            Tad_q(i,fit) = -coefs_q(2)/coefs_q(1);
            Tad_tq(i,fit) = -coefs_tq(2)/coefs_tq(1);
            Tad_qt(i,fit) = -coefs_qt(2)/coefs_qt(1);
            
            % Heat Transfer Coeficient
            HTC_t(i,fit) = -coefs_t(2);
            HTC_q(i,fit) = -coefs_q(2);
            HTC_tq(i,fit) = -coefs_tq(2);
            HTC_qt(i,fit) = -coefs_qt(2);
        end
        
        % Decide if any of them are worthwhile
        if min(Tad_t(:,fit)) > 300 & max(Tad_t(:,fit)) < 430
            new_points{1}(end+1) = fit;
            figure(1)
            plot(Tad_t(:,fit));
        end
        if min(Tad_q(:,fit)) > 300 & max(Tad_q(:,fit)) < 430
            new_points{2}(end+1) = fit;
            figure(2)
            plot(Tad_q(:,fit));
        end
        if min(Tad_tq(:,fit)) > 300 & max(Tad_tq(:,fit)) < 430
            new_points{3}(end+1) = fit;
            figure(3)
            plot(Tad_tq(:,fit));
        end
        if min(Tad_qt(:,fit)) > 300 & max(Tad_qt(:,fit)) < 430
            new_points{4}(end+1) = fit;
            figure(4)
            plot(Tad_qt(:,fit));
        end
        drawnow
    end
    
    % Now average all possible fits    
    Tad(:,gauge) = mean([Tad_t(:,new_points{1}) Tad_q(:,new_points{2}) Tad_tq(:,new_points{3}) Tad_qt(:,new_points{4})],2);
    HTC(:,gauge) = mean([HTC_t(:,new_points{1}) HTC_q(:,new_points{2}) HTC_tq(:,new_points{3}) HTC_qt(:,new_points{4})],2);
    
    figure(5)
    set(5,'position',[404 275 626 397],'menubar','none','numbertitle','off','doublebuffer','on','resize','off');
    set(gca,'ylim',[300 450]);
    plot(Tad(:,gauge))
    drawnow
    pause(0.1)
    figure(1)
    delete(gca)
    figure(2)
    delete(gca)
    figure(3)
    delete(gca)
    figure(4)
    delete(gca)
    new_points{1} = [];
    new_points{2} = [];
    new_points{3} = [];
    new_points{4} = [];
end