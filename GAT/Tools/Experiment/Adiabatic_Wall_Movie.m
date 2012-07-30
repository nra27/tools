function M = Adiabatic_Wall_Movie(location,gauge);

points_flag = 1;

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
load Time_Mean_Points;
load HT_Run_Distribution;

% Check size of runs to establish loop-limits
[gauges,temps] = size(runs);

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
set(gauge,'NumberTitle','off','Name',['Gauge ' num2str(gauge)],'color',[1 1 1])
delta1 = 0;
set(gauge,'position',[160 425 800 380])
set(gauge,'DoubleBuffer','on');

for i = 1:144
    subplot(1,2,2)
    set(gca,'position',[0.556 0.11 0.4020 0.8150])
    for j = 1:temps
        plot([1:144]/144*100,Q_dot(:,j),'b');
        hold on
    end
    set(gca,'ylim',[-2e5 4e5],'fontsize',14)
    grid on
    a = xlabel('Blade Phase (%)');
    pos1 = get(a,'position');
    set(a,'fontsize',14)
    a = ylabel('Wall Heat-Transfer Rate (Wm^{-2})');
    set(a,'fontsize',14)
    plot([i/144*100 i/144*100],[-2e5 4e5],'r')
    hold off
    
    subplot(1,2,1)
    set(gca,'position',[0.08 0.11 0.4020 0.8150])
    coefs = Line_Fit(T_wall(points{gauge}),Q_dot(i,points{gauge}),-1);        
    T_ad(i,gauge) = -coefs(2)/coefs(1);
    t = [280:400];
    
    q = polyval(coefs,t);
    plot(t,q,'k')
    set(gca,'xlim',[280 400],'ylim',[-2e5 4e5],'fontsize',14)
    grid on
    a = xlabel('Wall Temperature (^oC)');
    pos = get(a,'position');
    pos(2) = pos(2)+1.2e4;
    set(a,'fontsize',14,'position',pos)
    a = ylabel('Wall Heat-Transfer Rate (Wm^{-2})');
    set(a,'fontsize',14)
    hold on
    plot([280 400],[0 0],'k')
    plot(T_wall(points{gauge}),Q_dot(i,points{gauge}),'b*')
    qo = polyval(coefs,T_ad(i,gauge));
    plot(T_ad(i,gauge),qo,'r*')
    hold off
    M(i) = getframe(gauge,[0 0 800 380]);
    pause(0.01)
end

subplot(1,2,2)
set(gca,'position',[0.556 0.11 0.4020 0.8150])
grid on
for j = 1:temps
    plot([1:144]/144*100,Q_dot(:,j),'b');
    hold on
end
set(gca,'ylim',[-2e5 4e5],'fontsize',14)
grid on
a = xlabel('Blade Phase (%)');
set(a,'fontsize',14)
a = ylabel('Wall Heat-Transfer Rate (Wm^{-2})');
set(a,'fontsize',14)

subplot(1,2,1)
set(gca,'position',[0.08 0.11 0.4020 0.8150])
grid on
plot([1:144]/144*100,T_ad(:,gauge),'k')
set(gca,'ylim',[280 400],'fontsize',14);
grid on
a = ylabel('Adiabatic Wall Temperature (^oC)');
set(a,'fontsize',14)
a = xlabel('Blade Phase (%)');
set(a,'fontsize',14)
M(i+1) = getframe(gauge,[0 0 800 380]);