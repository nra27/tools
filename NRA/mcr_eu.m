function [tc_eu,NI,t] = mcr_eu_conv(run)

data_root = '~/Documents/research/NEWAC/mcr/data/test_runs';
cal_root = '~/Documents/research/NEWAC/mcr/data/cal_files';

%% eu conversion

% load prt cal
load([cal_root '/tel_prt_cal_006_12_10_10_linear.mat'])

% load raw telemetry data
load([ data_root '/' run '/tel_data.mat'])

% Convert the prts to engineering units
prt_chans = [1 13 29 45];

for i = 1:4,
    prt(:,i) = polyval(P(:,i),tel_data(:,prt_chans(i)));
end

%%
clear P % all calibrations use the same symbols

% load the telemetry thermocouple calibration
load([cal_root '/tel_tc_cal_001_12_10_10_linear.mat'])

% Apply the calibration to each module in turn
for i = 2:12,
    tc(:,i) = polyval(P(:,3),tel_data(:,i))+prt(:,1);
end

for i = 14:28,
    tc(:,i) = polyval(P(:,3),tel_data(:,i))+prt(:,1);
end

for i = 30:44,
    tc(:,i) = polyval(P(:,3),tel_data(:,i))+prt(:,1);
end

for i = 46:60,
    tc(:,i) = polyval(P(:,3),tel_data(:,i))+prt(:,1);
end

tc_eu = tc;

clear P

%
% Load the NI_data
load([data_root '/' run '/NI_data'])

% correct the length of the NI_data
len = length(tel_data);
NI = NI_data(1:len,:);

% set up a timebase
t = [[1:length(NI_data(:,1))].*(1./NI_data(:,27))'/60]';

%%
load([data_root '/' run '/TC_data.mat'])

% %%
% figure(1)
% subplot(3,1,1) % tcs and inlet temp
% plot(t,QuickFILT(tc,50,100,0.5))
% grid on
% hold on
% title('Drum thermocouples')
% ylabel('Metal temperature [\circC]')
% xlabel('Time [min]')
% 
% %%
% subplot(3,1,2) %
% plot(t,NI_data(:,4))
% grid on
% title('Inlet temperature')
% ylabel('Inlet air temperature [\circC]')
% xlabel('Time [min]')
% %%
% subplot(3,1,3) % speed
% plot(t,NI_data(:,21))
% title('Drum speed')
% ylabel('Drum speed [rpm]')
% grid on 
% xlabel('Time [min]')
%  
%  %%
% figure(2)
% subplot(3,1,1) % tcs and inlet temp
% plot(t,QuickFILT(tc,50,100,0.005))
% grid on
% hold on
% axis([40 82 6 200])
% title('Metal thermocouples')
% ylabel('Metal temperature [\circC]')
% xlabel('Time [min]')
% 
% subplot(3,1,2) %
% plot(t,NI_data(:,1:4))
% grid on
% axis([40 82 6 200])
% title('Inlet & outlet air temperature')
% ylabel('Air temperature [\circC]')
% xlabel('Time [min]')
% 
% subplot(3,1,3) % speed
% plot(t,NI_data(:,21))
% grid on
% title('Drum speed')
% ylabel('Drum speed [rpm]')
% xlabel('Time [min]')
% axis([40 82 0 8000])
% 
% %%
% figure(3)
% 
% n(1) = 6.5e4;
% n(2) = 8e4;
% 
% %%
% av = [65707   
%        66466      
%        69466        
%        70328         
%        72638        
%        73155     
%        76362      
%        76776     
%        78741
%        79224];
%    
%  
% tel_av(1,:) = mean(tc(av(1):av(2),:));
% tel_av(2,:) = mean(tc(av(3):av(4),:));
% tel_av(3,:) = mean(tc(av(5):av(6),:));
% tel_av(4,:) = mean(tc(av(7):av(8),:));
% tel_av(5,:) = mean(tc(av(9):av(10),:));
% 
% rpm_av(1,:) = mean(NI_data(av(1):av(2),8));
% rpm_av(2,:) = mean(NI_data(av(3):av(4),8));
% rpm_av(3,:) = mean(NI_data(av(5):av(6),8));
% rpm_av(4,:) = mean(NI_data(av(7):av(8),8));
% rpm_av(5,:) = mean(NI_data(av(9):av(10),8));
% 
% in_av(1,:) = mean(TC_data(av(1):av(2),1));
% in_av(2,:) = mean(TC_data(av(3):av(4),1));
% in_av(3,:) = mean(TC_data(av(5):av(6),1));
% in_av(4,:) = mean(TC_data(av(7):av(8),1));
% in_av(5,:) = mean(TC_data(av(9):av(10),1));
% %%
% 
% subplot(3,1,1) % tcs and inlet temp
% plot(QuickFILT(tc,50,100,0.005))
% grid on
% hold on
% axis([n(1) n(2) 15 150])
% title('Drum thermocouples')
% ylabel('Metal temperature [\circC]')
% xlabel('Time [min]')
% 
% subplot(3,1,2) %
% plot(TC_data(:,1:4))
% grid on
% axis([n(1) n(2) 6 30])
% title('Inlet temperature')
% ylabel('Inlet air temperature [\circC]')
% xlabel('Time [min]')
% 
% subplot(3,1,3) % speed
% plot(NI_data(:,8))
% grid on
% title('Drum speed')
% ylabel('Drum speed [rpm]')
% xlabel('Time [min]')
% axis([n(1) n(2) 0 3500])

