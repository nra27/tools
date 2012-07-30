function Casing_Snapshot(Data,data_type,build);
%
% Casing_Snapshot(Data,data_type,build)
%
% A function to create a casing animation
% from the output of Adiabatic_Wall_Compensator
% or Static_Pressure_Compensator

% Load Blade_Profiles
NGV = NGV_Profile;
HPB = HPB_Profile;

% Setup gauge locations
for j = 1:7
    gauge_x(:,j) = linspace(20,-79,8)'/100*24.35;
end
for j = 1:8
    gauge_y(j,:) = linspace(0,-100,7)/100*272*2*pi/36-272*2*pi/36/48*(j-1);
end

% Setup plot locations
for j = 1:49
    plot_x(:,j) = linspace(20,-79,8)'/100*24.35;
end
for j = 1:8
    plot_y(j,:) = linspace(0,-100,49)/100*275*2*pi/36-275*2*pi/36/48*(j-1);
end
    
% Delta NGV
D_NGV = 272*2*pi/36;
% Delta HPB
D_HPB = 272*2*pi/60*0.98;
% Delta HPB due to time
T_HPB = 6/144*272*2*pi/360*0.98;

% Add phase to the data
Mov = [Data; Data];


[time_points,data_points] = size(Data);

for i = 1:8
    for j = 1:data_points/8
        Plo(i,j,:) = Mov(:,i+(j-1)*8);
    end
end

% Setup data locations
for j = 1:data_points/8
    data_x(:,j) = linspace(20,-79,8)'/100*24.35;
end
for j = 1:8
    data_y(j,:) = linspace(0,-100,data_points/8)/100*272*2*pi/36-272*2*pi/36/48*(j-1);
end

% Loop through all time steps
if build == 1;
    skew1 = 20;
elseif build == 2;
    skew1 = 4;
else
    error('Unsuported build!');
end

for time = [52 82 112 142 172 202 232 262]-skew1
    % Plot the data
    figure
    set(gcf,'DoubleBuffer','on');
    if strcmp(data_type,'HT')
        %pcolor(data_y,data_x,Plo(:,:,time));
        %shading interp
        contourf(data_y,data_x,Plo(:,:,time),linspace(-0.5e5,3.0e5,14));
        caxis([-5e4 30e4])
    elseif strcmp(data_type,'Pres')
        %pcolor(data_y,data_x,Plo(:,:,time)*1e5);
        %shading interp
        contourf(data_y,data_x,Plo(:,:,time),linspace(2e5,5e5,14));
        caxis([2e5 5e5])
    elseif strcmp(data_type,'Tad')
        %pcolor(data_y,data_x,Plo(:,:,time));
        %shading interp
        contourf(data_y,data_x,Plo(:,:,time),linspace(280,420,14));
        caxis([280 400])
    elseif strcmp(data_type,'Nu')
        %pcolor(data_y,data_x,Plo(:,:,time));
        %shading interp
        contourf(data_y,data_x,Plo(:,:,time),linspace(1000,3000,10));
        caxis([1000 3000])
    elseif strcmp(data_type,'H');
        %pcolor(data_y,data_x,Plo(:,:,time))
        %shading interp
        contourf(data_y,data_x,Plo(:,:,time),linspace(1e3,6e3,11));
        caxis([1e3 6e3])
    else
        error('unknown call')
    end
    drawnow
    
    axis off
    axis equal
    a = gca;
    hold on
    
    if build == 1;
        der = 2;
    elseif build == 2;
        der = 0.4;
    else
        error('Unsuported build!');
    end
    
    % Plot HPBs
    plot(HPB(:,2)+der+D_HPB+(time-1)*T_HPB,HPB(:,1),'b')
    plot(HPB(:,2)+der+(time-1)*T_HPB,HPB(:,1),'b')
    plot(HPB(:,2)+der-D_HPB+(time-1)*T_HPB,HPB(:,1),'b')
    plot(HPB(:,2)+der-2*D_HPB+(time-1)*T_HPB,HPB(:,1),'b')
    plot(HPB(:,2)+der-3*D_HPB+(time-1)*T_HPB,HPB(:,1),'b')
    plot(HPB(:,2)+der-4*D_HPB+(time-1)*T_HPB,HPB(:,1),'b')
    plot(HPB(:,2)+der-5*D_HPB+(time-1)*T_HPB,HPB(:,1),'b')
    
    % Plot the gauge points
    %plot(gauge_y,gauge_x,'k+')
    
    % Set visual box
    set(a,'XLim',[-60 0]);
    set(a,'YLim',[-26.9216 19.8796]);
    drawnow
end

figure
axis off
H = colorbar('horz');
set(H,'position',[0.3 0.5 0.3869 0.0315])
axes(H)
if strcmp(data_type,'Pres')
    Xlabel('Pa')
    set(H,'xlim',[2e5 5e5])
    set(H,'xtick',[2 2.5 3 3.5 4 4.5 5]*1e5)
    set(H,'xticklabel',[2 2.5 3 3.5 4 4.5 5]*1e5)
    caxis([2e5 5e5])
    set(get(H,'children'),'xdata',[2e5 5e5])
    set(get(H,'children'),'CData',[1:63/13:64])
elseif strcmp(data_type,'HT')
    Xlabel('kW/m^2')
    set(H,'xlim',[-5e4 30e4])
    caxis([-5e4 30e4])
    set(get(H,'children'),'xdata',[-5e4 30e4])
    set(get(H,'children'),'CData',[1:63/13:64])
    set(H,'xtick',[0 10e4 20e4 30e4]);
    set(H,'xticklabel',[0 100 200 300]);
elseif strcmp(data_type,'H')
    Xlabel('W/m^2K')
    set(H,'xlim',[1e3 6e3])
    set(H,'xtick',[1e3 2e3 3e3 4e3 5e3 6e3])
    caxis([1e3 6e3])
    set(get(H,'children'),'xdata',[1e3 6e3])
    set(get(H,'children'),'CData',[1:63/10:64])
elseif strcmp(data_type,'Nu')
    Xlabel('')
    set(H,'xlim',[-5e4 30e4])
    caxis([1000 3000])
    set(get(H,'children'),'xdata',[1000 3000])
    set(get(H,'children'),'CData',[1:63/9:64])
elseif strcmp(data_type,'Tad')
    Xlabel('K')
    set(H,'xlim',[280 420])
    set(H,'xtick',[280 300 320 340 360 380 400 420])
    caxis([280 420])
    set(get(H,'children'),'xdata',[280 420])
    set(get(H,'children'),'CData',[1:63/13:64])
end
set(get(H,'Xlabel'),'fontsize',12,'fontname','times')


