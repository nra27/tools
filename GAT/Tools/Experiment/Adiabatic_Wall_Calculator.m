function [T_ad,Hwall,Qout,Twall,T01,opt_runs] = Adiabatic_Wall_Calculator(location,points_flag);
%

% Check to see where we are
if strcmp(location,'osney')
    file_root = '\\Engs-cheddar\Data\D''ata 2\''Casing_HT_Build2\';
elseif strcmp(location,'home')
    file_root = 'E:\E''xperimental Data\''Casing_HT_Build2\';
else
    disp('Where am I?')
    return
end

% Phase averaged
% Caculate Adiabatic Wall Temperature
load Time_Mean_Points;
load HT_Run_Distribution;
if points_flag == 1
    load Phase_Averaged_Points;
end

% Check size of runs to establish loop-limits
[gauges,temps] = size(runs);

% Start gauge loop
for gauge = 1:56
    if gauge == 14 % Don't bother with gauge 14
        continue
    end
    
    if points_flag == 0
        points{gauge} = [];
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
        opts(temp) = abs(1-opt.Re/2.7e6)+abs(1-opt.speed/423.3);
    end
    
    % Set up figure
    figure(gauge)
    set(gauge,'NumberTitle','off','Name',['Gauge ' num2str(gauge)])
    delta1 = 0;
    set(gauge,'position',[660+delta1*5 570-delta1*5 626 397])
    
    hold on
    for i = 1:temps
        plot([1:144]/144*100,Q_dot(:,i),'b');
    end
    
    fit = figure;
    set(fit,'NumberTitle','off','Name','Curve Fitting Window');
    set(fit,'position',[20 570 626 397]);
    set(fit,'DoubleBuffer','on');
    
    plot(T_wall,Q_dot(1,:),'*')
    set(gca,'xlim',[280 400],'ylim',[-2e5 4e5])
    hold on
    
    % check for points flag
    if points_flag == 0;
        % Test if the gauge is ok
        for i = 1:temps
            figure(gauge)
            plot([1:144]/144*100,Q_dot(:,i),'r');
        
            figure(fit)
            plot(T_wall(i),Q_dot(1,i),'ro');
        
            s = input('Is this run acceptable?  :','s');
            if strcmp(s,'y')
                points{gauge}(end+1) = i;
            end
        end
    end
        
    figure(fit)
    hold off
    
    for i = 1:144
        plot(T_wall,Q_dot(i,:),'*')
        set(gca,'xlim',[280 400],'ylim',[-2e5 4e5])
        hold on
        
        coefs = Line_Fit(T_wall(points{gauge}),Q_dot(i,points{gauge}),-1);        
        T_ad(i,gauge) = -coefs(2)/coefs(1);
        Hwall(i,gauge) = coefs(1);
        t = [280:400];
        
        q = polyval(coefs,t);
        plot(t,q,'k')
        plot([280 400],[0 0],'k')
        plot(T_wall(points{gauge}),Q_dot(i,points{gauge}),'ro')
        qo = polyval(coefs,T_ad(i,gauge));
        plot(T_ad(i,gauge),qo,'r*')
        hold off
        pause(0.05)
    end
    close(fit)
    
    for i = 1:10
        Qout(:,gauge,i) = Q_dot(:,i);
        Twall(i,gauge) = T_wall(i);
        T01(i,gauge) = T_total(i);
    end
    
    [y,i] = min(opts(points{gauge}));
    opt_runs(gauge,:) = [y,points{gauge}(i)];
    
    figure(gauge)
    hold off
    plot(T_ad(:,gauge),'k')
    pause(1)
end

% Fill in for gauge 14!
if gauge > 15
    T_ad(:,14) = 0.5*(T_ad(:,13)+T_ad(:,15));
    Hwall(:,14) = 0.5*(Hwall(:,13)+Hwall(:,15));
    Qout(:,14,:) = 0.5*(Qout(:,13,:)+Qout(:,15,:));
end

if points_flag == 0
    save Phase_Averaged_Points.mat points
end